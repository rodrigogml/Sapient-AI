# Example: Good Feature Spec

Este exemplo ilustra uma spec bem escrita: foco em QUE/POR QUE, sem detalhes de implementação, com success criteria mensuráveis e technology-agnostic.

---

# Feature Specification: Password Reset via Email

**Feature**: `password-reset-email`
**Created**: 2026-03-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - Request reset link (Priority: P1)

Usuário esqueceu a senha e precisa recuperar acesso sem contato humano. Na tela de login, clica em "Esqueci minha senha", fornece o email e recebe um link temporário por email para definir nova senha.

**Why this priority**: Sem esta story, usuários bloqueados precisam contactar suporte; o custo operacional e o tempo de resolução são inaceitáveis.

**Independent Test**: Do estado "usuário com conta ativa", solicitar reset e verificar que o email chega com link funcional em <2 minutos.

**Acceptance Scenarios**:

1. **Given** email pertence a conta ativa, **When** usuário solicita reset, **Then** sistema envia email com link válido por 1h
2. **Given** email não cadastrado, **When** usuário solicita reset, **Then** sistema retorna mensagem neutra (sem revelar se email existe)
3. **Given** 3 solicitações em menos de 5 minutos, **When** usuário solicita a 4a, **Then** sistema bloqueia temporariamente

---

### User Story 2 - Consume reset link (Priority: P1)

Usuário recebe o email, clica no link e define nova senha. Após sucesso, todas as sessões ativas são invalidadas.

**Why this priority**: Sem esta story, o link enviado na P1 não tem efeito. P1 também pois é o fechamento do fluxo crítico.

**Independent Test**: Do estado "link válido emitido", acessar o link e redefinir senha; login subsequente com senha nova deve funcionar.

**Acceptance Scenarios**:

1. **Given** link válido e não expirado, **When** usuário define senha que atende política, **Then** senha é atualizada e todas sessões são invalidadas
2. **Given** link expirado, **When** usuário tenta acessar, **Then** sistema pede novo link
3. **Given** link já utilizado, **When** usuário tenta reutilizar, **Then** sistema rejeita

---

### Edge Cases

- What happens when o serviço de email está indisponível no momento da solicitação?
- How does system handle concurrent requests do mesmo usuário em janelas diferentes?
- What happens when a conta foi deletada entre a emissão do link e a tentativa de uso?

## Requirements

### Functional Requirements

- **FR-001**: System MUST enviar link único e temporário (expira em 1h) para o email cadastrado
- **FR-002**: System MUST invalidar link após primeiro uso bem-sucedido
- **FR-003**: Users MUST be able to definir nova senha via link sem autenticação prévia
- **FR-004**: System MUST invalidar todas sessões ativas após reset concluído
- **FR-005**: System MUST aplicar rate limiting por email (máx. 3 solicitações por 5 minutos)
- **FR-006**: System MUST retornar mensagem neutra para emails não cadastrados (sem vazar existência)

### Key Entities

- **Reset Token**: representa um pedido de reset válido; associado a um usuário, com validade, estado (ativo/consumido/expirado) e rastreabilidade de uso
- **User**: conta existente cujo acesso pode ser recuperado

## Success Criteria

### Measurable Outcomes

- **SC-001**: 95% dos usuários que solicitam reset conseguem acessar em <5 minutos
- **SC-002**: Tempo entre solicitação e recebimento do email é <2 minutos em p95
- **SC-003**: Volume de tickets de suporte relacionados a "senha esquecida" reduz em 80% após lançamento
- **SC-004**: Zero vazamentos de existência de email por resposta diferente entre email cadastrado e não cadastrado

---

## Por que esta spec é boa

1. **User stories independentes e testáveis**: P1 de solicitar e P1 de consumir podem ser validadas separadamente.
2. **Success criteria mensuráveis e technology-agnostic**: "5 minutos", "2 minutos p95", "80% de redução"; nenhuma menção a framework ou banco.
3. **Edge cases pensados**: indisponibilidade de serviço externo, concorrência, deletion race.
4. **Rate limiting e segurança mencionados no QUE, não no COMO**: diz "aplicar rate limiting", não "Redis com sliding window".
5. **Sem detalhes de implementação**: não menciona "bcrypt", "JWT", "Redis"; isso vai para `Dev Pipeline - 5. Planning - Plan`.
