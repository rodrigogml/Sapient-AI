# Implementation Plan: [FEATURE]

**Feature**: `[feature-short-name]` | **Date**: [DATE] | **Spec**: [link relativo]

## Summary

[Requisito primário + abordagem técnica da pesquisa]

## Technical Context

**Language/Version**: [ex: Java 21, Go 1.24, Python 3.11, TypeScript 5.x ou NEEDS CLARIFICATION]
**Primary Dependencies**: [ex: Spring Boot, Chi v5, FastAPI, React 18 ou NEEDS CLARIFICATION]
**Storage**: [ex: PostgreSQL, Redis, files ou N/A]
**Testing**: [ex: JUnit, go test, pytest, vitest ou NEEDS CLARIFICATION]
**Target Platform**: [ex: Kubernetes, Vercel, mobile ou NEEDS CLARIFICATION]
**Project Type**: [ex: library, cli, web-service, mobile-app ou NEEDS CLARIFICATION]
**Performance Goals**: [ex: 1000 req/s, 60 fps ou NEEDS CLARIFICATION]
**Constraints**: [ex: <200ms p95, <100MB memory ou NEEDS CLARIFICATION]
**Scale/Scope**: [ex: 10k users, 1M LOC ou NEEDS CLARIFICATION]

## Constitution Check

*GATE: Deve passar antes do Phase 0. Rechecar após Phase 1.*

| Princípio | Status | Notas |
|-----------|--------|-------|
| [Nome] | PASS / FAIL / N/A | [Detalhes] |

## Project Structure

### Documentation (this feature)

```text
docs/specs/[feature]/
├── spec.md
├── plan.md          # This file
├── research.md      # Phase 0 output
├── data-model.md    # Phase 1 output
├── quickstart.md    # Phase 1 output
└── contracts/       # Phase 1 output
```

### Source Code (repository root)

[Árvore de diretórios real do projeto, com paths concretos]

**Structure Decision**: [Decisão documentada sobre estrutura escolhida]

## Convenções de Borda

[Preencher quando a feature atravessa fronteiras entre camadas. Se não aplicar: "N/A — single-layer".]

## Complexity Tracking

> Preencher APENAS se Constitution Check tem violações que precisam justificativa.

| Violação | Por Que Necessário | Alternativa Simples Rejeitada Porque |
|----------|-------------------|--------------------------------------|
| [ex: 4o serviço] | [necessidade] | [por que 3 são insuficientes] |
