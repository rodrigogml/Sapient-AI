---
name: dev-pipeline-1-discovery-briefing
description: Use when starting discovery for a new project, large feature, product initiative, or architecture effort before writing specifications, implementation plans, or tasks. This skill guides a structured briefing interview covering vision, users, scope, constraints, technical context, quality expectations, and future direction.
metadata:
  short-description: Discovery briefing for the dev pipeline
---

# Dev Pipeline - 1. Discovery - Briefing

## Overview

Conduza uma entrevista estruturada de discovery para capturar o contexto essencial do projeto antes de iniciar especificação, planejamento técnico ou decomposição de tarefas.

Esta skill produz um briefing objetivo, orientado a decisões, que deve alimentar as próximas etapas do pipeline de desenvolvimento.

## When To Use

Use esta skill quando o usuário quiser iniciar ou revisar o discovery de:
- um projeto novo;
- uma feature grande antes de escrever specs;
- uma iniciativa de produto ou arquitetura;
- um módulo ainda pouco definido;
- um projeto existente que precisa de alinhamento antes de planejamento técnico.

Não use esta skill para implementar código, revisar PR, corrigir bugs pontuais ou criar tarefas técnicas diretamente. Nesses casos, recomende a etapa apropriada do pipeline depois de verificar se já existe briefing suficiente.

## Output Contract

O resultado principal é um briefing datado salvo no projeto alvo, preferencialmente em:

```text
docs/briefing/YYYYMMDD-briefing.md
```

Se já existir um briefing e o usuário não pedir sobrescrita ou mesclagem, preserve o arquivo atual e crie uma nova versão datada no mesmo diretório.

O briefing deve registrar fatos fornecidos pelo usuário, inferências marcadas como `[inferido]` e pendências na seção `Itens a Definir`. Não transforme o briefing em especificação técnica nem em plano de implementação.

## Workflow

Siga este fluxo:

1. **Contexto**: leia os artefatos existentes para entender o que já se sabe.
2. **Triagem**: determine se a entrevista será completa, focada ou adaptada ao material existente.
3. **Entrevista**: faça perguntas estruturadas, uma por vez, cobrindo somente as lacunas relevantes.
4. **Síntese**: consolide as respostas em um briefing objetivo.
5. **Validação**: apresente um resumo executivo e aguarde confirmação antes de salvar.
6. **Salvamento**: grave o arquivo final e indique a próxima etapa do pipeline.

Depois do briefing, o fluxo sugerido é:
- `Dev Pipeline - 2. Discovery - Constitution`, ou;
- `Dev Pipeline - 3. Specification - Specify` para features já identificadas.

### ETAPA 1: CONTEXTO

#### 1.1 Detectar Projeto

Leia os seguintes arquivos (se existirem) para entender o que já se sabe:
```
SEMPRE LER (se existirem):
-- README.md
-- AGENTS.md
-- docs/briefing/*.md (briefings anteriores)
-- docs/constitution.md
-- docs/specs/{feature-short-name}/spec.md (specs existentes)
-- pom.xml, package.json, go.mod, pyproject.toml, Cargo.toml (stack técnica)
```

#### 1.2 Análise dos Briefings Existentes

Se encontrado:
- Carregar conteúdo atual
- Identificar seções incompletas ou marcadas com TODO
- Perguntar ao usuário: "Encontrei um briefing existente. Deseja **atualizar** ou **criar um novo**?"

Se não encontrado:
- Seguir para entrevista completa (Etapa 2)

### ETAPA 2: TRIAGEM

#### 2.1 Analisar Input

Analise o Argumento (input/prompt do usuário) e o contexto coletado:

| Cenário | Ação |
|---------|------|
| Argumento vazio, projeto vazio | Entrevista COMPLETA (todas as dimensões) |
| Argumento vazio, projeto existente | Entrevista FOCADA (apenas gaps detectados) |
| Argumento com descrição do projeto | Entrevista ADAPTADA (preencher o que falta da descrição) |
| Argumento com caminho para documento | Extrair contexto do documento + entrevista complementar |

#### 2.2 Preencher o que já se sabe

Para cada dimensão da entrevista, verificar se a informação já existe no contexto:
- Se inferível de arquivos do projeto: preencher e marcar como `[inferido]`
- Se explícita no argumento: preencher e marcar como `[fornecido]`
- Se desconhecida: incluir na fila de perguntas

#### 2.3 Calcular Fila de Perguntas

