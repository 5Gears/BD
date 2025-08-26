-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS FiveGears;
USE FiveGears;

-- Empresa
CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    fundador VARCHAR(255) NOT NULL,
    cnpj VARCHAR(14) UNIQUE NOT NULL
);

-- Endereço
CREATE TABLE endereco (
    id_endereco INT PRIMARY KEY AUTO_INCREMENT,
    rua VARCHAR(255) NOT NULL,
    numero VARCHAR(10),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(20)
    );

-- Nível de permissão
CREATE TABLE nivel_permissao (
    id_permissao INT PRIMARY KEY AUTO_INCREMENT,
    nome_permissao VARCHAR(50) NOT NULL UNIQUE
    );

-- Usuário
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

-- Login
CREATE TABLE login (
    id_login INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    senha VARCHAR(255) NOT NULL CHECK (CHAR_LENGTH(senha) >= 8),
    ultimo_login DATETIME,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

-- Status do usuário
CREATE TABLE status_usuario (
    id_status INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    data_entrada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_saida DATETIME,
    status_atual VARCHAR(20) DEFAULT 'ONLINE',
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

-- Chamados (Pipefy)
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

-- Projetos
CREATE TABLE projeto (
    id_projeto INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    tempo_estimado_horas INT,
    orcamento DECIMAL(10, 2),
    status VARCHAR(50) DEFAULT 'EM_PLANEJAMENTO',
    data_inicio DATE,
    data_fim DATE,
    id_responsavel INT NOT NULL,
    FOREIGN KEY (id_responsavel) REFERENCES usuario(id_usuario)
);

-- Grupos de projeto
CREATE TABLE grupo_projeto (
    id_grupo INT PRIMARY KEY AUTO_INCREMENT,
    nome_grupo VARCHAR(255),
    id_projeto INT NOT NULL,
    UNIQUE (nome_grupo, id_projeto),
    FOREIGN KEY (id_projeto) REFERENCES projeto(id_projeto)
);

-- Associação de usuários a grupos (com papel opcional)
CREATE TABLE usuario_grupo_projeto (
    id_usuario INT,
    id_grupo INT,
    papel VARCHAR(100),
    PRIMARY KEY (id_usuario, id_grupo),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_grupo) REFERENCES grupo_projeto(id_grupo)
);

-- Equipe de projetos (novo tipo de usuário)
CREATE TABLE equipe_projetos (
    id_equipe INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL CHECK (CHAR_LENGTH(senha) >= 8)
);

-- Aprovação de projetos pela equipe de projetos
CREATE TABLE projeto_aprovacao (
    id_projeto INT NOT NULL,
    id_equipe INT NOT NULL,
    data_aprovacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    status_aprovacao VARCHAR(50) DEFAULT 'PENDENTE', -- PENDENTE, ACEITO, REJEITADO
    razao_aprovacao TEXT,
    PRIMARY KEY (id_projeto, id_equipe),
    FOREIGN KEY (id_projeto) REFERENCES projeto(id_projeto),
    FOREIGN KEY (id_equipe) REFERENCES equipe_projetos(id_equipe)
);

-- Tabela de Auditoria
CREATE TABLE auditoria_log (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    tabela VARCHAR(100) NOT NULL,       -- Nome da tabela afetada
    id_registro INT NOT NULL,           -- ID do registro alterado
    acao VARCHAR(20) NOT NULL,          -- CREATE, UPDATE, DELETE (soft)
    usuario_responsavel INT NOT NULL,   -- id_usuario que fez a ação
    data_acao DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_responsavel) REFERENCES usuario(id_usuario)
);

-- Tabela de Certificações
CREATE TABLE certificacao (
    id_certificacao INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,         -- Nome da certificação
    emissor VARCHAR(255) NOT NULL,      -- Ex: AWS, Microsoft, Alura
    descricao TEXT,
    validade_meses INT,                 -- NULL se não expira
    url_referencia VARCHAR(500)
);

-- Relação Usuário ↔ Certificação
CREATE TABLE usuario_certificacao (
    id_usuario INT NOT NULL,
    id_certificacao INT NOT NULL,
    data_obtencao DATE NOT NULL,
    data_validade DATE,
    credencial_codigo VARCHAR(255),     -- Código único emitido
    PRIMARY KEY (id_usuario, id_certificacao),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_certificacao) REFERENCES certificacao(id_certificacao)
);

-- Permissões iniciais
INSERT INTO nivel_permissao (nome_permissao) VALUES
('FUNCIONARIO'),
('GERENTE'),
('ADMIN');
