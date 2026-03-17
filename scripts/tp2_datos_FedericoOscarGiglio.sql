-- Creacion de la base de datos --
CREATE DATABASE IF NOT EXISTS SistemaHospital;
USE SistemaHospital;

-- Tabla de las especialidades --
CREATE TABLE ESPECIALIDADES (
    id_espec INT AUTO_INCREMENT,
    esp_nombre VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_espec)
    );
    
    -- Tabla de obras sociales --
    CREATE TABLE OBRAS_SOCIALES (
    id_os INT AUTO_INCREMENT,
    os_nombre VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_os)
);

-- Tabla medicos (que depende de la tabla especialidades) --
CREATE TABLE MEDICOS (
    id_medico INT AUTO_INCREMENT,
    med_nombre VARCHAR(50) NOT NULL,
    med_apellido VARCHAR(50) NOT NULL,
    med_matri VARCHAR(20) NOT NULL UNIQUE, 
    id_espec INT, 
    PRIMARY KEY (id_medico),
    FOREIGN KEY (id_espec) REFERENCES ESPECIALIDADES(id_espec)
);

-- Tabla Pacientes (que depende de la table de obras sociales) --
CREATE TABLE PACIENTES (
    id_paciente INT AUTO_INCREMENT,
    pac_nombre VARCHAR(50) NOT NULL,
    pac_apellido VARCHAR(50) NOT NULL,
    pac_dni VARCHAR(15) NOT NULL UNIQUE, 
    pac_fecha_nac DATE NOT NULL,
    id_os INT, 
    PRIMARY KEY (id_paciente),
    FOREIGN KEY (id_os) REFERENCES OBRAS_SOCIALES(id_os)
);

-- 6. Tabla de los turnos (Conecta Pacientes y Médicos)
CREATE TABLE TURNOS (
    id_turno INT AUTO_INCREMENT,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado VARCHAR(20) DEFAULT 'Pendiente', 
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,  
    PRIMARY KEY (id_turno),
    FOREIGN KEY (id_paciente) REFERENCES PACIENTES(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES MEDICOS(id_medico)
);

-- 7. Tabla de las historias clinicas 
CREATE TABLE HISTORIAS_CLINICAS (
    id_historia INT AUTO_INCREMENT,
    fecha_consulta DATETIME DEFAULT CURRENT_TIMESTAMP,
    diagnostico TEXT,
    tratamiento TEXT,
    id_paciente INT NOT NULL, 
    id_medico INT NOT NULL,   
    PRIMARY KEY (id_historia),
    FOREIGN KEY (id_paciente) REFERENCES PACIENTES(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES MEDICOS(id_medico)
);

-- Estas son las prestadoras de salud
INSERT INTO OBRAS_SOCIALES (os_nombre) VALUES 
('OSDE'),
('Swiss Medical'),
('Galeno'),
('PAMI'),
('IOMA'),
('Medicus'),
('Omint'),
('Aca Salud'),
('Sancor Salud'),
('Particular'); -- Agregamos "Particular" para pacientes sin obra social

-- 2. Poblado de ESPECIALIDADES
-- El catálogo de áreas médicas de la clínica
INSERT INTO ESPECIALIDADES (esp_nombre) VALUES 
('Cardiología'),
('Pediatría'),
('Traumatología'),
('Dermatología'),
('Ginecología'),
('Neurología'),
('Oftalmología'),
('Clínica Médica'),
('Nutrición'),
('Kinesiología');

-- Poblado de la tabla MEDICOS
-- Nota: id_espec debe coincidir con los IDs de la tabla ESPECIALIDADES

INSERT INTO MEDICOS (med_nombre, med_apellido, med_matri, id_espec) VALUES 
('Juan', 'Pérez', 'MN12345', 1),    -- 1: Cardiología
('María', 'García', 'MN23456', 2),   -- 2: Pediatría
('Ricardo', 'López', 'MN34567', 3),  -- 3: Traumatología
('Elena', 'Fernández', 'MN45678', 4), -- 4: Dermatología
('Carlos', 'Sánchez', 'MN56789', 5),  -- 5: Ginecología
('Ana', 'Martínez', 'MN67890', 6),   -- 6: Neurología
('Jorge', 'Rodríguez', 'MN78901', 7), -- 7: Oftalmología
('Lucía', 'Gómez', 'MN89012', 8),    -- 8: Clínica Médica
('Roberto', 'Díaz', 'MN90123', 9),   -- 9: Nutrición
('Sofía', 'Álvarez', 'MN01234', 10); -- 10: Kinesiología

-- Poblado de la tabla PACIENTES

INSERT INTO PACIENTES (pac_nombre, pac_apellido, pac_dni, pac_fecha_nac, id_os) VALUES 
('Federico', 'Giglio', '35123456', '1990-05-15', 1),   -- 1: OSDE
('Laura', 'Mazzini', '38234567', '1985-08-22', 2),    -- 2: Swiss Medical
('Andrés', 'Castro', '40345678', '1998-01-10', 10),   -- 10: Particular
('Patricia', 'Sosa', '25456789', '1970-11-03', 3),    -- 3: Galeno
('Mariano', 'Closs', '30567890', '1975-03-20', 4),    -- 4: PAMI
('Jimena', 'Barón', '33678901', '1987-05-24', 5),     -- 5: IOMA
('Oscar', 'Ruggeri', '15789012', '1962-01-26', 6),    -- 6: Medicus
('Mónica', 'Ayos', '28890123', '1972-06-19', 7),      -- 7: Omint
('Diego', 'Torres', '22901234', '1971-03-09', 8),     -- 8: Aca Salud
('Natalia', 'Oreiro', '27012345', '1977-05-19', 9);   -- 9: Sancor Salud

-- Poblado de la tabla turnos

INSERT INTO turnos (fecha, hora, estado, id_paciente, id_medico) VALUES 
('2026-03-20', '09:00:00', 'Pendiente', 1, 1),
('2026-03-20', '10:30:00', 'Pendiente', 2, 2),
('2026-03-21', '11:00:00', 'Confirmado', 3, 8),
('2026-03-21', '15:00:00', 'Pendiente', 4, 4),
('2026-03-22', '08:30:00', 'Pendiente', 5, 10);

-- Poblado de la tabla historias_clinicas

INSERT INTO historias_clinicas (fecha_consulta, diagnostico, tratamiento, id_paciente, id_medico) VALUES 
('2026-01-10 10:00:00', 'Chequeo preventivo. Presión arterial normal.', 'Sin tratamiento indicado', 1, 1),
('2026-01-15 11:30:00', 'Control pediátrico de rutina. Crecimiento normal.', 'Seguir dieta habitual', 2, 2),
('2026-02-01 09:15:00', 'Cuadro de gripe estacional.', 'Reposo relativo y analgésicos', 3, 8),
('2026-02-10 16:45:00', 'Dermatitis por contacto detectada.', 'Aplicación de crema con corticoides', 4, 4),
('2026-02-20 08:00:00', 'Inicio de consulta nutricional.', 'Se entrega plan de alimentación personalizado', 10, 9);
