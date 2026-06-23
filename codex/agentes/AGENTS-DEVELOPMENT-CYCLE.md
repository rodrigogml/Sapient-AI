# Agente: Ciclo de Desenvolvimento

Define o comportamento do Codex em ciclos de implementação, manutenção ou correção que alterem o repositório.

## Gatilhos

Leia estas instruções quando:

- o usuário sinalizar início ou fim de ciclo de desenvolvimento;
- o usuário pedir para "baixar o código", "baixasse o código", "puxar o código", "atualizar o código", "subir o código", "subisse o código", "enviar o código", "publicar o código" ou usar expressão equivalente de sincronização com a origem;
- a tarefa exigir alteração no repositório ainda sem nenhuma alteração local realizada pelo agente;
- o agente concluir, por critérios objetivos, que o objetivo proposto foi atingido;
- a tarefa envolver commit, push, pull, merge, branch ou sincronização com a origem.

## Vocabulário Operacional

- "Baixar o código", "baixasse o código", "puxar o código" ou "atualizar o código" indicam sincronizar o repositório local com a origem remota. Execute `git fetch`, compare o branch local com o branch remoto rastreado e aplique `git pull`/merge quando necessário e seguro. Se houver alterações locais que possam ser afetadas ou conflitos de merge, preserve o trabalho local e apresente o impedimento antes de continuar.
- "Subir o código", "subisse o código", "enviar o código" ou "publicar o código" indicam autorização para enviar toda a alteração local do repositório atual para a origem remota. Verifique o estado do repositório, revise o escopo, adicione todos os arquivos locais pertinentes com `git add`, execute validações cabíveis, crie commit, sincronize com a origem com `fetch` e `pull`/merge quando necessário, resolva apenas merges seguros e sem conflito, e então execute `git push`.
- Quando o usuário pedir para "subir o código", trate a autorização como abrangente para todas as alterações locais do repositório atual, inclusive arquivos novos, exceto arquivos claramente sensíveis, gerados indevidamente, ignoráveis ou fora do escopo técnico do repositório. Se houver dúvida sobre algum arquivo, pergunte antes de incluí-lo.

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
