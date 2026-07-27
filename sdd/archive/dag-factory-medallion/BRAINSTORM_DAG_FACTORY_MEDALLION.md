# BRAINSTORM: DAG Factory Medallion

> Exploratory session to clarify intent and approach before requirements capture

## Metadata

| Attribute | Value |
|-----------|-------|
| **Feature** | DAG_FACTORY_MEDALLION |
| **Date** | 2026-05-19 |
| **Author** | brainstorm-agent |
| **Status** | Ready for Define |

---

## Initial Idea

**Raw Input:** Criar uma DAG factory no Composer para ler arquivos de configuração e montar pipelines padronizadas para Bronze, Silver e futuramente Gold. Para Bronze, a DAG deve acionar imagem Docker de ingestão e parametrizar a execução do job/template do Dataflow. Para Silver, a DAG deve acionar execuções de Dataform a partir de artefatos/repositório GitHub existentes. O objetivo é separar factories por camada e suportar crescimento de pipelines apenas por configuração.

**Context Gathered:**
- Workspace atual de Composer está praticamente vazio, com apenas uma DAG de monitoramento/liveness.
- Não existem factories, templates ou convenções prévias no Composer; o trabalho começa do zero na camada de orquestração.
- Ativos-base já existem: processamento em Dataflow, repositório de Dataform e BigQuery de destino.
- O contexto de projeto ativo em `knowledge_context` não está configurado, então não houve injeção de deployment context.

**Technical Context Observed (for Define):**

| Aspect | Observation | Implication |
|--------|-------------|-------------|
| Likely Location | `dags/` no repositório Composer | Implementação principal deve nascer como factories/config loaders de Airflow |
| Relevant KB Domains | airflow, gcp, medallion, containers | Reusar padrões de DAG design, integrações GCP e separação Bronze/Silver/Gold |
| IaC Patterns | Stack já provisionado; foco não é IaC agora | DEFINE deve priorizar DAGs, configs, operadores e testes operacionais |

---

## Discovery Questions & Answers

| # | Question | Answer | Impact |
|---|----------|--------|--------|
| 1 | Caso de uso principal | Pipeline de dados | Confirma foco em orquestração e não produto/app |
| 2 | Dor atual | Existem 3 repositórios (Dataflow, Dataform, Composer) e as pipelines vão crescer; é preciso manter o core padronizado e centralizar tudo em um arquivo de configuração no Composer | Justifica factory orientada a configuração para reduzir duplicação e divergência |
| 3 | Usuários e escala | Um único time, menos de 10 pessoas | Permite MVP mais opinionado, com menos necessidade de multi-tenant desde o início |
| 4 | Critério de sucesso | Piloto ponta a ponta com tabelas de cadastro + `rel_demonstrativo_titular` em Bronze/Silver e DW + relatórios finais na Gold | DEFINE precisa tratar um piloto concreto e mensurável |
| 5 | Restrições | Infra/base já existem; foco em criar DAGs e testar no ambiente atual | Evita escopo de plataforma nova, IaC pesada ou reprovisionamento |
| 6 | Solução existente | Composer começa do zero; só Dataflow, Dataform e BigQuery já estão criados | Factory, contratos de config e convenções precisam ser desenhados do zero |
| 7 | Integrações | GCP + GitHub | DAGs precisarão lidar com artefatos/configs GCP e versionamento/código no GitHub |
| 8 | Risco de falha | Médio | Exige retries, observabilidade mínima e reprocessamento controlado |
| 9 | Evolução esperada | Muitas pipelines só por configuração, factories separadas por Bronze/Silver/Gold, dependências entre cargas, validações por tipo | Reforça modularidade e governança por camada como requisito arquitetural |

---

## Sample Data Inventory

> Samples improve LLM accuracy through in-context learning and few-shot prompting.

| Type | Location | Count | Notes |
|------|----------|-------|-------|
| Input files | N/A no brainstorm | 0 | Ainda não foram fornecidos exemplos de config |
| Output examples | N/A no brainstorm | 0 | Seria útil ter formato esperado da DAG/config gerada |
| Ground truth | N/A no brainstorm | 0 | Não houve evidência de casos verificados de referência |
| Related code | `dags/airflow_monitoring.py` | 1 | Apenas exemplo mínimo de DAG, sem padrão reutilizável para factory |

