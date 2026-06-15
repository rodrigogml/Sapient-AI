---
name: dev-pipeline-5-planning-plan
description: Use after an SDD feature spec is clear when the user wants the technical HOW: architecture, technical decisions, data model, interface contracts, research, project structure, and validation scenarios. Skip when defining WHAT/for whom; use specify or clarify instead. Skip when decomposing implementation work; use create-tasks later.
metadata:
  short-description: Create technical implementation plans
---

# Dev Pipeline - 5. Planning - Plan

## Overview

Gere um plano técnico de implementação a partir de uma feature spec, cobrindo arquitetura, decisões técnicas, modelo de dados, contratos, pesquisa, estrutura do projeto e cenários de validação.

## Pré-requisitos

**Obrigatório**: `docs/specs/{feature-short-name}/spec.md` já existente e suficientemente claro.

**Recomendado**: `Dev Pipeline - 4. Specification - Clarify` executado quando a spec ainda possui `[NEEDS CLARIFICATION]`; `docs/constitution.md` existente para validar decisões contra princípios de governança.

## When To Use

Use quando o usuário quiser transformar uma spec em plano técnico, definir arquitetura, contratos, modelo de dados, estrutura de projeto, dependências, pesquisa técnica ou cenários de teste/quickstart.

Não use para criar a spec funcional, clarificar requisitos, quebrar o plano em tarefas ou implementar código.

## Output Contract

O resultado principal é `docs/specs/{feature-short-name}/plan.md`.

A skill também pode gerar `research.md`, `data-model.md`, `quickstart.md` e arquivos em `contracts/`, conforme a feature exigir. Nenhum código de produção deve ser implementado nesta etapa.

## Workflow

1. **Contexto**: carregar spec, constitution e artefatos do projeto.
2. **Constitution Check**: validar princípios antes de prosseguir.
3. **Technical Context**: preencher stack, dependências e constraints.
4. **Phase 0 - Research**: resolver unknowns e decisões técnicas.
5. **Phase 1 - Design**: gerar modelo de dados, contratos e quickstart.
6. **Plan Document**: consolidar `plan.md`.
7. **Re-check**: revalidar constitution após design.
8. **Salvamento**: salvar artefatos e reportar próximos passos.

## Próximos Passos

1. `Dev Pipeline - 6. Planning - Checklist` — gerar quality gate antes de implementar.
2. `Dev Pipeline - 7. Implementation - Create Tasks` — decompor o plano em backlog executável.
3. `Dev Pipeline - 8. Implementation - Analyze` — após ter tasks, validar consistência entre spec, plan e tasks.


## ETAPA 1: CONTEXTO

### 1.1 Localizar Spec

Use o pedido do usuário para encontrar a spec:

1. **Caminho direto**: usar como fornecido.
2. **Nome da feature**: buscar `docs/specs/{feature-short-name}/spec.md`.
3. **Glob**: listar `docs/specs/*/spec.md` e pedir ao usuário para escolher.

Se a spec não for encontrada, instrua o usuário a executar `Dev Pipeline - 3. Specification - Specify` primeiro.

### 1.2 Carregar Documentos

```text
OBRIGATÓRIO:
-- Feature spec (spec.md)

OPCIONAL (se existirem):
-- docs/constitution.md (princípios de governança)
-- AGENTS.md (convenções do projeto)
-- README.md (contexto geral)
-- docs/specs/{feature-short-name}/research.md (pesquisa prévia, se rerun)
```

### 1.3 Extrair da Spec

- User stories com prioridades.
- Functional requirements.
- Key entities.
- Success criteria.
- Edge cases.
- `[NEEDS CLARIFICATION]` pendentes, que devem ser resolvidos antes ou durante Phase 0.

## ETAPA 2: CONSTITUTION CHECK

### 2.1 Gate Obrigatório

Se `docs/constitution.md` existe:

1. Carregar todos os princípios MUST/SHOULD.
2. Para cada princípio, verificar se a feature spec está em conformidade.
3. Documentar resultado:

```markdown
## Constitution Check

*GATE: Deve passar antes do Phase 0. Rechecar após Phase 1.*

| Princípio | Status | Notas |
|-----------|--------|-------|
| [Nome] | PASS / FAIL / N/A | [Detalhes] |
```

