import { appendFileSync, existsSync, mkdirSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

type Route = {
  id: string;
  triggers?: string[];
  agent: string;
  kb?: string[];
  category?: string;
};

type RoutingConfig = {
  default_agent?: string;
  routes?: Route[];
};

type GraphNode = {
  id: string;
  label?: string;
  norm_label?: string;
  source_file?: string;
  community?: number;
};

type GraphEdge = {
  source: string;
  target: string;
  relation?: string;
};

type GraphJson = {
  nodes?: GraphNode[];
  edges?: GraphEdge[];
};

type AgentIndexEntry = {
  id: string;
  agentPath: string;
  category?: string;
  triggers: string[];
  kb: string[];
  graphTerms: string[];
  graphCommunities: number[];
};

type Candidate = {
  entry: AgentIndexEntry;
  score: number;
  reasons: string[];
};

type HardGateResult = {
  fallbackRequired: boolean;
  reasons: string[];
};

const SCRIPT_PATH = fileURLToPath(import.meta.url);
const CONFIG_ROOT = dirname(dirname(SCRIPT_PATH));
const WORKSPACE_ROOT = process.cwd();
const ROUTING_PATH = join(CONFIG_ROOT, "config", "routing.json");
const GRAPH_PATH = join(WORKSPACE_ROOT, "graphify-out", "graph.json");

function normalize(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function tokens(text: string): string[] {
  const normalized = normalize(text);
  if (!normalized) return [];
  return normalized.split(" ").filter((t) => t.length > 1);
}

function unique<T>(values: T[]): T[] {
  return [...new Set(values)];
}

function stripConfigPrefix(path: string): string {
  return path
    .replace(/^~\/\.config\/opencode\//, "")
    .replace(/^\/home\/ubuntu\/\.config\/opencode\//, "")
    .replace(/^\.\//, "")
    .replace(/^\//, "");
}

function readJson<T>(path: string): T {
  return JSON.parse(readFileSync(path, "utf8")) as T;
}

function loadRouting(): RoutingConfig {
  return readJson<RoutingConfig>(ROUTING_PATH);
}

function loadGraph(): GraphJson | null {
  if (!existsSync(GRAPH_PATH)) return null;
  return readJson<GraphJson>(GRAPH_PATH);
}

function buildGraphIndex(graph: GraphJson | null): Map<string, { terms: Set<string>; communities: Set<number> }> {
  const result = new Map<string, { terms: Set<string>; communities: Set<number> }>();
  if (!graph?.nodes?.length) return result;

  const nodeById = new Map<string, GraphNode>();
  const outgoing = new Map<string, Set<string>>();
  const incoming = new Map<string, Set<string>>();

  for (const node of graph.nodes) {
    if (!node.id) continue;
    nodeById.set(node.id, node);
  }

  for (const edge of graph.edges ?? []) {
    if (!edge?.source || !edge?.target) continue;
    if (!outgoing.has(edge.source)) outgoing.set(edge.source, new Set());
    if (!incoming.has(edge.target)) incoming.set(edge.target, new Set());
    outgoing.get(edge.source)!.add(edge.target);
    incoming.get(edge.target)!.add(edge.source);
  }

  const sourceFiles = unique(
    graph.nodes
      .map((n) => n.source_file)
      .filter((file): file is string => Boolean(file))
  );

  for (const sourceFile of sourceFiles) {
    const nodesForFile = graph.nodes.filter((n) => n.source_file === sourceFile);
    if (!nodesForFile.length) continue;

    const terms = new Set<string>();
    const communities = new Set<number>();

    for (const node of nodesForFile) {
      if (typeof node.community === "number") communities.add(node.community);
      for (const label of [node.label, node.norm_label]) {
        if (!label) continue;
        const normalized = normalize(label);
        if (normalized && normalized.length > 2) terms.add(normalized);
      }
      const neighbors = [
        ...(outgoing.get(node.id) ?? []),
        ...(incoming.get(node.id) ?? []),
      ];
      for (const neighborId of neighbors) {
        const neighbor = nodeById.get(neighborId);
        if (!neighbor) continue;
        if (typeof neighbor.community === "number") communities.add(neighbor.community);
        for (const label of [neighbor.label, neighbor.norm_label]) {
          if (!label) continue;
          const normalized = normalize(label);
          if (!normalized) continue;
          if (normalized.length <= 2) continue;
          if (/^(description|mode|permission|content|body|frontmatter)$/.test(normalized)) continue;
          terms.add(normalized);
        }
      }
    }

    result.set(sourceFile, {
      terms,
      communities,
    });
  }

  return result;
}

function buildIndex(routing: RoutingConfig, graph: GraphJson | null): AgentIndexEntry[] {
  const graphIndex = buildGraphIndex(graph);
  const routes = routing.routes ?? [];
  const routeByAgentPath = new Map<string, Route>();

  for (const route of routes) {
    routeByAgentPath.set(stripConfigPrefix(route.agent), route);
  }

  const graphAgentPaths = graph
    ? unique(
        graph.nodes
          .map((node) => node.source_file)
          .filter((sourceFile): sourceFile is string => Boolean(sourceFile))
          .filter((sourceFile) => /^agents\/.*\.agent\.md$/.test(sourceFile))
      )
    : [];

  const candidatePaths = unique([
    ...routes.map((route) => stripConfigPrefix(route.agent)),
    ...graphAgentPaths,
  ]).filter((agentPath) => {
    const base = agentPath.split("/").pop() ?? agentPath;
    return ![
      "DEFAULT.AGENT.agent.md",
      "dev.agent-router.agent.md",
      "graph-router.agent.md",
    ].includes(base);
  });

  return candidatePaths.map((agentPath) => {
    const route = routeByAgentPath.get(agentPath);
    const graphData = graphIndex.get(agentPath);
    const base = agentPath.split("/").pop() ?? agentPath;
    const baseTokens = tokens(base.replace(/\.agent\.md$/, ""));

    return {
      id: route?.id ?? base.replace(/\.agent\.md$/, ""),
      agentPath,
      category: route?.category ?? (baseTokens[0] ?? undefined),
      triggers: unique([
        ...((route?.triggers ?? []).map(normalize).filter(Boolean)),
        ...baseTokens,
      ]),
      kb: route?.kb ?? [],
      graphTerms: graphData ? unique([...graphData.terms]) : [],
      graphCommunities: graphData ? [...graphData.communities] : [],
    };
  });
}

function scoreCandidate(entry: AgentIndexEntry, query: string, queryTokens: Set<string>): Candidate {
  const reasons: string[] = [];
  let score = 0;
  const genericTriggers = new Set(["task", "route", "screen", "component", "model"]);

  const intentBoosts: Array<{ when: string[]; match: RegExp; bonus: number; reason: string }> = [
    {
      when: ["review", "judge", "fact check", "diff review", "plan review"],
      match: /(review|judge|fact check|diff review|plan review)/,
      bonus: 18,
      reason: "intent:review",
    },
    {
      when: ["clean", "refactor", "simplify", "modernize"],
      match: /(clean|refactor|simplify|modernize)/,
      bonus: 16,
      reason: "intent:cleanup",
    },
    {
      when: ["document", "docs", "readme", "doc"],
      match: /(document|docs|readme|doc)/,
      bonus: 16,
      reason: "intent:docs",
    },
    {
      when: ["architecture", "system design", "design", "plan"],
      match: /(architecture|system design|design|plan)/,
      bonus: 12,
      reason: "intent:design",
    },
  ];

  for (const boost of intentBoosts) {
    if (!boost.match.test(query)) continue;
    if (entry.graphTerms.some((term) => boost.when.some((phrase) => term.includes(phrase)))) {
      score += boost.bonus;
      reasons.push(boost.reason);
    }
  }

  for (const trigger of entry.triggers) {
    if (!trigger) continue;
    if (query.includes(trigger)) {
      const bonus = genericTriggers.has(trigger) ? 6 : 35;
      score += bonus;
      reasons.push(`trigger:${trigger}`);
      continue;
    }

    const triggerTokens = trigger.split(" ").filter(Boolean);
    if (triggerTokens.length > 1 && triggerTokens.every((t) => queryTokens.has(t))) {
      score += 20;
      reasons.push(`trigger-all:${trigger}`);
      continue;
    }

    const overlap = triggerTokens.filter((t) => queryTokens.has(t)).length;
    if (overlap > 0) {
      score += Math.min(10, overlap * 2);
      reasons.push(`trigger-overlap:${trigger}`);
    }
  }

  const categoryHints: Record<string, string[]> = {
    frontend: ["react", "frontend", "tsx", "component", "screen", "ui", "route", "router"],
    backend: ["supabase", "auth", "rls", "policy", "edge function", "postgres"],
    "data-engineering": ["dbt", "spark", "pyspark", "sql", "airflow", "dag", "pipeline", "lakeflow", "dlt", "streaming"],
    architect: ["architecture", "system design", "schema", "star schema", "lakehouse", "medallion", "bounded context"],
    qa: ["review", "judge", "ranking", "rule", "validation", "edge case"],
  };

  const category = entry.category ?? "";
  for (const hint of categoryHints[category] ?? []) {
    if (query.includes(hint)) {
      score += 8;
      reasons.push(`category-hint:${hint}`);
    }
  }

  let graphOverlap = 0;
  for (const term of entry.graphTerms) {
    if (!term) continue;
    if (query.includes(term)) {
      graphOverlap += 2;
      reasons.push(`graph-term:${term}`);
      continue;
    }
    const termTokens = tokens(term);
    const overlap = termTokens.filter((t) => queryTokens.has(t)).length;
    if (overlap > 0) {
      graphOverlap += Math.min(6, overlap);
      reasons.push(`graph-overlap:${term}`);
    }
  }
  score += Math.min(20, graphOverlap);

  if (query.includes("secret") || query.includes("auth") || query.includes("rls") || query.includes("row level security") || query.includes("pii")) {
    const securityPath = entry.agentPath.toLowerCase();
    const securityTerms = entry.graphTerms.join(" ").toLowerCase();
    if (securityPath.includes("security-guardian") || securityPath.includes("security") || securityTerms.includes("security") || securityTerms.includes("secret") || securityTerms.includes("auth") || securityTerms.includes("permission")) {
      score += 60;
      reasons.push("security-fit");
    }
  }

  const pathTokens = tokens(entry.agentPath);
  const pathOverlap = pathTokens.filter((t) => queryTokens.has(t)).length;
  if (pathOverlap > 0) {
    score += Math.min(8, pathOverlap * 2);
    reasons.push(`path-overlap:${entry.agentPath}`);
  }

  return {
    entry,
    score,
    reasons: unique(reasons),
  };
}

function detectHardGates(query: string): HardGateResult {
  const reasons: string[] = [];
  const normalized = normalize(query);
  const raw = query.trim();

  if (/^\/[a-z]+:[a-z-]+/i.test(raw)) {
    reasons.push("hard-gate:explicit-command");
  }

  const sensitivePatterns = [
    /\bauth(?:entication|orization)?\b/,
    /\brls\b/,
    /row level security/,
    /\bsecret(?:s)?\b/,
    /\bpii\b/,
    /\bpassword(?:s)?\b/,
    /\bcredential(?:s)?\b/,
    /api key/,
  ];

  for (const pattern of sensitivePatterns) {
    if (pattern.test(normalized)) {
      reasons.push(`hard-gate:sensitive:${pattern.source}`);
    }
  }

  return {
    fallbackRequired: reasons.length > 0,
    reasons,
  };
}

function choose(query: string) {
  const routing = loadRouting();
  const graph = loadGraph();
  const index = buildIndex(routing, graph);
  const normalizedQuery = normalize(query);
  const queryTokens = new Set(tokens(query));
  const hardGate = detectHardGates(query);

  const candidates = index.map((entry) => scoreCandidate(entry, normalizedQuery, queryTokens));
  candidates.sort((a, b) => b.score - a.score || a.entry.id.localeCompare(b.entry.id));

  const top = candidates[0] ?? null;
  const second = candidates[1] ?? null;

  const topHasStrongSignal =
    top?.reasons.some((reason) => {
      if (reason.startsWith("intent:")) return true;
      if (!reason.startsWith("trigger:")) return false;
      const trigger = reason.slice("trigger:".length);
      return !new Set(["task", "route", "screen", "component", "model"]).has(trigger);
    }) ?? false;

  const fallbackRequired =
    hardGate.fallbackRequired ||
    !top ||
    top.score < 15 ||
    (second ? top.score - second.score < 6 : false) ||
    (!topHasStrongSignal && top.score < 60);
  const confidence = top
    ? Math.max(
        0.1,
        Math.min(0.99, 0.35 + Math.min(top.score, 100) / 140 + Math.min((top.score - (second?.score ?? 0)), 25) / 100)
      )
    : 0.1;

  const selected = top ?? candidates[0] ?? null;

  return {
    query,
    best_agent: selected?.entry.id ?? routing.default_agent ?? null,
    best_agent_path: selected?.entry.agentPath ?? routing.default_agent ?? null,
    confidence: Number(confidence.toFixed(2)),
    fallback_required: fallbackRequired,
    alternates: candidates.slice(1, 6).map((candidate) => ({
      agent: candidate.entry.id,
      agent_path: candidate.entry.agentPath,
      score: candidate.score,
      reasons: candidate.reasons.slice(0, 5),
    })),
    reasons: selected?.reasons.slice(0, 8) ?? [],
    hard_gate_reasons: hardGate.reasons,
    minimal_context: selected ? [selected.entry.agentPath, ...(selected.entry.kb.slice(0, 1))] : [],
    index_summary: {
      routes: index.length,
      graph_enabled: Boolean(graph),
      graph_terms_for_best: selected?.entry.graphTerms.length ?? 0,
    },
    selected_via: hardGate.fallbackRequired
      ? "hard-gate+graphify+routing"
      : graph
        ? "graphify+routing"
        : "routing-only",
  };
}

function recordFeedback(payload: ReturnType<typeof choose>) {
  if (process.env.ROUTING_FEEDBACK === "0") return;

  const feedbackPath = join(CONFIG_ROOT, "state", "routing-feedback.jsonl");
  mkdirSync(dirname(feedbackPath), { recursive: true });

  const modelHint = process.env.OPENCODE_MODEL ?? process.env.MODEL ?? null;
  const record = {
    timestamp: new Date().toISOString(),
    query: payload.query,
    selected_agent: payload.best_agent,
    selected_agent_path: payload.best_agent_path,
    confidence: payload.confidence,
    fallback_required: payload.fallback_required,
    selected_via: payload.selected_via,
    model: modelHint,
    top_alternates: payload.alternates.slice(0, 3),
    reasons: payload.reasons,
  };

  appendFileSync(feedbackPath, `${JSON.stringify(record)}\n`, "utf8");
}

function main() {
  const args = process.argv.slice(2).filter((arg) => arg !== "--json");
  const query = args.join(" ").trim();

  if (!query) {
    console.error("Usage: node --experimental-strip-types ~/.config/opencode/tools/select-agent.mts <query>");
    process.exit(1);
  }

  const result = choose(query);
  recordFeedback(result);
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
}

main();
