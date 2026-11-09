# FIDELIZA 8.0 — Executive Navy

## Instalação
1. Faça backup do seu `index.html` atual (versão 7.2).
2. Substitua **apenas** o `index.html` na raiz do repositório GitHub `FIDELIZA`.
3. **Mantenha seu `config.js` atual**. O arquivo `config.example.js` é somente documentação e não precisa ser enviado.
4. Confirme em **Commit changes** e aguarde o GitHub Pages publicar.
5. Teste login, navegação por loja, carregamento dos clientes, ficha 360°, registro de contato, importação e exportação.

## Alterações da versão 8.0
- Visual Executive Navy: identidade UNIGAMES, menos gradientes, melhor espaçamento e contraste.
- Dashboard compacto, refinado, com indicadores e atualização manual da base.
- Nova lista de clientes com colunas e alternância para cards.
- Ficha 360° em painel lateral: dados comerciais, histórico de compras, contatos e WhatsApp.
- Mantidos filtros por loja, bairro, recorrência, quantidade de vendas, faturamento, período brasileiro e modalidades de pagamento.
- Mantidas as tabelas Supabase `fideliza_sales`, `fideliza_contacts`, `fideliza_profiles` e o login.

## Limites importantes
- Não foi acrescentada nenhuma tabela, campo ou política SQL.
- A medição de atendimentos no gráfico ainda depende dos dados presentes na base; apenas dados de vendas não permitem medir todos os atendimentos reais.
- As políticas RLS existentes devem permanecer ativas e ser testadas para cada usuário/loja.
- Não coloque dados de clientes ou chaves secretas no repositório público.
- Faça um teste funcional no GitHub Pages após a publicação.
