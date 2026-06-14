---
name: dev-pipeline-2-discovery-constitution
description: Use after a discovery briefing when the user wants to create or update project governance principles that guide architecture, quality, process, and future development decisions. This skill produces or amends a project constitution; for one-off technical decisions, use ADRs instead.
metadata:
  short-description: Project governance constitution
---

# Dev Pipeline - 2. Discovery - Constitution

## Overview

Crie ou atualize a constituição do projeto: o documento de princípios de governança que orienta decisões de arquitetura, qualidade e processo.

## Pré-requisitos

**Recomendado**: `Dev Pipeline - 1. Discovery - Briefing` executado antes. A constituição deriva princípios do contexto do projeto (visão, prioridades, restrições). Sem briefing, os princípios tendem a ficar genéricos.

## When To Use

Use quando o usuário quiser definir princípios de governança, regras não negociáveis, critérios de qualidade, limites arquiteturais, processo de alteração da governança ou atualização formal de uma constituição existente.

Não use para decisões técnicas pontuais ou escolhas de implementação localizadas. Nesses casos, recomende ADR.

## Output Contract

O resultado principal é `docs/constitution.md`, criado ou atualizado com princípios declarativos, testáveis e versionados.

Quando houver atualização, incluir relatório de impacto, versão SemVer, datas em formato ISO e lista de artefatos que precisam de sincronização.

## Workflow

1. **Contexto**: ler briefing, constituição existente, specs e artefatos relevantes.
2. **Coleta**: identificar princípios fornecidos, inferidos e pendentes.
3. **Geração**: preencher `templates/constitution.md` com conteúdo concreto.
4. **Propagação**: verificar impacto em `AGENTS.md`, plans, tasks e specs.
5. **Salvamento**: salvar `docs/constitution.md` e reportar versão, mudanças e pendências.



### ETAPA 1: CONTEXTO

#### 1.1 Detectar Projeto

Leia os seguintes arquivos, se existirem, para entender o contexto:

```text
SEMPRE LER (se existirem):
-- README.md
-- AGENTS.md
-- docs/01-discovery-briefing/*.md (briefings anteriores)
-- docs/constitution.md (constituição existente)
-- docs/specs/*/spec.md (specs existentes)
-- pom.xml, package.json, go.mod, pyproject.toml (stack técnica)
```

#### 1.2 Verificar Constituição Existente

Procure constituição existente em: `docs/constitution.md`

Se encontrada:
- Carregar conteúdo atual.
- Identificar placeholders `[ALL_CAPS_IDENTIFIER]` não preenchidos.
- Propor atualizações baseadas no input do usuário.

Se não encontrada:
- Seguir para coleta de princípios (Etapa 2).

### ETAPA 2: COLETA DE PRINCÍPIOS

#### 2.1 Fontes de Princípios

Analise o pedido atual do usuário e o contexto coletado. A entrada pode ser:
1. **Descrição do projeto**: inferir princípios a partir do contexto.
2. **Lista de princípios**: usar diretamente.
3. **Número de princípios**: respeitar a quantidade solicitada.
4. **Entrada vazia ou vaga**: inferir do contexto do projeto e perguntar ao usuário apenas quando houver lacunas relevantes.

#### 2.2 Derivar Valores

Para cada placeholder no template:
- Se o usuário forneceu valor: usar diretamente.
- Se inferível do contexto (README, docs, stack): derivar e documentar a inferência.
- Se desconhecido: marcar como `TODO(<CAMPO>): explicação` e incluir no relatório.


#### 2.3 Datas e Versionamento

- `RATIFICATION_DATE`: data original de adoção (se desconhecida, perguntar ou marcar TODO).
- `LAST_AMENDED_DATE`: data de hoje se mudanças foram feitas.
- `CONSTITUTION_VERSION`: incrementar seguindo versionamento semântico:
  - **MAJOR**: remoção ou redefinição incompatível de princípios.
  - **MINOR**: novo princípio ou expansão material de seção.
  - **PATCH**: clarificações, correções de texto, refinamentos não semânticos.
- Se o tipo de bump for ambíguo: propor raciocínio ao usuário antes de finalizar.


### ETAPA 3: GERAÇÃO

#### 3.1 Template da Constituição

Usar `templates/constitution.md` (subdiretório `templates/` desta skill) e substituir TODOS os placeholders `[ALL_CAPS]` por texto concreto. Estrutura:

- **Core Principles** — 3-5 princípios declarativos e testáveis.
- Seções opcionais conforme o projeto (ex: Quality Standards, Architecture Decisions).
- **Governance** — regras de amendment, versioning, exception handling.
- Rodapé com **Version / Ratified / Last Amended**.

#### 3.2 Regras de Preenchimento

