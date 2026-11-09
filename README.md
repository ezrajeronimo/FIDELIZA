# FIDELIZA 8.6 — Gestão de acessos + Visão Geral compartilhada

## O que mudou
- A gestão pode **criar usuário com e-mail e senha inicial**, sem depender de convite.
- A gestão pode **editar nome, e-mail, perfil, loja, redefinir senha e excluir usuário**.
- Usuários comuns podem **trocar a própria senha**.
- **Todos os usuários autenticados** veem a Visão Geral e o ranking por loja.
- Cada usuário comum continua vendo apenas **Clientes, Recorrência, Campanhas, Agendamentos e Relatórios da própria loja**.
- O ranking e os indicadores globais vêm de uma **RPC com dados agregados**, sem retornar nomes ou telefones de outras lojas.
- O dashboard consulta novos totais a cada ~30 segundos enquanto aberto, com opção de atualizar manualmente.

## Ordem de instalação
1. No Supabase **SQL Editor**, execute `visao-geral-segura.sql`. Confirme que retornou a função `fideliza_dashboard_snapshot`.
2. No Supabase **Edge Functions > fideliza-admin-users > Code**, substitua **todo** o conteúdo do `index.ts` pelo arquivo `supabase/functions/fideliza-admin-users/index.ts` deste pacote e clique **Deploy updates**.
3. Em **Edge Functions > Settings**, verifique o JWT do gateway. Se estiver desligado, o próprio código da função DEVE validar a sessão (`auth.getUser`) e perfil admin. Este código inclui as verificações; não use versões antigas.
4. No GitHub **FIDELIZA**, substitua **somente** o `index.html`.
5. **Não altere `config.js`** nem publique segredo `service_role` no GitHub.
6. Recarregue o navegador e faça login como admin. Crie um usuário de teste com senha forte; entre com ele em janela anônima.

## Testes obrigatórios (antes de liberar dados reais)
- Perfil admin consegue abrir Administração, salvar usuário e redefinir senha.
- Perfil de loja consegue entrar, ver Visão Geral e pódio **de todas as lojas**, mas **não consegue** abrir listas de outras lojas.
- No Supabase, verifique que a **RLS de vendas, contatos e agendamentos** bloqueia SELECT de outra loja, mesmo por chamada direta à API.
- O usuário comum não consegue chamar `fideliza-admin-users` para criar, excluir ou alterar contas (retorno 403).
- A Visão Geral atualiza os totais em até cerca de 30 segundos enquanto o app estiver aberto e ativo.

## Segurança e limites
- A senha é escolhida pela gestão, não é recuperável depois, mas pode ser **substituída**. Não envie senhas por canais públicos e recomende alteração após o primeiro login.
- A criação usa `email_confirm: true`. Confirme a posse do e-mail e a identidade dos colaboradores antes de conceder acessos, especialmente admin.
- Usuários comuns **não podem modificar identidade do sistema, outras contas ou importar vendas**.
- Dados operacionais das lojas continuam protegidos pelas políticas RLS. A RPC pública para autenticados fornece apenas estatísticas agrupadas.
- A API de gestão precisa ser publicada no Supabase Edge Functions; o arquivo TypeScript **não** vai no GitHub Pages.
- Não altera as tabelas comerciais existentes nem apaga o histórico de dados ao excluir a conta de login.

## Dependências
- O projeto Supabase já deve conter `fideliza_profiles`, `fideliza_sales`, `fideliza_contacts`, `fideliza_appointments`, `fideliza_settings`, as políticas anteriores e a função `fideliza_can_access(text)`.
- A Edge Function deve ter disponíveis `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` **somente como secrets no Supabase**.

## Limites de validação
A sintaxe JavaScript do HTML foi verificada com `node --check`. O SQL e a Edge Function precisam ser executados e testados no projeto Supabase real para confirmar comportamento e permissões.
