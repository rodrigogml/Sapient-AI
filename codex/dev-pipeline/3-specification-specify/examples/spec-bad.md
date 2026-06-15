# Example: Common Anti-Patterns in Specs

Este exemplo mostra erros típicos em specs, anotados com correção sugerida.

---

## Anti-padrão 1: Detalhes de implementação na spec

### Errado

> **FR-001**: System MUST hash passwords with bcrypt (cost factor 12) and store in PostgreSQL `users.password_hash` column.

**Por que está errado**: "bcrypt", "cost factor 12" e "PostgreSQL column" são detalhes de implementação. A spec responde QUE e POR QUE; COMO vai para `Dev Pipeline - 5. Planning - Plan`.

### Correto

> **FR-001**: System MUST store credentials using industry-standard one-way hashing with adaptive cost.

A decisão de algoritmo (bcrypt vs Argon2), parâmetros e coluna do banco vai para o plano técnico.

---

## Anti-padrão 2: Success criteria com jargão técnico

### Errado

- **SC-001**: API response time under 200ms
- **SC-002**: Database handles 1000 TPS
- **SC-003**: React components render efficiently with <50ms paint time

**Por que está errado**: "API", "TPS", "React", "paint time"; nada disso é verificável pela perspectiva do usuário. Se você trocar React por Vue, o sistema ainda precisa ser bom para o usuário.

### Correto

- **SC-001**: 95% dos cliques retornam resultado visível em <1s
- **SC-002**: Sistema suporta 10.000 usuários concorrentes sem degradação percebida
- **SC-003**: Busca retorna resultados em <2 segundos mesmo com 1M de registros

---

## Anti-padrão 3: User stories que dependem umas das outras

### Errado

> **Story P1**: Usuário cria conta
> **Story P2**: Usuário configura perfil (requer Story P1 completa)
> **Story P3**: Usuário busca outros usuários (requer Story P2 completa)

**Por que está errado**: Se só implementar P1, não há MVP; não dá para logar ou usar o sistema. Stories deveriam ser camadas de valor independente.

### Correto

Reestruturar para que cada story entregue valor standalone:

> **Story P1**: Login + uso mínimo da feature principal (entrega valor ao usuário)
> **Story P2**: Personalização de perfil (melhora UX, mas P1 já é usável)
> **Story P3**: Descoberta social (agrega mas não bloqueia uso básico)

---

## Anti-padrão 4: Adjetivos vagos sem quantificação

### Errado

> **FR-005**: System MUST be fast and responsive
> **FR-006**: System MUST be secure
> **FR-007**: UI MUST be intuitive

**Por que está errado**: "Fast", "secure", "intuitive"; quem mede? Como testa? Três pessoas vão discordar da definição.

### Correto

> **FR-005**: System MUST responder a ações de usuário em <500ms em 99% dos casos
> **FR-006**: System MUST seguir OWASP Top 10:2025 como baseline (em checklist separado)
> **FR-007**: 80% dos novos usuários MUST completar onboarding sem ajuda (medido em teste de usabilidade)

---

## Anti-padrão 5: Excesso de `[NEEDS CLARIFICATION]`

### Errado

Spec com 8 marcadores `[NEEDS CLARIFICATION]` espalhados: "qual provider de email?", "qual TTL do token?", "quanto tempo guardar logs?", "mobile ou web?", etc.

**Por que está errado**: Mais de 3 marcadores indica que a spec deveria voltar ao briefing antes de escrever. A skill limita exatamente por isso.

### Correto

- Priorizar: escopo > segurança > UX > tech.
- Manter só os 3 mais críticos como `[NEEDS CLARIFICATION]`.
- Para o resto, usar defaults informados e documentar a suposição:
  > FR-009: System MUST reter logs por 90 dias (*default padrão indústria; ajustar em `Dev Pipeline - 5. Planning - Plan` se compliance específico exigir*)

---

## Anti-padrão 6: Seções vazias com "N/A"

### Errado

> ## Key Entities
>
> N/A

**Por que está errado**: "N/A" é ruído no documento e confunde skills downstream (`Dev Pipeline - 5. Planning - Plan`, `Dev Pipeline - 7. Implementation - Create Tasks`).

### Correto

Remover a seção inteira. Se a feature não envolve entidades de dados, o header não precisa existir.
