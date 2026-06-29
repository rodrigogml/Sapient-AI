# Agente: Delegador

Define o roteamento inicial de instruções especializadas para o Codex.

## Regra Geral

Antes de agir, identifique se a tarefa exige agentes auxiliares por escopo, risco ou etapa do trabalho. Leia somente os arquivos diretamente aplicáveis.

## Roteamento

Leia `AGENTS-DEVELOPMENT-CYCLE.md` quando:
- o usuário sinalizar início ou fim de ciclo de desenvolvimento;
- o usuário usar expressões operacionais de sincronização, como "baixar o código", "baixasse o código", "puxar o código", "atualizar o código", "subir o código", "subisse o código", "enviar o código", "publicar o código" ou equivalentes;
- a tarefa exigir alteração no repositório ainda sem nenhuma alteração local realizada pelo agente;
- o objetivo proposto parecer concluído e o agente estiver preparando a entrega;
- a tarefa envolver commit, push, pull, merge, branch ou sincronização com a origem.
Essa leitura deve ocorrer antes da primeira alteração local e antes do encerramento do ciclo quando houver entrega, commit ou push.

Leia `AGENTS-DATABASE.md` quando:
- a tarefa envolver criação ou alteração de scripts SQL;
- a tarefa envolver arquivos em `src/main/resources/db/init/` ou `src/main/resources/db/update/`;
- a tarefa envolver banco de dados MySQL;
- a tarefa envolver modelagem de tabelas, colunas, constraints, PKs, FKs, índices ou schemas;
- a tarefa envolver entidades persistidas com impacto em banco de dados;
- a tarefa envolver configuração JPA/Hibernate relacionada a nomes físicos de tabelas e colunas.

Leia `AGENTS-JAVA-SPRING-BOOT.md` quando:
- a tarefa envolver projeto Java baseado em Spring Boot;
- a tarefa envolver criação, revisão ou reorganização da estrutura de repositório Maven/Spring Boot;
- a tarefa envolver configuração geral de projeto, `pom.xml`, `application.properties`, `src/` ou `docs/` em projeto Spring Boot.

Leia `AGENTS-JAVA-CODING.md` quando:
- a tarefa envolver criação, alteração ou revisão de código Java;
- a tarefa envolver nomenclatura, imports, tipos, classes, métodos, comentários, Javadoc, enums, DTOs, VOs, entities ou utility classes em Java;
- a tarefa envolver criação, alteração ou revisão de testes Java.

Leia `AGENTS-TASK-IMPLEMENTATION.md` quando:
- o usuário pedir para procurar, executar, implementar ou concluir tarefas pendentes de backlog;
- o usuário pedir para iterar por tarefas não implementadas até concluir tudo que for possível;
- o trabalho envolver implementação orientada por `tasks.md` ou documentação equivalente já existente.

## Conflitos

Se houver conflito entre agentes, aplique a instrução mais específica. Se o conflito afetar ação irreversível ou risco relevante, apresente a divergência ao usuário antes de agir.

## Delegação de Skills

Use `dev-pipeline-1-discovery-briefing` quando o usuário quiser iniciar um projeto do zero, organizar sua documentação inicial ou alinhar o contexto antes de especificar features.

Use `dev-pipeline-3-specification-specify` quando o usuário quiser descrever e começar o desenvolvimento de uma nova feature que ainda precisa de especificação funcional.

Use `dev-pipeline-4-specification-clarify` quando o usuário quiser alterar, melhorar ou refinar uma feature já existente a partir de uma spec atual.

Use `dev-pipeline-7-implementation-create-tasks` quando uma alteração ou melhoria já estiver clara e precisar virar backlog executável.

Use `dev-pipeline-9-implementation-execute-task` quando a alteração ou melhoria já estiver representada em uma tarefa existente do backlog.

Use `dev-pipeline-11-implementation-bugfix` quando o usuário relatar problema, erro, falha, bug ou mau funcionamento do sistema.
