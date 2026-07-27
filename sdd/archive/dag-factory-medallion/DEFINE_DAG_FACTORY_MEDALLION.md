# DEFINE: DAG Factory Medallion

> Criar uma solução config-driven no Composer para orquestrar pipelines Bronze, Silver e evolução para Gold usando factories separadas por camada.

## Metadata

| Attribute | Value |
|-----------|-------|
| **Feature** | DAG_FACTORY_MEDALLION |
| **Date** | 2026-05-19 |
| **Author** | define-agent |
| **Status** | ✅ Complete (Implemented / Updated) |
| **Clarity Score** | 14/15 |

---

## Problem Statement

O time de dados precisa criar e manter pipelines em repositórios separados de Composer, Dataflow e Dataform, e sem uma DAG factory padronizada o crescimento das cargas aumenta duplicação de lógica, divergência operacional e esforço manual para cada nova pipeline. A solução deve permitir expansão principalmente por configuração, preservando separação explícita entre camadas Bronze, Silver e futura Gold.

---

## Target Users

| User | Role | Pain Point |
|------|------|------------|
| Data engineering team | Responsável por orquestração e evolução das pipelines | Criar novas pipelines manualmente em 3 repositórios aumenta esforço operacional e risco de inconsistência |
| Pipeline maintainers | Responsáveis por operar e corrigir falhas no Composer | Ausência de convenções/factories no Composer dificulta retries, observabilidade e reprocessamento padronizado |

---

## Goals

What success looks like (prioritized):

| Priority | Goal |
|----------|------|
| **MUST** | Implementar uma DAG Bronze única (`bronze_medallion`) que leia configurações no Composer, crie um TaskGroup por tabela e acione a imagem/job de ingestão com parâmetros derivados do arquivo de config |
| **MUST** | Implementar uma DAG Silver única (`silver_medallion`) que leia as mesmas configurações, crie um TaskGroup por tabela e acione execuções de Dataform usando artefatos/repositório GitHub já existentes |
| **MUST** | Garantir que Silver só inicie após conclusão completa da Bronze usando Airflow Datasets |
| **MUST** | Permitir onboarding de ao menos 1 nova pipeline por configuração sem criar uma DAG manual do zero |
| **SHOULD** | Centralizar o contrato de configuração no Composer com validações por camada para evitar divergências entre pipelines |
| **SHOULD** | Incluir estratégia mínima e padronizada de retry, logging e observabilidade para falhas de risco médio |
| **COULD** | Preparar a estrutura para uma futura factory Gold sem exigir sua implementação completa neste ciclo |
| **COULD** | Permitir extensões futuras para diferentes tipos de validação e dependências por camada sem refatoração estrutural grande |

**Priority Guide:**
- **MUST** = MVP fails without this
- **SHOULD** = Important, but workaround exists
- **COULD** = Nice-to-have, cut first if needed

---

## Success Criteria

Measurable outcomes (must include numbers):

- [x] 100% das execuções Bronze são disparadas por configuração dentro da DAG única `bronze_medallion`, sem DAG manual dedicada por pipeline
- [x] 100% das execuções Silver são acionadas pela DAG única `silver_medallion` a partir de configuração e integram com o repositório/artefatos Dataform existentes
- [x] Silver espera Bronze concluir por Airflow Dataset (`dataset://medallion/bronze/complete`)
- [x] O time consegue adicionar nova pipeline ao padrão criando apenas um novo `*_pipeline.yaml`
- [x] A arquitetura limita paralelismo pesado via pools (`pool_bronze`, `pool_silver`) e preserva retries/logs operacionais

---

## Acceptance Tests

