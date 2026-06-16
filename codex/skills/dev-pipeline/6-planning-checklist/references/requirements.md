# Domínio: Requirements (Genérico)

Itens exemplo para checklist de qualidade geral de requisitos. Usar quando o domínio específico não se aplica ou como complemento.

## Completude

- Todos os requisitos funcionais necessários estão documentados? [Completude]
- Requisitos não funcionais estão cobertos (performance, security, observability)? [Completude]
- Declarações explícitas de fora-de-escopo estão documentadas? [Completude]

## Clareza

- Cada requisito usa verbo imperativo testável (MUST, SHOULD)? [Clareza]
- Adjetivos vagos (robusto, escalável, intuitivo) são quantificados? [Clareza]
- Placeholders (TODO, TKTK, ???) foram resolvidos? [Completude]

## Consistência

- Requisitos se alinham sem conflitos entre si? [Consistência]
- Terminologia é consistente (mesmo conceito com mesmo nome)? [Consistência]
- Requisitos não contradizem princípios da constitution? [Constitution Alignment]

## Mensurabilidade

- Success criteria são objetivamente verificáveis? [Mensurabilidade]
- Critérios de aceite podem ser transformados em teste automatizado? [Mensurabilidade]
- Métricas têm threshold definido (não apenas "deve ser rápido")? [Clareza]

## Cobertura de Cenários

- Happy paths estão documentados? [Cobertura]
- Error paths têm comportamento esperado definido? [Cobertura]
- Edge cases (limite, concorrência, timeout) são cobertos? [Edge Case, Gap]

## Dependências e Premissas

- Dependências externas são explícitas e validadas? [Completude]
- Premissas assumidas estão documentadas? [Clareza]
- Fallbacks em caso de dependência indisponível são definidos? [Completude]

## Rastreabilidade

- User stories se ligam a requisitos funcionais? [Traceability]
- Tasks mapeiam a requisitos/stories? [Traceability]
- Critérios de aceite se ligam a success criteria? [Traceability]

## Ambiguidades

- Marcações `[NEEDS CLARIFICATION]` foram resolvidas? [Ambiguity]
- Requisitos com interpretação múltipla foram refinados? [Ambiguity]