**How samples will be used:**
- Definir o schema do arquivo de configuração da factory
- Criar fixtures de teste para Bronze e Silver
- Validar o mapeamento entre config e parâmetros executados em Dataflow/Dataform

---

## Approaches Explored

### Approach A: Config-driven factories separadas por camada ⭐ Recommended

**Description:** Criar um núcleo comum de leitura/validação de configuração no Composer e expor factories separadas para Bronze, Silver e depois Gold. Cada factory interpreta apenas seu tipo de processo e monta tasks/operators específicos da camada.

**Pros:**
- Alinha com a evolução desejada: muitas pipelines apenas por configuração
- Mantém separação clara entre ingestão raw (Bronze), transformação curada (Silver) e consumo analítico (Gold)
- Facilita adicionar validações e dependências específicas por camada
- Reduz risco de uma factory genérica demais virar “if/else monster”

**Cons:**
- Requer definir um contrato de configuração bem pensado desde o início
- Pode gerar um pouco mais de estrutura inicial do que uma DAG única simples

**Why Recommended:** Está mais alinhada às respostas do brainstorm e aos padrões de medallion architecture. A KB de medallion reforça Bronze → Silver → Gold com responsabilidades distintas, e a KB de Airflow favorece tasks/factories pequenas e bem separadas. Confiança: **0.95** (KB + intenção do usuário + padrão arquitetural coerente).

---

### Approach B: Uma factory única para todos os tipos de pipeline

**Description:** Criar uma única DAG factory genérica com um arquivo de configuração universal capaz de montar pipelines Bronze, Silver e Gold por switches/tipos.

**Pros:**
- Menor esforço inicial de estrutura
- Um único ponto de entrada para onboarding

**Cons:**
- Tende a crescer em complexidade rapidamente
- Mistura regras de Dataflow e Dataform na mesma árvore decisória
- Dificulta evoluir validações e dependências específicas por camada

---

### Approach C: DAGs manuais por pipeline, sem factory

**Description:** Criar cada DAG explicitamente no Composer, sem camada central de configuração.

**Pros:**
- Entrega piloto muito rápida
- Menor abstração inicial

**Cons:**
- Não resolve o problema principal de escala e padronização
- Gera duplicação e dificulta onboarding/contribuição futura
- Vai contra o objetivo explícito de crescer “só por configuração”

---

## Data Engineering Context

### Source Systems
| Source | Type | Volume Estimate | Current Freshness |
|--------|------|-----------------|-------------------|
| Dataflow ingestion containers/templates | Batch ingestão | Unknown | A definir no DEFINE |
| Dataform repository (`gcp-dl-dataform-system`) | SQL transformations / workflow code | Unknown | A definir no DEFINE |
| BigQuery | DW / analytical target | Unknown | A definir no DEFINE |

### Data Flow Sketch
```text
[Config YAML/JSON no Composer] -> [Bronze Factory DAG] -> [Docker image params] -> [Dataflow job/template] -> [Bronze BigQuery/raw]
                                                        -> [Silver Factory DAG] -> [Dataform execution] -> [Silver datasets]
                                                        -> [Gold Factory DAG] -> [DW/reporting outputs]
```

### Key Data Questions Explored
| # | Question | Answer | Impact |
|---|----------|--------|--------|
| 1 | Qual é o primeiro domínio piloto? | Cadastro + `rel_demonstrativo_titular` | Permite recorte objetivo para MVP |
| 2 | Quais camadas entram no piloto? | Bronze + Silver + Gold final | Exige dependências cross-layer desde cedo |
| 3 | Qual a meta de evolução? | Muitas pipelines via config | O contrato de config vira artefato central da solução |

---

## Selected Approach

| Attribute | Value |
|-----------|-------|
| **Chosen** | Approach A |
| **User Confirmation** | Implícita pelo objetivo declarado de separar factories Bronze/Silver/Gold e crescer só por configuração |
| **Reasoning** | Melhor aderência à arquitetura medallion, ao stack existente e à necessidade de escala com padronização |

---

## Key Decisions Made

