import type { Plugin } from "@opencode-ai/plugin"

type Action = "allow" | "ask" | "deny"
type RuleMap = Record<string, Action>
type PermissionValue = Action | RuleMap
type PermissionConfig = {
  read?: PermissionValue
  edit?: PermissionValue
  glob?: PermissionValue
  grep?: PermissionValue
  list?: PermissionValue
  bash?: PermissionValue
  task?: PermissionValue
  skill?: PermissionValue
  websearch?: Action
  webfetch?: Action
  question?: Action
}

type AgentConfig = {
  hidden?: boolean
  permission?: PermissionConfig
}

const ORCHESTRATORS = new Map<string, AgentConfig>([
  [
    "DEFAULT",
    {
      permission: orchestratorPermission(["graph-router"]),
    },
  ],
  [
    "graph-router",
    {
      hidden: true,
      permission: orchestratorPermission([]),
    },
  ],
  [
    "dev.agent-router",
    {
      hidden: true,
      permission: orchestratorPermission(["graph-router"]),
    },
  ],
  [
    "architect.the-planner",
    {
      permission: orchestratorPermission([
        "explore",
        "dev.codebase-explorer",
        "dev.meeting-analyst",
        "dashboard-layout-specialist",
        "architect.data-platform-engineer",
        "architect.genai-architect",
        "architect.lakehouse-architect",
        "architect.medallion-architect",
        "product.system-design-agent",
        "product.external-integration-agent",
        "product.ux-design-system-agent",
      ]),
    },
  ],
])

const EXCEPTIONS = new Map<string, AgentConfig>([
  [
    "altitude-intent",
    {
      permission: specsWriterPermission([
        ".specs/changes/**/00-intent.md",
        ".specs/changes/**/state.md",
        ".specs/memory/active-state.md",
      ]),
    },
  ],
  [
    "altitude-structure",
    {
      permission: specsWriterPermission([
        ".specs/changes/**/01-structure.md",
        ".specs/changes/**/state.md",
        ".specs/memory/**",
      ], { bash: true, web: true }),
    },
  ],
  [
    "altitude-plan",
    {
      permission: specsWriterPermission([
        ".specs/changes/**/02-decomposition.md",
        ".specs/changes/**/tasks/**",
        ".specs/changes/**/state.md",
        ".specs/memory/active-state.md",
      ], { web: true }),
    },
  ],
  [
    "altitude-execution",
    {
      permission: altitudeExecutionPermission(),
    },
  ],
  [
    "altitude-validation",
    {
      permission: specsWriterPermission([
        ".specs/changes/**/04-validation.md",
        ".specs/changes/**/reviews/**",
        ".specs/changes/**/state.md",
        ".specs/changes/**/tasks/**",
      ], { bash: true, web: true, task: true }),
    },
  ],
  [
    "altitude-report",
    {
      permission: specsWriterPermission([
        ".specs/changes/**/05-executive-report.md",
        ".specs/changes/**/state.md",
        ".specs/reports/**",
      ]),
    },
  ],
  [
    "altitude-memory",
    {
      permission: specsWriterPermission([
        ".specs/memory/**",
        ".specs/archive/**",
        ".specs/changes/**/state.md",
        ".specs/changes/**/06-ship-note.md",
      ], { bash: true }),
    },
  ],
  [
    "workflow.brainstorm-agent",
    {
      permission: artifactWriterPermission([
        "explore",
        "dev.codebase-explorer",
        "dev.meeting-analyst",
        "architect.the-planner",
        "product.system-design-agent",
        "product.ux-design-system-agent",
        "dashboard-layout-specialist",
      ]),
    },
  ],
  [
    "workflow.define-agent",
    {
      permission: artifactWriterPermission([
        "explore",
        "dev.codebase-explorer",
        "dev.meeting-analyst",
        "architect.the-planner",
        "product.system-design-agent",
        "product.external-integration-agent",
      ]),
    },
  ],
  [
    "workflow.design-agent",
    {
      permission: artifactWriterPermission([
        "explore",
        "dev.codebase-explorer",
        "architect.data-platform-engineer",
        "architect.genai-architect",
        "architect.lakehouse-architect",
        "architect.medallion-architect",
        "architect.pipeline-architect",
        "architect.schema-designer",
        "product.system-design-agent",
        "product.external-integration-agent",
        "product.ux-design-system-agent",
        "dashboard-layout-specialist",
      ]),
    },
  ],
  [
    "workflow.build-agent",
    {
      permission: buildOrchestratorPermission(),
    },
  ],
  [
    "workflow.validate-agent",
    {
      permission: shellExceptionPermission([
        "explore",
        "dev.codebase-explorer",
        "dev.faithfulness-guard",
        "dev.judge-agent",
        "dev.security-guardian",
        "product.rules-qa-agent",
        "python.code-reviewer",
        "test.test-generator",
        "test.data-quality-analyst",
        "test.data-contracts-engineer",
        "data-engineering.sql-optimizer",
      ]),
    },
  ],
  [
    "workflow.iterate-agent",
    {
      permission: artifactWriterPermission([
        "explore",
        "dev.codebase-explorer",
        "workflow.define-agent",
        "workflow.design-agent",
        "workflow.build-agent",
      ]),
    },
  ],
  [
    "workflow.ship-agent",
    {
      permission: shellExceptionPermission([]),
    },
  ],
  [
    "dev.security-guardian",
    {
      permission: {
        ...baseReadPermission(),
        edit: "deny",
        bash: "allow",
        task: "deny",
        skill: "allow",
        websearch: "deny",
        webfetch: "deny",
        question: "allow",
      },
    },
  ],
])

