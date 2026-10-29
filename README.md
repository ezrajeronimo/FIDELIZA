# FIDELIZA — Importação PDV UNIGAMES (v2)

Atualização do CRM para aceitar **CSV original do PDV** com cabeçalhos após três linhas de introdução, separador `;`, codificação Windows-1252, datas DD/MM/AAAA e valores brasileiros.

## Publicar
No repositório `ezrajeronimo/FIDELIZA`, abra `index.html` > ícone de lápis para editar > substitua pelo arquivo atualizado (ou use Add file > Upload files para sobrescrever) > Commit changes. A publicação do Pages se atualiza.

## Regras
- Agrupa linhas de produtos da mesma venda usando Nº.
- Não inclui registros genéricos `CLIENTES UNIGAMES` ou `AVULSO`.
- Identifica cliente pelo telefone válido; caso não exista, utiliza nome normalizado (estimativa sujeita a homônimos).
- Gasto calculado pelo valor total da venda registrado, uma vez por Nº.
- **Não inventa bairro e cidade**: requer cadastro complementar para visão por região.
- Dados permanecem no navegador; NÃO suba planilhas de clientes ao GitHub ou repositórios públicos. Para uso comercial real, criar autenticação, base de dados segura e controles LGPD.

## Limitações
- Importação substitui a base anterior (não acumula arquivos).
- Com nomes comuns e telefones compartilhados, a recorrência é estimativa.
- O limite de armazenamento do navegador pode impedir a persistência de bases grandes.
- Página pública não é sistema multiusuário protegido.
