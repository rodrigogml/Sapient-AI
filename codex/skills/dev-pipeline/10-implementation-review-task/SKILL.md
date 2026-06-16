---
name: dev-pipeline-10-implementation-review-task
description: Use when the user wants a read-only backlog progress review, task status report, readiness analysis, dependency review, or recommendation of next tasks to execute. This skill analyzes tasks.md status, detects likely completed-but-unmarked work with evidence, calculates progress, and recommends next tasks. Skip for executing or editing tasks; use execute-task for implementation and backlog updates.
metadata:
  short-description: Review backlog progress
---

# Dev Pipeline - 10. Implementation - Review Task

## Overview

Analise o arquivo de tarefas do projeto e gere um relatório read-only de status, progresso, bloqueios, inconsistências e próximas tarefas recomendadas.

## Pré-requisitos

**Obrigatório**: arquivo de tasks existente em uma localização suportada: `docs/specs/*/tasks.md`, `docs/tasks.md`, `docs/tasks-*.md`, `tasks.md` ou `TODO.md`.

**Recomendado**: spec, plan e documentação relacionada existentes para interpretar dependências, criticidade e cobertura.

## When To Use

Use quando o usuário pedir revisão de tarefas, status do backlog, progresso do projeto, tarefas prontas para iniciar, tarefas bloqueadas ou recomendações de próxima execução.

Não use para executar tarefas, criar backlog, modificar `tasks.md` ou corrigir código. Para execução, use `Dev Pipeline - 9. Implementation - Execute Task`.

## Output Contract

O resultado é um relatório Markdown na conversa. Esta skill é read-only: não cria relatório em arquivo e não edita `tasks.md`, salvo se o usuário pedir explicitamente uma ação de persistência.

O relatório deve conter resumo executivo, métricas, tarefas possivelmente concluídas mas não marcadas, tarefas pendentes prontas, tarefas bloqueadas, progresso por fase e recomendações.

## Workflow

1. **Contexto**: identificar tipo de projeto.
2. **Localização**: encontrar o arquivo de tarefas.
3. **Métricas**: calcular status geral, preferindo `scripts/metrics.sh` quando possível.
4. **Auditoria**: verificar status marcado versus evidência real.
5. **Dependências**: identificar bloqueios e tarefas desbloqueadas.
6. **Priorização**: recomendar próximas tarefas por criticidade, dependência e impacto.
7. **Relatório**: emitir status consolidado na conversa.

## Próximos Passos

1. `Dev Pipeline - 9. Implementation - Execute Task` - iniciar a próxima tarefa recomendada.
2. Resolver dependências apontadas como bloqueadoras.
3. `Dev Pipeline - 8. Implementation - Analyze` - se houver drift entre spec, plan, tasks e implementação.

## ETAPA 1: CONTEXTO

### 1.1 Detectar Tipo de Projeto

| Tipo | Indicadores |
|------|-------------|
| Documentação | `docs/` com `.md`, ausência de `src/`, casos de uso, ADRs |
| Código | `src/`, `app/`, `lib/`, `package.json`, `pom.xml`, `go.mod`, `pyproject.toml` |
| Misto | Documentação e código-fonte |

Use esse contexto para interpretar evidências. Em projeto documental, a existência e completude de arquivos `.md` pode indicar tarefa concluída. Em projeto de código, evidência exige arquivos, build/teste, commits ou implementação observável.

## ETAPA 2: LOCALIZAÇÃO DO ARQUIVO DE TAREFAS

Procure nesta ordem:

1. `docs/specs/*/tasks.md`
2. `docs/tasks.md`
3. `docs/tasks-*.md`
4. `tasks.md`
5. `TODO.md`, `docs/TODO.md`, `.github/TODO.md`

Se houver múltiplos arquivos candidatos, escolha o mais coerente com o pedido do usuário. Se a escolha não for óbvia, liste as opções e peça confirmação.

## ETAPA 3: ANÁLISE DAS TAREFAS

### 3.1 Status Possíveis

- **Pendente**: não iniciada (`[ ]`).
- **Em andamento**: parcialmente concluída (`[~]`).
- **Concluída**: finalizada (`[x]`).
- **Bloqueada**: aguardando dependência (`[!]`).

### 3.2 Checklist de Análise

- [ ] Identificar fases, tarefas e subtarefas.
- [ ] Verificar status marcado versus evidência real.
- [ ] Detectar inconsistências, especialmente trabalho feito mas não marcado.
- [ ] Identificar dependências entre tarefas.
- [ ] Calcular progresso por fase e criticidade.
- [ ] Recomendar próximas tarefas acionáveis.

### 3.3 Métricas

Prefira o script `scripts/metrics.sh`, no diretório desta skill, para extrair contagens de forma determinística:

```bash
sh scripts/metrics.sh docs/specs/{feature-short-name}/tasks.md
```

Se `sh` não estiver disponível, calcule manualmente pelos marcadores:

