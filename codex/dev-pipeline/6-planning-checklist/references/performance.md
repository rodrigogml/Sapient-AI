# Domínio: Performance

Itens exemplo para checklist de qualidade de requisitos de performance.

## Targets Mensuráveis

- São requisitos de performance quantificados com métricas específicas (p50, p95, p99)? [Clareza]
- São targets de performance definidos para todas as jornadas críticas? [Cobertura]
- Definições incluem condições de medição (load, concorrência)? [Clareza]

## Escalabilidade

- São requisitos de carga concorrente quantificados (RPS, usuários simultâneos)? [Clareza]
- Estratégia de scaling (horizontal, vertical, elástico) é especificada? [Completude]
- Limites de crescimento (storage, compute) são documentados? [Cobertura]

## Degradação Graciosa

- São requisitos de degradação definidos para cenários de alta carga? [Edge Case, Gap]
- Política de circuit breaker é documentada? [Cobertura]
- Fallbacks em caso de dependência lenta/indisponível são definidos? [Completude]

## Caching

- São camadas de cache especificadas (CDN, app, DB)? [Cobertura]
- TTLs e política de invalidação são definidos? [Clareza]
- Cache miss handling (stampede protection) é especificado? [Gap]

## Queries e I/O

- São requisitos de latência de query definidos? [Clareza]
- N+1 query prevention é requisito explícito? [Cobertura]
- Índices necessários são mapeados a queries críticas? [Traceability]

## Tamanho de Payload

- Limites de tamanho de resposta (paginação) são definidos? [Clareza]
- Compressão (gzip, brotli) é requerida? [Cobertura]
- Lazy loading de recursos pesados é especificado? [Completude]

## Observabilidade de Performance

- Métricas de latência, throughput e erro por endpoint são requeridas? [Cobertura]
- Alertas de degradação têm thresholds definidos? [Clareza]
- Profiling em produção (sampling) é permitido/requerido? [Gap]

## Mobile e Frontend

- Budget de performance de frontend (LCP, FID, CLS) é definido? [Clareza]
- Tamanho máximo de bundle inicial é especificado? [Cobertura]
- Estratégia de imagem (lazy load, formatos modernos) é requisito? [Completude]
