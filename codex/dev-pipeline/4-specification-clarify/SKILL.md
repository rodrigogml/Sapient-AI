---
name: dev-pipeline-4-specification-clarify
description: Use after a feature spec exists when the user wants to refine ambiguities through structured Q&A and integrate the answers directly into the spec. This skill operates on an existing spec.md; use the specify step to create a new spec.
metadata:
  short-description: Refine existing SDD specs
---

# Dev Pipeline - 4. Specification - Clarify

## Overview

Identifique e resolva ambiguidades em uma feature spec existente via perguntas estruturadas, integrando as respostas diretamente no documento.

## Pré-requisitos

**Obrigatório**: `docs/specs/{feature-short-name}/spec.md` já existente, criado por `Dev Pipeline - 3. Specification - Specify` ou manualmente. Sem spec, abortar e orientar o usuário a criar a spec primeiro.

**Opcional**: `docs/constitution.md` para validar respostas contra princípios do projeto.

## When To Use

Use quando a spec já existe, mas ainda contém ambiguidades, lacunas, placeholders, `[NEEDS CLARIFICATION]`, requisitos pouco testáveis ou decisões que afetam arquitetura, modelo de dados, testes, UX, operação ou compliance.

Não use para criar uma spec do zero, revisar código, planejar implementação ou corrigir bugs.

## Output Contract

O resultado principal é a própria spec atualizada em `docs/specs/{feature-short-name}/spec.md`.

A skill deve adicionar ou atualizar a seção `## Clarifications`, registrar cada pergunta/resposta sob `### Session YYYY-MM-DD` e aplicar a resposta na seção mais apropriada da spec. No máximo 5 perguntas novas podem ser feitas.

## Workflow

1. **Localizar**: encontrar a spec existente.
2. **Escanear**: avaliar ambiguidades por taxonomia.
3. **Priorizar**: montar fila de até 5 perguntas.
4. **Perguntar**: fazer uma pergunta por vez.
5. **Integrar**: atualizar a spec após cada resposta aceita.
6. **Reportar**: resumir cobertura, mudanças e próximos passos.

## Próximos Passos

1. `Dev Pipeline - 5. Planning - Plan` — gerar plano técnico quando a spec estiver clara.
2. `Dev Pipeline - 6. Planning - Checklist` — gerar quality gate de requisitos após planejamento.
3. `Dev Pipeline - 4. Specification - Clarify` novamente — apenas se ambiguidades de alto impacto persistirem.


## ETAPA 1: LOCALIZAR SPEC

### 1.1 Encontrar Spec

Use o pedido do usuário para localizar a spec. Pode ser:

1. **Caminho direto**: `docs/specs/user-auth/spec.md`.
2. **Nome da feature**: buscar via `docs/specs/{feature-short-name}/spec.md`.
3. **Entrada vazia**: listar specs disponíveis e pedir ao usuário para escolher.

Se a spec não for encontrada, instrua o usuário a executar `Dev Pipeline - 3. Specification - Specify` primeiro.

### 1.2 Carregar Contexto

```text
CARREGAR:
-- A spec encontrada (obrigatório)
-- docs/constitution.md (se existir, para validar princípios)
-- docs/briefing/*.md (se necessário para contexto de produto)
```

## ETAPA 2: ESCANEAR AMBIGUIDADES

### 2.1 Taxonomia de Scan

Para cada categoria abaixo, marcar status: **Clear** / **Partial** / **Missing**.

**Escopo Funcional e Comportamento:**

- Objetivos core do usuário e critérios de sucesso.
- Declarações explícitas de fora-de-escopo.
- Diferenciação de papéis/personas de usuário.

**Domínio e Modelo de Dados:**

- Entidades, atributos, relacionamentos.
- Regras de identidade e unicidade.
- Transições de estado/lifecycle.
- Premissas de volume/escala de dados.

**Interação e Fluxo UX:**

- Jornadas críticas do usuário.
- Estados de erro/vazio/loading.
- Notas de acessibilidade ou localização.

**Qualidade Não Funcional:**

- Performance (latência, throughput).
- Escalabilidade (limites).
- Confiabilidade e disponibilidade (uptime, recuperação).
- Observabilidade (logging, métricas, tracing).
- Segurança e privacidade (authN/Z, proteção de dados).
- Compliance/regulatório.

**Integração e Dependências Externas:**

- Serviços/APIs externos e modos de falha.
- Formatos de import/export de dados.
- Premissas de protocolo/versionamento.

**Edge Cases e Tratamento de Falhas:**

- Cenários negativos.
- Rate limiting / throttling.
- Resolução de conflitos (ex: edições concorrentes).

**Constraints e Trade-offs:**

- Restrições técnicas (linguagem, storage, hosting).
- Trade-offs explícitos ou alternativas rejeitadas.

**Decisões de Infraestrutura Auditáveis (alta prioridade):**

