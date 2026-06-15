---
name: dev-pipeline-3-specification-specify
description: Use after discovery and constitution when the user wants to convert a natural-language feature description into a Spec-Driven Development feature specification with user stories, functional requirements, key entities, edge cases, and measurable success criteria. Skip for refining an existing spec; use the clarify step instead.
metadata:
  short-description: Create SDD feature specs
---

# Dev Pipeline - 3. Specification - Specify

## Overview

Transforme uma descrição de feature em linguagem natural em uma feature spec completa seguindo o formato Spec-Driven Development. O foco é no QUE e POR QUE, nunca no COMO implementar.

## Pré-requisitos

**Recomendado**: `Dev Pipeline - 1. Discovery - Briefing` e `Dev Pipeline - 2. Discovery - Constitution` executados antes. O briefing contextualiza a feature dentro do projeto, e a constitution ajuda a calibrar escopo, princípios e padrões de qualidade.

Sem esses artefatos, a skill funciona, mas pode precisar de mais perguntas ou marcações `[NEEDS CLARIFICATION]`.

## When To Use

Use quando o usuário quiser criar uma spec para feature nova, capacidade relevante, fluxo de produto, requisito funcional amplo ou comportamento que precisa ser alinhado antes de planejamento técnico.

Não use para bugfix, refactor interno, tarefa técnica pontual ou ajuste pequeno em feature existente. Nesses casos, recomende execução direta, bugfix, ADR ou etapa mais adequada do pipeline.

## Output Contract

O resultado principal é `docs/specs/{feature-short-name}/spec.md`, criado com user stories priorizadas, acceptance scenarios, edge cases, functional requirements, key entities quando aplicável e success criteria mensuráveis.

A spec deve ser compreensível para stakeholders não técnicos, não deve conter detalhes de implementação e deve marcar no máximo 3 ambiguidades críticas com `[NEEDS CLARIFICATION: pergunta específica]`.

## Workflow

0. **Triagem**: classificar o pedido e confirmar se SDD completo faz sentido.
1. **Análise**: parsear a descrição e extrair atores, ações, dados e restrições.
2. **Estrutura**: gerar short name e criar `docs/specs/{feature-short-name}/`.
3. **Especificação**: preencher `templates/feature-spec.md` com conteúdo concreto.
4. **Validação**: checar qualidade contra critérios internos.
5. **Clarificação**: resolver ambiguidades críticas com o usuário.
6. **Salvamento**: salvar a spec e reportar próximos passos.

## Próximos Passos

1. `Dev Pipeline - 4. Specification - Clarify` — resolver ambiguidades da spec, se houver `[NEEDS CLARIFICATION]`.
2. `Dev Pipeline - 5. Planning - Plan` — gerar plano técnico de implementação.
3. `Dev Pipeline - 6. Planning - Checklist` — validar qualidade dos requisitos antes de implementar.


## ETAPA 0: TRIAGEM (OBRIGATÓRIA ANTES DE PROSSEGUIR)

Antes de gerar qualquer artefato, classifique o pedido e valide com o usuário se o fluxo SDD completo faz sentido para o escopo. O fluxo SDD (spec -> clarify -> plan -> tasks) tem custo real e nem todo pedido justifica esse overhead.

### 0.1 Classificar o Pedido

Analise o pedido atual do usuário e classifique em uma das categorias:

- **Feature nova**: comportamento/capacidade que o sistema não tem hoje, com múltiplos atores, fluxos ou regras de negócio; SDD completo tende a se pagar.
- **Ajuste/extensão pontual**: mudança pequena em feature existente, uma regra nova, um campo a mais; SDD provavelmente é overkill.
- **Bugfix**: correção de comportamento incorreto; não usar specify, sugerir a skill de bugfix.
- **Refactor/tarefa técnica**: mudança interna sem impacto funcional observável; não usar specify, sugerir execução direta ou etapa de execução de tarefa.

### 0.2 Avaliar Relevância do SDD

Considere sinais de que o SDD completo vale o custo:

