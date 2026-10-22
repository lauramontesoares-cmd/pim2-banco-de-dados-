--  PIM CONSIGAZ - banco de dados
CREATE DATABASE pim_consigaz;
USE pim_consigaz;

--  2. CRIAÇÃO DAS TABELAS

--  2.1 Usuários (funcionários do sistema)

CREATE TABLE usuarios (
    id_usuario  INT AUTO_INCREMENT PRIMARY KEY,
    nome        VARCHAR(100) NOT NULL,
    login       VARCHAR(20)  NOT NULL UNIQUE,
    senha       VARCHAR(15)  NOT NULL,
    nivel       ENUM(
                    'ADMINISTRADOR',
                    'ATENDENTE',
                    'ENTREGADOR',
                    'CLIENTE'
                ) NOT NULL,
    ativo       BOOLEAN      NOT NULL DEFAULT TRUE
);

SELECT * FROM usuarios;

--  2.2 Clientes

CREATE TABLE clientes (
    id_cliente  INT AUTO_INCREMENT PRIMARY KEY,
    nome        VARCHAR(100) NOT NULL,
    login       VARCHAR(20)  NOT NULL UNIQUE,
    senha       VARCHAR(15)  NOT NULL,
    telefone    VARCHAR(20)  NOT NULL,
    endereco    VARCHAR(200) NOT NULL,
    ativo       BOOLEAN      NOT NULL DEFAULT TRUE
);

--  2.3 Produtos (botijões de gás)

CREATE TABLE produtos (
    id_produto  INT AUTO_INCREMENT PRIMARY KEY,
    tipo        ENUM('P13', 'P20', 'P45') NOT NULL UNIQUE,
    preco       DECIMAL(10,2) NOT NULL,
    ativo       BOOLEAN       NOT NULL DEFAULT TRUE,

    CHECK (preco >= 0)
);
--  2.4 Estoque

CREATE TABLE estoque (
    id_estoque  INT AUTO_INCREMENT PRIMARY KEY,
    id_produto  INT NOT NULL UNIQUE,
    quantidade  INT NOT NULL DEFAULT 0,

    FOREIGN KEY (id_produto) 
    REFERENCES produtos(id_produto),

    CHECK (quantidade >= 0)
);

--  2.5 Pedidos
CREATE TABLE pedidos (
    id_pedido         INT AUTO_INCREMENT PRIMARY KEY,

    id_cliente        INT NOT NULL,
    id_usuario        INT NULL,

    data_pedido       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    status            ENUM(
                          'PENDENTE',
                          'EM_SEPARACAO',
                          'SAIU_PARA_ENTREGA',
                          'ENTREGUE',
                          'CANCELADO'
                      ) NOT NULL DEFAULT 'PENDENTE',

    forma_pagamento   ENUM(
                          'PIX',
                          'CREDITO',
                          'DEBITO'
                      ) NOT NULL,

    endereco_entrega  VARCHAR(200)  NOT NULL,
    valor_total       DECIMAL(10,2) NOT NULL DEFAULT 0,

    FOREIGN KEY (id_cliente) 
    REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_usuario) 
    REFERENCES usuarios(id_usuario)
);

--  2.6 Itens do pedido
CREATE TABLE itens_pedido (
    id_item         INT AUTO_INCREMENT PRIMARY KEY,

    id_pedido       INT NOT NULL,
    id_produto      INT NOT NULL,

    quantidade      INT           NOT NULL,
    preco_unitario  DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (id_pedido)  
    REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_produto) 
    REFERENCES produtos(id_produto),

    CHECK (quantidade > 0),
    CHECK (preco_unitario >= 0)
);

--  2.7 Entregas
CREATE TABLE entregas (
    id_entrega     INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido      INT NOT NULL UNIQUE,
    id_entregador  INT NOT NULL,

    status         ENUM(
                       'PENDENTE',
                       'EM_ROTA',
                       'ENTREGUE'
                   ) NOT NULL DEFAULT 'PENDENTE',

    data_saida     DATETIME NULL,
    data_entrega   DATETIME NULL,

    FOREIGN KEY (id_pedido)     
    REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_entregador) 
    REFERENCES usuarios(id_usuario)
);

