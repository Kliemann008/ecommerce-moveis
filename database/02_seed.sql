-- =====================================================================
-- Dados de exemplo (fictícios) | Execute depois do 01_schema.sql
-- =====================================================================

INSERT INTO categorias (nome) VALUES ('Sala'), ('Quarto');

INSERT INTO produtos (categoria_id, nome, descricao, preco, cor_material) VALUES
    (1, 'Sofá 3 lugares', 'Sofá retrátil em tecido suede', 2499.90, 'Cinza'),
    (1, 'Mesa de centro',  'Mesa com tampo de vidro',        599.00, 'Madeira clara'),
    (2, 'Cama box casal',  'Cama box com baú',              1899.00, 'Branco');

INSERT INTO estoque (produto_id, quantidade) VALUES (1, 5), (2, 10), (3, 3);

INSERT INTO faixas_frete (cep_inicio, cep_fim, valor, prazo_dias) VALUES
    ('74000000', '74999999', 120.00, 5);

-- O valor de senha_hash é só texto de exemplo, não um hash real.
INSERT INTO clientes (nome, cpf, email, senha_hash) VALUES
    ('Cliente Exemplo', '52998224725', 'cliente@exemplo.com', 'hash_de_exemplo');

INSERT INTO enderecos (cliente_id, cep, logradouro, numero, bairro, cidade, uf) VALUES
    (1, '74000000', 'Rua das Flores', '10', 'Centro', 'Goiânia', 'GO');

INSERT INTO pedidos (cliente_id, valor_produtos, valor_frete, total, entrega_cep, entrega_endereco)
VALUES (1, 2499.90, 120.00, 2619.90, '74000000', 'Rua das Flores, 10 - Centro, Goiânia/GO');

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, nome_produto, preco_unitario)
VALUES (1, 1, 1, 'Sofá 3 lugares', 2499.90);

INSERT INTO pagamentos (pedido_id, meio, status, valor, id_transacao)
VALUES (1, 'pix', 'aprovado', 2619.90, 'TX-EXEMPLO-001');
