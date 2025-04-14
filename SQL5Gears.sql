CREATE DATABASE FiveGears;
USE FiveGears;

CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL
);

CREATE TABLE endereco (
    id_endereco INT PRIMARY KEY AUTO_INCREMENT,
    rua VARCHAR(255) NOT NULL,
    numero VARCHAR(10),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(20)
);

-- 3. TABELA DE NÍVEIS DE PERMISSÃO
CREATE TABLE nivel_permissao (
    id_permissao INT PRIMARY KEY AUTO_INCREMENT,
    nome_permissao VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    id_empresa INT,
    id_endereco INT,
    id_permissao INT,
    FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa),
    FOREIGN KEY (id_endereco) REFERENCES endereco(id_endereco),
    FOREIGN KEY (id_permissao) REFERENCES nivel_permissao(id_permissao)
);

CREATE TABLE login (
    id_login INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    senha VARCHAR(255) NOT NULL,
    ultimo_login DATETIME,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE status_usuario (
    id_status INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    data_entrada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_saida DATETIME,
    status_atual VARCHAR(20) DEFAULT 'ONLINE', 
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE chamado_pipefy (
    id_chamado INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT, 
    titulo VARCHAR(255),
    descricao TEXT,
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'ABERTO', 
    id_pipefy_card VARCHAR(100), 
    tipo_chamado VARCHAR(100), 
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);


INSERT INTO nivel_permissao (nome_permissao) VALUES
('FUNCIONARIO'),
('GERENTE'),
('ADMIN');

