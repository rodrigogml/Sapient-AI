---
name: dev-pipeline-9-implementation-execute-task
description: Use when the user wants Codex to execute one backlog task end-to-end from an existing tasks.md, including context reading, task lookup, implementation, tests, validation, lint/build checks, reporting, and marking the task complete. Skip for creating the backlog, planning architecture, reviewing completed work, or investigating a bug without a task.
metadata:
  short-description: Execute one backlog task
---

# Dev Pipeline - 9. Implementation - Execute Task

## Overview

Execute uma tarefa específica do backlog seguindo um fluxo obrigatório: entender contexto, localizar a tarefa, planejar arquivos afetados, implementar, testar, validar, executar lint/build quando aplicável, reportar evidências e atualizar `tasks.md`.

## Pré-requisitos

**Obrigatório**: arquivo de tarefas existente contendo a tarefa a executar. Localizações suportadas: `docs/specs/*/tasks.md`, `docs/tasks.md`, `docs/tasks-*.md`, `tasks.md` e `TODO.md`.

**Recomendado**: `spec.md`, `plan.md`, checklists, `docs/constitution.md`, `README.md` e `AGENTS.md` existentes. A skill deve ler a documentação relevante antes de implementar.

## When To Use

Use quando o usuário pedir para executar, implementar ou concluir uma tarefa específica do backlog.

Não use para criar o backlog, escrever spec, criar plano técnico, revisar tarefas já concluídas ou investigar bug sem vínculo com uma tarefa. Para drift entre artefatos antes da execução, use `Dev Pipeline - 8. Implementation - Analyze`.

## Output Contract

O resultado deve incluir:

- Tarefa executada, tipo e status.
- Arquivos criados e modificados.
- Testes, validações e lint/build executados, com evidência real ou motivo para não execução.
- Atualização do `tasks.md` marcando a tarefa/subtarefas concluídas.
- Pendências, riscos ou próximos passos se algo não pôde ser concluído.

## Workflow

0. **Validação empírica**: confirmar premissas técnicas quando aplicável.
1. **Análise**: detectar contexto e ler documentação.
2. **Localização**: encontrar tarefa no arquivo de tarefas.
3. **Planejamento**: definir escopo, arquivos afetados e validações.
4. **Implementação**: criar ou modificar arquivos.
5. **Testes**: executar ou justificar não execução.
6. **Validação**: verificar qualidade e consistência.
7. **Lint/Build**: executar comandos padrão do projeto quando aplicável.
8. **Conclusão**: reportar o que foi feito com evidências.
9. **Atualização**: marcar tarefa como `[x]` no arquivo de tarefas.

## Próximos Passos

1. `Dev Pipeline - 9. Implementation - Execute Task` - continuar com a próxima tarefa pendente.
2. `Dev Pipeline - 10. Implementation - Review Task` - revisar progresso e identificar dependências desbloqueadas.
3. `Dev Pipeline - 8. Implementation - Analyze` - se houver suspeita de drift entre implementação, spec, plan e tasks.

## ETAPA 0: VALIDAÇÃO EMPÍRICA DE PREMISSAS

### 0.1 Quando Aplicar

Use esta etapa sempre que estiver prestes a afirmar um problema técnico, comportamento de runtime, contrato de API, presença ou ausência de símbolo, versão de dependência, schema, tipo ou formato de payload.

Antes de tomar decisão baseada nessa afirmação, execute uma sonda empírica e guarde o comando e o fragmento literal do output.

Exemplos de sondas:

| Tipo da afirmação | Sonda empírica |
|-------------------|----------------|
| Erro de tipo | `npx tsc --noEmit`, `mvn compile`, `dotnet build` |
| Comportamento runtime | teste específico, comando local, chamada real controlada |
| Presença de símbolo | `rg '<símbolo>' src/` |
| Forma de módulo | inspecionar manifesto de dependência, exports ou documentação local |
| Forma de payload | request real controlado; não usar fixture/mock como prova única |
| Schema de DB | migration, schema file ou query introspectiva disponível |
| Saída de comando | comando com output literal suficiente para sustentar a conclusão |

### 0.2 Evidência

Toda conclusão técnica forte deve ser sustentada por evidência:

