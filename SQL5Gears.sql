
-- BANCO DE DADOS: FiveGears 

-- DROP DATABASE IF EXISTS FiveGears;
CREATE DATABASE IF NOT EXISTS FiveGears;
USE FiveGears;

-- EMPRESA / CLIENTE / ENDEREÇO

CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    fundador VARCHAR(255),
    cnpj VARCHAR(64) UNIQUE NOT NULL -- hash
);

CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(64) UNIQUE NOT NULL, -- hash
    email_responsavel VARCHAR(255) -- texto normal
);

CREATE TABLE endereco (
    id_endereco INT PRIMARY KEY AUTO_INCREMENT,
    rua VARCHAR(255) NOT NULL,
    numero VARCHAR(10),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(20),
    telefone VARCHAR(20), -- texto normal
    id_empresa INT,
    id_cliente INT,
    FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa) ON DELETE CASCADE,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE CASCADE
);

-- PERMISSÕES / STATUS

CREATE TABLE nivel_permissao (
    id_nivel INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT
);

INSERT INTO nivel_permissao (nome, descricao) VALUES
('FUNCIONARIO', 'Acesso padrão de funcionário'),
('GERENTE', 'Acesso de gerente com permissões adicionais'),
('PROJETOS', 'Acesso da equipe de projetos'),
('ADMIN', 'Acesso total ao sistema');

CREATE TABLE status_usuario (
    id_status INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT
);

INSERT INTO status_usuario (nome, descricao) VALUES
('ONLINE', 'Usuário está logado no sistema'),
('OFFLINE', 'Usuário não está logado no sistema');

-- USUÁRIO / LOGIN / SESSÃO

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    cpf VARCHAR(64) UNIQUE, 
    telefone VARCHAR(20),
    area VARCHAR(50),
    carga_horaria INT DEFAULT 0,
    valor_hora DECIMAL(10,2) DEFAULT 0,
    id_empresa INT,
    id_nivel INT,
    FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa) ON DELETE CASCADE,
    FOREIGN KEY (id_nivel) REFERENCES nivel_permissao(id_nivel)
);

CREATE TABLE login (
    id_login INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    senha VARCHAR(255) NOT NULL CHECK (CHAR_LENGTH(senha) >= 8), -- hash
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

CREATE TABLE sessao (
    id_sessao INT PRIMARY KEY AUTO_INCREMENT,
    id_login INT NOT NULL,
    id_status INT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    inicio_sessao DATETIME DEFAULT CURRENT_TIMESTAMP,
    fim_sessao DATETIME DEFAULT NULL,
    FOREIGN KEY (id_login) REFERENCES login(id_login) ON DELETE CASCADE,
    FOREIGN KEY (id_status) REFERENCES status_usuario(id_status)
);

-- CHAMADOS (PIPEFY)

CREATE TABLE chamado_pipefy (
    id_chamado INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT,
    titulo VARCHAR(255),
    descricao TEXT,
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'ABERTO',
    id_pipefy_card VARCHAR(100),
    tipo_chamado VARCHAR(100),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- CATALOGO ESCO/INTERNO 

CREATE TABLE cargo (
    id_cargo INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL UNIQUE,
    descricao TEXT,
    fonte ENUM('INTERNO', 'IMPORTADO') DEFAULT 'INTERNO'
);

CREATE TABLE usuario_cargo (
    id_usuario INT NOT NULL,
    id_cargo INT NOT NULL,
    senioridade ENUM('ESTAGIARIO','JUNIOR','PLENO','SENIOR') DEFAULT 'JUNIOR',
    data_inicio DATE DEFAULT (CURRENT_DATE),
    ultima_atualizacao DATE DEFAULT NULL,
    PRIMARY KEY (id_usuario, id_cargo),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_cargo) REFERENCES cargo(id_cargo)
);

CREATE TABLE competencia (
    id_competencia INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL UNIQUE,
    descricao TEXT,
    tipo VARCHAR(100),
    categoria VARCHAR(100)
);

CREATE TABLE usuario_competencia (
    id_usuario INT NOT NULL,
    id_competencia INT NOT NULL,
    ultima_utilizacao DATE,
    PRIMARY KEY (id_usuario, id_competencia),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_competencia) REFERENCES competencia(id_competencia)
);

CREATE TABLE cargo_competencia (
    id_cargo INT NOT NULL,
    id_competencia INT NOT NULL,
    peso INT DEFAULT 1,
    tipo_relacao ENUM('RECOMENDADA','REQUERIDA') DEFAULT 'REQUERIDA',
    PRIMARY KEY (id_cargo, id_competencia),
    FOREIGN KEY (id_cargo) REFERENCES cargo(id_cargo),
    FOREIGN KEY (id_competencia) REFERENCES competencia(id_competencia)
);

-- SOFT SKILLS / FEEDBACKS

CREATE TABLE soft_skill (
    id_soft_skill INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT
);

