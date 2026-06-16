---
name: dev-pipeline-11-implementation-bugfix
description: Use when the user wants to investigate, debug, and fix a bug with a structured multi-layer protocol before patching. This skill traces data flow across layers, identifies all mismatches, plans the fix, implements changes, verifies with tests/build/lint, and summarizes root cause. Skip for new feature work, backlog execution without a bug, or pure planning/specification.
metadata:
  short-description: Investigate and fix bugs
---

# Dev Pipeline - 11. Implementation - Bugfix

## Overview

Investigue e corrija bugs com um protocolo estruturado que mapeia o fluxo completo antes de editar qualquer camada. O objetivo é evitar ciclos de "corrige uma coisa, revela outra" causados por patch local sem entender o contrato end-to-end.

## Pré-requisitos

**Obrigatório**: descrição do bug, erro observado, comportamento esperado, log, teste falhando, screenshot ou caminho para artefato que reproduza o problema.

**Recomendado**: acesso ao código, documentação do projeto, comandos de build/teste e contexto de deploy quando o bug for de produção.

## When To Use

Use quando o usuário pedir bugfix, debug, investigação de bug, correção de erro, análise de comportamento inesperado ou falha em teste/build/runtime.

Não use para feature nova, criação de backlog, planejamento técnico, execução de tarefa comum sem bug ou validação read-only. Se o bug já estiver representado como tarefa no backlog e o pedido for executá-la, combine este protocolo com `Dev Pipeline - 9. Implementation - Execute Task`.

## Output Contract

O resultado deve incluir:

- Bug investigado e causa raiz.
- Camadas e serviços afetados.
- Plano de correção antes de mudanças relevantes.
- Arquivos modificados.
- Testes/build/lint executados com evidência ou motivo para não execução.
- Verificações pós-fix e riscos restantes.

## Workflow

1. **Complexidade**: determinar se é single-layer, multi-service ou ghost bug.
2. **Entendimento**: ler erro, comportamento esperado e camada que reportou.
3. **Artefatos obsoletos**: eliminar build/cache/deploy stale quando aplicável.
4. **Rastreamento**: mapear fluxo completo de dados.
5. **Mismatches**: listar discrepâncias encontradas.
6. **Plano**: apresentar plano de fix antes de mudanças relevantes.
7. **Implementação**: aplicar mudanças em ordem de dependência.
8. **Verificação**: rodar testes/build/lint e procurar referências residuais.
9. **Resumo**: reportar causa raiz, mudanças e validação.

## Próximos Passos

1. Se o fix corresponder a tarefa existente, atualizar via `Dev Pipeline - 9. Implementation - Execute Task`.
2. Se o bug revelou gap de requisitos, voltar para `Dev Pipeline - 4. Specification - Clarify`.
3. Se o bug revelou drift entre artefatos, usar `Dev Pipeline - 8. Implementation - Analyze`.

## ETAPA 1: DETERMINAR COMPLEXIDADE

Avalie o escopo antes de começar:

| Complexidade | Sinais | Abordagem |
|---------------|--------|-----------|
| Single-layer | Erro isolado em um arquivo, componente ou serviço | Rastreamento sequencial |
| Multi-service | DTOs, enums, eventos ou contratos atravessam serviços | Mapear todas as bordas antes do patch |
| Ghost bug | Intermitente, "funciona na minha máquina", pós-deploy | Foco em artefatos obsoletos, cache, build e commit implantado |

Para bugs multi-service, acompanhe progresso por camada para não perder discrepâncias.

## ETAPA 2: ENTENDER O BUG

1. Leia cuidadosamente mensagem de erro, descrição do usuário ou teste falhando.
2. Identifique qual serviço, camada ou tela reportou o erro.
3. Se houver screenshot, analise o estado visual e dados exibidos.
4. Pergunte ou infira qual camada deveria ser dona da responsabilidade.
5. Para bug reportado no frontend, verifique primeiro se a causa raiz pode estar no backend, contrato ou payload.

Não assuma que a camada que mostra o erro é a camada que deve ser corrigida.

## ETAPA 3: CHECAR ARTEFATOS OBSOLETOS

Antes de depurar profundamente, elimine ghost bugs. Use comandos adequados ao stack:

```bash
# Build limpo ou rebuild
# Node: limpar cache relevante e rodar build
# Java: mvn clean compile
# Go: go build ./...
# Rust: cargo clean && cargo build
# Python: remover __pycache__/build quando aplicável e compilar/testar

git status --short
git log --oneline -3
```

Para bugs de produção, confirme se o commit implantado corresponde ao código investigado.

Se encontrar artefato stale, avise o usuário antes de prosseguir com mudanças.

## ETAPA 4: RASTREAR FLUXO COMPLETO

Não corrija uma única camada ainda. Primeiro siga o dado ponta a ponta.

### Backend

1. Entry point, handler, controller ou rota.
2. DTO, request/response model e serialização.
3. Service ou regra de negócio.
4. Repository ou acesso a dados.
5. Schema, migration, constraints e enums.
6. Eventos, filas e consumidores, se houver.

### Frontend

1. API client.
2. Tipos, schemas e validação.
3. State layer, query keys e cache.
4. View/component, binding, loading e error states.

