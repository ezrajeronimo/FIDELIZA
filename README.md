# FIDELIZA — Filtro de pagamento

Substitua `index.html` na raiz de seu repositório FIDELIZA e publique pelo GitHub Pages.

## Novidades
- Filtro por **Crediário, PIX, Débito, Cartão de crédito, Dinheiro e Outros** (inclusive vendas com pagamento misto).
- Exporte a lista de clientes atualmente filtrada como CSV, com telefone e formas de pagamento.
- Importa automaticamente a coluna `Tipo Pgto` do relatório UNIGAMES.
- Modelo próprio CSV aceita coluna opcional `pagamento`.
- Filtra clientes que **já usaram** a modalidade em qualquer compra do histórico importado.

**Atenção**: cartão de crédito parcelado não é sinônimo de crediário. O relatório Guararapes fornecido parece registrar `CREDITO 1X`, `CREDITO 10X`, etc., mas não apresenta uma modalidade explicitamente chamada `CREDIARIO`. Por isso o filtro Crediário pode ficar vazio: verifique a nomenclatura usada no PDV antes de configurar equivalências.

Os dados permanecem no navegador. Não carregue CSV com dados pessoais no repositório público GitHub.