| # | Decision | Rationale | Alternative Rejected |
|---|----------|-----------|----------------------|
| 1 | A solução deve ser config-driven no Composer | Reduz duplicação e centraliza padrão operacional | DAGs manuais por pipeline |
| 2 | Bronze e Silver devem ter factories separadas | Regras de execução e integração são diferentes (Dataflow vs Dataform) | Factory única genérica |
| 3 | O piloto deve cobrir Bronze, Silver e desdobramento até Gold | Dá prova real do fluxo ponta a ponta | Fazer só uma camada isolada |
| 4 | O foco imediato não inclui criar plataforma nova | Infra já existe; valor está na orquestração | Reprovisionar stack/IaC agora |
| 5 | A arquitetura operacional final deve ter apenas 3 DAGs ativas | Reduz carga no scheduler/UI do Composer sem perder granularidade por tabela | Uma DAG por pipeline/tabela |

---

## Implementation Update (2026-05-20)

Após validação no Composer, a abordagem recomendada foi refinada:

- Manter factories Bronze/Silver separadas, mas **consolidar a superfície operacional em 3 DAGs ativas**.
- `bronze_medallion` executa todos os TaskGroups Bronze e publica Dataset de conclusão.
- `silver_medallion` é disparada por Dataset e executa todos os TaskGroups Silver somente após Bronze finalizar.
- `medallion_orchestrator_monitor` permanece como DAG leve de inventário/saúde.
- Os schedules por YAML foram removidos; o cron fica centralizado na Bronze (`0 6 * * *`).
- `dependencies.depends_on` passa a controlar encadeamento entre TaskGroups dentro das DAGs de camada.
- `.airflowignore` e lazy provider imports foram adicionados para evitar timeouts de parse no Composer.

---

## Features Removed (YAGNI)

| Feature Suggested | Reason Removed | Can Add Later? |
|-------------------|----------------|----------------|
| Reprovisionamento de infraestrutura GCP | Fora do problema central; stack já existe | Yes |
| Factory única cobrindo todos os comportamentos avançados desde o dia 1 | Risco alto de complexidade prematura | Yes |
| Governança completa multi-time | Time atual é pequeno; não é requisito imediato | Yes |
| Automação total de descoberta de pipelines via GitHub sem contrato de config | Aumenta acoplamento e complexidade cedo demais | Yes |

---

## Incremental Validations

| Section | Presented | User Feedback | Adjusted? |
|---------|-----------|---------------|-----------|
| Problem framing | ✅ | Usuário confirmou a dor: padronizar 3 repositórios com config central | Yes |
| Success scope | ✅ | Usuário delimitou piloto com cadastro + `rel_demonstrativo_titular` + DW/relatórios finais | Yes |
| Evolution path | ✅ | Usuário pediu crescimento por config, separação por camadas e dependências | Yes |

---

## Suggested Requirements for /workflow:define

Based on this brainstorm session, the following should be captured in the DEFINE phase:

### Problem Statement (Draft)
Criar uma solução de DAG factory no Composer que permita orquestrar pipelines de Bronze, Silver e posteriormente Gold de forma padronizada e escalável, usando configuração como interface principal para disparar jobs de Dataflow e execuções de Dataform sem duplicação de lógica entre pipelines.

### Target Users (Draft)
| User | Pain Point |
|------|------------|
| Data engineering team | Criar e manter novas pipelines manualmente em 3 repositórios aumenta risco de divergência e esforço operacional |

### Success Criteria (Draft)
- [ ] O piloto de Bronze para tabelas de cadastro e `rel_demonstrativo_titular` roda por configuração
- [ ] O piloto de Silver aciona corretamente o processo Dataform associado
- [ ] Existe separação explícita entre factories de Bronze e Silver
- [ ] A solução suporta inclusão de uma nova pipeline sem criar uma DAG manual do zero
- [ ] Há estratégia mínima de retry/observabilidade para falhas de risco médio

### Constraints Identified
- Stack GCP atual deve ser reaproveitado
- Composer começa sem factories prévias
- Integrações principais: GCP + GitHub
- O foco imediato é DAGs + testes, não provisionamento

### Out of Scope (Confirmed)
- Recriar infraestrutura-base do GCP
- Resolver toda governança organizacional multi-time agora
- Fazer descoberta totalmente automática de processos sem arquivo de configuração explícito

---

## Session Summary

| Metric | Value |
|--------|-------|
| Questions Asked | 9 |
| Approaches Explored | 3 |
| Features Removed (YAGNI) | 4 |
| Validations Completed | 3 |
| Duration | Conversational session |

---

## Next Step

**Ready for:** `/workflow:define ~/.config/opencode/sdd/features/dag-factory-medallion/BRAINSTORM_DAG_FACTORY_MEDALLION.md`
