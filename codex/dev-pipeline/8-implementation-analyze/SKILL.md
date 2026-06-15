---
name: dev-pipeline-8-implementation-analyze
description: Use after spec, plan, tasks, and optional constitution/checklists exist when the user wants a read-only cross-artifact consistency analysis across SDD documents. This skill finds inconsistencies, duplicated requirements, ambiguities, coverage gaps, constitution violations, and drift between spec, plan, tasks, contracts, and checklists. Skip for editing documents or validating a single document in isolation.
metadata:
  short-description: Analyze SDD artifact consistency
---

# Dev Pipeline - 8. Implementation - Analyze

## Overview

Execute uma análise read-only para identificar inconsistências, duplicações, ambiguidades e gaps de cobertura entre artefatos de uma feature: `spec.md`, `plan.md`, `tasks.md`, checklists e constitution.

## Pré-requisitos

**Obrigatório**: `spec.md` e `tasks.md` existentes na feature a analisar. Sem ambos, aborte e indique qual etapa do pipeline deve ser executada primeiro.

**Recomendado**: `plan.md`, `docs/constitution.md` e `docs/specs/{feature-short-name}/checklists/*.md`, quando existirem, aumentam a cobertura da análise.

## When To Use

Use quando o usuário quiser auditar a consistência entre artefatos antes de implementar, revisar se requisitos possuem cobertura em tarefas, detectar drift entre spec/plan/tasks, validar aderência à constitution ou encontrar ambiguidades remanescentes.

Não use para editar arquivos, remediar findings automaticamente, validar apenas um documento isolado ou testar comportamento de código.

## Output Contract

O resultado é um relatório Markdown na conversa. Esta skill não escreve, não edita e não cria arquivos.

O relatório deve conter findings priorizados, resumo de cobertura, alinhamento com constitution, tarefas não mapeadas, métricas e recomendações de próximos passos.

## Workflow

1. **Inicializar**: localizar e carregar artefatos.
2. **Modelar**: construir modelos semânticos internos.
3. **Detectar**: executar passes de consistência.
4. **Classificar**: atribuir severidade.
5. **Reportar**: gerar relatório compacto.
6. **Recomendar**: sugerir próximas ações sem modificar arquivos.

## Próximos Passos

1. Se houver issues `CRITICAL`, resolver antes de `Dev Pipeline - 9. Implementation - Execute Task`.
2. Se houver apenas `LOW`/`MEDIUM`, prosseguir com execução pode ser aceitável, mas com cleanup agendado.
3. Usar `Dev Pipeline - 3. Specification - Specify`, `Dev Pipeline - 4. Specification - Clarify`, `Dev Pipeline - 5. Planning - Plan` ou `Dev Pipeline - 7. Implementation - Create Tasks` conforme o tipo de finding.

## ETAPA 1: INICIALIZAR

### 1.1 Localizar Artefatos

Use o pedido do usuário para encontrar o diretório da feature e derivar paths absolutos:

- `SPEC` = `{feature_dir}/spec.md`
- `PLAN` = `{feature_dir}/plan.md`
- `TASKS` = `{feature_dir}/tasks.md`
- `CHECKLISTS` = `{feature_dir}/checklists/*.md`
- `CONSTITUTION` = `docs/constitution.md`

Se o argumento estiver vazio, liste diretórios em `docs/specs/` e peça ao usuário para escolher.

Artefatos obrigatórios: `spec.md` e `tasks.md`, ou equivalente explicitamente indicado pelo usuário. Se algum estiver ausente, aborte com mensagem indicando a etapa anterior necessária:

- Sem `spec.md`: `Dev Pipeline - 3. Specification - Specify`.
- Spec ambígua: `Dev Pipeline - 4. Specification - Clarify`.
- Sem `plan.md`, quando análise técnica for solicitada: `Dev Pipeline - 5. Planning - Plan`.
- Sem `tasks.md`: `Dev Pipeline - 7. Implementation - Create Tasks`.

### 1.2 Carregar Artefatos

Carregue apenas porções relevantes; não despeje documentos completos no relatório.

Da spec:

- Overview/contexto.
- Functional Requirements.
- Non-Functional Requirements.
- User Stories.
- Edge Cases, se presente.
- Success Criteria.

Do plan, se existir:

- Arquitetura e stack choices.
- Referências a data model.
- Contratos.
- Fases.
- Constraints técnicos.
- Convenções de borda.

