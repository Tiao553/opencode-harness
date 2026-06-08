import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

type CorpusCase = {
  id: string;
  query: string;
  expected_best_agent: string | null;
  expected_fallback: boolean;
  note?: string;
};

type SelectorResult = {
  best_agent: string | null;
  best_agent_path?: string | null;
  confidence: number;
  fallback_required: boolean;
  selected_via?: string;
  reasons?: string[];
  hard_gate_reasons?: string[];
};

type CaseReport = CorpusCase & {
  actual_best_agent: string | null;
  actual_fallback: boolean;
  confidence: number;
  selected_via?: string;
  pass: boolean;
  failures: string[];
};

const SCRIPT_PATH = fileURLToPath(import.meta.url);
const CONFIG_ROOT = dirname(dirname(SCRIPT_PATH));
const CORPUS_PATH = join(CONFIG_ROOT, "tools", "selector-parity-corpus.json");
const REPORT_PATH = join(CONFIG_ROOT, "state", "selector-parity-report.json");
const SELECTOR_PATH = join(CONFIG_ROOT, "tools", "select-agent.mts");

function loadCorpus(): CorpusCase[] {
  return JSON.parse(readFileSync(CORPUS_PATH, "utf8")) as CorpusCase[];
}

function runSelector(query: string): SelectorResult {
  const result = spawnSync(
    process.execPath,
    ["--experimental-strip-types", SELECTOR_PATH, query],
    { cwd: process.cwd(), encoding: "utf8" }
  );

  if (result.status !== 0) {
    throw new Error(
      `selector failed for query: ${query}\n${result.stdout ?? ""}${result.stderr ?? ""}`
    );
  }

  return JSON.parse(result.stdout) as SelectorResult;
}

function evaluateCase(testCase: CorpusCase): CaseReport {
  const actual = runSelector(testCase.query);
  const failures: string[] = [];

  if (testCase.expected_best_agent !== null && actual.best_agent !== testCase.expected_best_agent) {
    failures.push(`best_agent expected ${testCase.expected_best_agent} got ${actual.best_agent}`);
  }

  if (actual.fallback_required !== testCase.expected_fallback) {
    failures.push(
      `fallback expected ${testCase.expected_fallback} got ${actual.fallback_required}`
    );
  }

  return {
    ...testCase,
    actual_best_agent: actual.best_agent,
    actual_fallback: actual.fallback_required,
    confidence: actual.confidence,
    selected_via: actual.selected_via,
    pass: failures.length === 0,
    failures,
  };
}

function main() {
  const corpus = loadCorpus();
  const reports = corpus.map(evaluateCase);
  const passed = reports.filter((report) => report.pass).length;
  const failed = reports.length - passed;

  const summary = {
    total: reports.length,
    passed,
    failed,
    accuracy: Number((passed / reports.length).toFixed(2)),
  };

  writeFileSync(REPORT_PATH, `${JSON.stringify({ summary, reports }, null, 2)}\n`, "utf8");

  console.log(JSON.stringify(summary, null, 2));

  if (failed > 0) {
    for (const report of reports.filter((item) => !item.pass)) {
      console.error(`FAIL ${report.id}: ${report.failures.join("; ")}`);
    }
    process.exit(1);
  }
}

main();
