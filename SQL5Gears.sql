CREATE DATABASE IF NOT EXISTS FiveGears;
USE FiveGears;

-- Empresa
CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    fundador VARCHAR(255),
    cnpj VARCHAR(18) UNIQUE NOT NULL
);

-- Cliente
CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    email_responsavel VARCHAR(255)
);

-- Endereco
CREATE TABLE endereco (
    id_endereco INT PRIMARY KEY AUTO_INCREMENT,
    rua VARCHAR(255) NOT NULL,
    numero VARCHAR(10),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(20),
    id_empresa INT,
    id_cliente INT,
    FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

-- Nivel de Permissão
CREATE TABLE nivel_permissao (
    id_nivel INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT
);

-- Permissões iniciais
INSERT INTO nivel_permissao (nome, descricao) VALUES
('FUNCIONARIO', 'Acesso padrão de funcionário'),
('GERENTE', 'Acesso de gerente com permissões adicionais'),
('PROJETOS', 'Acesso da equipe de projetos que aceitam e não aceitam as propostas dos gerentes'),
('ADMIN', 'Acesso total ao sistema');

-- Status de Usuário
CREATE TABLE status_usuario (
    id_status INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT
);

INSERT INTO status_usuario (nome, descricao) VALUES ('ONLINE', 'Usuário está logado no sistema');
INSERT INTO status_usuario (nome, descricao) VALUES ('OFFLINE', 'Usuário não está logado no sistema');

-- Usuário
CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    telefone VARCHAR(20),
    area VARCHAR(20),
    carga_horaria INT DEFAULT 0,
    valor_hora DECIMAL(10,2) DEFAULT 0,
    id_empresa INT,
    id_nivel INT,
    id_status INT,
    FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa),
    FOREIGN KEY (id_nivel) REFERENCES nivel_permissao(id_nivel),
    FOREIGN KEY (id_status) REFERENCES status_usuario(id_status)
);

-- Login
CREATE TABLE login (
    id_login INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT,
    senha VARCHAR(255) NOT NULL CHECK (CHAR_LENGTH(senha) >= 8),
    ultimo_login DATETIME,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

-- Chamado Pipefy
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

-- Cargo
CREATE TABLE cargo (
    id_cargo INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    senioridade ENUM('ESTAGIARIO','JUNIOR','PLENO','SENIOR') DEFAULT 'JUNIOR'
);

-- Usuário ↔ Cargo
CREATE TABLE usuario_cargo (
    id_usuario INT NOT NULL,
    id_cargo INT NOT NULL,
    PRIMARY KEY (id_usuario, id_cargo),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_cargo) REFERENCES cargo(id_cargo)
);

-- Competência
CREATE TABLE competencia (
    id_competencia INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    codigo_esco VARCHAR(100),
    tipo VARCHAR(100),                -- ex: skill, knowledge, ability
    nivel_recomendado VARCHAR(50)   -- ex: básico, intermediário, avançado (um estag em bd não precisar ser avançado, mas um senior sim)
);

-- Usuário ↔ Competência
CREATE TABLE usuario_competencia (
    id_usuario INT NOT NULL,
    id_competencia INT NOT NULL,
    PRIMARY KEY (id_usuario, id_competencia),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_competencia) REFERENCES competencia(id_competencia)
);

-- Cargo ↔ Competência
CREATE TABLE cargo_competencia (
	peso INT DEFAULT 1, -- nivel competencia de 1 a 5
    id_cargo INT NOT NULL,
    id_competencia INT NOT NULL,
    PRIMARY KEY (id_cargo, id_competencia),
    FOREIGN KEY (id_cargo) REFERENCES cargo(id_cargo),
    FOREIGN KEY (id_competencia) REFERENCES competencia(id_competencia)
);


-- Projeto
CREATE TABLE projeto (
    id_projeto INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    tempo_estimado_horas INT,
    orcamento DECIMAL(15,2),
    status VARCHAR(50) DEFAULT 'EM_PLANEJAMENTO',
    data_inicio DATE,
    data_fim DATE,
    id_responsavel INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_responsavel) REFERENCES usuario(id_usuario)
);

-- Grupos de projeto (alocação de usuários)
CREATE TABLE usuario_projeto (
    id_projeto INT NOT NULL,
    id_usuario INT NOT NULL,
    id_cargo INT NOT NULL,
    status ENUM('ALOCADO','FINALIZADO') DEFAULT 'ALOCADO',
    horas_alocadas INT DEFAULT 0,      
    horas_por_dia INT DEFAULT 0,            
    data_alocacao DATETIME, 
    data_saida DATE DEFAULT NULL,            
    PRIMARY KEY (id_projeto, id_usuario),
    FOREIGN KEY (id_projeto) REFERENCES projeto(id_projeto),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_cargo) REFERENCES cargo(id_cargo)
);


-- Auditoria 
CREATE TABLE auditoria (
    id_auditoria INT PRIMARY KEY AUTO_INCREMENT,
    tabela_afetada VARCHAR(100) NOT NULL,
    id_registro INT NOT NULL,
    acao ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    valores_anteriores TEXT,
    valores_novos TEXT,
    usuario_responsavel INT,
    data_evento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_responsavel) REFERENCES usuario(id_usuario)
);
