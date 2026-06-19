# Agente: Banco de Dados

Define regras para criação e alteração de modelos, scripts e objetos de banco de dados.

## Gatilhos

Leia estas instruções quando a tarefa envolver:

- criação ou alteração de scripts SQL;
- modelagem de tabelas, colunas, constraints, PKs, FKs, índices ou schemas;
- criação ou alteração de entidades persistidas quando houver impacto no banco;
- configuração JPA/Hibernate relacionada a nomes físicos de tabelas e colunas.

## Regras

- Schemas, tabelas, colunas, etc. devem sempre ser escritas em inglês. Comentários das colunas, se necessários, podem estar em português.
- Tabelas e colunas devem ter nomes no padrão `camelCase`, sem utilização de `_`.
- Nome das colunas devem ter exatamente o nome do atributo do `Entity` correspondente.
- Se utilizar Spring com Hibernate utilize a propriedade `spring.jpa.hibernate.naming.physical-strategy=org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl` para garantir que o hibernate não renomeie as colunas descritas nas annotations.
- A coluna id da tabela deve ser sempre do tipo BigInt e AUTO_INCREMENT.
- Colunas de FK devem começar com o prefixo `id` seguidas do nome da tabela que relacionam. Exemplo: `idUser`.
  - No caso de múltiplas referências para a mesma tabela o nome da coluna deve iniciar com `id` mas seguido do relacionamento/função/descrição que explique a diferença entre os múltiplos relacionamentos.
- Tabelas de relacionamento entre tabelas devem ter o nome composto pelo nome das tabelas que ela relaciona separados por `_` (única exceção em que o nome da tabela deve conter `_`).
  - Tabelas de relacionamento N:N não devem ter coluna `id` por padrão, exceto quando virarem entidades com atributos próprios.
- Constraints podem ser definidas à vontade, apenas seguindo os prefixos `pk`, `fk` e `uk` com nomes curtos e objetivos.
- Quando houver necessidade de criação de coluna de monitoramento utilizar os nomes convencionados a seguir conforme o caso: `createdAt`, `updatedAt`.
- Banco de Dados devem utilizar `CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`.
- Quando o sistema tiver a separação lógica de módulos/ferramentas ou outra separação lógica o nome das tabela devem seguir com um prefixo que agrupe as tabelas por função, exemplo: `<módulo>_<nomeDaEntidade>` (Segunda exceção em que o uso de `_` é permitido).

## Scripts

- Scripts de criação de banco de dados devem ficar em `db/init/`, a partir da pasta `resources` do projeto.
  - Scripts de criação do banco de dados devem ser separados dos nos seguintes arquivos:
    - `01-ddl.sql`: Criação do database/schema, charset, collation, usuários de banco, permissões básicas e estrutura do banco: tabelas, colunas, PKs, FKs, constraints, índices, views, procedures, functions, triggers e events.
    - `02-seed.sql`: Dados obrigatórios para o sistema iniciar e funcionar corretamente.
    - `03-dev-test-data.sql`: Dados apenas para desenvolvimento, testes locais ou homologação. Não deve ser executado em produção.
- Scripts de alteração/atualização do banco de dados devem ficar em `db/update/`, a partir da pasta `resources` do projeto.
  - Nenhum arquivo existente nessa pasta deve jamais ser corrigido ou alterado por nenhum agente de AI.
  - Após criado, um arquivo de update também não deve ser reaberto para correção por agente de AI; se precisar corrigir, crie outro update.
  - Sempre que uma alteração for realizada na estrutura do banco de dados ela deve ser corrigida nos arquivos de criação do banco, e um novo arquivo deve ser criado na pasta com o nome `YYYYMMDD_XXX_update.sql`, onde `XXX` é um valor incremental começando em `001` e reiniciado por data.
  - Todo arquivo de update criado deve conter na primeira linha o seguinte comentário:

```sql
-- Arquivo de atualização do banco de dados, não pode ser alterado por agentes de IA.
```

- Não usar `USE`.
- Não usar `IF NOT EXISTS` em `CREATE TABLE`.
- Não usar `CHARSET`/`COLLATE` em `CREATE TABLE`.
- Finalizar tabelas com `ENGINE=InnoDB`.
