-- tabelas
CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    cpf CHAR(11) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE planos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE,
    valor_mensal_base NUMERIC(10,2) NOT NULL CHECK (valor_mensal_base > 0)
);

CREATE TABLE modalidades (
    id SERIAL PRIMARY KEY,
    plano_id INTEGER REFERENCES planos(id),
    nome VARCHAR(80) NOT NULL,
    sala VARCHAR(50) NOT NULL,
    capacidade_maxima INTEGER NOT NULL CHECK (capacidade_maxima > 0),
    disponivel BOOLEAN DEFAULT TRUE
);

CREATE TABLE matriculas (
    id SERIAL PRIMARY KEY,
    aluno_id INTEGER REFERENCES alunos(id),
    data_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(10) DEFAULT 'Ativa' CHECK (status IN ('Ativa','Cancelada','Trancada'))
);

CREATE TABLE itens_matricula (
    id SERIAL PRIMARY KEY,
    matricula_id INTEGER REFERENCES matriculas(id),
    modalidade_id INTEGER REFERENCES modalidades(id),
    duracao_meses INTEGER NOT NULL CHECK (duracao_meses > 0),
    valor_mensal_aplicado NUMERIC(10,2) NOT NULL CHECK (valor_mensal_aplicado > 0),
    taxa_adesao NUMERIC(10,2) DEFAULT 0.00 CHECK (taxa_adesao >= 0)
);

-- dados

INSERT INTO planos (nome, valor_mensal_base) VALUES
    ('VIP Premium', 199.90),
    ('Fitness Standard', 129.90),
    ('Basic Fit', 79.90);

INSERT INTO modalidades (plano_id, nome, sala, capacidade_maxima) VALUES
    (1, 'Crossfit Pro', 'Arena 01', 20),
    (2, 'Pilates Avançado', 'Studio 02', 12),
    (3, 'Musculação Livre', 'Arena 03', 40);

INSERT INTO alunos (nome, email, cpf, telefone) VALUES
    ('Ana Souza', 'ana.souza@email.com', '12345678901', '48999111111'),
    ('Bruno Lima', 'bruno.lima@email.com', '23456789012', '48999222222'),
    ('Carla Mendes', 'carla.mendes@email.com', '34567890123', '48999333333');

INSERT INTO matriculas (aluno_id, status) VALUES
    (1, 'Ativa'),
    (1, 'Trancada'),
    (2, 'Ativa'),
    (3, 'Cancelada');

INSERT INTO itens_matricula (matricula_id, modalidade_id, duracao_meses, valor_mensal_aplicado, taxa_adesao) VALUES
    (1, 1, 12, 189.90, 50.00),
    (2, 3, 6, 79.90, 0.00),
    (3, 2, 12, 119.90, 30.00),
    (4, 1, 3, 199.90, 100.00);

-- Q1
CREATE OR REPLACE VIEW vw_modalidades_custo_estimado AS
SELECT
    m.nome AS modalidade,
    m.sala,
    p.nome AS plano,
    ROUND(p.valor_mensal_base * 1.10, 2) AS valor_mensal_ajustado
FROM modalidades m
JOIN planos p ON p.id = m.plano_id
ORDER BY valor_mensal_ajustado DESC;

-- Q2
CREATE OR REPLACE VIEW vw_matriculas_ativas AS
SELECT
    a.nome AS aluno,
    a.cpf,
    mo.nome AS modalidade,
    mo.sala,
    im.duracao_meses,
    mt.data_inicio
FROM matriculas mt
JOIN alunos a           ON a.id = mt.aluno_id
JOIN itens_matricula im ON im.matricula_id = mt.id
JOIN modalidades mo     ON mo.id = im.modalidade_id
WHERE mt.status = 'Ativa';

-- Q3    
CREATE OR REPLACE VIEW vw_alunos_vip AS
SELECT
    a.nome AS aluno,
    COUNT(DISTINCT mt.id) AS qtd_contratos_ativos,
    SUM(im.valor_mensal_aplicado * im.duracao_meses + im.taxa_adesao) AS valor_total_investido
FROM alunos a
JOIN matriculas mt      ON mt.aluno_id = a.id
JOIN itens_matricula im ON im.matricula_id = mt.id
WHERE mt.status = 'Ativa'
GROUP BY a.id, a.nome
HAVING SUM(im.valor_mensal_aplicado * im.duracao_meses + im.taxa_adesao) > 1000.00;

-- Q4
SELECT
    m.id,
    m.nome AS modalidade,
    m.sala,
    m.capacidade_maxima,
    p.nome AS plano,
    p.valor_mensal_base
FROM modalidades m
JOIN planos p ON p.id = m.plano_id
WHERE m.capacidade_maxima >= 15
  AND p.valor_mensal_base > 100.00
  AND m.disponivel = TRUE;

-- Q5
CREATE OR REPLACE VIEW vw_faturamento_medio_plano AS
SELECT
    p.nome AS plano,
    SUM(im.valor_mensal_aplicado * im.duracao_meses + im.taxa_adesao) AS faturamento_total,
    ROUND(AVG(im.duracao_meses), 2) AS media_duracao_meses
FROM planos p
JOIN modalidades m      ON m.plano_id = p.id
JOIN itens_matricula im ON im.modalidade_id = m.id
JOIN matriculas mt      ON mt.id = im.matricula_id
WHERE mt.status = 'Ativa'
GROUP BY p.id, p.nome;
