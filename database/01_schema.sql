-- =====================================================================
-- E-commerce de móveis | Schema v1 | Supabase (PostgreSQL)
-- Execute este arquivo primeiro no SQL Editor e depois o 02_seed.sql.
-- =====================================================================

-- ---------- Tabelas ----------

CREATE TABLE clientes (
    id          SERIAL PRIMARY KEY,
    nome        VARCHAR(150) NOT NULL,
    cpf         CHAR(11)     NOT NULL UNIQUE CHECK (LENGTH(cpf) = 11),
    email       VARCHAR(254) NOT NULL UNIQUE,
    telefone    VARCHAR(13),
    senha_hash  TEXT         NOT NULL,
    ativo       BOOLEAN      NOT NULL DEFAULT TRUE,
    criado_em   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE enderecos (
    id           SERIAL PRIMARY KEY,
    cliente_id   INT          NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    cep          CHAR(8)      NOT NULL CHECK (LENGTH(cep) = 8),
    logradouro   VARCHAR(200) NOT NULL,
    numero       VARCHAR(10)  NOT NULL,
    complemento  VARCHAR(100),
    bairro       VARCHAR(100) NOT NULL,
    cidade       VARCHAR(100) NOT NULL,
    uf           CHAR(2)      NOT NULL
);

CREATE TABLE categorias (
    id    SERIAL PRIMARY KEY,
    nome  VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE produtos (
    id               SERIAL PRIMARY KEY,
    categoria_id     INT           NOT NULL REFERENCES categorias(id),
    nome             VARCHAR(200)  NOT NULL,
    descricao        TEXT,
    preco            NUMERIC(10,2) NOT NULL CHECK (preco > 0),
    altura_cm        NUMERIC(7,2)  CHECK (altura_cm > 0),
    largura_cm       NUMERIC(7,2)  CHECK (largura_cm > 0),
    profundidade_cm  NUMERIC(7,2)  CHECK (profundidade_cm > 0),
    cor_material     VARCHAR(100),
    ativo            BOOLEAN       NOT NULL DEFAULT TRUE,
    criado_em        TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE TABLE imagens_produto (
    id          SERIAL PRIMARY KEY,
    produto_id  INT  NOT NULL REFERENCES produtos(id) ON DELETE CASCADE,
    url         TEXT NOT NULL,
    ordem       INT  NOT NULL DEFAULT 0
);

CREATE TABLE estoque (
    produto_id  INT PRIMARY KEY REFERENCES produtos(id) ON DELETE CASCADE,
    quantidade  INT NOT NULL DEFAULT 0 CHECK (quantidade >= 0),
    reservada   INT NOT NULL DEFAULT 0 CHECK (reservada >= 0),
    CHECK (reservada <= quantidade)
);

CREATE TABLE pedidos (
    id                SERIAL PRIMARY KEY,
    cliente_id        INT           NOT NULL REFERENCES clientes(id),
    status            VARCHAR(30)   NOT NULL DEFAULT 'aguardando_pagamento'
                      CHECK (status IN ('aguardando_pagamento', 'pago', 'em_separacao',
                                        'enviado', 'entregue', 'cancelado')),
    valor_produtos    NUMERIC(10,2) NOT NULL CHECK (valor_produtos >= 0),
    valor_frete       NUMERIC(10,2) NOT NULL CHECK (valor_frete >= 0),
    total             NUMERIC(10,2) NOT NULL,
    observacoes       VARCHAR(500),
    entrega_cep       CHAR(8)       NOT NULL,
    entrega_endereco  TEXT          NOT NULL,
    criado_em         TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    CHECK (total = valor_produtos + valor_frete)
);

CREATE TABLE itens_pedido (
    id              SERIAL PRIMARY KEY,
    pedido_id       INT           NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
    produto_id      INT           NOT NULL REFERENCES produtos(id),
    quantidade      INT           NOT NULL CHECK (quantidade > 0),
    nome_produto    VARCHAR(200)  NOT NULL,
    preco_unitario  NUMERIC(10,2) NOT NULL CHECK (preco_unitario > 0),
    UNIQUE (pedido_id, produto_id)
);

CREATE TABLE pagamentos (
    id            SERIAL PRIMARY KEY,
    pedido_id     INT           NOT NULL REFERENCES pedidos(id),
    meio          VARCHAR(10)   NOT NULL CHECK (meio IN ('pix', 'cartao', 'boleto')),
    status        VARCHAR(10)   NOT NULL DEFAULT 'pendente'
                  CHECK (status IN ('pendente', 'aprovado', 'recusado', 'estornado')),
    valor         NUMERIC(10,2) NOT NULL CHECK (valor > 0),
    id_transacao  VARCHAR(100)  UNIQUE,
    criado_em     TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE TABLE entregas (
    id               SERIAL PRIMARY KEY,
    pedido_id        INT NOT NULL UNIQUE REFERENCES pedidos(id),
    codigo_rastreio  VARCHAR(60),
    despachado_em    TIMESTAMPTZ,
    entregue_em      TIMESTAMPTZ
);

CREATE TABLE faixas_frete (
    id          SERIAL PRIMARY KEY,
    cep_inicio  CHAR(8)       NOT NULL,
    cep_fim     CHAR(8)       NOT NULL,
    valor       NUMERIC(10,2) NOT NULL CHECK (valor >= 0),
    prazo_dias  INT           NOT NULL CHECK (prazo_dias > 0),
    CHECK (cep_inicio <= cep_fim)
);

CREATE TABLE usuarios_admin (
    id          SERIAL PRIMARY KEY,
    nome        VARCHAR(150) NOT NULL,
    email       VARCHAR(254) NOT NULL UNIQUE,
    senha_hash  TEXT         NOT NULL,
    ativo       BOOLEAN      NOT NULL DEFAULT TRUE
);

-- ---------- Índices ----------

CREATE INDEX idx_enderecos_cliente  ON enderecos(cliente_id);
CREATE INDEX idx_produtos_categoria ON produtos(categoria_id);
CREATE INDEX idx_imagens_produto    ON imagens_produto(produto_id);
CREATE INDEX idx_pedidos_cliente    ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_status     ON pedidos(status);
CREATE INDEX idx_pagamentos_pedido  ON pagamentos(pedido_id);

-- ---------- Segurança (RLS) ----------
-- No Supabase, toda tabela do schema public fica acessível pela API
-- pública. Com RLS ativado e sem política, ninguém acessa pela API.
-- Seu backend (conexão direta ou chave service_role) ignora o RLS.

ALTER TABLE clientes        ENABLE ROW LEVEL SECURITY;
ALTER TABLE enderecos       ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias      ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos        ENABLE ROW LEVEL SECURITY;
ALTER TABLE imagens_produto ENABLE ROW LEVEL SECURITY;
ALTER TABLE estoque         ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos         ENABLE ROW LEVEL SECURITY;
ALTER TABLE itens_pedido    ENABLE ROW LEVEL SECURITY;
ALTER TABLE pagamentos      ENABLE ROW LEVEL SECURITY;
ALTER TABLE entregas        ENABLE ROW LEVEL SECURITY;
ALTER TABLE faixas_frete    ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios_admin  ENABLE ROW LEVEL SECURITY;

-- Única leitura pública: o catálogo.
CREATE POLICY catalogo_categorias ON categorias
    FOR SELECT TO anon, authenticated USING (true);

CREATE POLICY catalogo_produtos ON produtos
    FOR SELECT TO anon, authenticated USING (ativo);

CREATE POLICY catalogo_imagens ON imagens_produto
    FOR SELECT TO anon, authenticated USING (true);