Do tasks:

- IDs de tarefas.
- Descrições.
- Agrupamento por fase.
- Criticidade.
- Referências a documentação.
- Paths de arquivo referenciados.

Dos checklists, se existirem:

- Itens abertos `[Gap]`, `[Ambiguity]`, `[Conflict]`.
- Itens `{humano}` pendentes que impliquem decisão ou trabalho.
- Itens resolvidos que sustentam cobertura.

Da constitution, se existir:

- Princípios `MUST`/`SHOULD`.
- Quality gates.
- Restrições de arquitetura, processo e qualidade.

## ETAPA 2: MODELAR

### 2.1 Construir Modelos Semânticos

Crie representações internas. Não inclua artefatos raw no output.

**Inventário de Requisitos**

- Cada requisito funcional e não funcional com chave estável.
- Derivar slug do verbo e objeto principal, por exemplo `user-can-upload-file`.
- Preservar IDs explícitos quando existirem.

**Inventário de User Stories/Ações**

- Ações discretas do usuário.
- Critérios de aceite.
- Prioridade e escopo.

**Mapeamento de Cobertura de Tasks**

- Mapear cada task a um ou mais requisitos/stories.
- Usar referências explícitas primeiro.
- Usar inferência por keyword, frases-chave e entidades quando não houver referência.
- Marcar baixa confiança quando o mapeamento for fraco.

**Conjunto de Regras da Constitution**

- Extrair nomes de princípios.
- Separar `MUST` de `SHOULD`.
- Tratar violação de `MUST` como `CRITICAL`.

## ETAPA 3: DETECTAR

### 3.1 Passes de Detecção

Execute 7 passes sobre os modelos semânticos. O detalhamento completo de cada pass fica em `references/consistency-checks.md`, no diretório desta skill.

- **A. Duplicação** - requisitos near-duplicate.
- **B. Ambiguidade** - adjetivos vagos, placeholders não resolvidos, termos não mensuráveis.
- **C. Subespecificação** - verbos sem objeto, critérios incompletos, success criteria sem threshold.
- **D. Alinhamento com Constitution** - violações de `MUST` são automaticamente `CRITICAL`.
- **E. Gaps de Cobertura** - requisitos órfãos, tasks órfãs, NFRs sem tarefas.
- **F. Inconsistência** - drift de terminologia, entidades divergentes, contradições.
- **G. Convenções de Borda** - case style e contratos divergentes entre plan, data model, contracts e exemplos.

Foque em findings de alto sinal. Limite: 50 findings total. Agregue o restante em resumo de overflow.

### 3.2 Convenções de Borda

Quando `plan.md` declarar `Convenções de Borda`, compare contra `data-model.md`, `contracts/*.md`, exemplos de payload e tasks.

Exemplos:

- Plan declara DB em `snake_case`, mas `data-model.md` cita coluna `userName`: flag `HIGH`.
- Contracts declaram payload `camelCase`, mas exemplo usa `user_name`: flag `HIGH`.
- Tasks implementam mapper sem subtarefa de validação de paridade: flag `MEDIUM` ou `HIGH`, conforme risco.

## ETAPA 4: CLASSIFICAR

### 4.1 Heurística de Severidade

| Severidade | Critério |
|------------|----------|
| `CRITICAL` | Violação de `MUST` na constitution, artefato core ausente, requisito core sem cobertura |
| `HIGH` | Duplicação/conflito, segurança/performance ambígua, critério não testável, contrato divergente |
| `MEDIUM` | Drift de terminologia, NFR parcialmente coberto, edge case subespecificado |
| `LOW` | Estilo, redundância menor, melhoria de clareza sem impacto direto |

Use `references/consistency-checks.md#heuristica-de-severidade` quando precisar de mais detalhes.

## ETAPA 5: REPORTAR

### 5.1 Formato do Relatório

Produza relatório Markdown na conversa. Não escreva arquivo.