4. Se FAIL em princípio MUST: **ERROR**; não prosseguir até resolver.

Se constitution não existe: pular esta etapa e documentar "No constitution found".

## ETAPA 3: TECHNICAL CONTEXT

### 3.1 Preencher Contexto

Ver seção **Technical Context** em `templates/plan.md` (subdiretório `templates/` desta skill). Preencher cada campo detectando do projeto e da spec; marcar unknowns como `NEEDS CLARIFICATION` apenas após tentar inferir do codebase.

### 3.2 Inferência

Antes de marcar `NEEDS CLARIFICATION`, tentar inferir de:

- `pom.xml`, `go.mod`, `package.json`, `pyproject.toml`, `Cargo.toml`: linguagem e dependências.
- `Dockerfile`, `docker-compose.yml`, manifests K8s: platform.
- `AGENTS.md`: convenções e stack.
- Patterns existentes no projeto: testing, storage.

## ETAPA 4: PHASE 0 - RESEARCH

### 4.1 Resolver Unknowns

Para cada `NEEDS CLARIFICATION` no Technical Context:

- Pesquisar no projeto por evidências.
- Se não resolvível: criar decisão de pesquisa em `research.md` e, se necessário, perguntar ao usuário.

Para cada dependência/tecnologia:

- Verificar best practices para o contexto.

### 4.2 Consolidar em `research.md`

Use `templates/research.md` como base. Uma seção `## Decision N` por unknown resolvido, com **Decision / Rationale / Alternatives considered**.

**Output**: `docs/specs/{feature-short-name}/research.md` com todos os `NEEDS CLARIFICATION` resolvidos ou explicitamente encaminhados.

## ETAPA 5: PHASE 1 - DESIGN

**Pré-requisito**: `research.md` completo ou unknowns críticos resolvidos.

### 5.1 Modelo de Dados

Base: `templates/data-model.md`. Extrair entidades da spec, uma seção `## Entity: Name` por entidade, com tabela de campos, relacionamentos e state transitions.

**Output**: `docs/specs/{feature-short-name}/data-model.md`

### 5.2 Contratos de Interface

Se o projeto expõe interfaces externas (APIs, CLI, eventos), use `templates/contracts.md`; um arquivo por grupo de endpoints em `docs/specs/{feature-short-name}/contracts/`.

Pular se projeto é puramente interno (build scripts, one-off tools).

**Output**: `docs/specs/{feature-short-name}/contracts/*.md`

### 5.3 Quickstart / Cenários de Teste

Base: `templates/quickstart.md`. Um cenário por fluxo crítico (happy path + ao menos um error case), no formato "1. Passo -> 2. Passo -> **Expected**: resultado".

**Output**: `docs/specs/{feature-short-name}/quickstart.md`

**Obrigatório para features com borda backend <-> frontend**: incluir cenário "Roundtrip End-to-End" que faz uma chamada real ao backend, captura o payload de resposta e compara o shape contra o contrato declarado.

### 5.4 Convenções de Borda

Quando a feature atravessa fronteiras (backend <-> frontend, DB <-> backend, broker <-> consumer), declarar explicitamente em uma tabela no `plan.md` qual é a fonte da verdade de cada convenção.

Estrutura obrigatória do `plan.md` entre "Project Structure" e "Complexity Tracking":

