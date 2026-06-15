# Consistency Checks Reference

Detalhamento dos 7 passes de detecção executados pela skill `dev-pipeline-8-implementation-analyze`. Cada pass opera sobre os modelos semânticos construídos na etapa de modelagem.

---

## A. Detecção de Duplicação

**Objetivo**: identificar requisitos near-duplicate que deveriam ser consolidados.

- Comparar requisitos funcionais por similaridade semântica: mesmo verbo, mesmo objeto ou mesmo outcome.
- Marcar fraseado de menor qualidade para consolidação.
- Duplicações entre user stories e functional requirements são comuns e devem ser apontadas quando criarem ambiguidade ou manutenção duplicada.

**Severidade típica**: `HIGH` quando requisitos são duplicados em mais de uma seção; `MEDIUM` quando há apenas near-duplicate com leve diferença de fraseado.

---

## B. Detecção de Ambiguidade

**Objetivo**: encontrar texto vago ou placeholder que impede implementação.

Apontar:

- Adjetivos vagos sem critérios mensuráveis: `rápido`, `escalável`, `seguro`, `intuitivo`, `robusto`, `amigável`, `flexível`.
- Placeholders não resolvidos: `TODO`, `TKTK`, `???`, `<placeholder>`, `[NEEDS CLARIFICATION]`, `XXX`.
- Verbos sem objeto: "Sistema deve suportar" sem dizer o que deve ser suportado.
- Quantificadores vagos: "muitos usuários", "pouco tempo", "alguns casos".

**Severidade típica**: `HIGH` para segurança/performance ambíguas; `MEDIUM` para os demais casos.

---

## C. Subespecificação

**Objetivo**: detectar requisitos incompletos.

- Requisitos com verbos, mas sem objeto ou outcome mensurável.
- User stories sem critérios de aceite alinhados.
- Tasks referenciando arquivos, componentes ou comportamentos não definidos em spec/plan.
- Success criteria sem threshold numérico quando o resultado precisa ser mensurado.

**Severidade típica**: `HIGH` quando afeta requisito de alto impacto; `MEDIUM` para suporte.

---

## D. Alinhamento com Constitution

**Objetivo**: garantir que design e requisitos respeitam princípios de governança.

- Qualquer requisito ou elemento do plan conflitando com princípio `MUST`.
- Seções obrigatórias ou quality gates da constitution ausentes no plan/tasks.
- Decisões técnicas que violam defaults da constitution sem justificativa explícita.

**Severidade**: violações de constitution são automaticamente `CRITICAL`, independentemente do contexto.

---

## E. Gaps de Cobertura

**Objetivo**: detectar requisitos órfãos e tasks órfãs.

- Requisitos com zero tasks associadas.
- Tasks sem requisito/story mapeado.
- Requisitos não funcionais não refletidos em tasks: performance, security, observability.
- Edge cases da spec sem tarefa correspondente.
- Gaps de checklist não consumidos pelo backlog.

**Severidade típica**: `HIGH` para requisitos funcionais core sem cobertura; `MEDIUM` para NFRs parciais.

---

## F. Inconsistência

**Objetivo**: detectar drift entre artefatos.

- **Drift de terminologia**: mesmo conceito nomeado de forma diferente entre artefatos, por exemplo "cliente" na spec, "customer" no plan e "user" nas tasks.
- Entidades referenciadas no plan ausentes na spec, ou vice-versa.
- Contradições de ordenação de tasks, como tasks de integração antes de setup sem nota de dependência.
- Requisitos conflitantes, por exemplo uma seção requer Next.js e outra especifica Vue.
- State transitions na spec divergentes do data model no plan.

**Severidade típica**: `HIGH` para contradições; `MEDIUM` para drift de terminologia.

---

## G. Convenções de Borda

**Objetivo**: detectar divergência entre convenções declaradas e uso real nos artefatos.

- Comparar `plan.md` seção `Convenções de Borda` contra `data-model.md`, `contracts/*.md`, exemplos de payload e tasks.
- Se o plan declara DB em `snake_case`, mas `data-model.md` cita coluna `userName`, apontar `HIGH`.
- Se contracts declaram payload em `camelCase`, mas exemplo usa `user_name`, apontar `HIGH`.
- Se tasks atravessam fronteiras sem subtarefa de mapper ou validação de paridade, apontar `MEDIUM` ou `HIGH`, conforme risco.

**Severidade típica**: `HIGH` quando o drift afeta payload, persistência, contrato externo ou integração; `MEDIUM` quando é apenas documentação incompleta.

---

## Heurística de Severidade

| Severidade | Critério |
|------------|----------|
| `CRITICAL` | Viola princípio `MUST` da constitution, artefato core ausente, requisito com zero cobertura que bloqueia funcionalidade baseline |
| `HIGH` | Requisito duplicado ou conflitante, atributo de segurança/performance ambíguo, critério de aceite não testável, contrato divergente |
| `MEDIUM` | Drift de terminologia, cobertura ausente de requisito não funcional, edge case subespecificado, checklist gap não consumido |
| `LOW` | Melhoria de estilo/redação, redundância menor que não afeta ordem de execução |

---

## Limites Operacionais

- Máximo de 50 findings; overflow vai para resumo.
- Resultados devem ser determinísticos: reexecutar sem mudanças produz os mesmos IDs e contagens.
- Nunca alucinar seções ausentes; reportar como gap.
- Findings devem citar localização concreta sempre que possível.
