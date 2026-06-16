# Quickstart: [FEATURE]

Cenários de teste que validam a implementação end-to-end. Um cenário por fluxo crítico (happy path + pelo menos um error case).

## Scenario 1: [Happy Path]

1. [Passo]
2. [Passo]
3. **Expected**: [Resultado]

## Scenario 2: [Error Case]

1. [Passo]
2. **Expected**: [Erro esperado]

## Scenario 3: Roundtrip End-to-End (obrigatório para features com borda backend <-> frontend)

Cenário que valida que o payload real do backend casa com o contrato declarado em `contracts/*.md` e com o tipo consumido pelo frontend. Não use mock/fixture; chame o backend de verdade.

1. Subir backend localmente (ex: `npm run dev` ou `make run`).
2. Fazer requisição real ao endpoint crítico (ex: `curl -s http://localhost:3000/api/foo`).
3. Capturar payload e comparar shape contra o contrato:
   - Nomes de campo (case style: camelCase? snake_case?).
   - Tipos (string vs number vs boolean, sem coerção silenciosa).
   - Enums (valores literais batem com o schema compartilhado?).
4. Frontend consome o mesmo payload e parseia com schema sem erros.
5. **Expected**: zero divergência entre payload real, contrato declarado e tipo no frontend.
