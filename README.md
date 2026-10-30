# FIDELIZA 7.0 — Conexão Supabase

## Instalação

1. Crie um projeto em https://supabase.com/dashboard.
2. Abra **SQL Editor** e execute `supabase.sql` (em projeto novo).
3. Em **Authentication > Users**, crie o usuário de gestão por e-mail e senha (confirme o e-mail, se exigido).
4. Copie o UUID desse usuário (não é a senha) e execute o `INSERT` de perfil de gestão que está comentado no fim do SQL.
5. Em **Project Settings > API / Connect**, copie a **Project URL** e a **publishable key (ou anon key pública)** para `config.js`. Não use secret key nem `service_role`.
6. Desative o cadastro público de usuários em Authentication > Providers > Email se não precisar de autoinscrição; crie contas de colaboradores pela administração.
7. No repositório GitHub Pages, publique `index.html` e `config.js`. **Não publique `supabase.sql` com dados pessoais ou credenciais** (o SQL distribuído não possui dados de clientes).
8. Entre no FIDELIZA com a conta de gestão e importe o CSV pela interface.
9. Crie outros usuários em Authentication e cadastre os perfis `role='store'` com a loja apropriada. Exemplo:
   `insert into public.fideliza_profiles(user_id,name,role,store) values ('UUID_DO_USUARIO','Equipe Guararapes','store','GUARARAPES');`

## O que foi implementado

- Login com Supabase Auth (e-mail/senha).
- Banco compartilhado de vendas e contatos, com RLS para gestão e cada loja.
- Gestão vê todas as lojas; usuários de loja veem somente os dados da própria unidade.
- Importação de vendas por loja e sincronização dos registros de contato.
- Visão Geral, clientes, filtros, recorrência, campanhas e relatórios preservados.

## Limitações que devem ser testadas antes de produção

- Esta versão é um ponto inicial de integração. Valide importações, integridade de números e políticas RLS com usuários de teste antes de dados reais.
- O banco tem proteção por loja; o cliente deve ser monitorado, e os CSVs reais devem permanecer fora do GitHub.
- Não há criação de usuários dentro do CRM, edição/exclusão de registros, auditoria avançada ou prevenção de importação parcial em falha de rede.
- O carregamento inicial consulta até todas as linhas em páginas de 1000; para bases grandes, migre análises agregadas e paginação para funções SQL/API.
- A chave pública pode estar no JavaScript; a segurança de dados depende de autenticação e políticas RLS corretas.