INSERT INTO soft_skill (nome, descricao) VALUES
('Comunicação', 'Capacidade de transmitir ideias de forma clara e eficaz.'),
('Trabalho em equipe', 'Colabora bem com colegas e apoia o grupo.'),
('Liderança', 'Motiva e orienta outras pessoas para alcançar objetivos.'),
('Adaptabilidade', 'Se ajusta rapidamente a mudanças e novos desafios.'),
('Criatividade', 'Apresenta soluções inovadoras e originais para problemas.'),
('Pensamento crítico', 'Analisa situações com lógica e faz julgamentos sólidos.'),
('Gestão de tempo', 'Organiza tarefas e prioridades de forma eficiente.'),
('Empatia', 'Entende e respeita as emoções e perspectivas dos outros.'),
('Proatividade', 'Toma iniciativa sem depender de instruções diretas.'),
('Resiliência', 'Mantém a performance mesmo sob pressão ou adversidades.');

CREATE TABLE usuario_soft_skill (
    id_usuario INT NOT NULL,
    id_soft_skill INT NOT NULL,
    nivel ENUM('HORRIVEL','BAIXO','MEDIO','ALTO','EXCELENTE'),
    ultima_avaliacao DATE,
    fonte_avaliacao ENUM('GERENTE') DEFAULT 'GERENTE',
    comentario TEXT,
    PRIMARY KEY (id_usuario, id_soft_skill),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_soft_skill) REFERENCES soft_skill(id_soft_skill)
);

CREATE TABLE feedback (
    id_feedback INT PRIMARY KEY AUTO_INCREMENT,
    id_avaliador INT NOT NULL,
    id_avaliado INT NOT NULL,
    tipo ENUM('TECNICO','COMPORTAMENTAL') DEFAULT 'COMPORTAMENTAL',
    comentario TEXT,
    nota INT CHECK (nota BETWEEN 0 AND 10),
    data_feedback DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_avaliador) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_avaliado) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

CREATE TABLE usuario_soft_skill_feedback (
    id_feedback INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_soft_skill INT NOT NULL,
    id_avaliador INT NOT NULL,
    nivel ENUM('HORRIVEL','BAIXO','MEDIO','ALTO','EXCELENTE') NOT NULL,
    comentario TEXT,
    data_avaliacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_soft_skill) REFERENCES soft_skill(id_soft_skill),
    FOREIGN KEY (id_avaliador) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- PROJETOS / ALOCAÇÕES

CREATE TABLE projeto (
    id_projeto INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    nome VARCHAR(255) NOT NULL UNIQUE, 
    descricao TEXT,
    tempo_estimado_horas INT,
    orcamento DECIMAL(15,2),
    status ENUM('EM_PLANEJAMENTO', 'EM_DESENVOLVIMENTO', 'NEGADO', 'CONCLUIDO', 'CANCELADO') DEFAULT 'EM_PLANEJAMENTO',
    data_inicio DATE,
    data_fim DATE,
    id_responsavel INT NOT NULL,
    competencias_requeridas TEXT,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE CASCADE,
    FOREIGN KEY (id_responsavel) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

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
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_cargo) REFERENCES cargo(id_cargo)
);

-- AUDITORIA

CREATE TABLE auditoria (
    id_auditoria INT PRIMARY KEY AUTO_INCREMENT,
    tabela_afetada VARCHAR(100) NOT NULL,
    id_registro INT NOT NULL,
    acao ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    valores_anteriores TEXT,
    valores_novos TEXT,
    usuario_responsavel INT,
    data_evento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_responsavel) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- TRIGGERS DE HASH

DELIMITER //

-- Usuario: CPF
CREATE TRIGGER usuario_before_insert
BEFORE INSERT ON usuario
FOR EACH ROW
BEGIN
    IF NEW.cpf IS NOT NULL THEN
        SET NEW.cpf = SHA2(NEW.cpf, 256);
    END IF;
END;
//

CREATE TRIGGER usuario_before_update
BEFORE UPDATE ON usuario
FOR EACH ROW
BEGIN
    IF NEW.cpf IS NOT NULL AND OLD.cpf <> NEW.cpf THEN
        SET NEW.cpf = SHA2(NEW.cpf, 256);
    END IF;
END;
//

-- Login: Senha
CREATE TRIGGER login_before_insert
BEFORE INSERT ON login
FOR EACH ROW
BEGIN
    IF NEW.senha IS NOT NULL THEN
        SET NEW.senha = SHA2(NEW.senha, 256);
    END IF;
END;
//

CREATE TRIGGER login_before_update
BEFORE UPDATE ON login
FOR EACH ROW
BEGIN
    IF NEW.senha IS NOT NULL AND OLD.senha <> NEW.senha THEN
        SET NEW.senha = SHA2(NEW.senha, 256);
    END IF;
END;
//

-- Cliente: CNPJ
CREATE TRIGGER cliente_before_insert
BEFORE INSERT ON cliente
FOR EACH ROW
BEGIN
    IF NEW.cnpj IS NOT NULL THEN
        SET NEW.cnpj = SHA2(NEW.cnpj, 256);
    END IF;
END;
//

CREATE TRIGGER cliente_before_update
BEFORE UPDATE ON cliente
FOR EACH ROW
BEGIN
    IF NEW.cnpj IS NOT NULL AND OLD.cnpj <> NEW.cnpj THEN
        SET NEW.cnpj = SHA2(NEW.cnpj, 256);
    END IF;
END;
//

DELIMITER ;
