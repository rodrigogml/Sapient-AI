---
name: dev-pipeline-6-planning-checklist
description: Use after spec and plan exist when the user wants a requirements quality gate by domain such as UX, API, security, performance, accessibility, or general requirements. This skill validates requirement quality, clarity, coverage, and traceability; it does not test code or implementation behavior.
metadata:
  short-description: Requirements quality gate
---

# Dev Pipeline - 6. Planning - Checklist

## Overview

Gere checklists que validam a qualidade dos requisitos, não da implementação. O conceito é "unit tests for English": itens que verificam clareza, completude, consistência, mensurabilidade e rastreabilidade dos requisitos escritos.

## Pré-requisitos

**Recomendado**: `docs/specs/{feature-short-name}/spec.md` e `docs/specs/{feature-short-name}/plan.md` existentes. Sem spec, a skill pode gerar checklist genérico de qualidade de requisitos, mas a rastreabilidade (`[Spec §X.Y]`) fica comprometida.

## When To Use

Use quando o usuário quiser validar a qualidade dos requisitos antes de criar tarefas ou implementar. Também use quando precisar de checklist por domínio (`requirements`, `ux`, `api`, `security`, `performance`) para revisar gaps, ambiguidades, conflitos e critérios pouco mensuráveis.

Não use para testar UI, chamar APIs, validar código, executar testes automatizados ou confirmar comportamento de implementação.

## Output Contract

O resultado principal é `docs/specs/{feature-short-name}/checklists/{domain}.md`.

Cada item deve testar a qualidade do requisito, terminar com dono `{auto}` ou `{humano}`, conter rastreabilidade quando possível e preservar itens existentes caso o arquivo já exista.

## Workflow

1. **Contexto**: localizar spec, plan e tasks da feature.
2. **Clarificação**: fazer até 3 perguntas de escopo, se necessário.
3. **Geração**: criar itens com dono `{auto}`/`{humano}`.
4. **Auto-resolução**: resolver itens `{auto}` contra spec/plan com evidência citável.
5. **Salvamento**: salvar ou fazer append em `checklists/{domain}.md`.
6. **Reportar**: consolidar gaps, ambiguidades, conflitos e próximos passos.

## Próximos Passos

1. `Dev Pipeline - 4. Specification - Clarify` — resolver `[Ambiguity]` e `[Conflict]`.
2. `Dev Pipeline - 7. Implementation - Create Tasks` — transformar `[Gap]` em tarefas de requisito ou implementação.
3. `Dev Pipeline - 8. Implementation - Analyze` — validar consistência cross-artifact quando spec, plan e tasks existirem.

## CONCEITO FUNDAMENTAL

**Checklists são unit tests para requisitos**: validam qualidade, clareza e completude dos requisitos escritos em linguagem natural.

**Não são para verificação/teste de implementação:**

- Errado: "Verificar se o botão funciona corretamente".
- Errado: "Testar se a API retorna 200".
- Errado: "Confirmar que o error handling funciona".

**São para validação de qualidade dos requisitos:**

- Correto: "São os requisitos de hierarquia visual definidos para todos os tipos de card?"
- Correto: "É 'exibição proeminente' quantificado com sizing/positioning específicos?"
- Correto: "São os requisitos de hover state consistentes entre todos os elementos interativos?"
- Correto: "São os requisitos de acessibilidade definidos para navegação por teclado?"

## ETAPA 1: CONTEXTO

### 1.1 Localizar Artefatos

Buscar artefatos da feature:

1. `docs/specs/{feature-short-name}/spec.md` — requisitos e escopo.
2. `docs/specs/{feature-short-name}/plan.md` — detalhes técnicos.
3. `docs/specs/{feature-short-name}/tasks.md` — tarefas de implementação, se existirem.

Carregar apenas porções relevantes; não despejar documentos completos sem necessidade.

### 1.2 Identificar Domínio

Derivar domínio do checklist a partir do pedido do usuário:

- `requirements` — qualidade geral de requisitos (default se nenhum domínio especificado).
- `ux` — hierarquia visual, interação, acessibilidade, responsividade.
- `api` — endpoints, error handling, versionamento.
- `security` — autenticação, autorização, proteção de dados.
- `performance` — latência, throughput, escalabilidade.
- Domínio customizado — usar contexto do argumento.

## ETAPA 2: CLARIFICAÇÃO DE INTENT

### 2.1 Perguntas Dinâmicas (máx. 3)

Gerar até 3 perguntas contextuais baseadas em sinais do projeto e do pedido. **Pular** perguntas cujas respostas já são óbvias.

Arquétipos de perguntas:

- **Refinamento de escopo**: "Deve incluir touchpoints de integração com X e Y?"
- **Priorização de risco**: "Quais áreas de risco devem receber checks obrigatórios?"
- **Calibração de profundidade**: "É um checklist leve pre-commit ou gate formal de release?"
- **Framing de audiência**: "Será usado pelo autor ou por peers em PR review?"
- **Exclusão de limite**: "Devemos excluir itens de performance tuning nesta rodada?"

Formato: tabela com opções A-E quando aplicável, ou resposta livre.

Defaults quando interação for impossível:

- Profundidade: Standard.
- Audiência: Reviewer (PR) se código; Author se docs.
- Foco: Top 2 clusters de relevância.

## ETAPA 3: GERAÇÃO

### 3.1 Dimensões de Qualidade

Organizar itens por dimensão:

- **Completude de Requisitos** — todos os requisitos necessários estão documentados?
- **Clareza de Requisitos** — requisitos são específicos e não ambíguos?
- **Consistência de Requisitos** — requisitos se alinham sem conflitos?
- **Qualidade de Critérios de Aceite** — success criteria são mensuráveis?
- **Cobertura de Cenários** — todos os fluxos/casos estão cobertos?
- **Cobertura de Edge Cases** — condições de contorno estão definidas?
- **Requisitos Não Funcionais** — performance, segurança, acessibilidade especificados?
- **Dependências e Premissas** — estão documentadas e validadas?
- **Ambiguidades e Conflitos** — o que precisa de clarificação?

### 3.2 Como Escrever Itens

**Padrão correto**: testar qualidade do requisito. Cada item termina com o dono `{auto}`/`{humano}`.

```markdown
- [ ] CHK001 - São os requisitos de [tipo] definidos/especificados para [cenário]? [Completude] {auto}
- [ ] CHK002 - É '[termo vago]' quantificado com critérios específicos? [Clareza, Spec §FR-2] {auto}
- [ ] CHK003 - São requisitos consistentes entre [seção A] e [seção B]? [Consistência] {auto}
- [ ] CHK004 - Pode [requisito] ser objetivamente medido/verificado? [Mensurabilidade] {auto}
- [ ] CHK005 - São [edge cases/cenários] cobertos nos requisitos? [Cobertura] {auto}
- [ ] CHK006 - A priorização de risco entre [X] e [Y] reflete o apetite do produto? [Risco] {humano}
```

**Proibido**: testar implementação.

```markdown
- Verificar se a página exibe 3 cards (ERRADO — testa implementação)
- Testar se hover states funcionam no desktop (ERRADO — testa comportamento)
- Confirmar que o logo clica para home (ERRADO — testa funcionalidade)
```

### 3.2.1 Dono de Cada Item

Todo item termina com um rótulo de dono:

- `{auto}` — verificável contra spec/plan: o agente resolve lendo o artefato e citando evidência.
- `{humano}` — julgamento de valor/risco/negócio: depende de contexto que o agente não tem.

Critério: se dá para responder só com os artefatos + evidência citável, é `{auto}`; se depende de preferência ou trade-off de negócio, é `{humano}`. Na dúvida, `{humano}`.

### 3.3 Exemplos por Domínio

Cada domínio tem um catálogo de itens em `references/{domain}.md` (subdiretório `references/` desta skill). Consultar sob demanda ao gerar o checklist:

- `references/requirements.md` — qualidade geral de requisitos (default).
- `references/ux.md` — hierarquia visual, estados de interação, acessibilidade, responsividade.
- `references/api.md` — contratos, error handling, auth, rate limiting, retry, observabilidade.
- `references/security.md` — authN/Z, proteção de dados, input validation, logging, compliance.
- `references/performance.md` — targets, escalabilidade, degradação, caching, queries.

Esses são pontos de partida; não copiar sem adaptar ao contexto da feature.

### 3.4 Rastreabilidade

- **Mínimo**: >= 80% dos itens devem incluir pelo menos uma referência de rastreabilidade.
- Cada item deve referenciar seção da spec `[Spec §X.Y]` ou marcadores `[Gap]`, `[Ambiguity]`, `[Conflict]`, `[Assumption]`.

### 3.5 Consolidação

- Soft cap: 40 itens. Se houver mais de 40 candidatos, priorizar por risco/impacto.
- Merge near-duplicates que checam o mesmo aspecto do requisito.
- Se houver mais de 5 edge cases de baixo impacto: criar um item agregado.

### 3.6 Template do Checklist