| ID | Scenario | Given | When | Then |
|----|----------|-------|------|------|
| AT-001 | Geração Bronze por configuração | Existem arquivos `*_pipeline.yaml` válidos no Composer | `bronze_medallion` é parseada | A DAG contém TaskGroups de Bronze e aciona o Cloud Run Job `ingestao` com parâmetros esperados |
| AT-002 | Geração Silver por configuração | Existem configs Silver válidas apontando para tags Dataform | `silver_medallion` é parseada | A DAG contém TaskGroups de Silver e executa o workflow Dataform esperado |
| AT-003 | Encadeamento Bronze→Silver | Bronze conclui com sucesso | `record_bronze_complete` publica Dataset | `silver_medallion` é disparada pelo Dataset e só inicia após Bronze completa |
| AT-004 | Onboarding de nova pipeline sem nova DAG manual | Existe uma nova configuração aderente ao contrato | A configuração é adicionada ao Composer | Um novo TaskGroup aparece dentro das DAGs Bronze/Silver sem criação de DAG dedicada |
| AT-005 | Falha operacional com retry/concurrency padronizados | Um job Cloud Run/Dataform falha de forma transitória ou há muitas tabelas simultâneas | A execução encontra a falha ou fila | Retries aplicam política padrão e pools limitam execuções pesadas a 4 simultâneas por camada |

---

## Out of Scope

Explicitly NOT included in this feature:

- Reprovisionar ou recriar a infraestrutura-base do GCP já existente
- Implementar governança completa multi-time ou capacidades multi-tenant no Composer
- Eliminar a necessidade de arquivo de configuração explícito por meio de descoberta totalmente automática via GitHub
- Construir uma factory única cobrindo Bronze, Silver e Gold com toda lógica avançada desde o dia 1
- Redesenhar os ativos upstream de Dataflow, Dataform ou BigQuery além do necessário para integração operacional do piloto

---

## Constraints

| Type | Constraint | Impact |
|------|------------|--------|
| Technical | Composer atual está praticamente vazio, com apenas uma DAG de monitoramento/liveness | O padrão de factories, loaders e convenções operacionais precisa começar do zero no repositório Composer |
| Technical | Dataflow, Dataform, BigQuery e integrações principais com GCP + GitHub já existem | O design deve reaproveitar ativos existentes e focar em orquestração, contrato de config e integração |
| Scope | O foco imediato é DAGs, configuração e testes operacionais, não provisionamento de plataforma | Evita expansão para IaC pesada e mantém o ciclo centrado no problema principal |
| Risk | Risco operacional classificado como médio | O design precisa incluir retry, logging, observabilidade mínima e reprocessamento controlado |

---

## Technical Context

> Essential context for Design phase - prevents misplaced files and missed infrastructure needs.

| Aspect | Value | Notes |
|--------|-------|-------|
| **Deployment Location** | `dags/` | O repositório Composer já expõe DAGs nessa pasta; factories, config loaders e módulos auxiliares devem nascer a partir dessa superfície |
| **KB Domains** | `airflow`, `gcp`, `medallion`, `containers` | O brainstorm apontou esses domínios como os mais relevantes para padrões de DAGs, integrações GCP, separação por camadas e execução de imagens/jobs |
| **IaC Impact** | None / Modify existing runtime configuration only | Não há requisito de provisionar nova infraestrutura; no máximo ajustes de configuração operacional no ambiente Composer atual |

**Why This Matters:**

- **Location** → Design phase uses correct project structure, prevents misplaced files
- **KB Domains** → Design phase pulls correct patterns from `~/.config/opencode/kb/`
- **IaC Impact** → Triggers infrastructure planning, avoids "works locally" failures

---

## Data Contract (if applicable)

> Include this section when the feature involves data pipelines, ETL, or analytics.

### Source Inventory
| Source | Type | Volume | Freshness | Owner |
|--------|------|--------|-----------|-------|
| Composer configuration files | YAML/JSON orchestration config | TBD | Loaded at DAG parse/runtime according to design | Data engineering team |
| Dataflow ingestion containers/templates | Batch ingestion processing | TBD | TBD in design/pilot plan | Data engineering / ingestion owners |
| Dataform repository (`gcp-dl-dataform-system`) | SQL transformation workflows | TBD | TBD in design/pilot plan | Data engineering / transformation owners |
| BigQuery datasets for Bronze/Silver/Gold-DW | Analytical storage targets | TBD | TBD in design/pilot plan | Data engineering / analytics owners |