const AUDITORS = new Set([
  "dev.faithfulness-guard",
  "dev.judge-agent",
  "product.rules-qa-agent",
])

const REVIEW_ONLY = new Set([
  "python.code-reviewer",
  "data-engineering.sql-optimizer",
])

const READ_ONLY = new Map<string, AgentConfig>([
  ["dev.codebase-explorer", { permission: readOnlyPermission() }],
  ["dev.meeting-analyst", { permission: readOnlyPermission() }],
  ["product.system-design-agent", { permission: readOnlyPermission() }],
  ["product.ux-design-system-agent", { permission: readOnlyPermission() }],
  [
    "architect.data-platform-engineer",
    { permission: readOnlyPermission({ web: true }) },
  ],
  ["architect.genai-architect", { permission: readOnlyPermission({ web: true }) }],
  [
    "architect.lakehouse-architect",
    { permission: readOnlyPermission({ web: true }) },
  ],
  ["architect.medallion-architect", { permission: readOnlyPermission() }],
  ["cloud.aws-data-architect", { permission: readOnlyPermission({ web: true }) }],
  ["cloud.gcp-data-architect", { permission: readOnlyPermission({ web: true }) }],
  ["platform.fabric-architect", { permission: readOnlyPermission({ web: true }) }],
  ["data-engineering.spark-specialist", { permission: readOnlyPermission() }],
  [
    "data-engineering.spark-performance-analyzer",
    { permission: readOnlyPermission() },
  ],
  ["data-engineering.spark-troubleshooter", { permission: readOnlyPermission() }],
  ["data-engineering.lakeflow-architect", { permission: readOnlyPermission() }],
  ["data-engineering.lakeflow-expert", { permission: readOnlyPermission() }],
  ["data-engineering.lakeflow-specialist", { permission: readOnlyPermission() }],
  [
    "data-engineering.spark-streaming-architect",
    { permission: readOnlyPermission() },
  ],
])

const BUILDER_NO_BASH = new Set([
  "dashboard-layout-specialist",
  "test.data-contracts-engineer",
  "python.code-documenter",
  "python.llm-specialist",
  "python.ai-prompt-specialist",
  "platform.fabric-ai-specialist",
  "dev.prompt-crafter",
  "architect.schema-designer",
  "architect.pipeline-architect",
  "cloud.aws-lambda-architect",
  "cloud.ai-prompt-specialist-gcp",
  "architect.kb-architect",
])

const BUILDER_WITH_WEB = new Set([
  "platform.fabric-pipeline-developer",
  "platform.fabric-security-specialist",
  "product.external-integration-agent",
  "platform.fabric-ai-specialist",
  "platform.fabric-logging-specialist",
  "platform.fabric-cicd-specialist",
  "cloud.ai-data-engineer-cloud",
  "cloud.supabase-specialist",
  "cloud.ci-cd-specialist",
  "cloud.ai-data-engineer-gcp",
  "cloud.aws-deployer",
  "cloud.ai-prompt-specialist-gcp",
])