```markdown
# [DOMAIN] Checklist: [FEATURE NAME]

**Purpose**: [Descrição breve do que este checklist cobre]
**Created**: [DATE]
**Feature**: [Link para spec.md]

## [Categoria 1]

- [ ] CHK001 - [Item de checklist com referência] [Dimensão, Ref] {auto|humano}
- [ ] CHK002 - [Item] [Dimensão, Ref] {auto|humano}

## [Categoria 2]

- [ ] CHK003 - [Item] [Dimensão, Ref] {auto|humano}
- [ ] CHK004 - [Item] [Dimensão, Ref] {auto|humano}

## Notes

- Itens `{auto}` já vêm resolvidos pelo agente (`[x]` com citação, ou marcador `[Gap]`).
- Itens `{humano}` ficam `[ ]` aguardando decisão do dono do produto.
- Marcar itens concluídos com `[x]`.
- Itens numerados sequencialmente para referência.
```

### 3.7 Auto-resolução dos Itens `{auto}`

Antes de salvar, percorra cada item `{auto}` e resolva-o contra spec/plan:

- **Satisfeito** -> `[x]` com citação que prova: `- [x] CHK001 - ... [Completude, Spec §4.2] {auto}`.
- **Não satisfeito** -> manter `[ ]` e marcar `[Gap]`, `[Ambiguity]` ou `[Conflict]`, citando o que falta.
- **Sem evidência para decidir** -> reclassificar como `{humano}` e deixar `[ ]`.

Marcar `[x]` sem citar a seção que sustenta não vale; é alegação, não verificação. Itens `{humano}` nunca são auto-marcados.

## ETAPA 4: SALVAMENTO

### 4.1 Nomear Arquivo

- Usar nome curto e descritivo baseado no domínio: `requirements.md`, `ux.md`, `api.md`, `security.md`, `performance.md`.
- Se arquivo já existe: **append** novos itens, continuando do último CHK ID.
- Nunca deletar ou substituir conteúdo existente.

### 4.2 Salvar

Salvar em `docs/specs/{feature-short-name}/checklists/{domain}.md`. Criar diretório `checklists/` se não existir.

### 4.3 Reportar

```markdown
## Checklist Criado

**Arquivo**: [caminho]
**Domínio**: [domínio]
**Itens**: [N] itens gerados
**Ação**: Novo arquivo / Append a existente

### Áreas de Foco

- [Área 1]
- [Área 2]

### Resolução

- **{auto} resolvidos**: [X] (`[x]` com evidência citada)
- **{humano} aguardando decisão**: [Y]
- **Gaps abertos** (`[Gap]`/`[Ambiguity]`/`[Conflict]`): [Z]

### Próximos Passos

- Decidir os [Y] itens `{humano}` em aberto (dono do produto)
- `Dev Pipeline - 4. Specification - Clarify` — resolver `[Ambiguity]`/`[Conflict]`
- `Dev Pipeline - 7. Implementation - Create Tasks` — `[Gap]` vira tarefa de requisito
- `Dev Pipeline - 6. Planning - Checklist [outro-domínio]` — gerar outro domínio
```

### 4.4 Follow-up Obrigatório: Gaps Viram Ação

O valor do checklist está em revelar gaps que viram ação, não em ficar verde. Dê a cada item aberto um destino explícito:

| Marcador | Destino |
|----------|---------|
| `[Ambiguity]`, `[Conflict]` | `Dev Pipeline - 4. Specification - Clarify` — resolver na spec |
| `[Gap]` (requisito ausente) | `Dev Pipeline - 7. Implementation - Create Tasks` — vira tarefa "definir/especificar X" |
| `{humano}` em aberto | decisão do dono do produto antes da implementação |

Um `[Gap]` varrido para baixo do tapete é a única forma de o checklist falhar de verdade: um checklist meio marcado cujos gaps viraram ação cumpriu o papel; um 100% verde cujos gaps foram ignorados, não.

## Gotchas

### Checklist valida requisito, não implementação

O erro mais comum é escrever itens como "Verificar se o botão funciona". Isso testa implementação. O item correto é "São os requisitos de interação definidos para o botão?". Se o item começa com "Verificar", "Testar", "Confirmar que X funciona", está errado.

### Rastreabilidade mínima 80%

Itens sem referência a `[Spec §X.Y]`, `[Gap]`, `[Ambiguity]`, `[Conflict]` ou `[Assumption]` são ruído; não dá para priorizar nem validar. Abaixo de 80%, o checklist perde utilidade como quality gate.

### Soft cap 40 itens por domínio: priorize risco

Um checklist com 200 itens é ignorado. Se houver mais de 40 candidatos, priorizar por risco/impacto, agrupar near-duplicates e agregar edge cases de baixo impacto em um item único.

### Append, nunca sobrescrever

Se o arquivo do domínio já existe, continue os IDs (CHK015, CHK016...) ao final; não substitua conteúdo existente nem reinicie a numeração. Usuários já podem ter marcado itens.

### Adjetivos vagos em itens de checklist também são proibidos

"São os requisitos bem documentados?" é tão vago quanto "sistema deve ser robusto". Use critérios verificáveis: "Cada requisito funcional tem critério de aceite mensurável?"