```markdown
## Convenções de Borda

| Camada | Case style | Validação | Fonte da verdade |
|--------|------------|-----------|------------------|
| DB columns | snake_case | constraint check + migration | `migrations/*.sql` |
| Backend DTO | camelCase | json tags / validation | backend DTOs |
| Frontend DTO | camelCase | schema parse no fetch | frontend/shared types |
| API payload | camelCase | schema nos dois lados | `contracts/*.md` |
| URL query/path params | kebab-case | router | routes |

**Mapper layer (DB <-> DTO)**: localização + responsável.

**Validação de schema**: request, response ou ambos; localização dos schemas compartilhados, se houver.
```

Se a feature é single-layer (ex: biblioteca pura, CLI tool, script), pular essa seção com nota explícita "N/A — single-layer".

**Output**: `docs/specs/{feature-short-name}/plan.md` §Convenções de Borda.

## ETAPA 6: PLAN DOCUMENT

### 6.1 Template do Plano

Consolidar tudo em `templates/plan.md`, preenchido com:

- **Summary** — requisito primário + abordagem técnica da pesquisa.
- **Technical Context** — da Etapa 3, com `NEEDS CLARIFICATION` resolvidos.
- **Constitution Check** — da Etapa 2.
- **Project Structure** — documentação da feature + source code real do projeto.
- **Complexity Tracking** — preencher apenas se houve violações de constitution que precisam justificativa.

**Output**: `docs/specs/{feature-short-name}/plan.md`

## ETAPA 7: RE-CHECK

### 7.1 Revalidar Constitution

Se constitution existe, rechecar princípios após design:

- Design introduziu complexidade não justificada?
- Princípios MUST continuam respeitados?
- Atualizar tabela de Constitution Check se necessário.

## ETAPA 8: SALVAMENTO

### 8.1 Artefatos Gerados

Listar todos os arquivos criados:

```markdown
## Artefatos

| Arquivo | Status |
|---------|--------|
| docs/specs/{feature-short-name}/plan.md | Criado |
| docs/specs/{feature-short-name}/research.md | Criado |
| docs/specs/{feature-short-name}/data-model.md | Criado |
| docs/specs/{feature-short-name}/contracts/*.md | Criado (se aplicável) |
| docs/specs/{feature-short-name}/quickstart.md | Criado |
```

### 8.2 Reportar

```markdown
## Plano Criado

**Feature**: [feature-short-name]
**Diretório**: docs/specs/{feature-short-name}/
**Artefatos**: [N] arquivos gerados
**Constitution**: PASS / N/A
**NEEDS CLARIFICATION restantes**: 0

### Próximos Passos

1. `Dev Pipeline - 6. Planning - Checklist` — Gerar quality gate antes de implementar
2. `Dev Pipeline - 7. Implementation - Create Tasks` — Decompor plano em tarefas executáveis
3. `Dev Pipeline - 8. Implementation - Analyze` — Validar consistência entre spec, plan e tasks após tasks
```

## REGRAS IMPORTANTES

- **Nunca gerar código nesta fase** — apenas documentação técnica.
- **NEEDS CLARIFICATION devem ser resolvidos** no Phase 0; não deixar para implementação.
- **Constitution violations são bloqueantes** — não prosseguir sem resolver.
- **Paths devem ser reais** — verificar existência de diretórios antes de referenciar.
- **Phase 0 vem antes de Phase 1** — não projetar modelo de dados com unknowns pendentes.

## Gotchas

### Nunca gerar código nesta fase

Plano é documentação técnica, não implementação. Se o impulso é escrever uma função ou SQL concreto, pare; isso vai para etapa de execução. O plano descreve contratos, schemas e estrutura, não implementa.

### NEEDS CLARIFICATION devem morrer no Phase 0, não em Phase 1

Projetar modelo de dados ou contratos com unknowns pendentes é retrabalho garantido. Se Phase 0 não resolveu, interromper e voltar ao usuário; não prosseguir para design com lacunas técnicas.

### Violação de constitution em princípio MUST é bloqueante

Não tente "documentar a violação em Complexity Tracking e seguir". MUST não negocia. Se o plano precisa violar um MUST, revisar escopo ou emendar constitution primeiro.

### Paths no Project Structure devem ser reais

Listar diretórios inventados que não existem no projeto cria plano desalinhado com o codebase. Sempre verificar estrutura existente antes de desenhar a árvore no plano.

### Re-check de constitution após Phase 1 não é formalidade

Design pode introduzir complexidade não justificada que viola princípios. O re-check é o gate final; execute com rigor.

### Technical Context com "NEEDS CLARIFICATION" em campo inferível é desleixo

Antes de marcar unknown, tentar inferir de `pom.xml`, `go.mod`, `package.json`, `Dockerfile` ou `AGENTS.md`. Marcar "NEEDS CLARIFICATION: linguagem" em repo com arquivo de build claro é sinal de que Phase 0 não leu o projeto.
