# Archetype Summary Index

This file summarizes the archetypes available under `archetypes-aggregation` so other agents can quickly choose the best-fit workflow and jump to the source repository for the full instructions.

## How To Use This Index

- Use the `Does` text to understand the archetype's primary responsibility.
- Use the `Best fit` text to decide when to invoke it.
- Use the `Keywords` line to match task vocabulary against archetype capabilities — these are high-signal terms (tool names, framework names, algorithm names, protocol names) that are **not** in the description but help an agent determine fit. Generic terms like `api`, `governance`, or `testing` are intentionally omitted.
- Use the `Depends on` text to understand notable prerequisites or adjacent archetypes to compose.
- Use the `Repo` link to retrieve the authoritative source — constitutions, workflow files, and templates live there.

> **Routing tip for agents:** Read `Keywords` first for keyword-match routing, then `Best fit` for intent-match routing. If uncertain, delegate to `00-core-orchestration` which has a discovery script.

## Core Orchestration

- **00-core-orchestration / Core Orchestration**
  Does: Routes user requests to the right specialist archetype and coordinates multi-archetype solution workflows.
  Best fit: Start here when the task is discovery, routing, or composing multiple archetypes into one solution workflow.
  Keywords: scaffold, debug, compare, refactor, document, solution-workflow, multi-archetype, manifest-discovery, constitution, meta-archetype, ecosystem, template-generator, archetype-quality
  Repo: [ATT-DP11/apm0047153-archetypes-00-core-orchestration](https://github.com/ATT-DP11/apm0047153-archetypes-00-core-orchestration.git)

- **archetype-architect / Archetype Architect**
  Does: Creates, refines, quality-controls, and documents other archetypes in the catalog.
  Best fit: Use when building a new archetype or standardizing an existing archetype's manifest, constitution, templates, and workflows.
  Keywords: constitution, manifest, meta-archetype, ecosystem, template-generator, archetype-quality
  Repo: [ATT-DP11/apm0047153-archetypes-archetype-architect](https://github.com/ATT-DP11/apm0047153-archetypes-archetype-architect)

## Agentic Development

- **agent-developer / Agent Developer**
  Does: Builds production-grade AI agents with ReAct patterns, RAG, tool calling, memory, and enterprise guardrails.
  Best fit: Use for implementing end-to-end agent runtimes, especially LangGraph or LangChain based agents.
  Depends on: `langchain`, `langgraph`, `langsmith`, `openai`, `anthropic`
  Keywords: ReAct, RAG, tool-calling, function-calling, LangGraph, LangChain, LlamaIndex, memory-management, autonomous, agentic, SOX-compliance, trajectory-evaluation, adversarial-testing, red-team, deepeval, langsmith, CI-promotion, benchmark, regression
  Repo: [ATT-DP11/apm0047153-archetypes-agent-developer](https://github.com/ATT-DP11/apm0047153-archetypes-agent-developer.git)

- **agent-validator / Agent Validator**
  Does: Creates test cases, adversarial checks, safety gates, and promotion criteria for agents.
  Best fit: Use when validating agent behavior before rollout or adding CI quality gates around agent trajectories.
  Depends on: `deepeval`, `pytest`, `langsmith`
  Keywords: LLM-as-judge, grader, hallucination, faithfulness, deepeval, ragas, arize-phoenix, langsmith, scoring, benchmark, trajectory-evaluation, adversarial-testing, red-team, CI-promotion, regression
  Repo: [ATT-DP11/apm0047153-archetypes-agent-validator](https://github.com/ATT-DP11/apm0047153-archetypes-agent-validator.git)

- **eval-specialist / Eval Specialist**
  Does: Designs and tunes evaluations using LLM-as-judge patterns, custom graders, and observability tooling.
  Best fit: Use when the core problem is agent or LLM evaluation design, benchmark tuning, hallucination or faithfulness measurement, or grading strategy.
  Keywords: LLM-as-judge, grader, hallucination, faithfulness, deepeval, ragas, arize-phoenix, langsmith, scoring, benchmark, prompt-injection, PII-masking, toxicity-filtering, presidio, Galileo, runtime-safety, input-validation, output-filtering
  Depends on: `deepeval`, `ragas`, `arize-phoenix`, `langsmith`
  Repo: [ATT-DP11/apm0047153-archetypes-eval-specialist](https://github.com/ATT-DP11/apm0047153-archetypes-eval-specialist.git)

- **guardrails-engineer / Guardrails Engineer**
  Does: Implements runtime safety controls such as prompt injection detection, PII masking, toxicity filtering, and compliance gates.
  Best fit: Use when an agent needs input or output safety enforcement rather than broader evaluation or agent construction.
  Depends on: `deepeval`, `presidio-analyzer`, `presidio-anonymizer`, `arize-phoenix`
  Keywords: prompt-injection, PII-masking, toxicity-filtering, hallucination-blocking, presidio, Galileo, runtime-safety, input-validation, output-filtering
  Repo: [ATT-DP11/apm0047153-archetypes-guardrails-engineer](https://github.com/ATT-DP11/apm0047153-archetypes-guardrails-engineer.git)

- **llm-pipeline-architect / LLM Pipeline Architect**
  Does: Designs multi-phase LLM and agent orchestration pipelines with routing, replanning, memory handoff, and deterministic quality gates.
  Best fit: Use when the problem is pipeline architecture across multiple agent phases, not just a single agent implementation.
  Keywords: intent-classification, model-routing, task-decomposition, context-handoff, loop-guard, multi-phase, replan, streaming-event, agent-pipeline
  Repo: [ATT-DP11/apm0047153-archetypes-llm-pipeline-architect](https://github.com/ATT-DP11/apm0047153-archetypes-llm-pipeline-architect.git)

- **mcp-developer / MCP Developer**
  Does: Builds Model Context Protocol servers with schema validation, error handling, and secure tool boundaries.
  Best fit: Use when exposing tools or capabilities to agents through MCP.
  Depends on: `mcp`, `langchain`, `pydantic`, `fastapi`
  Keywords: MCP, Model-Context-Protocol, tool-server, function-calling, schema-validation, tool-correctness, capability-exposure, Pydantic, JSON-Schema, structured-output, output-parsing, retry-logic, type-safe, output-contract
  Repo: [ATT-DP11/apm0047153-archetypes-mcp-developer](https://github.com/ATT-DP11/apm0047153-archetypes-mcp-developer.git)

- **model-specialist / Model Specialist**
  Does: Chooses and tunes LLM models, fallback chains, and cost or quality tradeoffs for agent workloads.
  Best fit: Use when the main decision is model selection, routing, fallback, or prompt-model optimization.
  Depends on: `langchain`, `openai`, `anthropic`
  Keywords: LLM, model-selection, fallback-chain, temperature, fine-tuning, provider-routing, cost-quality-tradeoff, openai, anthropic, AGENTS.md, git-worktree, boundary-control, lock-protocol, concurrent-agents, shared-file, merge-gate
  Repo: [ATT-DP11/apm0047153-archetypes-model-specialist](https://github.com/ATT-DP11/apm0047153-archetypes-model-specialist.git)

- **output-spec-specialist / Output Spec Specialist**
  Does: Defines structured output contracts with Pydantic, JSON Schema, and validation or retry patterns.
  Best fit: Use when reliable machine-readable model outputs are the main requirement.
  Keywords: Pydantic, JSON-Schema, structured-output, output-parsing, retry-logic, type-safe, output-contract
  Depends on: `pydantic`, `langchain`, `jsonschema`
  Repo: [ATT-DP11/apm0047153-archetypes-output-spec-specialist](https://github.com/ATT-DP11/apm0047153-archetypes-output-spec-specialist.git)

- **parallel-agent / Parallel Agent**
  Does: Governs safe multi-agent execution, especially parallel work with boundary control and coordination rules.
  Best fit: Use when several agents must work concurrently without conflicting over files or responsibilities.
  Keywords: AGENTS.md, git-worktree, boundary-control, lock-protocol, concurrent-agents, shared-file, merge-gate, few-shot, system-prompt, token-optimization, prompt-versioning, tiktoken, jinja2, prompt-chain, context-window
  Repo: [ATT-DP11/apm0047153-archetypes-parallel-agent](https://github.com/ATT-DP11/apm0047153-archetypes-parallel-agent)

- **production-monitor / Production Monitor**
  Does: Sets up production monitoring for agents with drift detection, dashboards, tracing, and SLOs.
  Best fit: Use when an agent system is already built and now needs runtime observability and operations coverage.
  Depends on: `arize-phoenix`, `prometheus-client`
  Keywords: arize-phoenix, drift-detection, SLO, tracing, SOX-dashboard, prometheus, alerting
  Repo: [ATT-DP11/apm0047153-archetypes-production-monitor](https://github.com/ATT-DP11/apm0047153-archetypes-production-monitor.git)

- **prompt-engineer / Prompt Engineer**
  Does: Creates and optimizes prompt templates with versioning, token efficiency, few-shot patterns, and prompt testing.
  Best fit: Use when prompt quality itself is the primary lever, separate from output schemas or full workflow design.
  Depends on: `langchain`, `tiktoken`, `jinja2`
  Keywords: few-shot, system-prompt, token-optimization, prompt-versioning, tiktoken, jinja2, prompt-chain, context-window, similarity-detection, capability-overlap, consolidation, deduplication, inventory-governance
  Repo: [ATT-DP11/apm0047153-archetypes-prompt-engineer](https://github.com/ATT-DP11/apm0047153-archetypes-prompt-engineer.git)

- **prompt-template-engineer / Prompt Template Engineer**
  Does: Builds structured prompt management systems with sanitization, type-safe loading, caching, and prompt testing.
  Best fit: Use when prompts need a maintainable file or template architecture, not just better prompt content.
  Keywords: handlebars, persona-system, prompt-injection-resistance, sanitization, template-caching, type-safe-prompts, prompt-catalog, prompts-as-files, StateGraph, TypedDict, checkpointing, multi-turn, LangGraph, persistence, session-memory, conversation-state
  Repo: [ATT-DP11/apm0047153-archetypes-prompt-template-engineer](https://github.com/ATT-DP11/apm0047153-archetypes-prompt-template-engineer.git)

- **reuse-master / Reuse Master**
  Does: Discovers reusable agent components, patterns, and archetypes across the catalog.
  Best fit: Use before building from scratch when the goal is finding reuse opportunities.
  Keywords: catalog-discovery, component-reuse, pattern-recommendation, library-search, reuse-inventory, LangGraph, node-composition, conditional-routing, subgraph, supervisor-pattern, multi-agent, DAG, StateGraph
  Repo: [ATT-DP11/apm0047153-archetypes-reuse-master](https://github.com/ATT-DP11/apm0047153-archetypes-reuse-master.git)

- **scope-deduplicator / Scope Deduplicator**
  Does: Detects overlapping agent capabilities and recommends consolidation.
  Best fit: Use when multiple archetypes or agents appear to cover the same capability and governance wants to reduce redundancy.
  Keywords: similarity-detection, capability-overlap, consolidation, deduplication, inventory-governance, latency-optimization, cost-reduction, bottleneck-identification, langsmith, profiling, workflow-tuning
  Repo: [ATT-DP11/apm0047153-archetypes-scope-deduplicator](https://github.com/ATT-DP11/apm0047153-archetypes-scope-deduplicator.git)

- **state-specialist / State Specialist**
  Does: Designs typed state schemas, checkpointing, persistence, and multi-turn conversation state for LangGraph agents.
  Best fit: Use when state modeling is the main complexity in an agent or workflow.
  Depends on: `langgraph`, `langchain`, `pydantic`
  Keywords: StateGraph, TypedDict, checkpointing, multi-turn, LangGraph, persistence, session-memory, conversation-state
  Repo: [ATT-DP11/apm0047153-archetypes-state-specialist](https://github.com/ATT-DP11/apm0047153-archetypes-state-specialist.git)

- **workflow-creator / Workflow Creator**
  Does: Designs LangGraph workflows with nodes, routing, subgraphs, and multi-agent composition.
  Best fit: Use when the problem is graph workflow structure rather than prompt, state, or model tuning in isolation.
  Depends on: `langgraph`, `langchain`
  Keywords: LangGraph, node-composition, conditional-routing, subgraph, supervisor-pattern, multi-agent, DAG, StateGraph
  Repo: [ATT-DP11/apm0047153-archetypes-workflow-creator](https://github.com/ATT-DP11/apm0047153-archetypes-workflow-creator.git)

- **workflow-optimizer / Workflow Optimizer**
  Does: Optimizes agent workflows for latency, cost, and bottlenecks.
  Best fit: Use after a workflow exists and needs performance tuning or cost reduction.
  Depends on: `langsmith`
  Keywords: latency-optimization, cost-reduction, bottleneck-identification, langsmith, profiling, workflow-tuning
  Repo: [ATT-DP11/apm0047153-archetypes-workflow-optimizer](https://github.com/ATT-DP11/apm0047153-archetypes-workflow-optimizer.git)

## Application Development

- **app-maker / App Maker**
  Does: Generates production-ready web applications aligned to AT&T brand standards.
  Best fit: Use when the deliverable is a full-stack application rather than a single frontend or backend component.
  Keywords: React, FastAPI, Vite, Tailwind, TypeScript, AT&T-brand, Flywheel, full-stack, production-ready
  Repo: [ATT-DP11/apm0047153-archetypes-06-application-development-app-maker](https://github.com/ATT-DP11/apm0047153-archetypes-06-application-development-app-maker.git)

- **backend-only / Backend Only**
  Does: Builds production-ready backend API services using FastAPI, containerization, and deployment patterns.
  Best fit: Use when the task is a backend service only, without frontend work.
  Keywords: FastAPI, Python, Poetry, Docker, Helm, Azure-DevOps, CI-CD, API, microservice
  Repo: [ATT-DP11/apm0047153-archetypes-backend-only](https://github.com/ATT-DP11/apm0047153-archetypes-backend-only)

- **frontend-only / Frontend Only**
  Does: Defines guardrails for frontend-only application development.
  Best fit: Use when the requested work is limited to the UI layer and should not include backend implementation.
  Keywords: React, TypeScript, Vite, Tailwind, accessibility, testing, UI-only, frontend
  Repo: [ATT-DP11/apm0047153-archetypes-frontend-only](https://github.com/ATT-DP11/apm0047153-archetypes-frontend-only)

- **flywheel-frontend-architect / Flywheel Frontend Architect**
  Does: Builds AT&T Flywheel-compliant React frontends using Forge components, React 19, Vite, Tailwind, and multi-brand theming.
  Best fit: Use when enterprise design-system fidelity and AT&T Flywheel compliance are mandatory.
  Keywords: Flywheel, Forge, React-19, Vite, Tailwind-v4, TypeScript, AT&T-brand, design-system, multi-brand, theming
  Repo: [ATT-DP11/apm0047153-archetypes-flywheel-frontend-architect](https://github.com/ATT-DP11/apm0047153-archetypes-flywheel-frontend-architect.git)

- **integration-specialist / Integration Specialist**
  Does: Governs service integration patterns across APIs, GraphQL, and application boundaries.
  Best fit: Use when connecting systems is the core problem rather than building a standalone service.
  Keywords: REST, GraphQL, API-gateway, service-mesh, integration, authentication, rate-limiting, contract-testing
  Repo: [ATT-DP11/apm0047153-archetypes-06-application-development-integration-specialist](https://github.com/ATT-DP11/apm0047153-archetypes-06-application-development-integration-specialist.git)

- **notebook-collaboration-coach / Notebook Collaboration Coach**
  Does: Establishes reproducible, source-controlled collaborative notebook workflows.
  Best fit: Use when teams are working in notebooks and need versioning, review discipline, and collaboration hygiene.
  Keywords: Jupyter, Databricks, source-control, reproducibility, collaboration, review-discipline, versioning
  Repo: [ATT-DP11/apm0047153-archetypes-06-application-development-notebook-collaboration-coach](https://github.com/ATT-DP11/apm0047153-archetypes-06-application-development-notebook-collaboration-coach.git)

- **streamlit-developer / Streamlit Developer**
  Does: Builds branded, production-ready Streamlit data applications.
  Best fit: Use when the deliverable is a Python Streamlit app rather than a React or service-based application.
  Keywords: Streamlit, Python, data-app, AT&T-brand, production-ready, deployment
  Repo: [ATT-DP11/apm0047153-archetypes-06-application-development-streamlit-developer](https://github.com/ATT-DP11/apm0047153-archetypes-06-application-development-streamlit-developer.git)

- **ui-theme-architect / UI Theme Architect**
  Does: Designs semantic theming systems with light or dark modes, CSS variables, contrast compliance, and theme-aware assets.
  Best fit: Use when theming and design-token architecture are the main objective.
  Keywords: semantic-tokens, CSS-variables, dark-mode, light-mode, WCAG, contrast-compliance, design-tokens, theming-system
  Repo: [ATT-DP11/apm0047153-archetypes-ui-theme-architect](https://github.com/ATT-DP11/apm0047153-archetypes-ui-theme-architect.git)

## Data Engineering And Platforms

- **data-pipeline-builder / Data Pipeline Builder**
  Does: Builds ingestion and transformation pipelines for batch and streaming data.
  Best fit: Use when the primary deliverable is a data pipeline implementation.
  Keywords: ingestion, transformation, batch, streaming, ETL, data-pipeline, merge-overwrite, incremental-loading
  Repo: [ATT-DP11/apm0047153-archetypes-03-data-engineering-data-pipeline-builder](https://github.com/ATT-DP11/apm0047153-archetypes-03-data-engineering-data-pipeline-builder.git)

- **data-solution-architect / Data Solution Architect**
  Does: Acts as the technical lead for governed data solution design and major architecture choices.
  Best fit: Use when the task is high-level data platform architecture rather than a single pipeline or notebook.
  Keywords: data-architecture, governed-solution, enterprise-standards, specialist-delegation, technical-lead
  Repo: [ATT-DP11/apm0047153-archetypes-03-data-engineering-data-solution-architect](https://github.com/ATT-DP11/apm0047153-archetypes-03-data-engineering-data-solution-architect.git)

- **data-sourcing-specialist / Data Sourcing Specialist**
  Does: Acquires governed data for exploration while respecting catalog, lineage, and sampling policies.
  Best fit: Use when safe and compliant data access or sampling is the bottleneck.
  Keywords: data-access, catalog, lineage, sampling, PII-guardrails, Unity-Catalog, governed-data
  Repo: [ATT-DP11/apm0047153-archetypes-03-data-engineering-data-sourcing-specialist](https://github.com/ATT-DP11/apm0047153-archetypes-03-data-engineering-data-sourcing-specialist.git)

- **databricks-developer-workflow / Databricks Developer Workflow**
  Does: Governs local IDE development, Databricks CLI usage, notebook deployment, and developer-triggered jobs.
  Best fit: Use when the task centers on the Databricks developer lifecycle.
  Keywords: Databricks, CLI, notebook-deployment, IDE-development, developer-lifecycle
  Repo: [ATT-DP11/apm0047153-archetypes-databricks-developer-workflow](https://github.com/ATT-DP11/apm0047153-archetypes-databricks-developer-workflow)

- **databricks-workflow-creator / Databricks Workflow Creator**
  Does: Designs and operates Databricks workflows, Delta Live Tables pipelines, and Unity Catalog governed assets.
  Best fit: Use when building scheduled or managed Databricks workflows rather than notebook-only development.
  Keywords: Databricks, Delta-Live-Tables, Unity-Catalog, scheduled-workflows, governed-assets
  Repo: [ATT-DP11/apm0047153-archetypes-03-data-engineering-databricks-workflow-creator](https://github.com/ATT-DP11/apm0047153-archetypes-03-data-engineering-databricks-workflow-creator.git)

- **eda-navigator / EDA Navigator**
  Does: Guides exploratory data analysis through reproducible and governed Databricks notebooks.
  Best fit: Use when exploration and discovery are needed before modeling or productization.
  Keywords: EDA, exploratory-analysis, Databricks, reproducibility, governed-notebooks, discovery
  Repo: [ATT-DP11/apm0047153-archetypes-03-data-engineering-eda-navigator](https://github.com/ATT-DP11/apm0047153-archetypes-03-data-engineering-eda-navigator.git)

- **elasticsearch-stream / Elasticsearch Stream**
  Does: Builds Python or notebook workflows that move data between EventHub topics and Elasticsearch indices.
  Best fit: Use when streaming or transforming data into Elasticsearch is the core requirement.
  Keywords: Elasticsearch, EventHub, streaming, real-time-indexing, Python, notebook-workflows
  Repo: [ATT-DP11/apm0047153-archetypes-03-data-engineering-elasticsearch-stream](https://github.com/ATT-DP11/apm0047153-archetypes-03-data-engineering-elasticsearch-stream.git)

- **impact-analyzer / Impact Analyzer**
  Does: Scans SQL jobs, orchestration manifests, and downstream code to estimate blast radius from schema or logic changes.
  Best fit: Use before making data model or workflow changes when you need impact analysis across dependencies.
  Keywords: impact-analysis, dependency-scanning, schema-changes, blast-radius, SQL-jobs, orchestration
  Repo: [ATT-DP11/apm0047153-archetypes-03-data-engineering-impact-analyzer](https://github.com/ATT-DP11/apm0047153-archetypes-03-data-engineering-impact-analyzer.git)

- **pipeline-orchestrator / Pipeline Orchestrator**
  Does: Defines orchestration patterns for DAGs, scheduling, workflow control, and task execution.
  Best fit: Use when the problem is orchestration logic across tasks, schedules, or dependencies.
  Keywords: orchestration, DAG, scheduling, Airflow, TWS, workflow-control, task-execution
  Repo: [ATT-DP11/apm0047153-archetypes-03-data-engineering-pipeline-orchestrator](https://github.com/ATT-DP11/apm0047153-archetypes-03-data-engineering-pipeline-orchestrator.git)

- **sql-query-crafter / SQL Query Crafter**
  Does: Crafts governed SQL including joins, CTEs, and data-retrieval logic.
  Best fit: Use when the main deliverable is SQL rather than a broader data pipeline.
  Keywords: SQL, CTE, joins, data-retrieval, named-CTE, parameterized-filters
  Repo: [ATT-DP11/apm0047153-archetypes-03-data-engineering-sql-query-crafter](https://github.com/ATT-DP11/apm0047153-archetypes-03-data-engineering-sql-query-crafter.git)

- **transformation-alchemist / Transformation Alchemist**
  Does: Builds governed data transformation logic for Spark, PySpark, SQL, and Databricks style ETL.
  Best fit: Use when the core work is transformation code rather than ingestion, orchestration, or governance policy.
  Keywords: PySpark, Spark, SQL, ETL, transformation, Delta-Lake, quality-checks
  Repo: [ATT-DP11/apm0047153-archetypes-03-data-engineering-transformation-alchemist](https://github.com/ATT-DP11/apm0047153-archetypes-03-data-engineering-transformation-alchemist.git)

- **xflow-orchestrator / XFlow Orchestrator**
  Does: Generates and validates XFlow JSON configurations for JDBC, Kafka, file, and HTTP ingestion into ADLS or Delta targets.
  Best fit: Use when the required artifact is XFlow configuration rather than handwritten pipeline code.
  Keywords: XFlow, JSON-configuration, JDBC, Kafka, HTTP, ADLS, Delta, ingestion
  Repo: [ATT-DP11/apm0047153-archetype-xflow](https://github.com/ATT-DP11/apm0047153-archetype-xflow.git)

## Data Governance, Reliability, And Security

- **ai-ethics-advisor / AI Ethics Advisor**
  Does: Assesses, documents, and mitigates ethical risks across the AI lifecycle in line with responsible AI standards.
  Best fit: Use when governance needs an ethics or responsible AI review.
  Keywords: responsible-AI, ethics-assessment, risk-mitigation, AI-lifecycle, governance-review, fairness, explainability
  Repo: [ATT-DP11/apm0047153-archetypes-04-data-governance-quality-ai-ethics-advisor](https://github.com/ATT-DP11/apm0047153-archetypes-04-data-governance-quality-ai-ethics-advisor.git)

- **data-classification-policy / Data Classification Policy**
  Does: Governs handling of SPI and PII according to AT&T data classification rules and regulatory requirements.
  Best fit: Use when a workflow touches sensitive data and classification policy is central.
  Keywords: SPI, PII, data-classification, regulatory-compliance, governance-framework, automation
  Repo: [ATT-DP11/apm0047153-archetypes-04-data-governance-quality-data-classification-policy](https://github.com/ATT-DP11/apm0047153-archetypes-04-data-governance-quality-data-classification-policy.git)

- **data-reliability / Data Reliability**
  Does: Defines standards for freshness, availability, latency, lineage integrity, and incident recovery.
  Best fit: Use when the issue is trustworthiness or resilience of data delivery.
  Keywords: SLO, monitoring, incident-response, freshness, availability, latency, lineage-integrity
  Repo: [ATT-DP11/apm0047153-archetypes-04-data-governance-quality-data-reliability](https://github.com/ATT-DP11/apm0047153-archetypes-04-data-governance-quality-data-reliability.git)

- **data-security / Data Security**
  Does: Enforces encryption, masking, retention, and exposure controls across the data lifecycle.
  Best fit: Use when security controls around data handling are the main concern.
  Keywords: encryption, masking, retention, exposure-controls, threat-detection, access-controls, data-lifecycle
  Repo: [ATT-DP11/apm0047153-archetypes-04-data-governance-quality-data-security](https://github.com/ATT-DP11/apm0047153-archetypes-04-data-governance-quality-data-security.git)

- **data-validation / Data Validation**
  Does: Defines standards for completeness, accuracy, timeliness, consistency, and contract compliance across data tiers.
  Best fit: Use when datasets or transformations need explicit validation rules.
  Keywords: data-quality, validation, completeness, accuracy, timeliness, consistency, contract-compliance
  Repo: [ATT-DP11/apm0047153-archetypes-04-data-governance-quality-data-validation](https://github.com/ATT-DP11/apm0047153-archetypes-04-data-governance-quality-data-validation.git)

- **quality-guardian / Quality Guardian**
  Does: Implements data quality checks, thresholds, and validation frameworks such as Great Expectations or Deequ style patterns.
  Best fit: Use when ongoing quality enforcement is needed, not just one-off validation.
  Keywords: Great-Expectations, Deequ, data-quality, validation-frameworks, thresholds, enforcement
  Repo: [ATT-DP11/apm0047153-archetypes-04-data-governance-quality-quality-guardian](https://github.com/ATT-DP11/apm0047153-archetypes-04-data-governance-quality-quality-guardian.git)

- **responsible-prompting / Responsible Prompting**
  Does: Safeguards prompt engineering practices so model interactions remain safe, inclusive, auditable, and policy aligned.
  Best fit: Use when prompt governance is the main risk, especially for policy-sensitive prompt design.
  Keywords: prompt-governance, safety, inclusivity, auditability, policy-alignment, risk-mitigation
  Repo: [ATT-DP11/apm0047153-archetypes-04-data-governance-quality-responsible-prompting](https://github.com/ATT-DP11/apm0047153-archetypes-04-data-governance-quality-responsible-prompting.git)

- **security-guardian / Security Guardian**
  Does: Provides cross-cutting security guardrails and SDLC verification requirements across archetypes.
  Best fit: Use when the task needs broad security review or security policy enforcement rather than a domain-specific implementation.
  Keywords: security-guardrails, SDLC, verification, cross-cutting, security-review, policy-enforcement
  Repo: [ATT-DP11/apm0047153-archetypes-security-guardian](https://github.com/ATT-DP11/apm0047153-archetypes-security-guardian.git)

- **sox-compliance-documentation / SOX Compliance**
  Does: Validates changes against SOX rules in development and release modes, including traceability and release checks.
  Best fit: Use when the main output is SOX validation or audit readiness evidence.
  Keywords: SOX, compliance, validation, traceability, release-checks, audit-readiness, development-mode, release-mode
  Repo: [ATT-DP11/apm0047153-archetypes-04-data-governance-quality-sox-compliance-documentation](https://github.com/ATT-DP11/apm0047153-archetypes-04-data-governance-quality-sox-compliance-documentation)

## Infrastructure, DevOps, And Platform Operations

- **aks-devops-deployment / AKS DevOps Deployment**
  Does: Builds compliant CI or CD pipelines, Helm charts, and AKS deployment assets for multi-framework microservices.
  Best fit: Use when deploying services onto AKS with enterprise DevOps controls.
  Keywords: AKS, Kubernetes, CI-CD, Helm, microservices, enterprise-DevOps, deployment-pipelines
  Repo: [ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-aks-devops-deployment](https://github.com/ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-aks-devops-deployment.git)

- **automation-scripter / Automation Scripter**
  Does: Produces scripts and automation workflows under governance and operational rules.
  Best fit: Use when the main deliverable is scripting or operational automation.
  Keywords: bash, PowerShell, automation, scripting, governance, operational-rules, idempotency, retry-logic
  Repo: [ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-automation-scripter](https://github.com/ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-automation-scripter.git)

- **camunda-workflow / Camunda Orchestration**
  Does: Designs Camunda 7 BPMN, DMN, Camel routes, external task patterns, and related Spring Boot orchestration setups.
  Best fit: Use when workflow orchestration is explicitly Camunda-centric.
  Keywords: Camunda-7, BPMN, DMN, Camel, Spring-Boot, external-tasks, workflow-orchestration
  Repo: [ATT-DP11/apm0047153-archetypes-05-infrastructure-camunda-workflow](https://github.com/ATT-DP11/apm0047153-archetypes-05-infrastructure-camunda-workflow)

- **container-hardening-specialist / Container Hardening Specialist**
  Does: Applies defense-in-depth hardening for containers, including privilege separation, rootfs lockdown, seccomp, and capability dropping.
  Best fit: Use when a container already exists but needs stronger runtime security posture.
  Keywords: container-hardening, privilege-separation, rootfs-lockdown, seccomp, capability-dropping, CIS-compliance, defense-in-depth
  Repo: [ATT-DP11/apm0047153-archetypes-container-hardening-specialist](https://github.com/ATT-DP11/apm0047153-archetypes-container-hardening-specialist.git)

- **container-solution-architect / Container Solution Architect**
  Does: Designs containerized solutions with multi-stage builds, process supervision, secure credential handling, and runtime controls.
  Best fit: Use when containerization itself is the main architecture problem.
  Keywords: containerization, multi-stage-builds, process-supervision, credential-handling, runtime-controls, Containerfile
  Repo: [ATT-DP11/apm0047153-archetypes-container-solution-architect](https://github.com/ATT-DP11/apm0047153-archetypes-container-solution-architect)

- **dev-ops-engineer / Dev Ops Engineer**
  Does: Establishes operational excellence patterns for deploying and sustaining scalable, observable, and compliant workflows.
  Best fit: Use when the problem spans platform operations broadly rather than one deployment technology.
  Keywords: operational-excellence, scalability, observability, compliance, platform-operations, deployment-patterns
  Repo: [ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-dev-ops-engineer](https://github.com/ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-dev-ops-engineer.git)

- **enterprise-microservice / Enterprise Microservice**
  Does: Provides a universal enterprise microservice pattern for Java or Python backends with cloud-native deployment concerns.
  Best fit: Use when building a production backend service and you need a language-agnostic enterprise baseline.
  Depends on: `backend-only`
  Keywords: microservice, Java, Spring-Boot, Python, FastAPI, cloud-native, enterprise-pattern, multi-stack
  Repo: [ATT-DP11/apm0047153-archetypes-05-infrastructure-enterprise-microservice](https://github.com/ATT-DP11/apm0047153-archetypes-05-infrastructure-enterprise-microservice)

- **key-vault-config-steward / Key Vault Config Steward**
  Does: Builds configuration layers that source secrets from Azure Key Vault with observability and typed fallbacks.
  Best fit: Use when secret-backed configuration management is the main requirement.
  Keywords: Azure-Key-Vault, secrets-management, configuration, observability, typed-fallbacks, secret-handling
  Repo: [ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-key-vault-config-steward](https://github.com/ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-key-vault-config-steward.git)

- **microservice-cicd-architect / Microservice CI/CD Architect**
  Does: Defines guardrails for CI or CD pipelines, automation, and runbooks around microservices.
  Best fit: Use when the problem is pipeline architecture for microservices rather than application code.
  Keywords: CI-CD, pipeline-architecture, microservices, automation, runbooks, progressive-delivery, security-scanning
  Repo: [ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-microservice-cicd-architect](https://github.com/ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-microservice-cicd-architect.git)

- **observability / Observability**
  Does: Builds a full OpenTelemetry-based observability layer across React and FastAPI services.
  Best fit: Use when logs, traces, metrics, and profiling are the core deliverable.
  Keywords: OpenTelemetry, observability, logs, traces, metrics, profiling, React, FastAPI, telemetry
  Repo: [ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-observability](https://github.com/ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-observability.git)

- **performance-tuner / Performance Tuner**
  Does: Profiles bottlenecks and tunes systems for better performance.
  Best fit: Use when the system exists but is too slow, resource heavy, or poorly tuned.
  Keywords: performance-optimization, profiling, bottleneck-analysis, tuning, performance-testing
  Repo: [ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-performance-tuner](https://github.com/ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-performance-tuner.git)

- **terraform-cicd-architect / Terraform CI/CD Architect**
  Does: Governs infrastructure-as-code delivery for Terraform modules with auditable, resilient deployment practices.
  Best fit: Use when Terraform delivery pipelines, policy controls, or IaC release patterns are the main concern.
  Keywords: Terraform, IaC, infrastructure-as-code, CI-CD, policy-controls, drift-detection, audit-controls
  Repo: [ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-terraform-cicd-architect](https://github.com/ATT-DP11/apm0047153-archetypes-05-infrastructure-devops-terraform-cicd-architect.git)

## Connectors And Integration Components

- **cassandra-connector / Cassandra Connector**
  Does: Standardizes secure and performant Spring Boot connectivity to Apache Cassandra using the DataStax driver.
  Best fit: Use when the problem is Cassandra connectivity, driver migration, or connection configuration.
  Keywords: Cassandra, Spring-Boot, DataStax-driver, connectivity, SSL, pooling, performance
  Repo: [ATT-DP11/apm0047153-cassandra-connector](https://github.com/ATT-DP11/apm0047153-cassandra-connector)

- **cosmosdb-connector / Cosmos DB Connector**
  Does: Builds production-ready Azure Cosmos DB connectors and client libraries for Spring Boot applications.
  Best fit: Use when integrating Java or Spring Boot services with Cosmos DB.
  Keywords: Cosmos-DB, Azure, Spring-Boot, Java, connector, client-library, production-ready
  Repo: [ATT-DP11/apm0047153-cosmosdb-connector](https://github.com/ATT-DP11/apm0047153-cosmosdb-connector)

## Machine Learning Models And MLOps

- **clustering-ml-models / Clustering ML Models**
  Does: Governs unsupervised clustering on Databricks with reproducibility, feature discipline, and transparent interpretation.
  Best fit: Use for general clustering work when a specific clustering algorithm archetype is not already chosen.
  Keywords: clustering, unsupervised-learning, Databricks, MLflow, reproducibility, feature-discipline, interpretation
  Repo: [ATT-DP11/apm0047153-archetypes-01-machine-learning-models-clustering-ml-models](https://github.com/ATT-DP11/apm0047153-archetypes-01-machine-learning-models-clustering-ml-models.git)

- **collaborative-filtering-model / Collaborative Filtering Model**
  Does: Governs recommender-system design, experimentation, and deployment using collaborative filtering.
  Best fit: Use when building recommendation systems or personalization features.
  Keywords: collaborative-filtering, recommender-systems, personalization, experimentation, deployment
  Repo: [ATT-DP11/apm0047153-archetypes-01-machine-learning-models-collaborative-filtering-model](https://github.com/ATT-DP11/apm0047153-archetypes-01-machine-learning-models-collaborative-filtering-model.git)

- **dbscan-model / DBSCAN Model**
  Does: Governs DBSCAN clustering workflows.
  Best fit: Use when density-based clustering is specifically required.
  Keywords: DBSCAN, density-based-clustering, unsupervised-learning, anomaly-detection
  Repo: [ATT-DP11/apm0047153-archetypes-01-machine-learning-models-dbscan-model](https://github.com/ATT-DP11/apm0047153-archetypes-01-machine-learning-models-dbscan-model.git)

- **experiment-scientist / Experiment Scientist**
  Does: Enforces rigorous experimentation, statistical validation, and promotion readiness for ML models.
  Best fit: Use when experiment design, validation rigor, or promotion decisions are central.
  Keywords: experimentation, statistical-validation, A-B-testing, promotion-readiness, ML-governance
  Repo: [ATT-DP11/apm0047153-archetypes-02-ml-operations-lifecycle-experiment-scientist](https://github.com/ATT-DP11/apm0047153-archetypes-02-ml-operations-lifecycle-experiment-scientist.git)

- **feature-architect / Feature Architect**
  Does: Designs reusable feature pipelines and feature-store patterns for governed ML usage.
  Best fit: Use when the main problem is feature engineering architecture or feature-store design.
  Keywords: feature-engineering, feature-pipelines, feature-store, governed-ML, reusability, point-in-time-correctness
  Repo: [ATT-DP11/apm0047153-archetypes-02-ml-operations-lifecycle-feature-architect](https://github.com/ATT-DP11/apm0047153-archetypes-02-ml-operations-lifecycle-feature-architect.git)

- **forecasting-analyst / Forecasting Analyst**
  Does: Governs time-series forecasting with backtesting, calibrated uncertainty, and controlled deployment.
  Best fit: Use when the core task is forecasting temporal behavior.
  Keywords: time-series, forecasting, backtesting, uncertainty-calibration, temporal-analysis
  Repo: [ATT-DP11/apm0047153-archetypes-01-machine-learning-models-forecasting-analyst](https://github.com/ATT-DP11/apm0047153-archetypes-01-machine-learning-models-forecasting-analyst.git)

- **gradient-boosted-trees / Gradient Boosted Trees**
  Does: Governs design, tuning, and deployment of gradient boosting models in regulated enterprise analytics.
  Best fit: Use for XGBoost or LightGBM style supervised modeling tasks.
  Keywords: gradient-boosting, XGBoost, LightGBM, supervised-learning, tree-ensembles, regulated-analytics
  Repo: [ATT-DP11/apm0047153-archetypes-01-machine-learning-models-gradient-boosted-trees](https://github.com/ATT-DP11/apm0047153-archetypes-01-machine-learning-models-gradient-boosted-trees.git)

- **inference-orchestrator / Inference Orchestrator**
  Does: Governs safe and observable deployment of MLflow-registered models to AKS and related serving targets for real-time and batch inference.
  Best fit: Use when the challenge is inference deployment and serving patterns rather than training.
  Keywords: inference, deployment, MLflow, AKS, real-time, batch-inference, model-serving, observability
  Repo: [ATT-DP11/apm0047153-archetypes-02-ml-operations-lifecycle-inference-orchestrator](https://github.com/ATT-DP11/apm0047153-archetypes-02-ml-operations-lifecycle-inference-orchestrator.git)

- **insight-reporter / Insight Reporter**
  Does: Produces stakeholder-facing performance narratives, visualizations, and KPI-centered reporting for models.
  Best fit: Use when model results need business-friendly interpretation and reporting.
  Keywords: performance-reporting, stakeholder-communication, KPI, visualization, business-intelligence, narrative
  Repo: [ATT-DP11/apm0047153-archetypes-07-graph-analytics-insight-reporter](https://github.com/ATT-DP11/apm0047153-archetypes-07-graph-analytics-insight-reporter.git)

- **interpretability-analyst / Interpretability Analyst**
  Does: Produces explanations and responsible AI artifacts that meet regulatory or stakeholder expectations.
  Best fit: Use when explainability, disclosure, or trust artifacts are the main deliverable.
  Keywords: explainability, responsible-AI, transparency, regulatory-compliance, trust-artifacts, SHAP, LIME
  Repo: [ATT-DP11/apm0047153-archetypes-02-ml-operations-lifecycle-interpretability-analyst](https://github.com/ATT-DP11/apm0047153-archetypes-02-ml-operations-lifecycle-interpretability-analyst.git)

- **isolation-forest-model / Isolation Forest Model**
  Does: Governs anomaly detection using isolation forest techniques.
  Best fit: Use when the problem is anomaly detection in tabular or telemetry-style data.
  Keywords: isolation-forest, anomaly-detection, unsupervised-learning, telemetry, tabular-data
  Repo: [ATT-DP11/apm0047153-archetypes-01-machine-learning-models-isolation-forest-model](https://github.com/ATT-DP11/apm0047153-archetypes-01-machine-learning-models-isolation-forest-model.git)

- **language-model-evaluation / Language Model Evaluation**
  Does: Establishes disciplined LLM evaluation with grader frameworks, async orchestration, and specification-driven assessment.
  Best fit: Use for LLM evaluation workflows outside the narrower agent-eval archetypes.
  Keywords: LLM-evaluation, grader-frameworks, async-orchestration, specification-driven, assessment
  Repo: [ATT-DP11/apm0047153-archetypes-language-model-evaluation](https://github.com/ATT-DP11/apm0047153-archetypes-language-model-evaluation)

- **logistic-regression-specialist / Logistic Regression Specialist**
  Does: Governs logistic regression modeling with calibrated outputs and observability.
  Best fit: Use when interpretable binary or multiclass supervised modeling with logistic regression is preferred.
  Keywords: logistic-regression, supervised-learning, calibration, observability, interpretable-model, binary-classification, multiclass
  Repo: [ATT-DP11/apm0047153-archetypes-01-machine-learning-models-logistic-regression-specialist](https://github.com/ATT-DP11/apm0047153-archetypes-01-machine-learning-models-logistic-regression-specialist.git)

- **model-architect / Model Architect**
  Does: Establishes disciplined model development with reproducible training pipelines and MLflow registration.
  Best fit: Use when the need is general model architecture and training pipeline design.
  Keywords: model-architecture, training-pipelines, MLflow, reproducibility, CI-integration, model-development
  Repo: [ATT-DP11/apm0047153-archetypes-02-ml-operations-lifecycle-model-architect](https://github.com/ATT-DP11/apm0047153-archetypes-02-ml-operations-lifecycle-model-architect.git)

- **model-ops-steward / Model Ops Steward**
  Does: Governs post-deployment model monitoring, incident handling, and lifecycle compliance.
  Best fit: Use when operational stewardship of deployed models is the core need.
  Keywords: model-operations, monitoring, incident-handling, lifecycle-compliance, telemetry, drift-detection
  Repo: [ATT-DP11/apm0047153-archetypes-02-ml-operations-lifecycle-model-ops-steward](https://github.com/ATT-DP11/apm0047153-archetypes-02-ml-operations-lifecycle-model-ops-steward.git)

- **neural-network-model / Neural Network Model**
  Does: Governs deep learning system design, training, evaluation, and deployment.
  Best fit: Use when general neural network development is required but no more specific deep-learning archetype applies.
  Keywords: neural-networks, deep-learning, training, evaluation, deployment, TensorFlow, PyTorch
  Repo: [ATT-DP11/apm0047153-archetypes-01-machine-learning-models-neural-network-model](https://github.com/ATT-DP11/apm0047153-archetypes-01-machine-learning-models-neural-network-model.git)

- **q-learning-model / Q Learning Model**
  Does: Governs reinforcement learning workflows centered on Q-learning.
  Best fit: Use when the problem is reinforcement learning rather than supervised or unsupervised learning.
  Keywords: reinforcement-learning, Q-learning, RL, workflows, supervised-learning, unsupervised-learning
  Repo: [ATT-DP11/apm0047153-archetypes-01-machine-learning-models-q-learning-model](https://github.com/ATT-DP11/apm0047153-archetypes-01-machine-learning-models-q-learning-model.git)

- **random-forest-model / Random Forest Model**
  Does: Governs reproducible and observable random forest model development.
  Best fit: Use when a tree-ensemble baseline or production random forest workflow is needed.
  Keywords: random-forest, tree-ensemble, supervised-learning, baseline-model, reproducible, observable
  Repo: [ATT-DP11/apm0047153-archetypes-01-machine-learning-models-random-forest-model](https://github.com/ATT-DP11/apm0047153-archetypes-01-machine-learning-models-random-forest-model.git)

- **siamese-neural-network / Siamese Neural Network**
  Does: Governs metric-learning models for similarity search, deduplication, and verification.
  Best fit: Use when the product depends on embeddings, similarity scoring, or pairwise verification.
  Keywords: siamese-networks, metric-learning, similarity-search, deduplication, verification, embeddings
  Repo: [ATT-DP11/apm0047153-archetypes-01-machine-learning-models-siamese-neural-network](https://github.com/ATT-DP11/apm0047153-archetypes-01-machine-learning-models-siamese-neural-network.git)

## Graph And Knowledge Graph Archetypes

- **general-graph-ontology / General Graph Ontology**
  Does: Provides baseline ontology scaffolding for graph-oriented solutions.
  Best fit: Use when a graph project needs shared ontology foundations before schema or graph application logic is built.
  Keywords: ontology, scaffolding, graph-foundations, schema, shared-ontology, graph-orientation
  Repo: [ATT-DP11/apm0047153-archetypes-06-application-development-general-graph-ontology](https://github.com/ATT-DP11/apm0047153-archetypes-06-application-development-general-graph-ontology.git)

- **graph-community-detection / Graph Community Detection**
  Does: Designs and operationalizes community detection solutions across graph analytics workflows.
  Best fit: Use when the graph problem is specifically clustering or community discovery.
  Keywords: community-detection, clustering, graph-analytics, workflows, scale-fitness, operational-readiness
  Repo: [ATT-DP11/apm0047153-archetypes-07-graph-analytics-graph-community-detection](https://github.com/ATT-DP11/apm0047153-archetypes-07-graph-analytics-graph-community-detection.git)

- **graph-data-scientist / Graph Data Scientist**
  Does: Applies graph algorithms and graph ML to knowledge graphs, including centrality, embeddings, pathfinding, and link prediction.
  Best fit: Use when the goal is advanced graph analytics over an existing graph dataset.
  Depends on: `graph-community-detection`, `knowledge-graph-builder`
  Keywords: graph-algorithms, graph-ML, centrality, embeddings, pathfinding, link-prediction, knowledge-graphs
  Repo: [ATT-DP11/apm0047153-archetypes-graph-data-scientist](https://github.com/ATT-DP11/apm0047153-archetypes-graph-data-scientist.git)

- **graph-pattern-detective / Graph Pattern Detective**
  Does: Detects patterns, anomalies, fraud signals, and dependency or vulnerability paths in knowledge graphs.
  Best fit: Use when the graph workload is pattern detection, tracing, or anomaly analysis.
  Depends on: `graph-data-scientist`, `knowledge-graph-builder`
  Keywords: pattern-detection, anomaly-analysis, fraud-detection, dependency-tracing, vulnerability-paths, knowledge-graphs
  Repo: [ATT-DP11/apm0047153-archetypes-graph-pattern-detective](https://github.com/ATT-DP11/apm0047153-archetypes-graph-pattern-detective.git)

- **identity-graph-specialist / Identity Graph Specialist**
  Does: Builds identity and metadata graphs for entity resolution, MDM, lineage, and confidence scoring.
  Best fit: Use when the graph problem is identity resolution or metadata unification.
  Depends on: `data-security`, `knowledge-graph-builder`
  Keywords: identity-graph, metadata-graph, entity-resolution, MDM, lineage, confidence-scoring
  Repo: [ATT-DP11/apm0047153-archetypes-identity-graph-specialist](https://github.com/ATT-DP11/apm0047153-archetypes-identity-graph-specialist.git)

- **knowledge-graph-builder / Knowledge Graph Builder**
  Does: Designs and builds knowledge graphs using property graph and RDF paradigms, including schema design and query patterns.
  Best fit: Use when the core problem is standing up a knowledge graph or graph data model.
  Depends on: `general-graph-ontology`, `ontology-engineer`
  Keywords: knowledge-graph, property-graph, RDF, schema-design, query-patterns, graph-data-model
  Repo: [ATT-DP11/apm0047153-archetypes-knowledge-graph-builder](https://github.com/ATT-DP11/apm0047153-archetypes-knowledge-graph-builder.git)

- **knowledge-graph-nlp-engineer / Knowledge Graph NLP Engineer**
  Does: Bridges NLP and knowledge graphs through NER, text-to-graph pipelines, semantic search, and graph querying from language.
  Best fit: Use when unstructured text must be turned into graph assets or queried through NLP.
  Depends on: `general-graph-ontology`, `knowledge-graph-builder`
  Keywords: NLP, knowledge-graphs, NER, text-to-graph, semantic-search, graph-querying, unstructured-text
  Repo: [ATT-DP11/apm0047153-archetypes-knowledge-graph-nlp-engineer](https://github.com/ATT-DP11/apm0047153-archetypes-knowledge-graph-nlp-engineer.git)

- **ontology-engineer / Ontology Engineer**
  Does: Generates RelationalAI ontologies from Snowflake tables with rules, types, and deployment scripts.
  Best fit: Use when the main deliverable is ontology generation from relational data.
  Keywords: RelationalAI, ontology, Snowflake, rules, types, deployment-scripts, relational-data
  Repo: [ATT-DP11/apm0047153-archetypes-06-application-development-ontology-engineer](https://github.com/ATT-DP11/apm0047153-archetypes-06-application-development-ontology-engineer.git)

## Software Quality, Upgrades, And Testing

- **data-eng-code-reviewer / Code Reviewer Archetype**
  Does: Performs AI-assisted peer review, security review, and architectural compliance checks for data engineering assets such as Snowflake SQL, Python, TWS, and Databricks code.
  Best fit: Use when a code review or quality gate is the primary task, especially in data engineering contexts.
  Keywords: code-review, AI-assisted, peer-review, security-review, architectural-compliance, Snowflake, Python, TWS, Databricks
  Repo: [ATT-DP11/apm0047153-archetypes-code-reviewer](https://github.com/ATT-DP11/apm0047153-archetypes-code-reviewer)

- **git-secret-remediation / Git Secret Remediation**
  Does: Removes exposed secrets from git history, resolves GitHub security alerts, and prevents future secret leaks.
  Best fit: Use when the main incident is a credential or secret exposure in git history.
  Keywords: git-secrets, secret-remediation, GitHub-security-alerts, credential-exposure, git-history, BFG-Repo-Cleaner
  Repo: [ATT-DP11/apm0047153-archetypes-git-secret-remediation](https://github.com/ATT-DP11/apm0047153-archetypes-git-secret-remediation)

- **idp-seed-upgrade / IDP Seed Upgrade**
  Does: Governs upgrades of IDP Java seed parent artifacts with compatibility and security considerations.
  Best fit: Use when updating `sdk-java-parent` or `sdk-java-library-parent` based services.
  Keywords: IDP, Java, seed-upgrade, sdk-java-parent, sdk-java-library-parent, compatibility, security, migration
  Repo: [ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-idp-seed-upgrade](https://github.com/ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-idp-seed-upgrade)

- **java-library-upgrade / Java Library Upgrade**
  Does: Detects and upgrades outdated Java dependencies while preserving compatibility.
  Best fit: Use when the task is dependency modernization in a Java codebase.
  Keywords: Java, dependencies, upgrade, modernization, compatibility, Maven, Gradle, dependency-check
  Repo: [ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-java-library-upgrade](https://github.com/ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-java-library-upgrade.git)

- **java-security-vulnerability / Java Security Vulnerability**
  Does: Identifies and remediates security vulnerabilities in Java code and dependencies.
  Best fit: Use when the main objective is Java security remediation.
  Keywords: Java, security, vulnerability, remediation, OWASP, CVE, dependency-check, security-scan
  Repo: [ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-java-security-vulnerability](https://github.com/ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-java-security-vulnerability.git)

- **pub-sub-load-testing / Pub Sub Load Testing**
  Does: Designs and analyzes load tests for Pub/Sub systems under expected and peak traffic.
  Best fit: Use when throughput, latency, and message-loss behavior must be validated for event systems.
  Keywords: load-testing, Pub-Sub, throughput, latency, message-loss, event-systems, performance-testing
  Repo: [ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-pub-sub-load-testing](https://github.com/ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-pub-sub-load-testing.git)

- **pull-review-risk / Pull Review Risk**
  Does: Reviews pull requests for production risk, security issues, and reliability concerns.
  Best fit: Use when the main question is whether a PR is safe to merge.
  Keywords: pull-request, risk-analysis, production-risk, security-review, reliability, merge-safety
  Repo: [ATT-DP11/apm0047153-archetypes-pull-review-risk](https://github.com/ATT-DP11/apm0047153-archetypes-pull-review-risk)

- **python-library-upgrade / Python Library Upgrade**
  Does: Updates Python dependencies while maintaining compatibility and project health.
  Best fit: Use when the primary task is dependency upgrades in a Python project.
  Keywords: Python, dependencies, upgrade, pip, requirements.txt, compatibility, project-health, poetry
  Repo: [ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-python-library-upgrade](https://github.com/ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-python-library-upgrade.git)

- **python-security-vulnerability / Python Security Vulnerability**
  Does: Identifies and remediates security vulnerabilities in Python code and dependencies.
  Best fit: Use when the primary objective is Python security remediation.
  Keywords: Python, security, vulnerability, remediation, bandit, safety, dependency-check, CVE
  Repo: [ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-python-security-vulnerability](https://github.com/ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-python-security-vulnerability.git)

- **regression-test-coverage / Regression Test Coverage**
  Does: Automates regression test creation, execution, and verification after code changes.
  Best fit: Use when protecting previously working behavior is the main quality concern.
  Keywords: regression-testing, test-automation, test-creation, test-execution, verification, code-changes
  Repo: [ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-regression-test-coverage](https://github.com/ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-regression-test-coverage.git)

- **unit-test-code-coverage / Unit Test Code Coverage**
  Does: Drives creation and validation of meaningful unit tests to maximize Java code coverage.
  Best fit: Use when improving or enforcing unit-test coverage is the main task.
  Keywords: unit-testing, code-coverage, Java, JUnit, JaCoCo, test-creation, test-validation, meaningful-tests
  Repo: [ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-unit-test-code-coverage](https://github.com/ATT-DP11/apm0047153-archetypes-08-software-quality-maintenance-unit-test-code-coverage.git)

## Documentation, Requirements, And Communication

- **demo-producer / Demo Producer**
  Does: Automates polished product demo generation using Playwright, animation patterns, and reusable components.
  Best fit: Use when the deliverable is a demo experience rather than application logic.
  Keywords: Playwright, demo-generation, animation, video-capture, reusable-components, product-demo
  Repo: [ATT-DP11/apm0047153-archetypes-demo-producer](https://github.com/ATT-DP11/apm0047153-archetypes-demo-producer)

- **documentation-evangelist / Documentation Evangelist**
  Does: Produces and reviews rich documentation including Mermaid, images, HTML, tables, CSV, and code blocks.
  Best fit: Use when the primary output is high-quality documentation or documentation review.
  Keywords: documentation, Mermaid, images, HTML, tables, CSV, code-blocks, rich-content
  Repo: [ATT-DP11/apm0047153-archetypes-09-documentation-requirements-documentation-evangelist](https://github.com/ATT-DP11/apm0047153-archetypes-09-documentation-requirements-documentation-evangelist.git)

- **jira-user-stories / Jira User Stories**
  Does: Creates governed Jira user stories, acceptance criteria, and backlog-ready requirements artifacts.
  Best fit: Use when the main output is user stories or backlog content.
  Keywords: Jira, user-stories, acceptance-criteria, backlog, requirements-artifacts, governed
  Repo: [ATT-DP11/apm0047153-archetypes-09-documentation-requirements-jira-user-stories](https://github.com/ATT-DP11/apm0047153-archetypes-09-documentation-requirements-jira-user-stories.git)

- **ppt-maker / PPT Maker**
  Does: Generates AT&T-branded PowerPoint decks from structured specifications.
  Best fit: Use when the final deliverable is a presentation deck.
  Keywords: PowerPoint, AT&T-brand, presentation-deck, structured-specifications, slide-generation
  Repo: [ATT-DP11/apm0047153-archetypes-09-documentation-requirements-ppt-maker](https://github.com/ATT-DP11/apm0047153-archetypes-09-documentation-requirements-ppt-maker.git)

- **software-release-notes / Software Release Notes**
  Does: Generates release notes from Jira stories and sprint data with traceability and business relevance.
  Best fit: Use when the main need is release communication rather than engineering changes.
  Keywords: release-notes, Jira, sprint-data, traceability, business-relevance, release-communication
  Repo: [ATT-DP11/apm0047153-archetypes-09-documentation-requirements-software-release-notes](https://github.com/ATT-DP11/apm0047153-archetypes-09-documentation-requirements-software-release-notes.git)

- **solution-design / Solution Intent**
  Does: Generates solution intent documentation with impact analysis, interface mapping, context diagrams, and dependency evidence.
  Best fit: Use when the output is a solution intent or high-level solution design artifact.
  Keywords: solution-intent, impact-analysis, interface-mapping, context-diagrams, dependency-evidence, solution-design
  Repo: [ATT-DP11/apm0047153-archetypes-09-documentation-requirements-solution-design](https://github.com/ATT-DP11/apm0047153-archetypes-09-documentation-requirements-solution-design.git)

## Submodules Referenced In .gitmodules But Not Available Locally

- **code-reviewer**
  Status: Referenced in `.gitmodules` but not checked out as a standalone folder in this workspace. The local `data-eng-code-reviewer` folder points to the same source repository.
  Repo: [ATT-DP11/apm0047153-archetypes-code-reviewer](https://github.com/ATT-DP11/apm0047153-archetypes-code-reviewer)

- **requirements-impact-analyst**
  Status: Referenced in `.gitmodules` but no local folder was present under `archetypes-aggregation`, so no local manifest was available to summarize.
  Repo: [ATT-DP11/apm0047153-archetypes-09-documentation-requirements-impact-analyst](https://github.com/ATT-DP11/apm0047153-archetypes-09-documentation-requirements-impact-analyst.git)

- **technical-design**
  Status: Referenced in `.gitmodules` but no local folder was present under `archetypes-aggregation`, so no local manifest was available to summarize.
  Repo: [ATT-DP11/apm0047153-archetypes-09-documentation-requirements-technical-design](https://github.com/ATT-DP11/apm0047153-archetypes-09-documentation-requirements-technical-design.git)

## Notes

- Summaries were derived primarily from each archetype's local `manifest.yaml` and, where needed, an archetype `README.md` to clarify vague descriptions.
- Repo links were taken from the local `.gitmodules` file.
- If an agent needs exact workflow entry points, constitutions, or template layouts, it should follow the repo link and retrieve the source instructions directly.
