--7. Efetue a criação das seguintes triggers utilizando PL/MySQL:
--a. Criar um trigger chamado "AntesDeInserirHospedagem" que é acionado antes de uma inserção na tabela "Hospedagem". O trigger deve verificar se o quarto está disponível na data de check-in. Se não estiver, a inserção deve ser cancelada.
CREATE OR REPLACE FUNCTION VerificarDisponibilidade()
RETURNS TRIGGER LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Hospedagem hs
        WHERE hs.quarto_id = NEW.quarto_id
        AND NEW.dt_checkin BETWEEN hs.dt_checkin AND hs.dt_checkout
    ) THEN
        RAISE EXCEPTION 'Quarto não disponível na data de check-in';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER AntesDeInserirHospedagem
BEFORE INSERT ON Hospedagem
FOR EACH ROW
EXECUTE FUNCTION VerificarDisponibilidade();

--b.Cria um trigger chamado "AposDeletarCliente" que é acionado após a exclusão de um cliente na tabela "Cliente". O trigger deve registrar a exclusão em uma tabela de log.​
CREATE TABLE LogExclusaoCliente (
    log_id SERIAL PRIMARY KEY,
    cliente_id INT,
    nome VARCHAR(255),
    email VARCHAR(255),
    telefone VARCHAR(20),
    cpf VARCHAR(11),
    data_exclusao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION RegistrarExclusaoCliente()
RETURNS TRIGGER LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO LogExclusaoCliente (cliente_id, nome, email, telefone, cpf)
    VALUES (OLD.cliente_id, OLD.nome, OLD.email, OLD.telefone, OLD.cpf);
    RETURN OLD;
END;
$$;

CREATE TRIGGER AposDeletarCliente
AFTER DELETE ON Cliente
FOR EACH ROW
EXECUTE FUNCTION RegistrarExclusaoCliente();
