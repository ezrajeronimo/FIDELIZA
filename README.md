# FIDELIZA 8.7 — Importação, pagamentos e exclusão por loja

## O que mudou
- Filtro **Bairro / Região** removido da tela Clientes (e relatório de região removido da tela Relatórios).
- Filtro de pagamento avalia **somente as vendas que correspondem à modalidade selecionada**, em vez de selecionar um cliente com histórico misturado e mostrar o faturamento de todas as compras. Filtro da financeira PAYJOY nunca inclui uma compra apenas no CREDITO 10X.
- Modalidades compostas (ex.: `PIX, CREDITO 10X`) preservam ambas as categorias. CRED. PAYJOY/PARCELEX/CREFAZ/ODRES são distintas do cartão de crédito.
- CSV com campos entre aspas, delimitadores `;` ou `,`, quebras de linha entre aspas e codificação UTF-8/Windows-1252.
- Após importar, aparece um diagnóstico de linhas, vendas únicas, clientes distintos e linhas descartadas, incluindo vendas genéricas como `CLIENTES UNIGAMES`.
- **Limpar vendas da loja** fica visível apenas para `admin`, exige selecionar uma loja e digitar `EXCLUIR NOMEDALOJA`, inicia download de backup JSON e faz a exclusão no Supabase com política RLS. Não exclui contatos nem agendamentos.

## Instalação em ordem
1. Antes de qualquer exclusão, faça backup do banco pela ferramenta apropriada do Supabase. Não use a limpeza sem cópia recuperável.
2. Supabase → SQL Editor: execute `limpeza-admin.sql`. **Esse script não exclui vendas**; apenas habilita DELETE para admin.
3. GitHub → repositório FIDELIZA: substitua **somente** o `index.html` pelo arquivo deste pacote.
4. Preserve `config.js`, as Edge Functions e as demais tabelas do Supabase.
5. Entre como administrador e **reimporte o CSV original** da loja, pois vendas importadas por versões antigas podem ter um código de pagamento incorreto. Use a seleção de loja quando o CSV não tiver a coluna Loja.
6. Confirme filtros, números de clientes e modalidades de venda na ficha do cliente. Teste inicialmente com dados fictícios.
7. Só depois de validar os dados, utilize a limpeza por loja, se necessário. O botão não serve para remover clientes individuais.

## Diagnóstico com o CSV fornecido do Guararapes
Na cópia original do arquivo disponível neste projeto, testamos o importador localmente: foram lidas **16.363 linhas de dados**, consolidadas **4.989 vendas identificadas** e aproximadamente **4.166 clientes distintos** (após ignorar registros genéricos). Isso **não é uma contagem da sua base atual do RioMar**, nem comprova a quantidade exata de leads daquele arquivo: cada venda pode ocupar várias linhas e o mesmo cliente pode comprar várias vezes.

## Segurança
A ação de exclusão utiliza o usuário conectado e a política RLS `fideliza_sales_delete_admin`. Usuários de loja não têm autorização de DELETE no banco, mesmo que alguém manipule o navegador. A base de clientes não é colocada no GitHub.

## Verificação
Sintaxe JavaScript checada localmente. Importação e categorias de pagamento testadas com o CSV fornecido anteriormente. As políticas do SQL e operações no seu Supabase precisam de validação no projeto real.