- Política de scheduling (`autoSchedule = cron|wakeup|manual|auto`).
- Política de key rotation (versionamento `v1:<base64>` sim/não).
- Refresh policy (on-demand vs job periódico; gap window aceitável).
- Mutex multi-pod (lock advisory, redis, SELECT FOR UPDATE).
- Idempotência (chave, TTL, escopo).
- Backup/restore (cron, retenção, RB-NNN de drill).

Cada item ausente da spec mas relevante para a feature deve aparecer no topo da fila de perguntas, antes de UX e detalhes técnicos. Isso evita descobrir premissas operacionais tarde demais, durante planejamento ou execução.

**Terminologia e Consistência:**

- Termos canônicos do glossário.
- Sinônimos evitados / termos deprecados.

**Sinais de Completude:**

- Testabilidade dos critérios de aceite.
- Indicadores mensuráveis de Definition of Done.

**Placeholders e Pendências:**

- Marcadores TODO, ???, `<placeholder>`.
- Adjetivos ambíguos ("robusto", "intuitivo") sem quantificação.

### 2.2 Filtrar Oportunidades

Para cada categoria Partial ou Missing, adicionar candidato a pergunta EXCETO se:

- Clarificação não mudaria materialmente a implementação ou estratégia de validação.
- Informação é melhor resolvida na fase de planejamento, caso em que deve ser anotada internamente como Deferred.

## ETAPA 3: PRIORIZAR PERGUNTAS

### 3.1 Gerar Fila

Gerar fila priorizada de **máximo 5 perguntas**. Critérios:

- Cada pergunta deve ser respondível com:
  - **Multiple-choice** (2-5 opções mutuamente exclusivas), ou
  - **Resposta curta** (máx. 5 palavras).
- Só incluir perguntas cujas respostas impactam materialmente arquitetura, modelo de dados, decomposição de tasks, design de testes, comportamento UX, prontidão operacional ou compliance.
- Balancear cobertura de categorias: priorizar áreas de alto impacto não resolvidas.
- Se mais de 5 categorias não resolvidas existirem: selecionar top 5 por Impacto x Incerteza.

**Ordem de prioridade (alta -> baixa):**

1. **Decisões de Infraestrutura Auditáveis** — scheduling, key rotation, refresh policy, mutex multi-pod, idempotência.
2. **Escopo funcional** — fora-de-escopo declarado, papéis distintos.
3. **Domínio e Modelo de Dados** — entidades, identidade, lifecycle.
4. **Qualidade não funcional** — performance, segurança, compliance.
5. **UX e interação** — jornadas críticas, edge cases.
6. **Constraints técnicas** — linguagem, storage, hosting.

Aplicar essa ordem dentro do top-5 final.

### 3.2 Excluir

- Perguntas já respondidas na spec.
- Preferências estilísticas triviais.
- Detalhes de execução do plan, a menos que bloqueiem corretude.

## ETAPA 4: PERGUNTAR

### 4.1 Formato: Uma Pergunta por Vez

**Para perguntas multiple-choice:**

1. Analisar todas as opções e determinar a **mais adequada** baseado em:
   - Best practices para o tipo de projeto.
   - Padrões comuns em implementações similares.
   - Redução de risco (segurança, performance, manutenção).
   - Alinhamento com constitution, se existir.

2. Apresentar:

```markdown
## Pergunta [N]: [Tópico]

**Contexto**: [Citar seção relevante da spec]

**O que precisamos saber**: [Pergunta específica]

**Recomendado:** Opção [X] - [raciocínio em 1-2 frases]

| Opção | Descrição |
|-------|-----------|
| A     | [Descrição opção A] |
| B     | [Descrição opção B] |
| C     | [Descrição opção C] |

Responda com a letra da opção (ex: "A"), aceite a recomendação com "sim", ou forneça sua própria resposta curta.
```

**Para perguntas de resposta curta:**

```markdown
## Pergunta [N]: [Tópico]

**Contexto**: [Citar seção relevante]

**Sugestão:** [resposta sugerida] - [raciocínio breve]

Formato: resposta curta (máx. 5 palavras). Aceite a sugestão com "sim" ou forneça sua própria resposta.
```

### 4.2 Após Cada Resposta

- Se usuário responde "sim", "recomendado" ou "sugestão": usar a opção recomendada/sugerida.
- Validar que a resposta mapeia a uma opção ou cabe no constraint de 5 palavras.
- Se ambíguo: pedir desambiguação rápida, sem contar como nova pergunta.
- Registrar em memória de trabalho e avançar para próxima pergunta.

### 4.3 Parar Quando

- Todas as ambiguidades críticas foram resolvidas.
- Usuário sinaliza conclusão ("pronto", "done", "sem mais").
- 5 perguntas foram feitas.

## ETAPA 5: INTEGRAR RESPOSTAS

### 5.1 Após CADA Resposta Aceita

Atualizar a spec imediatamente:

