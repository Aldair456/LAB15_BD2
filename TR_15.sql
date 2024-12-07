DROP SCHEMA lab15_2 CASCADE;


CREATE SCHEMA IF NOT EXISTS lab15_2;

SET search_path TO lab15_2;


-- Crear tabla Médico como tabla particionada
drop table Medico cascade;
CREATE TABLE Medico (
    DNI VARCHAR(20),
    Nombre VARCHAR(50),
    Apellidos VARCHAR(50),
    Especialidad VARCHAR(50),
    NumColegiado VARCHAR(20),
    CentroSalud VARCHAR(50),
    Ciudad VARCHAR(50),
    PRIMARY KEY (DNI, Ciudad) -- Incluir Ciudad en la clave primaria
) PARTITION BY HASH (Ciudad);
select count(*) from  Medico;
-- Crear particiones basadas en el hash de Ciudad
CREATE TABLE Medico_Hash_0 PARTITION OF Medico FOR VALUES WITH (MODULUS 3, REMAINDER 0);
CREATE TABLE Medico_Hash_1 PARTITION OF Medico FOR VALUES WITH (MODULUS 3, REMAINDER 1);
CREATE TABLE Medico_Hash_2 PARTITION OF Medico FOR VALUES WITH (MODULUS 3, REMAINDER 2);




-- Crear tabla Diagnóstico como tabla particionada
-- Crear tabla Diagnóstico como tabla particionada
drop table Diagnostico;
CREATE TABLE Diagnostico (
    Id SERIAL,
    DNI_Paciente VARCHAR(20),
    DNI_Medico VARCHAR(20),
    Ciudad VARCHAR(50),
    Diagnostico TEXT,
    Peso DECIMAL(5,2),
    Edad INT,
    Sexo CHAR(1),
    PRIMARY KEY (Id, Ciudad), -- Clave primaria incluye Ciudad
    FOREIGN KEY (DNI_Medico, Ciudad) REFERENCES Medico (DNI, Ciudad)
) PARTITION BY HASH (Ciudad);

select count(*) from  Diagnostico;



CREATE TABLE Diagnostico_Hash_0 PARTITION OF Diagnostico FOR VALUES WITH (MODULUS 3, REMAINDER 0);
CREATE TABLE Diagnostico_Hash_1 PARTITION OF Diagnostico FOR VALUES WITH (MODULUS 3, REMAINDER 1);
CREATE TABLE Diagnostico_Hash_2 PARTITION OF Diagnostico FOR VALUES WITH (MODULUS 3, REMAINDER 2);

-- Insertar datos en la tabla Medico

DO $$
DECLARE
    ciudades TEXT[] := ARRAY['Lima', 'Cusco', 'Arequipa', 'Trujillo', 'Tacna', 'Iquitos']; -- Ciudades adicionales para mejor distribución
    ciudad_seleccionada TEXT;
BEGIN
    FOR i IN 1..1000000 LOOP
        -- Seleccionar ciudad para garantizar residuos variados
        ciudad_seleccionada := ciudades[(i % array_length(ciudades, 1)) + 1];

        INSERT INTO Medico (DNI, Nombre, Apellidos, Especialidad, NumColegiado, CentroSalud, Ciudad)
        VALUES (
            CONCAT('DNI', LPAD(i::TEXT, 7, '0')), -- DNI incremental
            CONCAT('Nombre', i), -- Nombre dinámico
            CONCAT('Apellido', i), -- Apellido dinámico
            CASE (i % 5) + 1 -- Asignar especialidades ciclando entre 5 opciones
                WHEN 1 THEN 'Pediatría'
                WHEN 2 THEN 'Cardiología'
                WHEN 3 THEN 'Dermatología'
                WHEN 4 THEN 'Neurología'
                WHEN 5 THEN 'General'
            END,
            CONCAT('C', LPAD(i::TEXT, 4, '0')), -- Número de colegiado incremental
            CONCAT('Salud', i % 10), -- Nombre de centro ciclando entre 10 opciones
            ciudad_seleccionada -- Ciudad seleccionada dinámicamente
        );
    END LOOP;