- **Entrevista completa**: até 10 perguntas (todas as dimensões)
- **Entrevista focada/adaptada**: apenas gaps, máx. 7 perguntas
- Nunca exceder 10 perguntas no total

### ETAPA 3: ENTREVISTA

#### 3.1 Dimensões de Discovery

A entrevista cobre 7 dimensões, com 1-2 perguntas cada. O roteiro completo (texto de cada pergunta, exemplos, formatos, regras) está em `references/discovery-guide.md`. Consultar sob demanda em vez de memorizar.

Dimensões:
1. **Visão e Propósito** — elevator pitch
2. **Usuários e Stakeholders** — atores e quem decide
3. **Escopo e Prioridades** — MVP vs pós-MVP, trade-offs
4. **Restrições** — prazo, equipe, budget, tech
5. **Contexto Técnico** — stack, infra, integrações
6. **Qualidade e Padrões** — testes, segurança, observabilidade, compliance
7. **Visão de Futuro** — evolução em 6-12 meses

**Perguntas são feitas UMA POR VEZ**, aguardando resposta antes de avançar.

#### 3.2 Regras da Entrevista

Ver detalhamento em `references/discovery-guide.md#regras-da-entrevista`. Resumo: uma pergunta por vez, máximo 10 total, adaptar ao contexto, confirmar inferências, não julgar respostas.

#### 3.3 Transição entre Perguntas

Após cada resposta:
- Agradecer brevemente (1 linha máx., sem ser efusivo)
- Se a resposta levantar aspecto não coberto: adicionar pergunta de follow-up (dentro do limite)
- Apresentar próxima pergunta

### ETAPA 4: SÍNTESE

#### 4.1 Template do Briefing

Após encerrar a entrevista, consolidar todas as respostas usando `references/briefing-template.md` (subdiretório `references/` desta skill). Estrutura:

1. Visão e Propósito
2. Usuários e Stakeholders
3. Escopo (MVP / Pós-MVP / Fora de Escopo)
4. Prioridades e Trade-offs
5. Restrições (prazo, equipe, budget, técnica)
6. Stack Técnica
7. Qualidade e Padrões
8. Visão de Futuro
+ Itens a Definir (pendências)

#### 4.2 Regras de Síntese

- **Usar as palavras do usuário** — não reescrever em jargão técnico
- **Marcar inferências** — se algo foi inferido (não dito explicitamente), indicar com `[inferido]`
- **Marcar pendências** — itens sem resposta vão para "Itens a Definir"
- **Remover seções vazias** — se dimensão inteira não se aplica, remover (não deixar "N/A")
- **Não inventar** — se o usuário não mencionou, não adicionar

### ETAPA 5: VALIDAÇÃO

#### 5.1 Apresentar Resumo

Antes de salvar, apresentar ao usuário um resumo executivo:

```markdown
## Resumo do Briefing

**Projeto**: [Nome]
**Resumo**: [1-2 frases]
**Atores**: [N] identificados
**Features MVP**: [N] features
**Stack**: [resumo da stack]
**Restrições críticas**: [lista curta]
**Itens a definir**: [N] pendências

Deseja que eu salve este briefing? Ou há algo a corrigir/complementar?
```

#### 5.2 Iterar se Necessário

- Se usuário pedir correções: aplicar e re-apresentar resumo
- Se usuário pedir mais perguntas: retomar entrevista (respeitando limite de 10)
- Se usuário aprovar: prosseguir para salvamento

### ETAPA 6: SALVAMENTO

#### 6.1 Criar Diretório

Se `docs/briefing/` não existir, criar.

#### 6.2 Salvar Briefing

Salvar em `docs/briefing/YYYYMMDD-briefing.md`.

Se já existe um briefing, preservar o arquivo atual e criar uma nova versão datada, exceto quando o usuário pedir explicitamente sobrescrita ou mesclagem.

#### 6.3 Reportar

```markdown
## Briefing Salvo

**Arquivo**: docs/briefing/YYYYMMDD-briefing.md
**Dimensões cobertas**: [N]/7
**Itens a definir**: [N]

### Próximos Passos (fluxo SDD recomendado)

1. `Dev Pipeline - 2. Discovery - Constitution` — Definir princípios de governança baseados no briefing
2. `Dev Pipeline - 3. Specification - Specify` — Especificar features do MVP identificadas
3. `Dev Pipeline - 4. Specification - Clarify` — Resolver ambiguidades nas specs geradas
4. `Dev Pipeline - 5. Planning - Plan` — Gerar planos técnicos de implementação
```