--  2.8 Movimentações do estoque
CREATE TABLE movimentacoes_estoque (
    id_movimentacao    INT AUTO_INCREMENT PRIMARY KEY,
    id_produto         INT NOT NULL,
    id_usuario         INT NULL,
    tipo               ENUM(
                           'ENTRADA',
                           'SAIDA',
                           'DEVOLUCAO'
                       ) NOT NULL,

    quantidade         INT NOT NULL,
    data_movimentacao  DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_produto) 
    REFERENCES produtos(id_produto),
    FOREIGN KEY (id_usuario) 
    REFERENCES usuarios(id_usuario),

    CHECK (quantidade > 0)
);

--  3. DADOS INICIAIS
--  3.1 Usuários
INSERT INTO usuarios (nome, login, senha, nivel)
VALUES
    ('Administrador', 'admin',      '1234', 'ADMINISTRADOR'),
    ('Atendente',     'atendente',  '1234', 'ATENDENTE'),
    ('Entregador',    'entregador', '1234', 'ENTREGADOR');

--  3.2 Clientes
INSERT INTO clientes (nome, login, senha, telefone, endereco)
VALUES
    (
        'Godofredo',
        'godofredo',
        '1234',
        '(12) 99999-1111',
        'Rua das Flores, 100 - Taubaté - SP'
    ),
    (
        'Ariana Grande',
        'ariana',
        '1234',
        '(12) 98888-2222',
        'Avenida Brasil, 200 - São José dos Campos - SP'
    ),
    (
        'Dolores Santos',
        'Dolores',
        '1234',
        '(12) 99999-1111',
        'Rua das Flores, 100 - Taubaté - SP'
    );

--  3.3 Produtos
INSERT INTO produtos (tipo, preco)
VALUES
    ('P13', 100.00),
    ('P20', 150.00),
    ('P45', 300.00);
    
    
UPDATE produtos
set preco = 110.00
where tipo = 'P13';

UPDATE produtos
set preco = 250.00
where tipo = 'P20';

UPDATE produtos
set preco = 450.00
where tipo = 'P45';

SELECT * FROM produtos;

--  3.4 Estoque inicial
INSERT INTO estoque (id_produto, quantidade)
VALUES
    (1, 50),
    (2, 30),
    (3, 20);

--  4. TESTE DE PEDIDO
-- 4.1 Criar pedido
INSERT INTO pedidos (id_cliente, forma_pagamento, endereco_entrega)
VALUES (1, 'PIX', 'Rua das Flores, 100 - Taubaté - SP');

INSERT INTO pedidos (id_cliente, forma_pagamento, endereco_entrega)
VALUES (1, 'DEBITO', 'Avenida Brasil, 200 - São José dos Campos - SP');

SELECT * FROM pedidos;

-- 4.2 Adicionar produto ao pedido

INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario)
VALUES (1, 1, 1, 100.00);

-- 4.3 Atualizar o valor total do pedido
UPDATE pedidos
SET valor_total = (
    SELECT SUM(quantidade * preco_unitario)
    FROM itens_pedido
    WHERE id_pedido = 1
)
WHERE id_pedido = 1;

-- 4.4 Atualizar o estoque após a venda
UPDATE estoque
SET quantidade = quantidade - 1
WHERE id_produto = 1
AND quantidade >= 1;


-- 4.5 Registrar a movimentação de estoque (saída por venda)
INSERT INTO movimentacoes_estoque (id_produto, id_usuario, tipo, quantidade)
VALUES (1, 2, 'SAIDA', 1);

--  5. TESTE DE ENTREGA

-- 5.1 Criar entrega
INSERT INTO entregas (id_pedido, id_entregador)
VALUES (1, 3);

-- 5.2 Colocar entrega em rota
UPDATE entregas
SET status     = 'EM_ROTA',
    data_saida = CURRENT_TIMESTAMP
WHERE id_entrega = 1;

-- 5.3 Marcar entrega como entregue
UPDATE entregas
SET status       = 'ENTREGUE',
    data_entrega = CURRENT_TIMESTAMP
WHERE id_entrega = 1;

-- 5.4 Atualizar status do pedido
UPDATE pedidos
SET status = 'ENTREGUE'
WHERE id_pedido = 1;

--  6. CONSULTAS PARA CONFERIR OS RESULTADOS

SELECT * FROM usuarios;
SELECT * FROM clientes;
SELECT * FROM produtos;
SELECT * FROM estoque;
SELECT * FROM pedidos;
SELECT * FROM itens_pedido;
SELECT * FROM entregas;
SELECT * FROM movimentacoes_estoque;