END $$;



INSERT INTO Medico (DNI, Nombre, Apellidos, Especialidad, NumColegiado, CentroSalud, Ciudad)
VALUES
('DNI001', 'Ana', 'Pérez', 'Pediatría', 'C001', 'SaludCentral', 'Lima'),
('DNI002', 'Luis', 'Martínez', 'Cardiología', 'C002', 'SaludNorte', 'Cusco'),
('DNI003', 'María', 'Lopez', 'Dermatología', 'C003', 'SaludSur', 'Arequipa'),
('DNI004', 'Carlos', 'Gomez', 'Neurología', 'C004', 'SaludOeste', 'Lima'),
('DNI005', 'Laura', 'Castro', 'Pediatría', 'C005', 'SaludEste', 'Trujillo');
('DNI006', 'Pedro', 'Ramírez', 'General', 'C006', 'SaludOeste', 'CiudadX');

INSERT INTO Medico (DNI, Nombre, Apellidos, Especialidad, NumColegiado, CentroSalud, Ciudad)
VALUES
('DNI006', 'Pedro', 'Ramírez', 'General', 'C006', 'SaludOeste', 'CiudadX');

-- Verificar contenido en cada partición
SELECT * FROM Medico_Hash_0;
SELECT * FROM Medico_Hash_1;
SELECT * FROM Medico_Hash_2;


-- Insertar datos en la tabla Diagnostico
INSERT INTO Diagnostico (DNI_Paciente, DNI_Medico, Ciudad, Diagnostico, Peso, Edad, Sexo)
VALUES
('P001', 'DNI001', 'Lima', 'Gripe', 70.5, 30, 'F'),
('P002', 'DNI002', 'Cusco', 'Hipertensión', 85.0, 45, 'M'),
('P003', 'DNI003', 'Arequipa', 'Dermatitis', 60.2, 22, 'F'),
('P004', 'DNI001', 'Lima', 'Asma', 68.3, 35, 'M'),
('P005', 'DNI002', 'Cusco', 'Diabetes', 90.4, 50, 'M'),
('P006', 'DNI003', 'Arequipa', 'Alergia', 55.6, 28, 'F');


---


DO $$
DECLARE
    ciudades TEXT[] := ARRAY['Lima', 'Cusco', 'Arequipa', 'Trujillo', 'Tacna', 'Iquitos']; -- Diversidad de ciudades
    diagnosticos TEXT[] := ARRAY['Gripe', 'Hipertensión', 'Alergia', 'Asma', 'Diabetes', 'Dermatitis']; -- Tipos de diagnósticos
    sexo CHAR[] := ARRAY['M', 'F']; -- Sexo de los pacientes
    ciudad_seleccionada TEXT;
    diagnostico_seleccionado TEXT;
    sexo_seleccionado CHAR;
BEGIN
    FOR i IN 1..1000000 LOOP
        -- Seleccionar ciudad, diagnóstico y sexo dinámicamente
        ciudad_seleccionada := ciudades[(i % array_length(ciudades, 1)) + 1];
        diagnostico_seleccionado := diagnosticos[(i % array_length(diagnosticos, 1)) + 1];
        sexo_seleccionado := sexo[(i % array_length(sexo, 1)) + 1];

        -- Insertar el registro
        INSERT INTO Diagnostico (DNI_Paciente, DNI_Medico, Ciudad, Diagnostico, Peso, Edad, Sexo)
        VALUES (
            CONCAT('P', LPAD(i::TEXT, 5, '0')), -- DNI_Paciente incremental
            CONCAT('DNI', LPAD((i % 5 + 1)::TEXT, 4, '0')), -- DNI_Medico ciclado entre 5 valores
            ciudad_seleccionada, -- Ciudad seleccionada dinámicamente
            diagnostico_seleccionado, -- Diagnóstico seleccionado dinámicamente
            50.0 + (i % 50) + RANDOM() * 10, -- Peso variado entre 50.0 y 110.0
            20 + (i % 60), -- Edad variada entre 20 y 80
            sexo_seleccionado -- Sexo seleccionado dinámicamente
        );
    END LOOP;
