-- ==========================================
-- LIMPEZA E INSERÇÃO COMPLETA (FiveGears)
-- ==========================================

-- ==========================================
-- 1️⃣ LIMPEZA DE REGISTROS ANTIGOS / DUPLICADOS
-- ==========================================

-- Apagar sessões antigas do admin
DELETE FROM sessao
WHERE id_login IN (
    SELECT id_login
    FROM login
    WHERE id_usuario IN (
        SELECT id_usuario FROM usuario WHERE email = 'admin@fivegears.com'
    )
);

-- Apagar logins duplicados do admin (mantém apenas o menor id_login)
DELETE FROM login
WHERE id_usuario IN (
    SELECT id_usuario FROM usuario WHERE email = 'admin@fivegears.com'
)
AND id_login NOT IN (
    SELECT MIN(id_login)
    FROM (
        SELECT id_login
        FROM login
        WHERE id_usuario IN (
            SELECT id_usuario FROM usuario WHERE email = 'admin@fivegears.com'
        )
    ) AS keep_one
);

-- Garantir que o admin tenha apenas 1 usuário com aquele e-mail
DELETE FROM usuario
WHERE email = 'admin@fivegears.com'
AND id_usuario NOT IN (
    SELECT MIN(id_usuario)
    FROM (
        SELECT id_usuario
        FROM usuario
        WHERE email = 'admin@fivegears.com'
    ) AS keep_one
);

-- ==========================================
-- 2️⃣ INSERÇÃO SEGURA DE ADMINISTRADOR (FiveGears)
-- ==========================================

-- Criar empresa FiveGears se ainda não existir
INSERT INTO empresa (nome, fundador, cnpj)
VALUES ('FiveGears', 'Equipe FiveGears', SHA2('00000000000100', 256))
ON DUPLICATE KEY UPDATE nome = VALUES(nome);

-- Buscar IDs necessários
SET @id_empresa := (SELECT id_empresa FROM empresa WHERE nome = 'FiveGears');
SET @id_admin := (SELECT id_nivel FROM nivel_permissao WHERE nome = 'ADMIN');
SET @id_status_offline := (SELECT id_status FROM status_usuario WHERE nome = 'OFFLINE');

-- Criar usuário admin se ainda não existir
INSERT INTO usuario (nome, email, cpf, telefone, area, carga_horaria, valor_hora, id_empresa, id_nivel)
VALUES (
    'Administrador FiveGears',
    'admin@fivegears.com',
    SHA2('00000000000', 256),
    '(11) 90000-0000',
    'Administração',
    40,
    100.00,
    @id_empresa,
    @id_admin
)
ON DUPLICATE KEY UPDATE
    nome = VALUES(nome),
    area = VALUES(area),
    valor_hora = VALUES(valor_hora),
    id_empresa = VALUES(id_empresa),
    id_nivel = VALUES(id_nivel);

-- Vincular login do admin (sem duplicar)
SET @id_usuario_admin := (SELECT id_usuario FROM usuario WHERE email = 'admin@fivegears.com');

INSERT INTO login (id_usuario, senha, primeiro_acesso)
VALUES (@id_usuario_admin, 'admin1234', TRUE)
ON DUPLICATE KEY UPDATE
    senha = VALUES(senha),
    primeiro_acesso = VALUES(primeiro_acesso);

-- ==========================================
-- 3️⃣ DEMAIS MOCKS DE TESTE (CARGO, COMPETÊNCIAS, FUNCIONÁRIOS, PROJETO)
-- ==========================================

-- EMPRESA COMPLEMENTAR
INSERT IGNORE INTO empresa (id_empresa, nome, fundador, cnpj)
VALUES (NULL, 'FiveGears Tecnologia', 'Equipe FiveGears', SHA2('00000000000200', 256));

SELECT id_empresa INTO @id_empresa_fivegears FROM empresa WHERE nome = 'FiveGears Tecnologia';

-- CLIENTE INTERNO
INSERT IGNORE INTO cliente (id_cliente, nome, cnpj, email_responsavel)
VALUES (NULL, 'FiveGears Interno', SHA2('00000000000999', 256), 'interno@fivegears.com');

SELECT id_cliente INTO @id_cliente_interno FROM cliente WHERE nome = 'FiveGears Interno';

-- CARGO
INSERT IGNORE INTO cargo (id_cargo, nome, descricao, fonte)
VALUES (NULL, 'Programador', 'Responsável pelo desenvolvimento e manutenção de software.', 'INTERNO');

SELECT id_cargo INTO @id_cargo_programador FROM cargo WHERE nome = 'Programador';