const LOCAL_AGENT_NAMES = new Set([
  ...ORCHESTRATORS.keys(),
  ...EXCEPTIONS.keys(),
  ...AUDITORS,
  ...REVIEW_ONLY,
  ...READ_ONLY.keys(),
  "dashboard-layout-specialist",
  "test.test-generator",
  "test.data-quality-analyst",
  "test.data-contracts-engineer",
  "product.supabase-backend-agent",
  "python.code-documenter",
  "python.python-developer",
  "python.code-cleaner",
  "platform.fabric-pipeline-developer",
  "platform.fabric-security-specialist",
  "product.frontend-react-agent",
  "product.external-integration-agent",
  "python.llm-specialist",
  "python.ai-prompt-specialist",
  "dev.shell-script-specialist",
  "platform.fabric-ai-specialist",
  "data-engineering.streaming-engineer",
  "platform.fabric-logging-specialist",
  "platform.fabric-cicd-specialist",
  "dev.prompt-crafter",
  "data-engineering.airflow-specialist",
  "data-engineering.qdrant-specialist",
  "data-engineering.spark-engineer",
  "data-engineering.ai-data-engineer",
  "data-engineering.lakeflow-pipeline-builder",
  "data-engineering.dbt-specialist",
  "cloud.ai-data-engineer-cloud",
  "cloud.container-specialist",
  "cloud.supabase-specialist",
  "architect.schema-designer",
  "architect.pipeline-architect",
  "cloud.aws-lambda-architect",
  "cloud.lambda-builder",
  "cloud.ai-prompt-specialist-gcp",
  "architect.kb-architect",
  "cloud.ci-cd-specialist",
  "cloud.ai-data-engineer-gcp",
  "cloud.aws-deployer",
])

function baseReadPermission(): PermissionConfig {
  return {
    read: "allow",
    glob: "allow",
    grep: "allow",
    list: "allow",
  }
}

function taskAllowlist(names: string[]): RuleMap {
  return names.reduce<RuleMap>(
    (rules, name) => {
      rules[name] = "allow"
      return rules
    },
    { "*": "deny" },
  )
}

function editAllowlist(paths: string[]): RuleMap {
  return paths.reduce<RuleMap>(
    (rules, path) => {
      rules[path] = "allow"
      return rules
    },
    { "*": "deny" },
  )
}

function readOnlyPermission(options?: { web?: boolean }): PermissionConfig {
  return {
    ...baseReadPermission(),
    edit: "deny",
    bash: "deny",
    task: "deny",
    skill: "allow",
    websearch: options?.web ? "allow" : "deny",
    webfetch: options?.web ? "allow" : "deny",
    question: "allow",
  }
}

function specsWriterPermission(paths: string[], options?: { bash?: boolean; web?: boolean; task?: boolean }): PermissionConfig {
  return {
    ...baseReadPermission(),
    edit: editAllowlist(paths),
    bash: options?.bash ? "allow" : "deny",
    task: options?.task ? "ask" : "deny",
    skill: "allow",
    websearch: options?.web ? "ask" : "deny",
    webfetch: options?.web ? "ask" : "deny",
    question: "allow",
  }
}

function builderPermission(options?: { bash?: boolean; web?: boolean }): PermissionConfig {
  return {
    ...baseReadPermission(),
    edit: "allow",
    bash: options?.bash ? "allow" : "deny",
    task: "deny",
    skill: "allow",
    websearch: options?.web ? "allow" : "deny",
    webfetch: options?.web ? "allow" : "deny",
    question: "allow",
  }
}

function altitudeExecutionPermission(): PermissionConfig {
  return {
    ...baseReadPermission(),
    edit: "allow",
    bash: "allow",
    task: "allow",
    skill: "allow",
    websearch: "allow",
    webfetch: "allow",
    question: "allow",
  }
}

