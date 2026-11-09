# FIDELIZA 8.5 — Reativação animada

## Atualizações
- **Gráfico e pódio animados** por loja.
- Alternância entre **Reativações confirmadas** e **Contatos registrados**.
- **Zero em vermelho**, inclusive no pódio.
- Contagem única por cliente, loja e dia. A data exibida segue `dd/mm/aaaa`.
- Registro comercial ganha a opção `6 = Cliente reativado (recompra confirmada)`.
- Apenas esse status conta para reativações: importação de vendas ou simples abertura do WhatsApp **não** equivale a recompra gerada por ação de CRM.
- Os dados continuam armazenados em `fideliza_contacts` no Supabase, preservando a autenticação e permissões existentes.

## Publicação
1. Faça backup do `index.html` atual.
2. Substitua **apenas** `index.html` no GitHub. Não altere `config.js` nem execute SQL.
3. Recarregue o sistema, registre um contato de teste com opção 6, e veja o gráfico de reativação na data de hoje.

## Nota operacional
O ranking de reativação exige registro manual explícito da recompra. Registros anteriores de `Venda realizada` não serão automaticamente interpretados como reativação, para evitar falsos positivos. Os gráficos de contatos também não devem ser confundidos com total de atendimentos físicos/digitais realizados por toda a loja.