```text
Comando: npx tsc --noEmit
Evidência: error TS2322 em src/foo.ts:12 'string' is not assignable to 'number'
```

Não parafraseie como prova. O relatório pode resumir, mas a decisão precisa ter sido tomada a partir de output real.

### 0.3 Quando Pular

Pode pular esta etapa para:

- Tarefa puramente documental.
- Reformatar sem mudança semântica.
- Gerar boilerplate por template já validado.
- Alteração mecânica cujo comportamento não depende de runtime.

Mesmo nesses casos, declare brevemente por que a validação empírica não se aplica.

## ETAPA 1: ANÁLISE

### 1.1 Detectar Contexto do Projeto

Identifique o tipo de projeto:

| Tipo | Indicadores | Foco |
|------|-------------|------|
| Documentação | `docs/` com `.md`, ausência de código executável relevante | Markdown, diagramas, links |
| Código | `src/`, `app/`, `package.json`, `pom.xml`, `go.mod`, `pyproject.toml` | Implementação, testes, build |
| Misto | Documentação e código-fonte | Ambos |

### 1.2 Ler Documentação Relevante

Antes de executar qualquer tarefa, leia documentação relevante quando existir:

- `README.md`
- `AGENTS.md`
- `docs/constitution.md`
- `docs/specs/{feature-short-name}/spec.md`
- `docs/specs/{feature-short-name}/plan.md`
- `docs/specs/{feature-short-name}/tasks.md`
- `docs/specs/{feature-short-name}/checklists/*.md`
- Documentação específica do módulo ou serviço afetado.

Para projetos com múltiplos serviços, verificar também:

- `docs/tasks-{service-name}.md`
- Código de referência em serviços similares.
- Convenções de build/teste documentadas no projeto.

### 1.3 Checklist da Análise

- [ ] Tipo de projeto identificado.
- [ ] `README.md` lido, se existir.
- [ ] `AGENTS.md` lido, se existir.
- [ ] Documentação relevante em `docs/` lida.
- [ ] Contexto da tarefa entendido.

## ETAPA 2: LOCALIZAÇÃO

### 2.1 Encontrar Arquivo de Tarefas

Procure nesta ordem:

1. `docs/specs/*/tasks.md` - backlog ligado a uma spec SDD.
2. `docs/tasks.md`
3. `docs/tasks-*.md` - backlog por módulo ou serviço.
4. `tasks.md`
5. `TODO.md`, `docs/TODO.md`, `.github/TODO.md`

Se a tarefa se origina de uma spec em `docs/specs/{feature-short-name}/`, o `tasks.md` a atualizar ao final é `docs/specs/{feature-short-name}/tasks.md`, não um arquivo de tarefas na raiz.

### 2.2 Identificar a Tarefa

Encontre a tarefa solicitada e extraia:

- ID da tarefa ou subtarefa.
- Descrição completa.
- Subtarefas.
- Criticidade/prioridade.
- Dependências.
- Domínio/contexto.
- Referências a spec, plan, checklist, ADR ou documentação.

### 2.3 Verificar Dependências

Antes de implementar:

- Confirme se dependências estão concluídas.
- Se uma dependência não está concluída, pare e reporte o bloqueio.
- Se a dependência já foi implementada, mas não marcada, valide e atualize o `tasks.md` com nota curta.

## ETAPA 3: PLANEJAMENTO

### 3.1 Classificar Tipo de Tarefa

| Tipo | Exemplos | Ações Principais |
|------|----------|------------------|
| Documentação | Criar UC, atualizar ADR, modelagem | Criar/editar `.md` |
| Código | Implementar feature, alterar comportamento | Criar/editar código |
| Testes | Criar testes, aumentar cobertura | Criar/editar testes |
| Infraestrutura | CI/CD, configs, scripts | Criar/editar configs |

### 3.2 Definir Escopo

Liste internamente antes de editar:

1. Arquivos a criar.
2. Arquivos a modificar.
3. Arquivos a consultar.
4. Validações necessárias.
5. Riscos e rollback lógico, se houver.

### 3.3 Identificar Padrões do Projeto

Antes de implementar, verifique:

