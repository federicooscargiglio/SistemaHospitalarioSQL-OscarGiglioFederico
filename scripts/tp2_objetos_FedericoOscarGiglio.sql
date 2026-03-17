-- ============================================================
-- PROYECTO: Sistema de Gestión Hospitalaria
-- ARCHIVO:  tp2_objetos_FedericoOscarGiglio.sql
-- AUTOR:    Federico Oscar Giglio
-- FECHA:    2026
-- DESCRIPCIÓN: Script de creación de Vistas, Funciones,
--              Stored Procedures y Triggers para la base
--              de datos SistemaHospital.
-- ============================================================

USE SistemaHospital;

-- ============================================================
-- SECCIÓN 1: VISTAS (VIEWS)
-- ============================================================

-- ============================================================
-- VISTA 1: v_turnos_completos
-- Descripción: Muestra los turnos programados reemplazando
--              los IDs por los datos reales de cada entidad.
-- Objetivo: Facilitar la consulta operativa de turnos sin
--           necesidad de hacer JOINs manuales cada vez.
-- Tablas que la componen: TURNOS, PACIENTES, MEDICOS,
--                         ESPECIALIDADES
-- ============================================================

CREATE OR REPLACE VIEW v_turnos_completos AS
SELECT 
    t.id_turno,
    t.fecha,
    t.hora,
    t.estado,
    CONCAT(p.pac_nombre, ' ', p.pac_apellido) AS paciente,
    CONCAT(m.med_nombre, ' ', m.med_apellido) AS medico,
    e.esp_nombre AS especialidad
FROM TURNOS t
JOIN PACIENTES p ON t.id_paciente = p.id_paciente
JOIN MEDICOS m ON t.id_medico = m.id_medico
JOIN ESPECIALIDADES e ON m.id_espec = e.id_espec;

-- ============================================================
-- VISTA 2: v_pacientes_por_os
-- Descripción: Lista todos los pacientes junto con la obra
--              social a la que pertenecen, ordenados
--              alfabéticamente por prestadora.
-- Objetivo: Permitir una rápida consulta administrativa de
--           la cobertura médica de cada paciente.
-- Tablas que la componen: PACIENTES, OBRAS_SOCIALES
-- ============================================================

CREATE OR REPLACE VIEW v_pacientes_por_os AS
SELECT 
    os.os_nombre AS obra_social,
    CONCAT(p.pac_nombre, ' ', p.pac_apellido) AS paciente,
    p.pac_dni AS dni
FROM PACIENTES p
JOIN OBRAS_SOCIALES os ON p.id_os = os.id_os
ORDER BY os.os_nombre;

-- ============================================================
-- VISTA 3: v_historial_clinico
-- Descripción: Muestra el historial clínico completo de cada
--              paciente con nombres reales de paciente, médico
--              y especialidad en lugar de IDs.
-- Objetivo: Consultar el historial médico de forma legible
--           para uso clínico y administrativo.
-- Tablas que la componen: HISTORIAS_CLINICAS, PACIENTES,
--                         MEDICOS, ESPECIALIDADES
-- ============================================================

CREATE OR REPLACE VIEW v_historial_clinico AS
SELECT 
    hc.id_historia,
    hc.fecha_consulta,
    CONCAT(p.pac_nombre, ' ', p.pac_apellido) AS paciente,
    CONCAT(m.med_nombre, ' ', m.med_apellido) AS medico,
    e.esp_nombre AS especialidad,
    hc.diagnostico,
    hc.tratamiento
FROM HISTORIAS_CLINICAS hc
JOIN PACIENTES p ON hc.id_paciente = p.id_paciente
JOIN MEDICOS m ON hc.id_medico = m.id_medico
JOIN ESPECIALIDADES e ON m.id_espec = e.id_espec;


-- ============================================================
-- SECCIÓN 2: FUNCIONES (FUNCTIONS)
-- ============================================================

-- ============================================================
-- FUNCIÓN 1: calcular_edad
-- Descripción: Calcula la edad actual de un paciente en años
--              a partir de su fecha de nacimiento.
-- Objetivo: Evitar el cálculo manual de edades y centralizar
--           la lógica en un único objeto reutilizable.
-- Parámetro: fecha_nac (DATE) - fecha de nacimiento
-- Retorna:   edad en años completos (INT)
-- Tablas relacionadas: PACIENTES (campo pac_fecha_nac)
-- ============================================================

DELIMITER //
CREATE FUNCTION IF NOT EXISTS calcular_edad(fecha_nac DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, fecha_nac, CURDATE());
END //
DELIMITER ;

-- ============================================================
-- FUNCIÓN 2: contar_turnos_medico
-- Descripción: Devuelve la cantidad total de turnos asignados
--              a un médico específico.
-- Objetivo: Permitir consultas rápidas de carga de trabajo
--           por médico sin necesidad de escribir subconsultas.
-- Parámetro: p_id_medico (INT) - ID del médico a consultar
-- Retorna:   cantidad de turnos asignados (INT)
-- Tablas relacionadas: TURNOS (campo id_medico)
-- ============================================================

