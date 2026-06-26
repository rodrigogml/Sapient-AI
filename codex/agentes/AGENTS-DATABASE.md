# Agente: Banco de Dados MySQL

Define regras de modelagem, nomenclatura, scripts e revisão de banco de dados MySQL.

## Escopo

Use este agente para:

- criação ou alteração de scripts SQL MySQL;
- modelagem de schemas, tabelas, colunas, PKs, FKs, constraints, índices, views, procedures, functions, triggers ou events;
- alterações em entidades persistidas com impacto no banco;
- configuração JPA/Hibernate relacionada a nomes físicos de tabelas e colunas.

## Nomenclatura

- Schemas, tabelas, colunas, constraints e índices devem ser escritos em inglês.
- Comentários SQL, quando necessários, podem ser escritos em português.
- Tabelas e colunas devem usar `camelCase`, sem `_`.
- Use nomes claros, no singular, sem abreviações obscuras.
- Colunas devem ter exatamente o mesmo nome do atributo da `Entity` correspondente.
- `_` só é permitido em tabelas de relacionamento N:N e em prefixo de módulo/domínio no nome da tabela:
  - `user_userGroup`: relacionamento entre tabelas;
  - `security_user`: prefixo de módulo;
  - `security_user_userGroup`: composição de módulo e relacionamento.
- Quando houver prefixo por módulo/domínio, use `<module>_<entityName>`.
- Constraints devem usar `snake_case` com prefixo curto: `pk`, `fk` ou `uk`.
- Índices devem usar nome curto, objetivo e orientado à consulta que atendem.

## Charset, Collation e Engine

- Database/schema deve usar `CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`.
- Defina charset e collation no `CREATE DATABASE`, não em cada `CREATE TABLE`.
- Tabelas devem finalizar com `ENGINE=InnoDB`.
- Não declare `CHARSET` ou `COLLATE` em `CREATE TABLE`.

## Chaves e Relacionamentos

- A PK padrão deve ser `id BIGINT AUTO_INCREMENT`.
- Tabelas N:N puras não devem ter coluna `id`.
- Tabelas N:N com atributos próprios deixam de ser relacionamento puro, devem ter `id` e ser mapeadas como `Entity`.
- Colunas FK devem começar com `id` seguido do nome da tabela referenciada. Exemplo: `idUser`.
- Quando houver múltiplas FKs para a mesma tabela, use `id` seguido da função do relacionamento. Exemplo: `idCreatedByUser`.
- Posicione FKs preferencialmente logo após a PK.
- Em alteração de tabela existente, use `AFTER` quando a posição da coluna for relevante para legibilidade.
- Defina `ON DELETE` e `ON UPDATE` explicitamente quando a regra de integridade não for a padrão do projeto.

## Colunas Padrão

- Use `createdAt` e `updatedAt` para auditoria temporal.
- Use tipos compatíveis com MySQL e com o mapeamento Java/JPA esperado.
- Não armazene segredo em texto puro quando a informação exigir criptografia, hash ou proteção fora do banco.

## JPA e Hibernate

- Em projetos Spring/Hibernate, use:

```properties
spring.jpa.hibernate.naming.physical-strategy=org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
```

- O objetivo é impedir renomeação automática de tabelas e colunas descritas nas annotations.
- Entity, annotations JPA e scripts SQL devem permanecer sincronizados.
- Alteração de schema deve atualizar script de criação e script incremental aplicável.

## Scripts de Criação

- Scripts de criação devem ficar em `src/main/resources/db/init/`, salvo padrão mais específico do projeto.
- Separe scripts iniciais em:
  - `01-ddl.sql`: database/schema, charset, collation, usuários, permissões básicas e estrutura do banco.
  - `02-seed.sql`: dados obrigatórios para o sistema iniciar.
  - `03-dev-test-data.sql`: dados apenas para desenvolvimento, teste local ou homologação.
- Scripts de criação representam uma base nova já atualizada.
- Toda alteração estrutural deve ser refletida no script de criação.
- Não use `USE`.
- Não use `IF NOT EXISTS` em `CREATE TABLE`.
- Não inclua schema no nome da tabela, exceto quando o projeto exigir referência entre schemas.

## Scripts de Atualização

- Scripts de atualização devem ficar em `src/main/resources/db/update/`, salvo padrão mais específico do projeto.
- Arquivo de update já criado não deve ser alterado por agente de IA.
- Se um update precisar de correção, crie novo update incremental.
- Ao alterar estrutura, crie novo arquivo `YYYYMMDD_XXX_update.sql`, com `XXX` incremental por data.
- Todo update criado por agente de IA deve iniciar com:

```sql
-- Arquivo de atualização do banco de dados, não pode ser alterado por agentes de IA.
```

- Updates devem ser determinísticos, revisáveis e compatíveis com bancos existentes.
- Não escreva migração destrutiva, perda de dados, drop de coluna/tabela ou alteração irreversível sem autorização explícita.

## Multi-Tenancy

- Aplique estas regras quando o projeto declarar schemas global/tenant.
- Schema global pode ser referenciado por schema tenant; o inverso é proibido.
- FK tenant -> global deve declarar `ON DELETE SET NULL` quando o vínculo for opcional.
- FK tenant -> global deve declarar `ON DELETE CASCADE` quando o filho não puder existir sem o pai.
- FK tenant -> global não deve usar `ON DELETE RESTRICT` nem `ON DELETE NO ACTION`.
- Scripts globais e tenant devem ser separados conforme o padrão do projeto.

## Revisão e Validação

- Antes de editar SQL, verifique scripts init, updates existentes, entidades JPA e documentação de banco do projeto.
- Valide que init e update produzem o mesmo schema final para a alteração feita.
- Verifique nomes, tipos, nulidade, defaults, constraints, índices e FKs contra o contrato da aplicação.
- Prefira testes de schema quando o projeto já possuir esse padrão.
- Não altere dados de seed, fixtures ou massa histórica sem necessidade explícita.
