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
