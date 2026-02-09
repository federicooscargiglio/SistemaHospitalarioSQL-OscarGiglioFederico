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