- O usuário pode pedir mais ou menos princípios que o template; ajustar conforme necessário.
- Cada princípio deve ser: **declarativo, testável e livre de linguagem vaga**.
  - Trocar "should" por MUST/SHOULD com rationale quando apropriado.
- Remover comentários HTML do template ao preencher.
- Manter hierarquia de headings exatamente como no template.
- Não deixar nenhum placeholder `[...]` sem justificativa explícita.

### ETAPA 4: PROPAGAÇÃO

#### 4.1 Checklist de Consistência

Após gerar a constituição, verificar alinhamento com outros artefatos:

- [ ] `AGENTS.md`: princípios refletidos nas instruções do projeto?
- [ ] `docs/specs/*/plan.md`: plans existentes referenciam princípios?
- [ ] `docs/specs/*/tasks.md`: tasks refletem quality gates da constituição?

#### 4.2 Sync Impact Report

Gerar relatório de impacto como comentário HTML no topo do arquivo:

```markdown
<!--
Sync Impact Report
- Version: old -> new
- Princípios modificados: [lista]
- Seções adicionadas: [lista]
- Seções removidas: [lista]
- Artefatos que precisam atualização: [lista com status]
- TODOs pendentes: [lista]
-->
```

### ETAPA 5: SALVAMENTO

#### 5.1 Validação Final

Antes de salvar:
- [ ] Nenhum placeholder `[...]` sem justificativa.
- [ ] Versão consistente com relatório de impacto.
- [ ] Datas em formato ISO YYYY-MM-DD.
- [ ] Princípios são declarativos e testáveis.
- [ ] Sem trailing whitespace.

#### 5.2 Salvar

Salvar em `docs/constitution.md`, ou em caminho especificado pelo usuário.

#### 5.3 Relatório

Apresentar ao usuário:
- Nova versão e rationale do bump.
- Princípios criados/modificados.
- Artefatos que precisam atualização manual.
- Sugestão de commit message (ex: `docs: create project constitution v1.0.0`).

### EXEMPLOS DE PRINCÍPIOS

Os exemplos abaixo ilustram formato; adaptar ao domínio do projeto, não copiar literalmente.

**Princípios de arquitetura:**

- Library-First: features começam como bibliotecas standalone.
- Modularidade: serviços comunicam via contratos, não memória compartilhada.
- Simplicity: YAGNI; não abstrair prematuramente.

**Princípios de qualidade:**

- Test-First (NON-NEGOTIABLE): TDD obrigatório, Red-Green-Refactor.
- Integration Testing: testes contra sistema real, não mocks.
- Observability: logging estruturado obrigatório em todas as operações críticas.

**Princípios de UX/acessibilidade:**

- Component-First: UI construída de componentes reutilizáveis.
- Accessibility: WCAG 2.1 AA como mínimo.
- Progressive Enhancement: funcionalidade core funciona sem JS.

**Princípios de segurança/compliance:**

- Security: OWASP Top 10 como baseline.
- Deny by Default: permissões explícitas em vez de implícitas.
- Data Minimization: coletar/persistir só o necessário.

**Princípios de processo:**

- Documentation: código auto-documentado, comentários para o "por que".
- Reviewable Changes: PRs pequenos e focados, não merges gigantes.

### Gotchas

#### Princípios devem ser declarativos, testáveis e livres de linguagem vaga

"Sistema deve ser robusto" não é princípio, é aspiração. Trocar por MUST/SHOULD com rationale: "MUST: toda operação de escrita em banco deve ser idempotente (Why: retry sem corrupção de estado)".

#### Versão segue SemVer, e o bump deve ser justificado

- MAJOR: remove ou redefine princípio de forma incompatível.
- MINOR: adiciona princípio ou expande seção materialmente.
- PATCH: clarifica texto sem mudar semântica.

Se o bump é ambíguo, propor rationale ao usuário antes de finalizar. Datas e versão são auditadas.

#### Placeholders `[ALL_CAPS]` não sobrevivem no documento final

Todo placeholder no template tem que ser preenchido com conteúdo concreto ou marcado como `TODO(<CAMPO>): explicação`. Placeholders não resolvidos em produto final são indicador de constituição incompleta.

#### Princípios conflitantes invalidam a constituição

Se "Moving Fast" e "Zero Bugs" coexistem como princípios MUST, o projeto não tem governança; tem contradição. Detectar conflitos antes de salvar e pedir ao usuário para resolver a tensão, tipicamente promovendo um a MUST e rebaixando outro a SHOULD com trade-off documentado.

#### Sync Impact Report é obrigatório em atualizações

Bumps MAJOR/MINOR precisam listar quais artefatos (`AGENTS.md`, plans, tasks) precisam atualização. Sem isso, a constituição se desintegra dos outros documentos silenciosamente.