END $$;
---
Select count(*) from Diagnostico

-- Verificar contenido en las particiones
SELECT * FROM Diagnostico_Hash_0;
SELECT * FROM Diagnostico_Hash_1;
SELECT * FROM Diagnostico_Hash_2;
------------------------------------------------------------
-- Consulta a) SELECT * FROM Diagnostico ORDER BY Ciudad


BEGIN;

-- Crear tabla temporal para recopilar datos
CREATE TEMPORARY TABLE Temp_Diagnostico AS
SELECT * FROM Diagnostico_Hash_0
UNION ALL
SELECT * FROM Diagnostico_Hash_1
UNION ALL
SELECT * FROM Diagnostico_Hash_2;

-- Ordenar los datos
EXPLAIN ANALYZE
SELECT * FROM Temp_Diagnostico ORDER BY Ciudad;

-- Limpiar tabla temporal
DROP TABLE Temp_Diagnostico;

COMMIT;
---00000-------------


--Consulta b) SELECT DISTINCT DNI_Paciente FROM Diagnostico
BEGIN;
-- Crear tabla temporal para recopilar datos
CREATE TEMPORARY TABLE Temp_DNI_Paciente AS
SELECT DNI_Paciente FROM Diagnostico_Hash_0
UNION
SELECT DNI_Paciente FROM Diagnostico_Hash_1
UNION
SELECT DNI_Paciente FROM Diagnostico_Hash_2;

-- Obtener valores distintos
EXPLAIN ANALYZE
SELECT DISTINCT DNI_Paciente FROM Temp_DNI_Paciente;

-- Limpiar tabla temporal
DROP TABLE Temp_DNI_Paciente;

COMMIT;



--  c)
BEGIN;

-- Crear tabla temporal para recopilar datos agrupados
CREATE TEMPORARY TABLE Temp_Edad_Count AS
SELECT Edad, COUNT(*) AS Total
FROM Diagnostico_Hash_0
GROUP BY Edad
UNION ALL
SELECT Edad, COUNT(*) AS Total
FROM Diagnostico_Hash_1
GROUP BY Edad
UNION ALL
SELECT Edad, COUNT(*) AS Total
FROM Diagnostico_Hash_2
GROUP BY Edad;

-- Consolidar los resultados finales
EXPLAIN ANALYZE

SELECT Edad, SUM(Total) AS Count
FROM Temp_Edad_Count
GROUP BY Edad;

-- Limpiar tabla temporal
DROP TABLE Temp_Edad_Count;
COMMIT;
--- Consulta d) SELECT Especialidad, COUNT(*) FROM Medico M JOIN Diagnostico D ON M.DNI = D.DNI_Medico

BEGIN;

-- Crear tabla temporal para recopilar datos de cada fragmento
CREATE TEMPORARY TABLE Temp_Especialidad_Count AS
SELECT M.Especialidad, COUNT(*) AS Total
FROM Medico_Hash_0 M JOIN Diagnostico_Hash_0 D ON M.DNI = D.DNI_Medico
GROUP BY M.Especialidad
UNION ALL
SELECT M.Especialidad, COUNT(*) AS Total
FROM Medico_Hash_1 M JOIN Diagnostico_Hash_1 D ON M.DNI = D.DNI_Medico
GROUP BY M.Especialidad
UNION ALL
SELECT M.Especialidad, COUNT(*) AS Total
FROM Medico_Hash_2 M JOIN Diagnostico_Hash_2 D ON M.DNI = D.DNI_Medico
GROUP BY M.Especialidad;

-- Consolidar los resultados finales
EXPLAIN ANALYZE

SELECT Especialidad, SUM(Total) AS Count
FROM Temp_Especialidad_Count
GROUP BY Especialidad;
-- Limpiar tabla temporal
DROP TABLE Temp_Especialidad_Count;
COMMIT;




