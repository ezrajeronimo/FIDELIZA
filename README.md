# FIDELIZA 8.3 — Administração e identidade

## Novidades
- Login com nome do sistema animado e respeito a `prefers-reduced-motion`.
- Logo/foto do sistema alterável pelo administrador, exibida também no login.
- Três temas: **Executive Navy**, **Ocean Blue** e **Graphite**.
- Painel **Administração** para administrador visualizar usuários, enviar convites e atualizar perfil/loja.
- Usuário de loja: somente sua unidade, com consulta de clientes, WhatsApp, registro de contatos e agendamentos. Sem configurações, permissões, exportação ou importação de vendas.

## Instalar, nesta ordem

1. Abra **Supabase → SQL Editor** e execute `admin.sql`. Ele adiciona a tabela `fideliza_settings`, as permissões e restringe a gravação de vendas para administradores. Não apaga tabelas existentes.
2. No Supabase, crie a **Edge Function** `fideliza-admin-users` e cole o conteúdo de `supabase/functions/fideliza-admin-users/index.ts` (ou faça deploy com Supabase CLI). A função usa `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` fornecidas como variáveis secretas no **servidor**. Nunca publique a secret key no GitHub.
3. **Função Edge:** desative a verificação JWT do *gateway* para esta função apenas caso seu projeto utilize a nova `sb_publishable_...`. **A própria função valida o token de login e a função `admin` no servidor antes de executar qualquer operação.** Restrinja outras funções do projeto normalmente.
4. Em **Authentication → URL Configuration**, configure o **Site URL** como `https://ezrajeronimo.github.io/FIDELIZA/` e autorize esse mesmo endereço em **Redirect URLs**. Confirme que o serviço de e-mail do Supabase permite enviar convites; o envio de e-mails de produção pode exigir SMTP próprio.
5. No GitHub, substitua somente o `index.html` pelo do pacote. Mantenha o `config.js` já funcional.
6. Abra o site, faça login como administrador, entre em **Administração**, salve um tema/logo e envie um convite para um e-mail de teste. Ao receber, o usuário define sua senha e passa a acessar o sistema segundo o perfil atribuído.

### Permissões
- **Administrador:** todas as lojas, identidade, convites e permissões, importação de vendas e ações comerciais.
- **Usuário comum:** apenas sua loja; consultar clientes, abrir WhatsApp, registrar contato, criar/acompanhar agendamentos; não altera tema, usuários, perfis nem base importada.
- As regras relevantes são implementadas no Supabase; esconder botões isoladamente não seria seguro.

### Segurança
- `fideliza_settings.logo_data` é imagem pública de identidade visual (não contém informações pessoais). PNG/JPG/WebP reduzido antes do upload.
- A Edge Function jamais entrega nem aceita senhas dos colaboradores. Os convidados recebem um link e definem a própria senha.
- A chave `service_role` fica **somente** no ambiente de execução da Edge Function.
- Faça backup antes de executar migrações e teste primeiro com um colaborador de exemplo.

### Observação
O teste de sintaxe do JavaScript foi realizado. A integração com seu Supabase e o envio real de e-mails exigem publicação e testes no projeto.