### Bordas

1. Clientes inter-service.
2. Payloads de evento.
3. Valores de enum compartilhados.
4. Gateway, proxy, auth, CORS e roteamento.

## ETAPA 5: IDENTIFICAR TODOS OS MISMATCHES

Liste cada discrepância antes de editar:

- Campo com nomes divergentes: `full_name`, `fullName`, `FullName`.
- Enum divergente entre código, banco e cliente.
- Campo ausente em request/response.
- Tipo divergente: string vs UUID, number vs string, nullable vs required.
- Query sem schema/namespace correto.
- Ordem de rotas que captura path errado.
- Tag de serialização divergente.
- Conversão de case ausente ou duplicada.
- Tratamento incorreto de `null`, omitido ou string vazia.

Priorize a causa raiz, mas não ignore discrepâncias que fazem parte do mesmo fluxo.

## ETAPA 6: PLANEJAR O FIX

Apresente o plano antes de implementar mudanças relevantes:

- Arquivos a alterar.
- O que muda em cada arquivo.
- Ordem correta de mudanças.
- Necessidade de migration.
- Testes ou validações que provarão o fix.

Nunca execute migrations ou operações destrutivas de banco sem mostrar SQL/comando e obter aprovação explícita.

## ETAPA 7: IMPLEMENTAR

Siga ordem de dependência:

1. Migrations ou schema, se aprovados e necessários.
2. Domain, enums, DTOs e contratos.
3. Service/repository.
4. Handler/controller.
5. Tipos frontend.
6. API client/hooks.
7. Componentes/telas.
8. Testes.

### Stop-and-Remap

Se o fix revelar novo problema em outra camada, pare. Não persiga o novo problema no improviso. Volte ao rastreamento, atualize a lista de mismatches e revise o plano.

## ETAPA 8: VERIFICAR

Execute a cadeia adequada ao stack:

```bash
# Build
# go build ./...
# npm run build ou npx tsc --noEmit
# cargo build
# python -m compileall .
# mvn compile
# dotnet build

# Testes
# go test ./...
# npm test
# cargo test
# pytest
# mvn test
# dotnet test

# Lint/static analysis
# npm run lint
# ruff check .
# go vet ./...
# cargo clippy -- -D warnings
```

Depois de rename/refactor, procure referências residuais com `rg`.

### Verificação Test-Driven

Para bug sutil ou recorrente:

1. Escreva teste que falha reproduzindo o bug.
2. Adicione edge cases relevantes.
3. Implemente fix mínimo.
4. Rode teste específico.
5. Rode verificação ampla aplicável.

## ETAPA 9: RESUMIR

Use este formato:

```markdown
## Bug Fix Summary

**Bug:** [descrição]
**Root cause:** [causa raiz]
**Serviços/camadas afetados:** [lista]

### Changes

| File | Change |
|------|--------|
| path/to/file | [mudança] |

### Verification

- [x] [comando] - [evidência]
- [ ] Não executado: [motivo]

### Verify After Deploy

- [ ] [o que checar em staging/produção]
```

## Regras Importantes

- Nunca corrigir só uma camada e declarar concluído sem rastrear o fluxo.
- Nunca rodar migrations ou operações destrutivas sem aprovação explícita.
- Quando um fix revelar outro issue, parar e remapear.
- Sempre procurar referências residuais após rename/refactor.
- Para bugs reportados pelo cliente/frontend, checar backend/contrato primeiro.
- Não sobrescrever arquivos completos com stubs mínimos.
- Conferir campos de persistência contra models e bindings.
- Conferir enums em todas as camadas.

## Gotchas

### Stop-and-remap quando o fix revela novo issue

Se uma correção expõe outro problema, pare e remapeie o fluxo. Continuar no improviso cria ciclos longos de retrabalho.

### Não corrigir uma camada e declarar done

Um handler corrigido não prova que contrato, cliente, banco e testes estão coerentes. Rastreie o caminho completo antes de encerrar.

### Bug reportado no frontend pode ser backend

Formulário exibindo valor errado muitas vezes é payload errado. Verifique ownership antes de editar a tela.

### Sempre procurar referências residuais

Nome antigo pode estar em config, fixture, teste, contrato, comentário útil ou tipo gerado. Use `rg` no repositório inteiro quando fizer rename.

### Nunca rodar operação destrutiva de banco sem aprovação

Mesmo em dev. Mostre SQL/comando e aguarde autorização explícita.

### Enum drift é silencioso

Servidor usa `ACTIVE`, banco aceita `active`, cliente espera `Active`. Isso raramente falha em compile time e costuma aparecer em runtime.

### Ordem de rotas importa

Em muitos routers, rotas estáticas precisam vir antes de rotas com parâmetro. Um `/users/me` capturado por `/users/:id` é bug clássico.

### Não sobrescrever arquivos com stubs

Preserve código existente. Faça mudanças cirúrgicas, mantendo contexto e comportamento não relacionado.

### Bindings de banco precisam bater com models

Scan/bind incompleto pode descartar campos sem erro óbvio. Verifique alinhamento entre colunas, models e DTOs.