- Feature tem 2+ user stories independentes?
- Envolve múltiplos atores ou papéis?
- Tem regras de negócio ou edge cases não triviais?
- Precisa alinhar stakeholders antes de implementar?
- Vai gerar backlog de tarefas para mais de uma sessão de trabalho?

Se a maioria for "não", provavelmente o pedido pode ser resolvido inline ou com um UC/ADR pontual, sem passar pelo pipeline SDD completo.

### 0.3 Apresentar a Análise e Deixar o Usuário Decidir

Antes de criar diretório ou arquivos, apresentar ao usuário:

```markdown
## Triagem do pedido

**Classificação**: [Feature nova | Ajuste pontual | Bugfix | Refactor]

**Análise de relevância SDD**:
- [Justificar por que vale ou não vale gerar spec completa]
- [Citar sinais específicos do pedido]

**Opções**:

1. **Executar direto** — resolver o pedido sem gerar artefatos SDD
   (recomendado se: escopo pequeno, bugfix, refactor, ajuste inline)
2. **Criar feature SDD completa** — gerar spec + seguir pipeline
   (recomendado se: feature com stories múltiplas, stakeholders, backlog)
3. **Alternativa sugerida**: [ex: criar UC clássico, ADR, rodar bugfix]

Qual caminho prefere?
```

**Nunca prosseguir para ETAPA 1 sem confirmação explícita do usuário.** Se o usuário escolher opção 1 ou 3, encerrar esta skill e executar o caminho escolhido ou delegar para a skill apropriada.

## ETAPA 1: ANÁLISE

### 1.1 Parsear Descrição

Extraia do pedido:

- **Atores**: quem usa a feature (usuários, admins, sistemas).
- **Ações**: o que a feature permite fazer.
- **Dados**: que entidades/informações estão envolvidas.
- **Restrições**: limites, regras, condições.

### 1.2 Ler Contexto do Projeto

```text
SEMPRE LER (se existirem):
-- README.md
-- AGENTS.md
-- docs/briefing/*.md (briefings anteriores)
-- docs/constitution.md (para alinhar com princípios)
-- docs/specs/ (para verificar specs existentes e evitar duplicatas)
```

## ETAPA 2: ESTRUTURA

### 2.1 Gerar Short Name

Crie um nome curto (2-4 palavras, kebab-case) que capture a essência da feature:

- Formato ação-substantivo quando possível.
- Preservar termos técnicos e siglas.
- Exemplos:
  - "Quero adicionar autenticação de usuário" -> `user-auth`.
  - "Implementar integração OAuth2 para a API" -> `oauth2-api-integration`.
  - "Criar dashboard de analytics" -> `analytics-dashboard`.

### 2.2 Criar Diretório

Criar `docs/specs/{feature-short-name}/`, ou caminho sugerido pelo usuário.

## ETAPA 3: ESPECIFICAÇÃO

### 3.1 Template da Feature Spec

Ler o template em `templates/feature-spec.md` (subdiretório `templates/` desta skill) e preencher com conteúdo concreto derivado da descrição. Estrutura:

- **User Scenarios & Testing** — stories priorizadas (P1..Pn) + edge cases.
- **Requirements** — functional requirements e key entities.
- **Success Criteria** — measurable outcomes, technology-agnostic.

Para ver exemplos de spec bem escrita vs mal escrita:

- `examples/spec-good.md` — ilustra stories independentes, success criteria mensuráveis, zero detalhes de implementação.
- `examples/spec-bad.md` — catálogo de anti-patterns (jargão técnico em SC, stories acopladas, adjetivos vagos, excesso de `[NEEDS CLARIFICATION]`).

### 3.2 Regras de Preenchimento

**User Stories:**

- Priorizadas como jornadas de usuário ordenadas por importância.
- Cada story deve ser INDEPENDENTEMENTE TESTÁVEL.
- Se implementar apenas UMA story, ainda deve haver um MVP viável.
- Adicionar quantas stories forem necessárias (P1, P2, P3, P4...).

**Functional Requirements:**

