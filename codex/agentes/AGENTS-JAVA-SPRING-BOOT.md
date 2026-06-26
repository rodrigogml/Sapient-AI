# Agente: Java Spring Boot

Define regras e configurações para repositórios de projetos Java baseados em Spring Boot.

## Organização do Repositório

Use a estrutura padrão do Maven como base:

```text
/
+-- docs/
+-- pom.xml
+-- application.properties
+-- src/
    +-- main/
    |   +-- java/
    |   +-- resources/
    +-- test/
        +-- java/
        +-- resources/
```

- `src/main/java/`: código-fonte principal da aplicação.
- `src/main/resources/`: recursos empacotados junto com a aplicação.
- `src/test/java/`: código de testes automatizados.
- `src/test/resources/`: recursos usados pelos testes automatizados.
- `docs/`: documentação do projeto, incluindo requisitos, decisões, arquitetura e demais guias técnicos.
- `pom.xml`: definição Maven do projeto, dependências, plugins e configurações de build.
- `application.properties`: arquivo de properties do projeto. Deve ficar na raiz do projeto, não em `src/main/resources/`.

## Documentação

- Requisitos do projeto devem ficar em `docs/requirements/`, quando houver separação formal de requisitos.
- Decisões técnicas relevantes devem ficar em `docs/decisions/`, quando houver registro formal de decisões.
- Documentação de arquitetura deve ficar em `docs/architecture/`, quando houver visão arquitetural específica.

## Application Properties

- `application.properties` deve ficar na raiz do projeto e nunca deve ser versionado.
- Inclua `application.properties` no `.gitignore`. Se o projeto não usar Git, aplique configuração equivalente para impedir versionamento ou publicação.
- Segredos, chaves criptográficas, senhas, credenciais, URLs sensíveis e configurações de ambiente nunca devem ficar no código-fonte.
- Configurações sensíveis e específicas de ambiente devem ficar em `application.properties`.
- `application.properties` não deve ler variáveis de ambiente para redefinir propriedades.
- Mantenha `application.properties.model` na mesma pasta de `application.properties`.
- `application.properties.model` deve ser versionado, conter comentários objetivos sobre cada atributo e usar valores sugeridos ou padrões de preenchimento.
- `application.properties` deve conter valores reais do ambiente local, de homologação ou de produção.
- Ao encontrar os dois arquivos, mantenha ambos sincronizados e com os atributos na mesma ordem.
- O cabeçalho dos dois arquivos deve informar que eles precisam permanecer sincronizados: o `.model` documenta e sugere valores; o `application.properties` contém os valores reais do ambiente.

## Packages

- Package base: `<group>.<project>`, sempre em lowercase e sem underscores.
- A classe principal Spring Boot deve ficar diretamente no package base.
- Packages devem ser singulares, por contexto/responsabilidade, sem agrupadores genéricos.
- Use `module` para agrupar módulos de negócio.
- Exceções ao singular: use `enums` e `interfaces`, pois `enum` e `interface` são palavras reservadas do Java.
- Use `util`, nunca `utils`.

### Acesso entre Packages

- `ui` acessa apenas `api` e `shared`; nunca acessa `backend`.
- `api` acessa apenas `shared`; não depende de `backend` nem de `ui`.
- `backend` implementa `api`, pode acessar `shared` e não depende de `ui`.
- `shared` não depende de `api`, `backend` ou `ui`.
- `entity` e `repository` nunca saem do `backend`.
- `service` não acessa `ui`; publica comportamento externo por `facade`.
- `controller` não contém regra de negócio; delega para `facade` ou contrato equivalente.

### Packages Repetidos

- `config`: configuração do escopo onde está. Em `<base>.config`, infraestrutura geral; em `backend.config`, infraestrutura interna; em `ui.config`, apresentação; em `module.<module>.config`, wiring do módulo.
- `dto`: objetos mutáveis de transporte da camada onde estão. Em `api.dto`, contrato externo; em `backend.module.<module>.dto`, transporte interno; em `shared.dto`, somente contratos transversais.
- `vo`: valores imutáveis da camada onde estão. Em `api.vo`, retorno/entrada pública; em `backend.module.<module>.vo`, valor interno de domínio; em `shared.vo`, valor transversal.
- `enums`: enumerações do contrato onde estão. Enums usadas por UI/API ficam em `api` ou `shared`; enums internas ficam no módulo backend.
- `exception`: apenas em `shared.exception`. Toda exception propagável deve ficar em `shared` para evitar `ClassNotFoundException` em aplicações externas.
- `facade`: contrato público em `api.facade`; implementação e orquestração em `backend.module.<module>.facade`.
- `component` e `view`: exclusivos de `ui`; não carregam regra de negócio.

### Responsabilidades Arquiteturais

- `controller`: borda HTTP. Recebe requests, chama `facade` e retorna responses. Não acessa `repository` nem contém regra de negócio.
- `facade`: borda pública da aplicação. Publica operações completas, coordena `service` e concentra a entrada de casos de uso.
- `service`: regra de negócio atômica e reutilizável. Manipula `entity`, usa `repository` e não conhece `ui` ou `controller`.
- `repository`: acesso a dados. Manipula apenas `entity` e não contém regra de negócio.
- `entity`: modelo persistido. Fica restrito ao `backend` e não é exposto para `api` ou `ui`.
- `dto`: transporte mutável entre camadas e contratos.
- `vo`: valor imutável, preferencialmente definido como `record`.
- Não crie package `core` como agrupador genérico; use `module.platform` apenas para funcionalidades base e transversais reais.

```text
<base>
+-- config
+-- shared
|   +-- dto
|   +-- vo
|   +-- enums
|   +-- exception
+-- api
|   +-- controller
|   +-- facade
|   +-- dto
|   +-- vo
|   +-- enums
+-- backend
|   +-- config
|   +-- module
|       +-- <module>
|           +-- config
|           +-- facade
|           +-- service
|           +-- entity
|           +-- repository
|           +-- dto
|           +-- vo
|           +-- enums
|           +-- util
+-- ui
    +-- config
    +-- view
    +-- component
    +-- module
        +-- <module>
            +-- view
            +-- component
```

- `api`: contratos de entrada/saída, controllers REST, facades públicas, DTOs, VOs e enums expostos.
- `backend`: regras de negócio, persistência, integrações internas e implementação das facades.
- `ui`: telas, rotas e componentes visuais; não acessa `backend` diretamente.
- `shared`: contratos transversais realmente compartilhados entre camadas.
- `shared.exception`: exceptions propagáveis por qualquer camada ou aplicação externa.
- `entity` e `repository` pertencem ao backend e não devem ser expostos para UI ou API.
- `service` contém lógica de negócio atômica.
- `facade` publica operações completas e coordena services quando necessário.
- Testes em `src/test/java` devem espelhar o package da classe testada.
