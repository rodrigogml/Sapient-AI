# Agente: Codificação Java

Define regras de escrita, nomenclatura, documentação e testes para código Java.

## Idioma e Encoding

- Código, identificadores e APIs devem ser escritos em inglês.
- Comentários e Javadocs devem ser escritos em português.
- Preserve o encoding original do arquivo.
- Novos arquivos devem usar UTF-8 limpo, sem BOM.

## Nomenclatura

- Classes, interfaces, enums, records e annotations: `PascalCase`.
- Métodos, variáveis, campos e parâmetros: `camelCase`.
- Constantes: `UPPER_SNAKE_CASE`.
- Packages: lowercase, sem underscores.
- Prefira package no singular.
- Exceções ao singular: use `enums` e `interfaces`, pois `enum` e `interface` são palavras reservadas do Java.
- Use `util`, nunca `utils`.
- Arquivos Java devem ter o mesmo nome da classe pública.
- Não use abreviações obscuras.
- Não use nomes genéricos quando houver conceito de domínio claro.

## Tipos, Imports e Estrutura

- Não use `var`; declare tipos explicitamente.
- Não use `canonicalName`; prefira imports.
- Prefira imports explícitos; evite nomes totalmente qualificados no corpo do código.
- Classes devem ser pequenas, coesas e com uma única responsabilidade.
- Não crie helpers pequenos/triviais sem reutilização real.
- Evite classes grandes, múltiplas responsabilidades e métodos longos.
- Código não deve depender de detalhes internos de outra camada ou módulo.

## Sufixos e Prefixos

- `Config`: configuração.
- `Definitions`: constantes de definições globais.
- `Enum`: enumeração em classe própria.
- `DTO`: objeto mutável de transporte.
- `QueryDTO`: parâmetros de consulta, pesquisa, relatório, lazy load ou query avançada.
- `VO`: valor imutável, preferencialmente `record`.
- `Entity`: modelo persistido.
- `Repository`: acesso a dados.
- `Service`: regra de negócio atômica.
- `Facade`: contrato público de operação completa.
- `FacadeImpl`: implementação de facade.
- `View`: rota ou tela.
- `Component`: componente visual reutilizável.
- `Interface`: uso restrito para interfaces que não representem API exposta.
- `Util`: prefixo para utility class estática.

## Javadoc e Comentários

- Preserve Javadocs existentes, `@author`, `@since` e comentários úteis.
- Não remova Javadoc de método.
- Javadoc de classe deve declarar objetivo, escopo e responsabilidade.
- Se `@author` estiver ausente, use o autor definido nas instruções aplicáveis do usuário ou do projeto.
- Se nenhum autor estiver definido, não invente um valor, questione e solicite que o usuário defina no aquivo de AGENTS.md pessoal.
- Se `@since` estiver ausente, inclua `@since YYYY-MM-DD`.
- Todo tipo público deve possuir Javadoc: classe, interface, enum, record ou annotation.
- Todo método não `private` deve possuir Javadoc completo.
- Todo método com mais de 5 linhas deve possuir Javadoc completo.
- Métodos, atributos e classes com regra, limitação, contrato ou comportamento específico devem possuir Javadoc.
- Javadoc deve informar finalidade, argumentos obrigatórios ou nullable, retorno, possíveis retornos `null` e exceções lançadas.
- Use `@see` quando houver documentação externa relevante.
- Use `{@link}` para referenciar tipos, métodos ou campos dentro do Javadoc.
- Não use Javadoc para histórico de alteração.
- Comentários devem explicar o porquê, não o quê.
- Não escreva comentários óbvios.
- Comentários TODO devem usar o formato `// TODO`.
- Não transforme Javadoc em tutorial.

## Enums

- Toda enum em classe própria deve usar sufixo `Enum`.
- Enum interna só é permitida para uso estritamente local da classe/container.
- Enum compartilhada entre camadas, persistência, i18n, serialização, integração ou contrato público deve ser classe própria.
- Enums expostas devem ter chave i18n no padrão `enum.<SimpleName>.<VALUE>`.

## DTO, VO e Entity

- `DTO` é mutável, transporta dados e não contém regra de negócio.
- `VO` é imutável, definido preferencialmente como `record` e sem setters.
- `Entity` representa persistência e não contém regra de apresentação ou contrato externo.
- Não coloque acesso a `Service` ou `Repository` em `DTO`, `VO` ou `Entity`.
- Não referencie atributos de `DTO` ou `VO` por string literal quando houver metaobject disponível.

## Utility Classes

- Utility class deve ser `final`.
- Utility class deve ter construtor privado.
- Utility class não deve manter estado.
- Utility class deve ter testes unitários com 100% de cobertura quando testes forem solicitados.

## Testes Java

- Não crie testes sem solicitação explícita.
- Testes devem ficar no mesmo package da classe testada; a pasta física segue o padrão do projeto.
- Classe de teste unitário: `<ClasseTestada>Test`.
- Classe de teste de integração: `<ClasseTestada>IT`.
- Não use prefixos ou sufixos alternativos.
- Classe de teste deve ser package-private.
- Use `@Nested` para agrupar cenários quando fizer sentido.
- Use `@DisplayName` para legibilidade.
- Método de teste: `<methodName>_should<ExpectedBehavior>_when<Condition>`.
- Use `camelCase` nas partes textuais do nome do teste.
- Um método de teste deve validar um comportamento.
- Estruture testes em blocos `arrange`, `act`, `assert`.
- Não use `System.out.println`.
- Não use `try/catch` para validar exceções; use `assertThrows`.
- Teste contratos e comportamento observável, não detalhes internos triviais.
- Testes devem ser pequenos, determinísticos e independentes.
