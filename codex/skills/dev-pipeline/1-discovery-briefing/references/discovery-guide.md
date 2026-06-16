# Discovery Guide: 7 Dimensões da Entrevista

Roteiro detalhado para a etapa de entrevista do `briefing`. Cada dimensão tem 1-2 perguntas. Perguntas são feitas **UMA POR VEZ**, aguardando resposta.

## DIMENSÃO 1: Visão e Propósito

**O que captura**: A essência do projeto — o que é, por que existe, qual problema resolve.

**Pergunta 1.1 — Elevator Pitch**:

```markdown
## Pergunta 1: Visão do Projeto

Descreva o projeto em 2-3 frases, como se estivesse explicando para alguém que nunca ouviu falar dele.

**O que preciso saber**:
- O que o projeto FAZ
- Qual PROBLEMA resolve
- Para QUEM

**Exemplo**: "Um sistema de gestão de pedidos que permite lojistas acompanharem vendas em tempo real e emitirem notas automaticamente. Resolve o problema de visibilidade operacional para pequenos comércios."

Responda com sua descrição livre.
```

## DIMENSÃO 2: Usuários e Stakeholders

**O que captura**: Quem usa o sistema e quem toma decisões.

**Pergunta 2.1 — Atores Principais**:

```markdown
## Pergunta 2: Usuários e Atores

Quem são os USUÁRIOS do sistema? Liste os tipos de usuário (personas/papéis) e o que cada um faz.

**Exemplos de papéis**: admin, operador, cliente final, parceiro, sistema externo

**Formato sugerido**:
- [Papel]: [O que faz no sistema]
- [Papel]: [O que faz no sistema]

Responda listando os papéis, ou descreva livremente.
```

## DIMENSÃO 3: Escopo e Prioridades

**O que captura**: O que está dentro e fora do escopo, e o que é mais importante.

**Pergunta 3.1 — Features Core vs Nice-to-Have**:

```markdown
## Pergunta 3: Escopo e Prioridades

Quais são as funcionalidades ESSENCIAIS (sem elas o projeto não faz sentido) vs funcionalidades DESEJÁVEIS (agregam valor mas podem esperar)?

**Formato sugerido**:

**Essenciais (MVP)**:
1. [Feature]
2. [Feature]

**Desejáveis (pós-MVP)**:
1. [Feature]
2. [Feature]

Responda listando ou descrevendo livremente.
```

**Pergunta 3.2 — Trade-offs** (se projeto não-trivial):

```markdown
## Pergunta 4: Trade-offs

Quando precisar escolher, qual sua prioridade?

| Opção | Descrição |
|-------|-----------|
| A | **Velocidade de entrega** — Lançar rápido, iterar depois |
| B | **Qualidade e robustez** — Fazer bem feito, mesmo que demore |
| C | **Escopo completo** — Entregar tudo planejado, ajustando prazo |
| D | **Experiência do usuário** — UX impecável, mesmo sacrificando features |

Responda com a letra (ou ordene por prioridade, ex: "B > D > A > C").
```

## DIMENSÃO 4: Restrições

**O que captura**: Limites reais do projeto — tempo, equipe, orçamento, tech.

**Pergunta 4.1 — Restrições do Projeto**:

```markdown
## Pergunta 5: Restrições

Quais restrições o projeto tem? Responda o que souber:

- **Prazo**: Há deadline? (ex: "lançar em 3 meses", "sem prazo fixo")
- **Equipe**: Quantas pessoas? Qual experiência? (ex: "1 dev fullstack senior")
- **Budget**: Há limitação de custo? (ex: "usar apenas serviços free-tier")
- **Técnica**: Alguma tecnologia obrigatória ou proibida? (ex: "tem que ser em Go", "sem vendor lock-in")

Responda o que for relevante — pode pular itens que não se aplicam.
```

## DIMENSÃO 5: Contexto Técnico

**O que captura**: Stack, infraestrutura, integrações.

**Pergunta 5.1 — Stack e Infraestrutura**:

Pular se já inferido de arquivos do projeto (go.mod, package.json, etc.).

```markdown
## Pergunta 6: Stack Técnica

Qual a stack técnica do projeto? Se ainda não decidiu, descreva preferências.

**Categorias**:
- **Backend**: (ex: Go, Node.js, Python, Java)
- **Frontend**: (ex: React, Vue, mobile nativo, nenhum)
- **Banco de dados**: (ex: PostgreSQL, MongoDB, SQLite)
- **Infraestrutura**: (ex: Docker, Kubernetes, serverless, VPS)
- **Integrações externas**: (ex: Stripe, SendGrid, APIs de terceiros)

Responda o que souber. Se preferir que eu sugira, diga "sugira baseado no projeto".
```

## DIMENSÃO 6: Qualidade e Padrões

**O que captura**: Expectativas de qualidade, compliance, observabilidade.

**Pergunta 6.1 — Padrões de Qualidade**:

```markdown
## Pergunta 7: Qualidade e Padrões

Quais padrões de qualidade são importantes para o projeto?

| Opção | Descrição |
|-------|-----------|
| A | **Testes rigorosos** — TDD, cobertura alta, CI/CD |
| B | **Segurança primeiro** — OWASP, auditoria, compliance (LGPD/GDPR) |
| C | **Observabilidade** — Logging, métricas, alertas, tracing |
| D | **Performance** — Baixa latência, alta concorrência |
| E | **Acessibilidade** — WCAG, i18n, suporte a múltiplos dispositivos |
| F | **Documentação** — Código documentado, ADRs, specs completos |

Selecione todas que se aplicam (ex: "A, B, F") ou descreva suas expectativas.
```

## DIMENSÃO 7: Visão de Futuro

**O que captura**: Direção de longo prazo, escalabilidade, evolução.

**Pergunta 7.1 — Evolução**:

```markdown
## Pergunta 8: Visão de Futuro

Como você vê o projeto daqui a 6-12 meses?

- Vai crescer em **usuários**? (escala)
- Vai crescer em **features**? (escopo)
- Vai precisar de **mais desenvolvedores**? (equipe)
- Há planos de **monetização** ou **mudança de modelo**?

Descreva livremente o que imagina para o futuro do projeto.
```

## Regras da Entrevista

1. **Uma pergunta por vez** — aguardar resposta antes de avançar
2. **Adaptar ao contexto** — pular perguntas cujas respostas já são conhecidas
3. **Aceitar respostas livres** — não forçar formato; extrair informação do texto
4. **Aceitar "não sei"** — marcar como `[a definir]` e seguir em frente
5. **Aceitar atalhos** — se usuário responder várias dimensões de uma vez, registrar todas
6. **Máximo 10 perguntas** — se usuário disser "chega", "pronto" ou "prossiga", encerrar
7. **Não julgar respostas** — registrar fielmente; críticas são trabalho de uma skill de advisor/revisão estratégica
8. **Confirmar inferências** — quando preencher algo inferido, confirmar brevemente