- Cada requisito deve ser testável.
- Foco no QUE o sistema faz, não COMO implementar.
- Usar defaults razoáveis para detalhes não especificados:
  - Retenção de dados: práticas padrão da indústria.
  - Performance: expectativas padrão para web/mobile.
  - Tratamento de erros: mensagens user-friendly com fallbacks.
  - Autenticação: session-based ou OAuth2 para web apps.
- Para ambiguidades críticas, marcar com `[NEEDS CLARIFICATION: pergunta específica]`.
- **MÁXIMO 3 marcadores `[NEEDS CLARIFICATION]`** no total.
- Prioridade de clarificação: escopo > segurança > UX > detalhes técnicos.

**Decisões de Infraestrutura Auditáveis (obrigatório para features com runtime de longo prazo):**

Features que envolvem schedulers, sessões persistentes, refresh de tokens externos ou rotação de chaves DEVEM declarar essas políticas como FRs explícitos na spec, não como dívida descoberta na execução.

Checklist mínimo (cada item vira FR explícito quando aplicável):

| Tipo de decisão | FR explícito sugerido | Quando aplicar |
|-----------------|------------------------|----------------|
| Política de scheduling | `FR-NN-INFRA-SCHED: autoSchedule = 'cron' \| 'wakeup' \| 'manual' \| 'auto' (default <X>)` | Feature dispara trabalho periódico ou agendado |
| Política de key rotation | `FR-NN-INFRA-KEY: SESSION_ENCRYPTION_KEY suporta versionamento (v1:<base64>, v2:<base64>) — rotação sem downtime` | Feature criptografa dados persistentes |
| Refresh policy (token externo) | `FR-NN-INFRA-REFRESH: refresh on-demand + job periódico a cada Xmin; gap window aceitável: Y min` | Feature consome IdP, OAuth ou recurso com TTL |
| Mutex multi-pod | `FR-NN-INFRA-LOCK: serialização cross-pod via <pg_try_advisory_xact_lock\|redis lock\|SELECT FOR UPDATE>` | Deploy multi-replica + estado compartilhado |
| Backup / restore | `FR-NN-INFRA-BACKUP: snapshot cron Xh, retenção Yd, restore tested via RB-NNN` | Feature persiste dados críticos |
| Idempotência | `FR-NN-INFRA-IDEMP: <chave de idempotência, TTL, scope>` | Feature aceita request retry |

Se a feature NÃO toca nenhum desses, anotar explicitamente uma linha: `> Decisões de infraestrutura: N/A (feature stateless, sem scheduling)`. Não deixar implícito; `N/A explícito > silêncio`.

**Success Criteria:**

- DEVEM ser mensuráveis (tempo, porcentagem, contagem, taxa).
- DEVEM ser technology-agnostic (sem frameworks, linguagens, databases).
- DEVEM ser user-focused (perspectiva do usuário/negócio).
- DEVEM ser verificáveis sem conhecer detalhes de implementação.

**Exemplos de Success Criteria BEM escritos:**

- "Usuários completam checkout em menos de 3 minutos".
- "Sistema suporta 10.000 usuários concorrentes".
- "95% das buscas retornam resultados em menos de 1 segundo".

**Exemplos de Success Criteria MAL escritos (implementation-focused):**

- "API response time under 200ms" (muito técnico).
- "Database handles 1000 TPS" (detalhe de implementação).
- "React components render efficiently" (framework-specific).

## ETAPA 4: VALIDAÇÃO

### 4.1 Checklist de Qualidade Interna

Valide a spec contra estes critérios:

- [ ] Nenhum detalhe de implementação (linguagens, frameworks, APIs).
- [ ] Focado no valor para o usuário e necessidades do negócio.
- [ ] Escrito para stakeholders não técnicos.
- [ ] Todas as seções obrigatórias preenchidas.
- [ ] Requisitos são testáveis e não ambíguos.
- [ ] Success criteria são mensuráveis.
- [ ] Success criteria são technology-agnostic.
- [ ] Acceptance scenarios definidos para todas as stories.
- [ ] Edge cases identificados.
- [ ] Escopo claramente delimitado.

### 4.2 Auto-Correção

Se itens falham na validação:

