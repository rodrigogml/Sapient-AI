# Domínio: API

Itens exemplo para checklist de qualidade de requisitos de API.

## Contratos e Schemas

- São formatos de request/response definidos para todos os endpoints? [Completude]
- São versões de API e estratégia de versionamento especificadas? [Clareza]
- São schemas (JSON Schema, OpenAPI) mantidos como contrato formal? [Consistência]

## Error Handling

- São formatos de resposta de erro especificados para todos os cenários de falha? [Completude]
- Códigos de erro seguem convenção consistente (HTTP status + error code)? [Consistência]
- Mensagens de erro definem se são seguras para exibir ao usuário final? [Spec §FR-X]

## Autenticação e Autorização

- São requisitos de autenticação consistentes entre todos os endpoints? [Consistência]
- São definidos escopos/permissions necessários por endpoint? [Cobertura]
- Tokens e sessões têm TTL e política de refresh definidos? [Clareza]

## Rate Limiting e Throttling

- São requisitos de rate limiting quantificados com thresholds específicos? [Clareza]
- Comportamento em caso de exceder rate limit é definido? [Completude]
- Rate limits variam por tipo de usuário/plano? [Cobertura]

## Retry e Idempotência

- São requisitos de retry/timeout definidos para dependências externas? [Cobertura, Gap]
- Endpoints que mutam estado são idempotentes (ou exigem idempotency-key)? [Clareza]
- Política de backoff em falhas é especificada? [Clareza]

## Observabilidade

- Requisitos de logging estruturado são definidos? [Cobertura]
- Métricas por endpoint (latência, taxa de erro) são requeridas? [Cobertura]
- Tracing distribuído é especificado para requisições cross-service? [Cobertura, Gap]

## Paginação e Filtros

- Paginação tem estratégia definida (cursor, offset, etc.) e limites? [Clareza]
- Filtros e ordenação seguem convenção consistente entre endpoints? [Consistência]

## Deprecação

- Política de deprecação de endpoints é definida (aviso, período de sunset)? [Completude, Gap]