1. Garantir que seção `## Clarifications` existe (criar logo após seção de contexto/overview).
2. Sob `### Session YYYY-MM-DD`, adicionar:

   ```markdown
   - Q: [pergunta] -> A: [resposta final]
   ```

3. Aplicar clarificação na seção mais apropriada:

| Tipo de Clarificação | Seção Alvo |
|---------------------|------------|
| Ambiguidade funcional | Functional Requirements |
| Distinção de ator/interação | User Stories ou Actors |
| Shape de dados/entidades | Key Entities |
| Constraint não funcional | Success Criteria ou nova seção NFR |
| Edge case/fluxo negativo | Edge Cases |
| Conflito de terminologia | Normalizar termo em toda a spec |

4. Se a clarificação invalida afirmação anterior: **substituir**, não duplicar.
5. Salvar spec **após cada integração**.
6. Preservar formatação: não reordenar seções; manter hierarquia de headings.

### 5.2 Validação Após Cada Write

- Seção Clarifications contém exatamente um bullet por resposta aceita.
- Total de perguntas feitas <= 5.
- Seções atualizadas não contêm placeholders que a resposta deveria resolver.
- Nenhuma afirmação contraditória anterior permanece.
- Markdown válido; únicos headings novos permitidos: `## Clarifications`, `### Session YYYY-MM-DD`.
- Consistência terminológica: mesmo termo canônico em todas as seções atualizadas.

## ETAPA 6: REPORTAR

### 6.1 Relatório de Conclusão

```markdown
## Clarificação Concluída

**Spec**: [caminho]
**Perguntas feitas**: [N]
**Seções atualizadas**: [lista]

### Cobertura

| Categoria | Status |
|-----------|--------|
| Escopo Funcional | Clear / Resolved / Deferred / Outstanding |
| Modelo de Dados | Clear / Resolved / Deferred / Outstanding |
| Fluxo UX | Clear / Resolved / Deferred / Outstanding |
| Qualidade Não Funcional | Clear / Resolved / Deferred / Outstanding |
| Integrações | Clear / Resolved / Deferred / Outstanding |
| Edge Cases | Clear / Resolved / Deferred / Outstanding |
| Constraints | Clear / Resolved / Deferred / Outstanding |
| Terminologia | Clear / Resolved / Deferred / Outstanding |

**Legenda:**
- **Resolved**: era Partial/Missing, resolvido nesta sessão.
- **Deferred**: excede cota de perguntas ou é melhor resolvido no planejamento.
- **Clear**: já estava suficiente.
- **Outstanding**: ainda Partial/Missing, mas baixo impacto.

### Próximo Passo

- `Dev Pipeline - 5. Planning - Plan` — gerar plano técnico de implementação.
- `Dev Pipeline - 4. Specification - Clarify` novamente — se Outstanding de alto impacto restarem.
```

### 6.2 Regras de Comportamento

- Se nenhuma ambiguidade significativa encontrada: "Nenhuma ambiguidade crítica detectada." e sugerir prosseguir.
- Se spec não existe: instruir a executar `Dev Pipeline - 3. Specification - Specify` primeiro.
- Nunca exceder 5 perguntas totais; retries de desambiguação não contam.
- Evitar perguntas especulativas sobre tech stack, a menos que bloqueiem clareza funcional.
- Respeitar sinais de encerramento do usuário ("stop", "done", "prosseguir").
- Se cota esgotada com categorias Outstanding de alto impacto: marcar explicitamente como Deferred com rationale.

## Gotchas

### Máximo 5 perguntas TOTAL: não "só mais uma"

Retries de desambiguação, quando a resposta do usuário foi ambígua, não contam; perguntas novas contam. Exceder o limite corrói o valor da skill. Se 5 não resolveram tudo, documente as ambiguidades restantes como Deferred e passe para `Dev Pipeline - 5. Planning - Plan`.

### Uma pergunta por vez: esperar resposta antes de avançar

Despejar 5 perguntas de uma vez parece eficiente, mas quebra a integração incremental. Cada resposta aceita dispara um write na spec; perguntas em lote perdem esse ciclo.

### Write após cada resposta

Integre a resposta na spec imediatamente; não acumule respostas para integrar no final. Se o usuário interromper na pergunta 3, as 2 respostas anteriores já estão persistidas.

### Respostas devem mapear para opções ou ter até 5 palavras

Respostas livres longas violam o contrato do formato. Se o usuário responder em texto longo, sintetize em resposta curta e confirme; não integre o texto cru na spec.

### Se a spec não existe, abortar e instruir Specify

Não tente "clarificar do nada" inferindo o que a spec poderia ser. A skill opera sobre texto existente. Sem texto, use `Dev Pipeline - 3. Specification - Specify` primeiro.

### Não reordenar seções nem reescrever heading hierarchy

As únicas adições estruturais permitidas são `## Clarifications` e `### Session YYYY-MM-DD`. Alterar outros headings contamina o diff e quebra ferramentas downstream.
