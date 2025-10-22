CREATE DATABASE VidaSanaDB;
Go

-- 1. Tabla: Medicos

-- Entidad que almacena información de los doctores.

-- PRIMARY KEY: id_medico.

CREATE TABLE Medicos (

id_medico INT PRIMARY KEY IDENTITY(1,1),  -- Identificador único del médico

nombre VARCHAR(100) NOT NULL,

apellido VARCHAR(100) NOT NULL,

especialidad VARCHAR(100), -- Especialidad médica

telefono VARCHAR(20),

email VARCHAR(100) UNIQUE -- Correo electrónico único

);

-- 2. Tabla: Pacientes

-- Entidad que almacena información de los pacientes.

-- PRIMARY KEY: id_paciente.

CREATE TABLE Pacientes (

id_paciente INT PRIMARY KEY IDENTITY(1,1),  -- Identificador único del paciente

nombre VARCHAR(100) NOT NULL,

apellido VARCHAR(100) NOT NULL,

fecha_nacimiento DATE,

direccion VARCHAR(255),

telefono VARCHAR(20)

);


-- 3. Tabla: Turnos

-- Entidad para registrar las citas agendadas.

-- PRIMARY KEY: id_turno.

-- FOREIGN KEYS: id_medico (referencia a Medicos), id_paciente (referencia a Pacientes).

CREATE TABLE Turnos (
    id_turno INT PRIMARY KEY IDENTITY(1,1),
    id_medico INT NOT NULL,
    id_paciente INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    motivo VARCHAR(255),
    estado VARCHAR(15) NOT NULL DEFAULT 'Pendiente', 
    
    -- Coloca la restricción CHECK aquí (solución del error anterior)
    CONSTRAINT CK_TurnoEstado CHECK (estado IN ('Pendiente', 'Confirmado', 'Realizado', 'Cancelado')),
    
    -- DEFINE LAS CLAVES FORÁNEAS AL FINAL, SEPARADAS POR COMA
    CONSTRAINT FK_Turnos_Medico FOREIGN KEY (id_medico) REFERENCES Medicos(id_medico),
    CONSTRAINT FK_Turnos_Paciente FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente)
);


-- Inserción de Médicos

INSERT INTO Medicos (nombre, apellido, especialidad, telefono, email) VALUES

('Carlos', 'Gómez', 'Cardiología', '555-1000', 'a.gomez@vidasana.com'),

('Luis', 'Pérez', 'Pediatría', '555-1001', 'l.perez@vidasana.com'),

('Carla', 'Díaz', 'Dermatología', '555-1002', 'c.diaz@vidasana.com');

-- Inserción de Pacientes

INSERT INTO Pacientes (nombre, apellido, fecha_nacimiento, direccion, telefono) VALUES

('Juana', 'Campos', '1985-05-20', 'Calle A #123', '555-2000'),

('María', 'Rojas', '2010-01-20', 'Avenida B #456', '555-2001'),

('Pedro', 'Castro', '1970-11-30', 'Ruta C #789', '555-2002'),

('Laura', 'Vargas', '1995-07-25', 'Calle D #101', '555-2003');


-- DECLARACIÓN Y ASIGNACIÓN DE VARIABLES EN T-SQL
DECLARE @fecha_actual NVARCHAR(20);
DECLARE @fecha_manana NVARCHAR(20);

-- Asigna la fecha actual formateada como YYYY-MM-DD
SET @fecha_actual = CONVERT(NVARCHAR(20), GETDATE(), 23); 
-- El estilo 23 da 'YYYY-MM-DD'.

-- Asigna la fecha de mañana. DATEADD es la función de T-SQL
SET @fecha_manana = CONVERT(NVARCHAR(20), DATEADD(day, 1, GETDATE()), 23); 

