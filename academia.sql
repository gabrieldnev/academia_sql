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