1. Listar itens que falharam e problemas específicos.
2. Atualizar a spec para corrigir cada problema.
3. Revalidar (máx. 3 iterações).
4. Se ainda falhar após 3 iterações: documentar problemas restantes e avisar usuário.

## ETAPA 5: CLARIFICAÇÃO

### 5.1 Resolver `[NEEDS CLARIFICATION]`

Se existem marcadores `[NEEDS CLARIFICATION]` na spec:

1. Extrair todos os marcadores.
2. Se houver mais de 3: manter apenas os 3 mais críticos e fazer guesses informados para o resto.
3. Para cada marcador, apresentar ao usuário:

```markdown
## Questão [N]: [Tópico]

**Contexto**: [Citar seção relevante da spec]

**O que precisamos saber**: [Pergunta específica]

**Respostas Sugeridas**:

| Opção | Resposta | Implicações |
|-------|----------|-------------|
| A     | [Primeira opção] | [O que significa para a feature] |
| B     | [Segunda opção] | [O que significa para a feature] |
| C     | [Terceira opção] | [O que significa para a feature] |

**Sua escolha**: _[Aguardar resposta]_
```

4. Após respostas: atualizar spec substituindo marcadores pelas respostas.

## ETAPA 6: SALVAMENTO

### 6.1 Salvar Spec

Salvar em `docs/specs/{feature-short-name}/spec.md`.

### 6.2 Reportar

```markdown
## Spec Criada

**Feature**: {short-name}
**Arquivo**: docs/specs/{feature-short-name}/spec.md
**Status**: Draft
**User Stories**: {N} stories (P1-P{N})
**Requisitos**: {N} functional requirements
**Clarificações pendentes**: {N}

### Próximos Passos

1. `Dev Pipeline - 4. Specification - Clarify` — Refinar ambiguidades na spec, se houver NEEDS CLARIFICATION
2. `Dev Pipeline - 5. Planning - Plan` — Gerar plano técnico de implementação
```

## DIRETRIZES RÁPIDAS

- Foco no **QUE** usuários precisam e **POR QUE**.
- Evitar COMO implementar (sem tech stack, APIs, estrutura de código).
- Escrito para stakeholders de negócio, não desenvolvedores.
- Quando seção não se aplica: remover inteiramente (não deixar como "N/A").
- Pensar como tester: todo requisito vago deve falhar no checklist de qualidade.

## Gotchas

### ZERO detalhes de implementação na spec

Sem linguagens, frameworks, APIs, estrutura de código, nomes de bibliotecas ou classes. A spec responde QUE e POR QUE; o COMO vai para `Dev Pipeline - 5. Planning - Plan`. Se aparece "em React" ou "com PostgreSQL" na spec, está errado.

### Success Criteria devem ser technology-agnostic E mensuráveis

Correto: "Usuário completa checkout em <3 minutos", "95% das buscas retornam <1s", "Sistema suporta 10k usuários concorrentes". Errado: "API responde <200ms" (técnico), "Database aguenta 1000 TPS" (implementação), "Componentes React renderizam rápido" (framework).

### Máximo 3 `[NEEDS CLARIFICATION]`: priorizar escopo > segurança > UX > tech

Mais de 3 marcadores indica que a spec deveria voltar ao usuário antes de escrever. Priorize o que impacta corretude e use defaults informados para o resto.

### Cada user story deve ser INDEPENDENTEMENTE TESTÁVEL

Se implementar apenas P1 não gera MVP viável, as stories estão acopladas demais. Cada story precisa ter valor isolado para o usuário.

### Não deixar seções vazias com "N/A"

Se a feature não envolve entidades de dados, remover a seção "Key Entities" inteira; não deixar header com "N/A" abaixo. Seções vazias são ruído para `Dev Pipeline - 5. Planning - Plan` e `Dev Pipeline - 7. Implementation - Create Tasks` downstream.

### Defaults razoáveis em vez de `[NEEDS CLARIFICATION]` para tudo

Retenção de dados, tratamento de erros padrão e autenticação web-padrão: se não forem críticos, use o default da indústria e documente a suposição. Marcar tudo como pendente trava o fluxo.
