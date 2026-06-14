# Sapient-AI

Repositorio de definicoes, instrucoes, agents, skills e profiles para configurar e melhorar o uso de plataformas de IA, com foco inicial em Codex e Claude.

Este repositorio nao e uma aplicacao executavel. Ele funciona como um acervo versionado de arquivos que orientam agentes, ferramentas e fluxos de trabalho baseados em IA.

## Proposito

O objetivo do Sapient-AI e centralizar configuracoes e instrucoes reutilizaveis para evitar arquivos dispersos, facilitar evolucao incremental e manter organizacao por contexto.

O repositorio deve ser util desde o primeiro artefato publicado. A estrutura pode evoluir conforme surgirem novas necessidades, novos agents, novas skills e novos profiles.

## Escopo

Este repositorio deve conter:

- instrucoes globais de usuario;
- definicoes de agents;
- colecoes de skills;
- profiles e configuracoes por contexto;
- instrucoes por projeto ou por tipo de projeto;
- documentos auxiliares sobre uso, convencoes e organizacao.

Este repositorio nao tem como objetivo:

- entregar uma aplicacao executavel;
- manter metas de produto, prazo ou escopo fechado;
- cobrir todas as plataformas de IA desde o inicio;
- armazenar credenciais, dados sensiveis ou informacoes privadas.

## Estrutura Inicial

A organizacao primaria deve ser por contexto e funcionalidade. Quando houver diferencas entre plataformas, a separacao por Codex, Claude ou outra ferramenta deve ficar no nivel final da estrutura.

```text
user/
  agents/
  skills/
    nome-da-habilidade/
projects/
docs/
  01-discovery-briefing/
```

### `user/`

Agrupa instrucoes e configuracoes em nivel de usuario, aplicaveis de forma ampla e reutilizavel entre projetos.

### `user/agents/`

Agrupa definicoes de agents e suas funcionalidades.

### `user/skills/`

Agrupa skills por finalidade. Cada habilidade deve ter sua propria pasta quando possuir um conjunto de arquivos ou quando a separacao melhorar a manutencao.

### `projects/`

Agrupa instrucoes especificas para projetos ou tipos de projetos.

### `docs/`

Agrupa documentacao do proprio repositorio, incluindo briefings, decisoes, convencoes e orientacoes de uso.

## Plataformas

O foco inicial e:

1. Codex
2. Claude

Outras plataformas podem ser adicionadas quando houver uso real ou necessidade concreta.

## Formatos

Markdown e o formato principal para instrucoes, documentacao e definicoes legiveis.

Outros formatos, como JSON, YAML, TOML ou scripts de apoio, podem ser usados quando forem exigidos por uma plataforma, agent, skill ou fluxo de trabalho.

## Padroes de Qualidade

Os artefatos devem priorizar:

- clareza e utilidade pratica;
- compatibilidade com os contratos da plataforma alvo;
- documentacao suficiente para uso e manutencao;
- seguranca e privacidade no conteudo versionado.

Evite incluir credenciais, tokens, dados pessoais sensiveis, segredos operacionais ou instrucoes que possam induzir comportamento inseguro.

## Evolucao

O repositorio deve crescer de forma natural, conforme o uso real. Nao ha prazo fixo nem obrigatoriedade de completar uma lista fechada de funcionalidades.

Quando uma nova estrutura, convencao ou plataforma for adicionada, prefira documentar a decisao de forma objetiva para facilitar manutencao futura.

## Discovery

O briefing inicial do projeto esta em:

- [`docs/01-discovery-briefing/20260614-briefing.md`](docs/01-discovery-briefing/20260614-briefing.md)