- `[ ]` pendente.
- `[~]` em andamento.
- `[x]` concluída.
- `[!]` bloqueada.

## ETAPA 4: DETECÇÃO DE INCONSISTÊNCIAS

### 4.1 Trabalho Feito Mas Não Marcado

Procure tarefas que parecem concluídas, mas continuam pendentes.

Para documentação:

```text
Se a tarefa pede "Criar UC-XXX-NNN"
e o arquivo UC-XXX-NNN.md existe
e o arquivo está completo
então reporte como provável conclusão não marcada.
```

Para código:

```text
Se a tarefa pede "Implementar feature X"
e o código da feature existe
e há evidência de build/teste ou implementação coerente
então reporte como provável conclusão não marcada.
```

Não marque automaticamente. Inclua evidência e recomende executar `Dev Pipeline - 9. Implementation - Execute Task` para sincronizar `tasks.md`, ou peça autorização explícita para editar.

### 4.2 Verificação via Git

Quando houver histórico Git:

```bash
git status --short
git log --oneline -20
git log --oneline --grep="<task-keyword>"
```

Use Git como evidência auxiliar, não como única prova de conclusão.

### 4.3 Monorepos e Multi-serviço

Quando `tasks.md` cobre múltiplos módulos ou serviços, audite por área:

- Agrupe tarefas por módulo.
- Calcule progresso por módulo.
- Identifique bloqueios cross-service.
- Recomende próximas tarefas desbloqueadas por criticidade.

## ETAPA 5: PRIORIZAÇÃO

Ordene tarefas pendentes por:

1. Criticidade: `[C]` antes de `[A]`, antes de `[M]`.
2. Dependências: tarefas sem bloqueios primeiro.
3. Impacto: maior valor de negócio ou desbloqueio técnico.
4. Proximidade com fase atual: evite pular fundação pendente para tarefa downstream.

Recomende no máximo 3 próximas tarefas para manter o relatório acionável.

## ETAPA 6: RELATÓRIO

Use este formato:

```markdown
# Relatório de Status das Tarefas

**Data:** [YYYY-MM-DD]
**Projeto:** [nome]
**Tipo:** [Documentação/Código/Misto]
**Arquivo de Tarefas:** [caminho]

## Resumo Executivo

| Métrica | Valor |
|---------|-------|
| Total de Tarefas | X |
| Concluídas | X (X%) |
| Em Progresso | X (X%) |
| Pendentes | X (X%) |
| Bloqueadas | X (X%) |

## Possíveis Inconsistências

### [TASK-ID]: [Nome]
- **Status atual:** `[ ]`
- **Evidências de conclusão:**
  - Arquivo existe: `path/to/file`
  - Build/teste/commit relevante: [evidência]
- **Recomendação:** sincronizar via `Dev Pipeline - 9. Implementation - Execute Task` ou autorizar atualização manual.

## Tarefas Pendentes - Prontas para Iniciar

### Top 3 Recomendadas

#### 1. [TASK-ID]: [Nome]
- **Prioridade:** [C|A|M]
- **Dependências:** Nenhuma
- **Justificativa:** [por que começar agora]
- **Próximo passo:** `Dev Pipeline - 9. Implementation - Execute Task`

## Tarefas Bloqueadas

### [TASK-ID]: [Nome]
- **Bloqueada por:** [dependência]
- **Para desbloquear:** [ação]

## Progresso por Fase

| Fase | Total | Concluídas | % |
|------|-------|------------|---|
| 1 - Fundação | X | X | X% |

## Recomendações

1. [ação]
2. [ação]
3. [ação]
```

## Regras Importantes

- Não executar tarefas pendentes nesta skill.
- Não editar `tasks.md` sem autorização explícita.
- Não criar arquivo de relatório salvo, salvo pedido explícito do usuário.
- Toda inconsistência deve vir com evidência.
- Recomendações devem respeitar criticidade e dependências.
- Se não houver inconsistência, diga isso claramente.

## Gotchas

### Detectar inconsistências é a razão de ser da skill

Relatar apenas contagem de checkboxes agrega pouco. O valor está em cruzar status com evidências e identificar drift entre trabalho feito e backlog.

### Procurar tasks em múltiplas localizações

Projetos SDD usam `docs/specs/*/tasks.md`; projetos por serviço podem usar `docs/tasks-*.md`. Não assuma um único caminho.

### Não confundir com execute-task

Esta skill lê e relata. Ela não implementa, não marca tarefa e não corrige código. Se o usuário quiser agir, encaminhe para `Dev Pipeline - 9. Implementation - Execute Task`.

### Top 3 deve respeitar criticidade e dependências

Recomendar `[M]` enquanto existe `[C]` desbloqueada é erro de priorização. Dependência bloqueada nunca deve aparecer como pronta.

### Evidência explícita para conclusão provável

Nunca diga "parece concluída" sem apontar arquivo, commit, build, teste ou outro sinal verificável.