-- COMPETÊNCIAS TÉCNICAS
INSERT INTO competencia (nome, descricao, tipo, categoria)
VALUES
('Java', 'Linguagem de programação voltada a aplicações robustas.', 'Técnica', 'Backend'),
('Kotlin', 'Linguagem moderna para backend e Android.', 'Técnica', 'Backend'),
('Spring Boot', 'Framework Java/Kotlin para APIs REST.', 'Técnica', 'Framework'),
('MySQL', 'Banco de dados relacional popular.', 'Técnica', 'Banco de Dados'),
('Docker', 'Containerização de aplicações.', 'Técnica', 'DevOps')
AS new
ON DUPLICATE KEY UPDATE
descricao = new.descricao,
tipo = new.tipo,
categoria = new.categoria;

-- VINCULAR COMPETÊNCIAS AO CARGO
INSERT IGNORE INTO cargo_competencia (id_cargo, id_competencia, peso, tipo_relacao)
SELECT @id_cargo_programador, id_competencia, 3, 'REQUERIDA' FROM competencia;

-- USUÁRIOS (FUNCIONÁRIOS)
SELECT id_nivel INTO @id_funcionario FROM nivel_permissao WHERE nome = 'FUNCIONARIO';

INSERT IGNORE INTO usuario (nome, email, cpf, telefone, area, carga_horaria, valor_hora, id_empresa, id_nivel)
VALUES
('Alice Silva', 'alice@fivegears.com', SHA2('11111111111', 256), '(11) 91111-1111', 'Desenvolvimento', 40, 75.00, @id_empresa_fivegears, @id_funcionario),
('Bruno Costa', 'bruno@fivegears.com', SHA2('22222222222', 256), '(11) 92222-2222', 'Desenvolvimento', 40, 80.00, @id_empresa_fivegears, @id_funcionario),
('Carla Souza', 'carla@fivegears.com', SHA2('33333333333', 256), '(11) 93333-3333', 'Desenvolvimento', 40, 70.00, @id_empresa_fivegears, @id_funcionario);

SELECT id_usuario INTO @id_alice FROM usuario WHERE email = 'alice@fivegears.com';
SELECT id_usuario INTO @id_bruno FROM usuario WHERE email = 'bruno@fivegears.com';
SELECT id_usuario INTO @id_carla FROM usuario WHERE email = 'carla@fivegears.com';

-- USUÁRIOS → CARGO
INSERT IGNORE INTO usuario_cargo (id_usuario, id_cargo, senioridade)
VALUES 
(@id_alice, @id_cargo_programador, 'PLENO'),
(@id_bruno, @id_cargo_programador, 'SENIOR'),
(@id_carla, @id_cargo_programador, 'JUNIOR');

-- USUÁRIOS → COMPETÊNCIAS
INSERT IGNORE INTO usuario_competencia (id_usuario, id_competencia, ultima_utilizacao)
SELECT @id_alice, id_competencia, '2025-01-05' FROM competencia;

INSERT IGNORE INTO usuario_competencia (id_usuario, id_competencia, ultima_utilizacao)
SELECT @id_bruno, id_competencia, '2025-01-08' FROM competencia;

INSERT IGNORE INTO usuario_competencia (id_usuario, id_competencia, ultima_utilizacao)
SELECT @id_carla, id_competencia, '2024-12-15' FROM competencia;

-- PROJETO (EM DESENVOLVIMENTO)
SELECT id_usuario INTO @id_responsavel_admin FROM usuario WHERE email = 'admin@fivegears.com';

INSERT INTO projeto (
    id_cliente, nome, descricao, tempo_estimado_horas, orcamento, status,
    data_inicio, data_fim, id_responsavel, competencias_requeridas
)
VALUES (
    @id_cliente_interno,
    'Projeto Apollo',
    'Sistema interno de gestão automatizada com APIs e dashboard em tempo real.',
    400,
    50000.00,
    'EM_DESENVOLVIMENTO',
    '2025-01-10',
    '2025-06-10',
    @id_responsavel_admin,
    'Kotlin, Spring Boot, MySQL, Docker'
)
AS new
ON DUPLICATE KEY UPDATE
descricao = new.descricao,
status = new.status,
orcamento = new.orcamento,
tempo_estimado_horas = new.tempo_estimado_horas;

SELECT id_projeto INTO @id_projeto_apollo FROM projeto WHERE nome = 'Projeto Apollo';

-- ==========================================
-- ✅ VERIFICAÇÕES FINAIS
-- ==========================================
SELECT 'USUÁRIO ADMIN' AS secao;
SELECT id_usuario, nome, email FROM usuario WHERE email = 'admin@fivegears.com';

SELECT 'LOGIN ADMIN' AS secao;
SELECT * FROM login WHERE id_usuario = @id_usuario_admin;

SELECT 'FUNCIONÁRIOS' AS secao;
SELECT nome, email FROM usuario WHERE email LIKE '%@fivegears.com%' AND email <> 'admin@fivegears.com';

SELECT 'PROJETO APOLLO' AS secao;
SELECT * FROM projeto WHERE nome = 'Projeto Apollo';

select * from usuario_projeto where id_projeto = 1;

select * from usuario;