DELIMITER //
CREATE FUNCTION IF NOT EXISTS contar_turnos_medico(p_id_medico INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM TURNOS
    WHERE id_medico = p_id_medico;
    RETURN total;
END //
DELIMITER ;


-- ============================================================
-- SECCIÓN 3: STORED PROCEDURES
-- ============================================================

-- ============================================================
-- STORED PROCEDURE 1: registrar_turno
-- Descripción: Inserta un nuevo turno en el sistema con estado
--              'Pendiente' por defecto.
-- Objetivo: Estandarizar el proceso de alta de turnos,
--           garantizando que el estado inicial sea siempre
--           consistente.
-- Parámetros: p_fecha (DATE), p_hora (TIME),
--             p_id_paciente (INT), p_id_medico (INT)
-- Tablas que impacta: TURNOS (INSERT)
-- ============================================================

DROP PROCEDURE IF EXISTS registrar_turno;

DELIMITER //
CREATE PROCEDURE registrar_turno(
    IN p_fecha DATE,
    IN p_hora TIME,
    IN p_id_paciente INT,
    IN p_id_medico INT
)
BEGIN
    INSERT INTO TURNOS (fecha, hora, estado, id_paciente, id_medico)
    VALUES (p_fecha, p_hora, 'Pendiente', p_id_paciente, p_id_medico);
END //
DELIMITER ;

-- ============================================================
-- STORED PROCEDURE 2: cancelar_turno
-- Descripción: Actualiza el estado de un turno existente
--              a 'Cancelado' a partir de su ID.
-- Objetivo: Centralizar la lógica de cancelación de turnos,
--           lo que a su vez activa el Trigger de auditoría.
-- Parámetros: p_id_turno (INT) - ID del turno a cancelar
-- Tablas que impacta: TURNOS (UPDATE)
-- ============================================================

DROP PROCEDURE IF EXISTS cancelar_turno;

DELIMITER //
CREATE PROCEDURE cancelar_turno(
    IN p_id_turno INT
)
BEGIN
    UPDATE TURNOS
    SET estado = 'Cancelado'
    WHERE id_turno = p_id_turno;
END //
DELIMITER ;

-- ============================================================
-- STORED PROCEDURE 3: agregar_historia_clinica
-- Descripción: Registra una nueva entrada en el historial
--              clínico de un paciente con la fecha y hora
--              actual del sistema.
-- Objetivo: Simplificar el registro de consultas médicas
--           asegurando que la fecha se capture automáticamente.
-- Parámetros: p_id_paciente (INT), p_id_medico (INT),
--             p_diagnostico (TEXT), p_tratamiento (TEXT)
-- Tablas que impacta: HISTORIAS_CLINICAS (INSERT)
-- ============================================================

DROP PROCEDURE IF EXISTS agregar_historia_clinica;

DELIMITER //
CREATE PROCEDURE agregar_historia_clinica(
    IN p_id_paciente INT,
    IN p_id_medico INT,
    IN p_diagnostico TEXT,
    IN p_tratamiento TEXT
)
BEGIN
    INSERT INTO HISTORIAS_CLINICAS (fecha_consulta, diagnostico, tratamiento, id_paciente, id_medico)
    VALUES (NOW(), p_diagnostico, p_tratamiento, p_id_paciente, p_id_medico);
END //
DELIMITER ;


-- ============================================================
-- SECCIÓN 4: TRIGGERS
-- ============================================================

-- ============================================================
-- TABLA DE AUDITORÍA: AUDITORIA_CANCELACIONES
-- Descripción: Tabla auxiliar que almacena un registro
--              automático cada vez que un turno es cancelado.
--              Es requerida por el Trigger 2.
-- ============================================================

CREATE TABLE IF NOT EXISTS AUDITORIA_CANCELACIONES (
    id_auditoria INT AUTO_INCREMENT,
    id_turno INT NOT NULL,
    fecha_cancelacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_auditoria)
);

-- ============================================================
-- TRIGGER 1: before_insert_turno
-- Descripción: Antes de insertar un nuevo turno, verifica que
--              el valor del campo 'estado' sea uno de los
--              permitidos. Si no lo es, lo reemplaza por
--              'Pendiente' automáticamente.
-- Objetivo: Garantizar la integridad de los datos en la tabla
--           TURNOS evitando estados inválidos.
-- Evento: BEFORE INSERT
-- Tabla que monitorea: TURNOS
-- ============================================================

DROP TRIGGER IF EXISTS before_insert_turno;

DELIMITER //
CREATE TRIGGER before_insert_turno
BEFORE INSERT ON TURNOS
FOR EACH ROW
BEGIN
    IF NEW.estado NOT IN ('Pendiente', 'Confirmado', 'Cancelado') THEN
        SET NEW.estado = 'Pendiente';
    END IF;
END //
DELIMITER ;

-- ============================================================
-- TRIGGER 2: after_cancelar_turno
-- Descripción: Después de que el estado de un turno cambia a
--              'Cancelado', inserta automáticamente un registro
--              en la tabla AUDITORIA_CANCELACIONES con el ID
--              del turno y la fecha/hora exacta del evento.
-- Objetivo: Mantener un historial de auditoría de todas las
--           cancelaciones sin intervención manual.
-- Evento: AFTER UPDATE
-- Tabla que monitorea: TURNOS
-- Tabla que impacta: AUDITORIA_CANCELACIONES
-- ============================================================

DROP TRIGGER IF EXISTS after_cancelar_turno;

DELIMITER //
CREATE TRIGGER after_cancelar_turno
AFTER UPDATE ON TURNOS
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Cancelado' AND OLD.estado != 'Cancelado' THEN
        INSERT INTO AUDITORIA_CANCELACIONES (id_turno, fecha_cancelacion)
        VALUES (NEW.id_turno, NOW());
    END IF;
END //
DELIMITER ;