```markdown
## Specification Analysis Report

### Findings

| ID | Categoria | Severidade | Localização | Resumo | Recomendação |
|----|-----------|------------|-------------|--------|--------------|
| A1 | Duplicação | HIGH | spec.md §FR-3, §FR-7 | Requisitos similares sobre... | Unificar e manter versão mais clara |
| B1 | Ambiguidade | MEDIUM | spec.md §SC-002 | "rápido" sem métrica | Quantificar com threshold |
| D1 | Constitution | CRITICAL | plan.md §Tech | Viola princípio Test-First | Ajustar plano antes da execução |
| E1 | Cobertura | HIGH | spec.md §FR-005 | Zero tasks mapeadas | Adicionar task em tasks.md |

### Coverage Summary

| Requisito | Tem Task? | Task IDs | Notas |
|-----------|-----------|----------|-------|
| FR-001 | Sim | 1.2, 1.4 | |
| FR-002 | Sim | 2.1 | |
| FR-003 | Não | - | Gap: sem tasks |

### Constitution Alignment

[Lista de violações ou "Todos os princípios atendidos"]

### Unmapped Tasks

[Tasks sem requisito/story correspondente ou "Todas as tasks mapeadas"]

### Métricas

- **Total de Requisitos**: [N]
- **Total de Tasks**: [N]
- **Cobertura**: [N]% (requisitos com >= 1 task)
- **Ambiguidades**: [N]
- **Duplicações**: [N]
- **Issues Críticas**: [N]
```

### 5.2 Finding IDs

Use IDs determinísticos por categoria:

- `A1`, `A2` para duplicação.
- `B1`, `B2` para ambiguidade.
- `C1`, `C2` para subespecificação.
- `D1`, `D2` para constitution.
- `E1`, `E2` para cobertura.
- `F1`, `F2` para inconsistência.
- `G1`, `G2` para convenções de borda.

Ordene por severidade e depois por localização estável.

## ETAPA 6: RECOMENDAR

### 6.1 Próximas Ações

Baseado nos findings:

- Se issues `CRITICAL` existem, recomendar resolver antes de `Dev Pipeline - 9. Implementation - Execute Task`.
- Se apenas `LOW`/`MEDIUM`, o usuário pode prosseguir, mas deve receber sugestões de melhoria.
- Se a correção pertence à spec, recomendar `Dev Pipeline - 4. Specification - Clarify` ou edição explícita da spec.
- Se a correção pertence ao plano, recomendar `Dev Pipeline - 5. Planning - Plan`.
- Se a correção é cobertura de tarefas, recomendar `Dev Pipeline - 7. Implementation - Create Tasks` ou edição de `tasks.md`.

### 6.2 Oferecer Remediação

Pergunte ao usuário:

"Deseja que eu sugira edições concretas de remediação para os principais findings?"

Não aplicar automaticamente. Apenas sugerir ou editar se o usuário aprovar explicitamente.

## Regras Importantes

- Nunca modificar arquivos nesta skill.
- Nunca alucinar seções ausentes; se algo não existe, reporte com precisão.
- Priorizar violações de constitution; `MUST` violado é sempre `CRITICAL`.
- Usar exemplos específicos, não regras genéricas sem evidência.
- Reportar zero issues com relatório de sucesso e estatísticas de cobertura.
- Manter resultados determinísticos: reexecutar sem mudanças deve produzir IDs e contagens consistentes.
- Limitar a 50 findings e agregar overflow.

## Diferença de Validação de Documento

Esta skill valida múltiplos artefatos entre si. Uma validação de documento isolado verifica apenas estrutura e qualidade interna de um único arquivo.

Use `Dev Pipeline - 8. Implementation - Analyze` para consistência cross-artifact. Use uma skill específica de validação documental apenas quando o pedido for revisar um documento isolado sem cruzar spec, plan e tasks.

## Gotchas

### Read-only é contrato da skill

A skill não escreve nem edita arquivos. Se uma correção parece óbvia, sugira no relatório e aguarde aprovação explícita do usuário.

### Violações de constitution são sempre CRITICAL

Se conflita com um princípio `MUST`, a severidade é `CRITICAL` e bloqueia execução até resolver. Não rebaixe para `HIGH` por contexto.

### Max 50 findings

Mais do que 50 findings dilui o sinal. Priorize por impacto e incerteza; agregue o restante em um resumo de overflow.

### Não inventar seções ausentes

Se a spec não tem "Edge Cases", reporte como gap. O papel desta skill é detectar, não preencher.

### Resultados devem ser determinísticos

Reexecutar a análise sem mudanças nos artefatos deve produzir os mesmos IDs, contagens e severidades. Se duas execuções consecutivas divergem, reveja os critérios de mapeamento.