- Convenções de nomenclatura.
- Estrutura de arquivos similar.
- Padrões de código e documentação.
- Templates existentes.
- Comandos de teste/lint/build do projeto.

Não invente arquitetura nova quando o projeto já tem padrão aplicável.

## ETAPA 4: IMPLEMENTAÇÃO

### 4.1 Tarefas de Documentação

Para documentação:

1. Leia documentos relacionados existentes.
2. Use templates e padrões do projeto.
3. Crie ou atualize documentos em Markdown.
4. Inclua Mermaid quando apropriado.
5. Mantenha links internos funcionais.
6. Preserve nomenclatura e taxonomia existentes.

Padrões obrigatórios:

- Headers hierárquicos.
- Tabelas consistentes.
- Code blocks com linguagem especificada.
- Links relativos para arquivos internos.
- Sem quebras artificiais no meio de parágrafos.

### 4.2 Tarefas de Código

Para código:

1. Leia código relacionado existente.
2. Siga `AGENTS.md` e convenções locais.
3. Verifique assinaturas/interfaces antes de implementar.
4. Prefira padrões já existentes no projeto.
5. Trate erros com mensagens claras e acionáveis.
6. Mantenha encoding original do arquivo.

Pontos de atenção por camada:

- **Persistência**: schema, migrations, constraints, enums e bindings precisam bater.
- **API/transporte**: payload, status codes, rotas, versionamento e contrato precisam ser consistentes.
- **Domínio/tipos**: enums, DTOs, VOs e tipos compartilhados precisam estar sincronizados.
- **UI**: estados, acessibilidade, responsividade e integração com dados reais precisam ser considerados.

Para tarefas multi-módulo:

- Trace tipos, enums e contratos em todos os módulos afetados.
- Procure referências residuais após rename/refactor.
- Divida implementação em passos verificáveis.

### 4.3 Checklist da Implementação

- [ ] Padrões existentes seguidos.
- [ ] Arquivos necessários criados.
- [ ] Arquivos existentes modificados conforme planejado.
- [ ] Código/documentação completo.
- [ ] Sem TODOs pendentes sem justificativa.

## ETAPA 5: TESTES

Não pular testes por padrão. Se não executar, declare motivo concreto.

### 5.1 Projetos de Código

Use comandos do projeto quando existirem em README, Makefile, scripts, CI ou documentação. Exemplos comuns:

| Stack | Comandos típicos |
|-------|------------------|
| Node / TypeScript | `npm test`, `npm run build`, `npx tsc --noEmit`, `npm run lint` |
| Python | `pytest`, `ruff check .`, `mypy .`, `python -m compileall .` |
| Java / Kotlin | `mvn test`, `mvn verify`, `./gradlew test`, `./gradlew build` |
| .NET | `dotnet test`, `dotnet build` |
| Go | `go test ./...`, `go build ./...`, `go vet ./...` |
| Rust | `cargo test`, `cargo build`, `cargo clippy -- -D warnings` |

Critérios:

- [ ] Testes existentes relevantes executados.
- [ ] Novos testes criados quando a alteração exige cobertura.
- [ ] Resultado citado com evidência real.

### 5.2 Projetos de Documentação

Validar quando aplicável:

- Mermaid.
- Links internos.
- Tabelas Markdown.
- Ortografia, acentuação e consistência terminológica.

Se não houver ferramenta automatizada, fazer revisão manual e declarar isso.

## ETAPA 6: VALIDAÇÃO

### 6.1 Qualidade

Para documentação:

- [ ] Seções obrigatórias preenchidas.
- [ ] Conteúdo claro e completo.
- [ ] Sem erros óbvios de português.
- [ ] Diagramas legíveis e coerentes.
- [ ] Referências cruzadas corretas.

Para código:

- [ ] Código compila ou passa no build aplicável.
- [ ] Funcionalidade implementada conforme tarefa.
- [ ] Tratamento de erros adequado.
- [ ] Sem vulnerabilidades óbvias.
- [ ] Sem regressões conhecidas.

### 6.2 Consistência

- [ ] Consistente com spec.
- [ ] Consistente com plan.
- [ ] Consistente com tasks.
- [ ] Consistente com constitution, se existir.
- [ ] Nomenclatura segue padrões do projeto.