-- Inserción de Turnos
INSERT INTO Turnos (id_medico, id_paciente, fecha_hora, motivo, estado) VALUES
-- Citas para HOY
(1, 1, @fecha_actual + ' 09:00:00', 'Chequeo general', 'Pendiente'),
(1, 3, @fecha_actual + ' 10:30:00', 'Revisión cardiológica', 'Confirmado'),
(2, 2, @fecha_actual + ' 11:00:00', 'Control pediátrico', 'Realizado'),
(3, 4, @fecha_actual + ' 14:00:00', 'Consulta dermatológica', 'Pendiente'),
(1, 4, @fecha_actual + ' 16:00:00', 'Dolor de pecho', 'Confirmado'),
-- Cita para Mañana
(2, 3, @fecha_manana + ' 09:00:00', 'Vacunación', 'Pendiente'); 

SELECT
    T.id_turno,
    T.fecha_hora,
    M.nombre AS Medico,
    P.nombre AS Paciente,
    T.motivo,
    T.estado
FROM 
    Turnos T
-- Unimos Turnos con Medicos para obtener el nombre del médico asignado.
JOIN 
    Medicos M ON T.id_medico = M.id_medico
-- Unimos Turnos con Pacientes para obtener el nombre de la persona que toma el turno.
JOIN 
    Pacientes P ON T.id_paciente = P.id_paciente
WHERE 
    -- ----------------------------------------------------------------------
    -- **CAMBIO CRÍTICO para SQL Server (T-SQL)**: 
    -- ----------------------------------------------------------------------
    -- 1. CAST(T.fecha_hora AS DATE): Equivale a la función DATE() de MySQL. 
    --    Extrae solo la parte de la fecha (YYYY-MM-DD) de la columna DATETIME.
    CAST(T.fecha_hora AS DATE) = 
    
    -- 2. CAST(GETDATE() AS DATE): Equivale a la función CURDATE() de MySQL. 
    --    GETDATE() obtiene la fecha y hora actual, y CAST la convierte solo a la fecha.
    CAST(GETDATE() AS DATE) 
    -- ----------------------------------------------------------------------
ORDER BY 
    T.fecha_hora;



   --Usar JOIN para Listar Pacientes con su Médico Asignado

--Esta consulta muestra la relación directa de quién atiende a quién en los turnos.

SELECT

P.nombre AS Nombre_Paciente,

P.apellido AS Apellido_Paciente,

M.nombre AS Nombre_Medico,

M.apellido AS Apellido_Medico,

T.fecha_hora

FROM Turnos T

-- Usamos INNER JOIN para asegurarnos de que solo traemos turnos que tienen Médico y Paciente válidos

INNER JOIN Pacientes P ON T.id_paciente = P.id_paciente

INNER JOIN Medicos M ON T.id_medico = M.id_medico

ORDER BY P.apellido, T.fecha_hora;



SELECT TOP 1 WITH TIES
    M.nombre,
    M.apellido,
    COUNT(T.id_turno) AS Total_Citas -- Contamos las citas por médico
FROM 
    dbo.Turnos T
JOIN 
    dbo.Medicos M ON T.id_medico = M.id_medico
WHERE 
    -- Filtramos solo por las citas de HOY (equivalente a DATE(T.fecha_hora) = CURDATE())
    CAST(T.fecha_hora AS DATE) = CAST(GETDATE() AS DATE) 
GROUP BY 
    M.id_medico, M.nombre, M.apellido
ORDER BY 
    Total_Citas DESC;




    SELECT
    P.nombre,
    P.apellido,
    P.telefono
FROM 
    dbo.Pacientes P
-- Incluimos a TODOS los pacientes (LEFT JOIN) y buscamos coincidencias en Turnos (T)
LEFT JOIN 
    dbo.Turnos T ON P.id_paciente = T.id_paciente
WHERE 
    -- Filtramos donde NO hubo coincidencia, es decir, el paciente NO tiene turnos
    T.id_turno IS NULL
GROUP BY 
    P.id_paciente, P.nombre, P.apellido, P.telefono; 
    -- Agregamos todas las columnas no agregadas al GROUP BY (estándar T-SQL)



    SELECT
    AVG(SubConsulta.Total_Citas * 1.0) AS Promedio_Citas_Por_Medico
FROM (
    -- Subconsulta: Cuenta el total de citas por cada médico
    SELECT
        id_medico,
        COUNT(id_turno) AS Total_Citas
    FROM 
        dbo.Turnos
    GROUP BY 
        id_medico
) AS SubConsulta;
