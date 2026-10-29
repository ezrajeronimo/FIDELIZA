# FIDELIZA v4 — Gestão por lojas e histórico de contatos

## Instalação
Substitua `index.html` no repositório GitHub Pages. Não envie CSVs de clientes para o repositório.

## Organização
- Visão Geral consolidada: indicadores, regiões, registros manuais de contatos, busca e exportação CSV dos contatos.
- Menus por unidade: GUARARAPES, RECIFE, RIOMAR, TACARUNA, PATTEO, PNWS e QUIOSQUE.
- Cada unidade possui Clientes, Recorrência, Campanhas e Relatórios.
- Importação de CSV da unidade selecionada ou com identificação no cabeçalho. Importações substituem a base local daquela unidade, mantendo as demais unidades importadas.
- Os registros de contato são manuais, com resultado e observação, e ficam armazenados no navegador local. Abrir WhatsApp não registra nem comprova contato.

## Importante: segurança
A navegação por loja **não é controle de acesso**. Esta versão não tem autenticação, servidor nem base compartilhada; não é possível impedir que uma unidade veja as outras no mesmo navegador. Para implantar permissões reais, é necessário backend seguro, contas por loja, regras de autorização no servidor e banco central com tratamento LGPD.