### Schema Contract
| Column | Type | Constraints | PII? |
|--------|------|-------------|------|
| `layer` | STRING | Required; values limited to Bronze/Silver/Gold-ready semantics in config contract | No |
| `pipeline_id` | STRING | Required; unique within config inventory | No |
| `execution_target` | STRING | Required; identifies Dataflow job/template or Dataform action target | No |
| `depends_on` | ARRAY/STRING | Optional; used to express cross-layer dependency ordering | No |

### Freshness SLAs
| Layer | Target | Measurement |
|-------|--------|-------------|
| Bronze pilot | Batch completion within the schedule defined for the pilot configuration | Compare scheduled trigger time vs Dataflow completion metadata |
| Silver pilot | Transformation completion after Bronze success in the same orchestration chain | Compare upstream Bronze completion vs Dataform completion |
| Gold/DW pilot | Final reporting outputs available after successful Silver completion in the same chain | Compare Silver completion vs final DAG stage completion |

### Completeness Metrics
- 100% das pipelines piloto presentes no inventário de configuração devem gerar orquestração executável sem DAG manual dedicada
- Zero configurações piloto aprovadas podem ficar sem target de execução explícito (`Dataflow` ou `Dataform`)

### Lineage Requirements
- Dependências entre Bronze, Silver e Gold/DW devem ser explícitas no contrato de configuração ou derivadas deterministicamente dele
- O design deve permitir rastrear qual configuração originou cada execução de Dataflow ou Dataform do piloto

---

## Assumptions

Assumptions that if wrong could invalidate the design:

| ID | Assumption | If Wrong, Impact | Validated? |
|----|------------|------------------|------------|
| A-001 | Os artefatos/job templates de Dataflow e o repositório/artefatos Dataform existentes já expõem interfaces executáveis pelo Composer sem retrabalho estrutural relevante | A solução precisará incluir adaptação adicional nos repositórios upstream ou mudar a abordagem de integração | [ ] |
| A-002 | O contrato de configuração no Composer será a interface principal aceita pelo time para onboarding de novas pipelines | Se o time exigir múltiplas interfaces ou descoberta automática imediata, o design precisará ampliar escopo e complexidade | [x] |
| A-003 | O piloto de cadastro + `rel_demonstrativo_titular` é suficiente para validar o padrão Bronze/Silver/Gold neste ciclo | Se o piloto não representar bem a diversidade das futuras cargas, haverá risco de refatoração precoce das factories | [ ] |
| A-004 | Não será necessário provisionar infraestrutura nova para entregar o piloto funcional | Se houver lacunas de permissões, conexões ou runtime, o trabalho precisará incluir trilha de infraestrutura fora do escopo atual | [ ] |

**Note:** Validate critical assumptions before DESIGN phase. Unvalidated assumptions become risks.

---

## Clarity Score Breakdown

| Element | Score (0-3) | Notes |
|---------|-------------|-------|
| Problem | 3 | Dor, contexto operacional e impacto estão explícitos |
| Users | 3 | Usuários principais e respectivas dores operacionais estão identificados |
| Goals | 3 | Objetivos estão priorizados em MoSCoW e conectados ao piloto |
| Success | 2 | Critérios são mensuráveis, mas SLAs/volumes ainda dependem de detalhamento posterior |
| Scope | 3 | Limites e exclusões estão claros e alinhados ao brainstorm |
| **Total** | **14/15** | |

**Scoring Guide:**
- 0 = Missing entirely
- 1 = Vague or incomplete
- 2 = Clear but missing details
- 3 = Crystal clear, actionable

**Minimum to proceed: 12/15**

---

## Open Questions

- Confirmar no DESIGN se os arquivos de configuração ficarão sob `dags/` diretamente ou em subestrutura dedicada como `dags/config/`.
- Confirmar no DESIGN o formato final do contrato de configuração (YAML, JSON ou ambos) e o mecanismo de validação.
- Confirmar no DESIGN quais operadores/integrações do Composer serão usados para Dataflow e Dataform no ambiente atual.

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-05-19 | define-agent | Initial version |
| 1.1 | 2026-05-20 | implementation | Updated goals/acceptance for 3-DAG architecture, Dataset orchestration, central schedule and pool-limited TaskGroups |

---

## Next Step

**Ready for:** Composer deployment validation of `bronze_medallion`, `silver_medallion` and `medallion_orchestrator_monitor`.