function orchestratorPermission(allowedTasks: string[]): PermissionConfig {
  return {
    ...baseReadPermission(),
    edit: "deny",
    bash: "deny",
    task: taskAllowlist(allowedTasks),
    skill: "allow",
    websearch: "deny",
    webfetch: "deny",
    question: "allow",
  }
}

function artifactWriterPermission(allowedTasks: string[]): PermissionConfig {
  return {
    ...baseReadPermission(),
    edit: "allow",
    bash: "deny",
    task: taskAllowlist(allowedTasks),
    skill: "allow",
    websearch: "deny",
    webfetch: "deny",
    question: "allow",
  }
}

function shellExceptionPermission(allowedTasks: string[]): PermissionConfig {
  return {
    ...baseReadPermission(),
    edit: "allow",
    bash: "allow",
    task: taskAllowlist(allowedTasks),
    skill: "allow",
    websearch: "deny",
    webfetch: "deny",
    question: "allow",
  }
}

function buildOrchestratorPermission(): PermissionConfig {
  return {
    ...baseReadPermission(),
    edit: "allow",
    bash: "allow",
    task: taskAllowlist([
      "explore",
      "dev.codebase-explorer",
      "dev.security-guardian",
      "dev.shell-script-specialist",
      "dashboard-layout-specialist",
      "product.external-integration-agent",
      "product.frontend-react-agent",
      "product.supabase-backend-agent",
      "python.ai-prompt-specialist",
      "python.code-cleaner",
      "python.code-documenter",
      "python.llm-specialist",
      "python.python-developer",
      "test.test-generator",
      "test.data-quality-analyst",
      "test.data-contracts-engineer",
      "data-engineering.ai-data-engineer",
      "data-engineering.airflow-specialist",
      "data-engineering.dbt-specialist",
      "data-engineering.lakeflow-pipeline-builder",
      "data-engineering.qdrant-specialist",
      "data-engineering.spark-engineer",
      "data-engineering.streaming-engineer",
      "cloud.ai-data-engineer-cloud",
      "cloud.ai-data-engineer-gcp",
      "cloud.ai-prompt-specialist-gcp",
      "cloud.aws-deployer",
      "cloud.aws-lambda-architect",
      "cloud.ci-cd-specialist",
      "cloud.container-specialist",
      "cloud.lambda-builder",
      "cloud.supabase-specialist",
      "platform.fabric-ai-specialist",
      "platform.fabric-cicd-specialist",
      "platform.fabric-logging-specialist",
      "platform.fabric-pipeline-developer",
      "platform.fabric-security-specialist",
      "architect.kb-architect",
      "architect.pipeline-architect",
      "architect.schema-designer",
    ]),
    skill: "allow",
    websearch: "deny",
    webfetch: "deny",
    question: "allow",
  }
}

function applyOverride(agent: AgentConfig | undefined, override: AgentConfig): void {
  if (!agent) return
  if (override.hidden !== undefined) agent.hidden = override.hidden
  if (override.permission) agent.permission = override.permission
}

export default (async () => {
  return {
    config: async (cfg) => {
      const typed = cfg as { agent?: Record<string, AgentConfig | undefined> }
      if (!typed.agent) return

      for (const [name, override] of ORCHESTRATORS) {
        applyOverride(typed.agent[name], override)
      }

      for (const [name, override] of EXCEPTIONS) {
        applyOverride(typed.agent[name], override)
      }

      for (const name of AUDITORS) {
        applyOverride(typed.agent[name], { permission: readOnlyPermission() })
      }

      for (const name of REVIEW_ONLY) {
        applyOverride(typed.agent[name], { permission: readOnlyPermission() })
      }

      for (const [name, override] of READ_ONLY) {
        applyOverride(typed.agent[name], override)
      }

      for (const name of LOCAL_AGENT_NAMES) {
        if (ORCHESTRATORS.has(name) || EXCEPTIONS.has(name) || AUDITORS.has(name) || REVIEW_ONLY.has(name) || READ_ONLY.has(name)) {
          continue
        }

        applyOverride(typed.agent[name], {
          permission: builderPermission({
            bash: !BUILDER_NO_BASH.has(name),
            web: BUILDER_WITH_WEB.has(name),
          }),
        })
      }
    },
  }
}) satisfies Plugin