## ETAPA 7: LINT / BUILD

Execute o comando padrão do projeto. Se não houver comando documentado, inferir conservadoramente a partir do stack e declarar o comando usado.

Se o comando falhar:

- Corrija quando a falha estiver dentro do escopo da tarefa.
- Se for falha preexistente ou fora do escopo, reporte com evidência e não oculte.

Não declare lint/build como concluído sem output real.

## ETAPA 8: CONCLUSÃO

### 8.1 Relatório de Execução

Use este formato na resposta final:

```markdown
## Tarefa Executada

**Tarefa:** [ID e nome]
**Tipo:** [Documentação/Código/Testes/Infraestrutura]
**Status:** Concluída / Parcial / Bloqueada

### Arquivos Criados
- `path/to/new-file`

### Arquivos Modificados
- `path/to/existing` - [descrição da mudança]

### Testes e Validações
- [x] [comando] - [evidência resumida]
- [ ] Não executado: [motivo]

### Observações
- [riscos, pendências ou próximos passos]
```

### 8.2 Evidência

Cada `[x]` exige evidência real. Marcar "testes executados" sem comando e output é alegação, não validação.

Se não executou, escreva "não executado: <motivo>". Nunca use `[x]` otimista.

## ETAPA 9: ATUALIZAÇÃO DO BACKLOG

### 9.1 Marcar Tarefa Como Concluída

Atualize o arquivo de tarefas ao final:

```markdown
# Antes
- [ ] 1.1.1 Descrição da subtarefa

# Depois
- [x] 1.1.1 Descrição da subtarefa
```

Se a tarefa tem subtarefas, marque todas as subtarefas concluídas que realmente foram executadas ou validadas.

### 9.2 Sincronizar com Código

Antes de declarar a tarefa concluída, compare arquivos modificados com checkboxes do `tasks.md`.

Se identificar checkbox pendente cujo código já existe no repositório, marque `[x]` com nota inline:

```markdown
- [x] 1.1.3 Implementar UserRepository <!-- validado no código existente -->
```

Se a tarefa criou trabalho emergente não previsto, insira esse trabalho como nova subtarefa ou tarefa no `tasks.md` antes de finalizar.

## Nomenclaturas Comuns

Estas convenções são ilustrativas. A lista real vem do projeto.

### Documentação

- `UC-{DOMINIO}-NNN`: Caso de Uso.
- `ADR-NNN`: Architectural Decision Record.
- `DER-{system}`: Diagrama Entidade-Relacionamento.

### Regras e Testes

- `RN-NNN`: Regra de Negócio.
- `CT-NNN`: Caso de Teste.
- `E-NNN`: Código de Exceção.
- `RNF-NNN`: Requisito Não Funcional.
- `FA{N}`: Fluxo Alternativo.

## Gotchas

### Ler documentação antes de executar é obrigatório

Pular análise leva a implementação fora dos padrões do projeto. README, AGENTS e docs explicam convenções que o código nem sempre revela sozinho.

### Atualizar tasks.md no final é obrigatório

Tarefa concluída mas não marcada `[x]` será reprocessada depois. Marque como última ação da etapa 9.

### Se a tarefa veio de uma spec, atualize o tasks.md da spec

Tarefa originada em `docs/specs/{feature-short-name}/` atualiza `docs/specs/{feature-short-name}/tasks.md`, não `docs/tasks-*.md` na raiz.

### Não pular testes/lint por "tarefa pequena"

Teste/lint/build são gates contra regressão. Se não se aplicam, justifique; se se aplicam, execute.

### Stop-and-remap durante implementação

Se surgir issue em outra camada, pare, revise o plano da tarefa e só então continue. Perseguir issues emergentes sem remapear cria ciclos de retrabalho.

### Detectar stack antes de escolher comando

Rodar comando de stack errado gera ruído. Use a etapa de análise para identificar o stack antes de escolher testes, lint ou build.

### Cada etapa precisa de mini-resumo interno

Ao final de cada etapa, confirme mentalmente o que foi feito e se o fluxo ainda está correto. Se algo mudou, atualize o plano antes de seguir.
