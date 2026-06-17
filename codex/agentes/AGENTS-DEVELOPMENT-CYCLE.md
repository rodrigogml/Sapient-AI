# Agente: Ciclo de Desenvolvimento

Define o comportamento do Codex em ciclos de implementação, manutenção ou correção que alterem o repositório.

## Gatilhos

Leia estas instruções quando:

- o usuário sinalizar início ou fim de ciclo de desenvolvimento;
- a tarefa exigir alteração no repositório ainda sem nenhuma alteração local realizada pelo agente;
- o agente concluir, por critérios objetivos, que o objetivo proposto foi atingido;
- a tarefa envolver commit, push, pull, merge, branch ou sincronização com a origem.

## Início

Antes da primeira alteração local:

1. Verifique `git status --short --branch`.
2. Verifique a origem remota.
3. Execute `git fetch`.
4. Compare branch local e branch remoto rastreado.
5. Se houver atualização remota e for seguro, use `git pull --ff-only`.

Se o fast-forward não for possível, não force integração. Analise a divergência e apresente ao usuário um plano com alternativas, riscos e justificativas, incluindo continuar sem atualizar e o risco de merge mais complexo no fim.

Se já houver alterações locais, preserve-as. Continue apenas quando for seguro distinguir o trabalho existente do trabalho do ciclo atual.

## Execução

- Mantenha o escopo restrito ao objetivo.
- Leia código e documentação relevantes antes de alterar comportamento.
- Preserve alterações preexistentes que não foram feitas pelo agente.
- Valide a mudança com os comandos adequados ao projeto, quando existirem.
- Registre falhas, impedimentos e validações executadas.

## Encerramento

O ciclo termina quando o usuário declarar o fim, quando o objetivo estiver concluído ou quando uma métrica automatizada definida indicar conclusão.

Ao encerrar:

1. Verifique `git status --short`.
2. Revise o diff.
3. Execute validações cabíveis.
4. Resuma alterações e validações.
5. Faça commit quando autorizado para o ciclo ou repositório.
6. Faça push quando houver remoto configurado e o commit tiver sido criado.

Se o push falhar por divergência remota, não use force push sem autorização explícita. Busque a origem, analise a integração e apresente o plano ao usuário.

## Segurança

- Não use `git reset --hard`, `git checkout -- <arquivo>`, `git clean` ou equivalentes sem pedido explícito.
- Não reescreva histórico remoto sem autorização explícita.
- Não inclua arquivos fora do escopo no commit.
- Não oculte falhas de validação.
- Se o usuário pedir para não commitar, não faça commit nem push.
