-- ============================================================
-- PROYECTO: Sistema de Gestión Hospitalaria (SGH)
-- ARCHIVO:  tpfinal_estructura_FedericoOscarGiglio.sql
-- AUTOR:    Federico Oscar Giglio
-- FECHA:    2026
-- ENTREGA:  Trabajo Práctico Final - Base de Datos
-- ============================================================
-- DESCRIPCIÓN:
-- Script de creación completa del esquema de la base de datos.
-- Incluye:
--   - Creación de la base de datos
--   - Creación de 16 tablas (1 de hechos, 2 transaccionales,
--     1 de auditoría y 12 de entidades/catálogo)
--   - Creación de 5 Vistas
--   - Creación de 3 Funciones
--   - Creación de 4 Stored Procedures
--   - Creación de 3 Triggers
--
-- ORDEN DE EJECUCIÓN:
--   1) Este archivo (estructura)
--   2) tpfinal_datos_FedericoOscarGiglio.sql (poblado)
--   3) tpfinal_informes_FedericoOscarGiglio.sql (consultas)
-- ============================================================

DROP DATABASE IF EXISTS SistemaHospital;
CREATE DATABASE SistemaHospital 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;
USE SistemaHospital;


-- ============================================================
-- SECCIÓN 1: CREACIÓN DE TABLAS (DDL)
-- ============================================================
-- El orden de creación respeta las dependencias de claves
-- foráneas: primero las tablas maestras/catálogo, luego las
-- tablas de entidades principales, y finalmente las
-- transaccionales, la tabla de hechos y la de auditoría.
-- ============================================================

-- ------------------------------------------------------------
-- Tabla: ESPECIALIDADES (catálogo)
-- ------------------------------------------------------------
CREATE TABLE ESPECIALIDADES (
    id_espec    INT AUTO_INCREMENT,
    esp_nombre  VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (id_espec)
);

-- ------------------------------------------------------------
-- Tabla: OBRAS_SOCIALES (catálogo)
-- ------------------------------------------------------------
CREATE TABLE OBRAS_SOCIALES (
    id_os       INT AUTO_INCREMENT,
    os_nombre   VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (id_os)
);

-- ------------------------------------------------------------
-- Tabla: CONSULTORIOS (catálogo)
-- Representa los consultorios físicos donde se atiende.
-- ------------------------------------------------------------
CREATE TABLE CONSULTORIOS (
    id_consultorio  INT AUTO_INCREMENT,
    con_numero      VARCHAR(10) NOT NULL UNIQUE,
    con_piso        INT NOT NULL,
    con_descripcion VARCHAR(100),
    PRIMARY KEY (id_consultorio)
);

-- ------------------------------------------------------------
-- Tabla: PRESTACIONES (catálogo / nomenclador)
-- Catálogo de servicios médicos con su código y precio base.
-- Se usa para facturar consultas, prácticas y estudios.
-- ------------------------------------------------------------
CREATE TABLE PRESTACIONES (
    id_prestacion    INT AUTO_INCREMENT,
    pre_codigo       VARCHAR(15) NOT NULL UNIQUE,
    pre_descripcion  VARCHAR(150) NOT NULL,
    pre_precio_base  DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_prestacion)
);

-- ------------------------------------------------------------
-- Tabla: MEDICAMENTOS (catálogo)
-- Catálogo de medicamentos disponibles para prescripciones.
-- ------------------------------------------------------------
CREATE TABLE MEDICAMENTOS (
    id_medicamento       INT AUTO_INCREMENT,
    med_nombre_comercial VARCHAR(100) NOT NULL,
    med_droga            VARCHAR(100) NOT NULL,
    med_presentacion     VARCHAR(100),
    PRIMARY KEY (id_medicamento),
    INDEX idx_droga (med_droga)
);

-- ------------------------------------------------------------
-- Tabla: ROLES (catálogo)
-- Roles de los usuarios del sistema (admin, recepción, etc.)
-- ------------------------------------------------------------
CREATE TABLE ROLES (
    id_rol      INT AUTO_INCREMENT,
    rol_nombre  VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY (id_rol)
);

-- ------------------------------------------------------------
-- Tabla: MEDICOS
-- Depende de ESPECIALIDADES y CONSULTORIOS.
-- ------------------------------------------------------------
CREATE TABLE MEDICOS (
    id_medico       INT AUTO_INCREMENT,
    med_nombre      VARCHAR(50) NOT NULL,
    med_apellido    VARCHAR(50) NOT NULL,
    med_matri       VARCHAR(20) NOT NULL UNIQUE,
    id_espec        INT NOT NULL,
    id_consultorio  INT,
    PRIMARY KEY (id_medico),
    FOREIGN KEY (id_espec)       REFERENCES ESPECIALIDADES(id_espec),
    FOREIGN KEY (id_consultorio) REFERENCES CONSULTORIOS(id_consultorio),
    INDEX idx_apellido (med_apellido)
);

-- ------------------------------------------------------------
-- Tabla: PACIENTES
-- Depende de OBRAS_SOCIALES.
-- ------------------------------------------------------------
CREATE TABLE PACIENTES (
    id_paciente     INT AUTO_INCREMENT,
    pac_nombre      VARCHAR(50) NOT NULL,
    pac_apellido    VARCHAR(50) NOT NULL,
    pac_dni         VARCHAR(15) NOT NULL UNIQUE,
    pac_fecha_nac   DATE NOT NULL,
    id_os           INT,
    PRIMARY KEY (id_paciente),
    FOREIGN KEY (id_os) REFERENCES OBRAS_SOCIALES(id_os),
    INDEX idx_apellido (pac_apellido)
);

-- ------------------------------------------------------------
-- Tabla: USUARIOS
-- Personal administrativo/operativo del sistema (login).
-- Depende de ROLES.
-- ------------------------------------------------------------
CREATE TABLE USUARIOS (
    id_usuario          INT AUTO_INCREMENT,
    usu_username        VARCHAR(30) NOT NULL UNIQUE,
    usu_nombre_completo VARCHAR(100) NOT NULL,
    usu_email           VARCHAR(100) NOT NULL UNIQUE,
    usu_activo          BOOLEAN DEFAULT TRUE,
    id_rol              INT NOT NULL,
    PRIMARY KEY (id_usuario),
    FOREIGN KEY (id_rol) REFERENCES ROLES(id_rol)
);

-- ------------------------------------------------------------
-- Tabla: TURNOS (TRANSACCIONAL)
-- Conecta PACIENTES, MEDICOS y CONSULTORIOS.
-- ------------------------------------------------------------
CREATE TABLE TURNOS (
    id_turno       INT AUTO_INCREMENT,
    fecha          DATE NOT NULL,
    hora           TIME NOT NULL,
    estado         VARCHAR(20) DEFAULT 'Pendiente',
    id_paciente    INT NOT NULL,
    id_medico      INT NOT NULL,
    id_consultorio INT,
    PRIMARY KEY (id_turno),
    FOREIGN KEY (id_paciente)    REFERENCES PACIENTES(id_paciente),
    FOREIGN KEY (id_medico)      REFERENCES MEDICOS(id_medico),
    FOREIGN KEY (id_consultorio) REFERENCES CONSULTORIOS(id_consultorio),
    INDEX idx_fecha (fecha),
    INDEX idx_estado (estado)
);

-- ------------------------------------------------------------
-- Tabla: HISTORIAS_CLINICAS (TRANSACCIONAL)
-- Registro clínico generado a partir de una atención.
-- ------------------------------------------------------------
CREATE TABLE HISTORIAS_CLINICAS (
    id_historia              INT AUTO_INCREMENT,
    fecha_consulta           DATETIME DEFAULT CURRENT_TIMESTAMP,
    diagnostico              TEXT,
    tratamiento              TEXT,
    duracion_consulta_min    INT DEFAULT 30,
    id_paciente              INT NOT NULL,
    id_medico                INT NOT NULL,
    PRIMARY KEY (id_historia),
    FOREIGN KEY (id_paciente) REFERENCES PACIENTES(id_paciente),
    FOREIGN KEY (id_medico)   REFERENCES MEDICOS(id_medico),
    INDEX idx_fecha_consulta (fecha_consulta)
);

-- ------------------------------------------------------------
-- Tabla: PRESCRIPCIONES
-- Relación entre una historia clínica y los medicamentos
-- recetados. Permite registrar varios medicamentos por
-- consulta (relación muchos a muchos).
-- ------------------------------------------------------------
CREATE TABLE PRESCRIPCIONES (
    id_prescripcion  INT AUTO_INCREMENT,
    id_historia      INT NOT NULL,
    id_medicamento   INT NOT NULL,
    pre_dosis        VARCHAR(100) NOT NULL,
    pre_duracion_dias INT,
    PRIMARY KEY (id_prescripcion),
    FOREIGN KEY (id_historia)    REFERENCES HISTORIAS_CLINICAS(id_historia),
    FOREIGN KEY (id_medicamento) REFERENCES MEDICAMENTOS(id_medicamento)
);

-- ------------------------------------------------------------
-- Tabla: FACTURAS (cabecera)
-- Factura emitida por una o más prestaciones realizadas
-- a un paciente, con su obra social como responsable de pago.
-- ------------------------------------------------------------
CREATE TABLE FACTURAS (
    id_factura        INT AUTO_INCREMENT,
    fac_numero        VARCHAR(20) NOT NULL UNIQUE,
    fac_fecha_emision DATE NOT NULL,
    fac_total         DECIMAL(12,2) NOT NULL DEFAULT 0,
    id_paciente       INT NOT NULL,
    id_os             INT NOT NULL,
    PRIMARY KEY (id_factura),
    FOREIGN KEY (id_paciente) REFERENCES PACIENTES(id_paciente),
    FOREIGN KEY (id_os)       REFERENCES OBRAS_SOCIALES(id_os),
    INDEX idx_fecha_emision (fac_fecha_emision)
);

-- ------------------------------------------------------------
-- Tabla: DETALLE_FACTURAS
-- Renglones de cada factura, con las prestaciones cobradas.
-- ------------------------------------------------------------
CREATE TABLE DETALLE_FACTURAS (
    id_detalle          INT AUTO_INCREMENT,
    id_factura          INT NOT NULL,
    id_prestacion       INT NOT NULL,
    det_cantidad        INT NOT NULL DEFAULT 1,
    det_precio_unitario DECIMAL(10,2) NOT NULL,
    det_subtotal        DECIMAL(12,2) GENERATED ALWAYS AS
                        (det_cantidad * det_precio_unitario) STORED,
    PRIMARY KEY (id_detalle),
    FOREIGN KEY (id_factura)    REFERENCES FACTURAS(id_factura),
    FOREIGN KEY (id_prestacion) REFERENCES PRESTACIONES(id_prestacion)
);

-- ------------------------------------------------------------
-- Tabla: HECHOS_ATENCIONES (TABLA DE HECHOS)
-- Tabla desnormalizada para uso analítico / BI.
-- Consolida métricas clave de cada atención (consulta)
-- realizada, permitiendo consultas agregadas rápidas por
-- dimensiones (fecha, especialidad, obra social, etc.)
-- ------------------------------------------------------------
CREATE TABLE HECHOS_ATENCIONES (
    id_hecho                 INT AUTO_INCREMENT,
    fecha_atencion           DATE NOT NULL,
    id_paciente              INT NOT NULL,
    id_medico                INT NOT NULL,
    id_especialidad          INT NOT NULL,
    id_obra_social           INT,
    duracion_consulta_min    INT,
    cant_prescripciones      INT DEFAULT 0,
    monto_facturado          DECIMAL(12,2) DEFAULT 0,
    edad_paciente_al_momento INT,
    PRIMARY KEY (id_hecho),
    FOREIGN KEY (id_paciente)     REFERENCES PACIENTES(id_paciente),
    FOREIGN KEY (id_medico)       REFERENCES MEDICOS(id_medico),
    FOREIGN KEY (id_especialidad) REFERENCES ESPECIALIDADES(id_espec),
    FOREIGN KEY (id_obra_social)  REFERENCES OBRAS_SOCIALES(id_os),
    INDEX idx_fecha_atencion (fecha_atencion),
    INDEX idx_especialidad   (id_especialidad),
    INDEX idx_obra_social    (id_obra_social)
);

-- ------------------------------------------------------------
-- Tabla: AUDITORIA_CANCELACIONES
-- Tabla auxiliar poblada automáticamente por el trigger
-- after_cancelar_turno. Registra toda cancelación de turno.
-- ------------------------------------------------------------
CREATE TABLE AUDITORIA_CANCELACIONES (
    id_auditoria      INT AUTO_INCREMENT,
    id_turno          INT NOT NULL,
    fecha_cancelacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_auditoria),
    FOREIGN KEY (id_turno) REFERENCES TURNOS(id_turno)
);


-- ============================================================
-- SECCIÓN 2: VISTAS (VIEWS)
-- ============================================================

-- ------------------------------------------------------------
-- VISTA 1: v_turnos_completos
-- Muestra los turnos programados reemplazando los IDs por
-- los datos reales de cada entidad. Facilita la consulta
-- operativa de turnos sin hacer JOINs manuales cada vez.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_turnos_completos AS
SELECT
    t.id_turno,
    t.fecha,
    t.hora,
    t.estado,
    CONCAT(p.pac_nombre, ' ', p.pac_apellido) AS paciente,
    CONCAT(m.med_nombre, ' ', m.med_apellido) AS medico,
    e.esp_nombre                              AS especialidad,
    c.con_numero                              AS consultorio
FROM TURNOS t
JOIN PACIENTES      p ON t.id_paciente    = p.id_paciente
JOIN MEDICOS        m ON t.id_medico      = m.id_medico
JOIN ESPECIALIDADES e ON m.id_espec       = e.id_espec
LEFT JOIN CONSULTORIOS c ON t.id_consultorio = c.id_consultorio;

-- ------------------------------------------------------------
-- VISTA 2: v_pacientes_por_os
-- Lista todos los pacientes junto con su obra social,
-- ordenados alfabéticamente por prestadora.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_pacientes_por_os AS
SELECT
    os.os_nombre                                AS obra_social,
    CONCAT(p.pac_nombre, ' ', p.pac_apellido)   AS paciente,
    p.pac_dni                                   AS dni
FROM PACIENTES p
JOIN OBRAS_SOCIALES os ON p.id_os = os.id_os
ORDER BY os.os_nombre;

-- ------------------------------------------------------------
-- VISTA 3: v_historial_clinico
-- Historial clínico completo de cada paciente con nombres
-- reales y especialidad del médico tratante.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_historial_clinico AS
SELECT
    hc.id_historia,
    hc.fecha_consulta,
    CONCAT(p.pac_nombre, ' ', p.pac_apellido) AS paciente,
    CONCAT(m.med_nombre, ' ', m.med_apellido) AS medico,
    e.esp_nombre                              AS especialidad,
    hc.diagnostico,
    hc.tratamiento
FROM HISTORIAS_CLINICAS hc
JOIN PACIENTES      p ON hc.id_paciente = p.id_paciente
JOIN MEDICOS        m ON hc.id_medico   = m.id_medico
JOIN ESPECIALIDADES e ON m.id_espec     = e.id_espec;

-- ------------------------------------------------------------
-- VISTA 4: v_productividad_medicos
-- Métrica de productividad por médico: total de turnos,
-- total de consultas efectivamente realizadas (historias)
-- y suma de minutos atendidos.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_productividad_medicos AS
SELECT
    m.id_medico,
    CONCAT(m.med_nombre, ' ', m.med_apellido) AS medico,
    e.esp_nombre                              AS especialidad,
    COUNT(DISTINCT t.id_turno)                AS total_turnos,
    COUNT(DISTINCT hc.id_historia)            AS total_consultas,
    COALESCE(SUM(hc.duracion_consulta_min),0) AS minutos_atendidos
FROM MEDICOS m
JOIN ESPECIALIDADES e ON m.id_espec = e.id_espec
LEFT JOIN TURNOS t             ON t.id_medico  = m.id_medico
LEFT JOIN HISTORIAS_CLINICAS hc ON hc.id_medico = m.id_medico
GROUP BY m.id_medico, medico, especialidad;

-- ------------------------------------------------------------
-- VISTA 5: v_facturacion_por_os
-- Resumen de facturación agrupado por obra social.
-- Permite conocer el volumen de facturación que aporta cada
-- prestadora a la clínica.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_facturacion_por_os AS
SELECT
    os.os_nombre                AS obra_social,
    COUNT(f.id_factura)         AS cant_facturas,
    COALESCE(SUM(f.fac_total),0) AS total_facturado
FROM OBRAS_SOCIALES os
LEFT JOIN FACTURAS f ON f.id_os = os.id_os
GROUP BY os.id_os, os.os_nombre
ORDER BY total_facturado DESC;

-- ------------------------------------------------------------
-- VISTA 6: v_resumen_atenciones
-- Vista sobre la tabla de hechos para consultas analíticas
-- rápidas: atenciones agregadas por especialidad.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_resumen_atenciones AS
SELECT
    e.esp_nombre                        AS especialidad,
    COUNT(h.id_hecho)                   AS cant_atenciones,
    ROUND(AVG(h.duracion_consulta_min),1) AS promedio_minutos,
    COALESCE(SUM(h.monto_facturado),0)  AS monto_total,
    ROUND(AVG(h.edad_paciente_al_momento),1) AS edad_promedio
FROM HECHOS_ATENCIONES h
JOIN ESPECIALIDADES e ON h.id_especialidad = e.id_espec
GROUP BY e.id_espec, e.esp_nombre
ORDER BY cant_atenciones DESC;


-- ============================================================
-- SECCIÓN 3: FUNCIONES (FUNCTIONS)
-- ============================================================

-- ------------------------------------------------------------
-- FUNCIÓN 1: calcular_edad
-- Calcula la edad actual de un paciente (años completos).
-- Parámetro: fecha_nac (DATE)
-- Retorna:   INT - edad en años
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS calcular_edad;
DELIMITER //
CREATE FUNCTION calcular_edad(fecha_nac DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, fecha_nac, CURDATE());
END //
DELIMITER ;

-- ------------------------------------------------------------
-- FUNCIÓN 2: contar_turnos_medico
-- Devuelve la cantidad total de turnos asignados al médico
-- indicado por parámetro.
-- Parámetro: p_id_medico (INT)
-- Retorna:   INT - total de turnos
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS contar_turnos_medico;
DELIMITER //
CREATE FUNCTION contar_turnos_medico(p_id_medico INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM TURNOS
    WHERE id_medico = p_id_medico;
    RETURN total;
END //
DELIMITER ;

-- ------------------------------------------------------------
-- FUNCIÓN 3: monto_facturado_paciente
-- Devuelve el monto total facturado histórico de un paciente.
-- Parámetro: p_id_paciente (INT)
-- Retorna:   DECIMAL(12,2) - monto total acumulado
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS monto_facturado_paciente;
DELIMITER //
CREATE FUNCTION monto_facturado_paciente(p_id_paciente INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(12,2);
    SELECT COALESCE(SUM(fac_total), 0) INTO total
    FROM FACTURAS
    WHERE id_paciente = p_id_paciente;
    RETURN total;
END //
DELIMITER ;


-- ============================================================
-- SECCIÓN 4: STORED PROCEDURES
-- ============================================================

-- ------------------------------------------------------------
-- SP 1: registrar_turno
-- Inserta un nuevo turno con estado 'Pendiente' por defecto.
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS registrar_turno;
DELIMITER //
CREATE PROCEDURE registrar_turno(
    IN p_fecha          DATE,
    IN p_hora           TIME,
    IN p_id_paciente    INT,
    IN p_id_medico      INT,
    IN p_id_consultorio INT
)
BEGIN
    INSERT INTO TURNOS (fecha, hora, estado, id_paciente, id_medico, id_consultorio)
    VALUES (p_fecha, p_hora, 'Pendiente', p_id_paciente, p_id_medico, p_id_consultorio);
END //
DELIMITER ;

-- ------------------------------------------------------------
-- SP 2: cancelar_turno
-- Actualiza el estado de un turno a 'Cancelado'.
-- Activa el trigger de auditoría.
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- SP 3: agregar_historia_clinica
-- Registra una nueva historia clínica capturando la fecha
-- y hora actual del sistema.
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS agregar_historia_clinica;
DELIMITER //
CREATE PROCEDURE agregar_historia_clinica(
    IN p_id_paciente  INT,
    IN p_id_medico    INT,
    IN p_diagnostico  TEXT,
    IN p_tratamiento  TEXT,
    IN p_duracion_min INT
)
BEGIN
    INSERT INTO HISTORIAS_CLINICAS
        (fecha_consulta, diagnostico, tratamiento, duracion_consulta_min,
         id_paciente, id_medico)
    VALUES
        (NOW(), p_diagnostico, p_tratamiento, p_duracion_min,
         p_id_paciente, p_id_medico);
END //
DELIMITER ;

-- ------------------------------------------------------------
-- SP 4: generar_factura
-- Genera una factura con una única prestación y actualiza
-- el total de la factura automáticamente.
-- Demuestra el uso de una transacción para mantener la
-- integridad entre FACTURAS y DETALLE_FACTURAS.
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS generar_factura;
DELIMITER //
CREATE PROCEDURE generar_factura(
    IN p_numero         VARCHAR(20),
    IN p_id_paciente    INT,
    IN p_id_os          INT,
    IN p_id_prestacion  INT,
    IN p_cantidad       INT
)
BEGIN
    DECLARE v_precio       DECIMAL(10,2);
    DECLARE v_id_factura   INT;
    DECLARE v_subtotal     DECIMAL(12,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT pre_precio_base INTO v_precio
    FROM PRESTACIONES
    WHERE id_prestacion = p_id_prestacion;

    SET v_subtotal = v_precio * p_cantidad;

    INSERT INTO FACTURAS (fac_numero, fac_fecha_emision, fac_total, id_paciente, id_os)
    VALUES (p_numero, CURDATE(), v_subtotal, p_id_paciente, p_id_os);

    SET v_id_factura = LAST_INSERT_ID();

    INSERT INTO DETALLE_FACTURAS (id_factura, id_prestacion, det_cantidad, det_precio_unitario)
    VALUES (v_id_factura, p_id_prestacion, p_cantidad, v_precio);

    COMMIT;
END //
DELIMITER ;


-- ============================================================
-- SECCIÓN 5: TRIGGERS
-- ============================================================

-- ------------------------------------------------------------
-- TRIGGER 1: before_insert_turno
-- Garantiza la integridad del campo 'estado' en TURNOS.
-- Si se intenta insertar un estado inválido, lo reemplaza
-- por 'Pendiente'.
-- Evento: BEFORE INSERT ON TURNOS
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS before_insert_turno;
DELIMITER //
CREATE TRIGGER before_insert_turno
BEFORE INSERT ON TURNOS
FOR EACH ROW
BEGIN
    IF NEW.estado NOT IN ('Pendiente', 'Confirmado', 'Cancelado', 'Atendido') THEN
        SET NEW.estado = 'Pendiente';
    END IF;
END //
DELIMITER ;

-- ------------------------------------------------------------
-- TRIGGER 2: after_cancelar_turno
-- Registra automáticamente en AUDITORIA_CANCELACIONES cada
-- vez que un turno pasa a estado 'Cancelado'.
-- Evento: AFTER UPDATE ON TURNOS
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- TRIGGER 3: after_insert_historia
-- Al registrarse una nueva historia clínica, se inserta
-- automáticamente un registro en la tabla de HECHOS
-- (HECHOS_ATENCIONES), desnormalizando los datos claves
-- para análisis posteriores.
-- Evento: AFTER INSERT ON HISTORIAS_CLINICAS
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS after_insert_historia;
DELIMITER //
CREATE TRIGGER after_insert_historia
AFTER INSERT ON HISTORIAS_CLINICAS
FOR EACH ROW
BEGIN
    DECLARE v_id_espec INT;
    DECLARE v_id_os    INT;
    DECLARE v_edad     INT;

    SELECT id_espec INTO v_id_espec
    FROM MEDICOS
    WHERE id_medico = NEW.id_medico;

    SELECT id_os, TIMESTAMPDIFF(YEAR, pac_fecha_nac, NEW.fecha_consulta)
    INTO v_id_os, v_edad
    FROM PACIENTES
    WHERE id_paciente = NEW.id_paciente;

    INSERT INTO HECHOS_ATENCIONES
        (fecha_atencion, id_paciente, id_medico, id_especialidad,
         id_obra_social, duracion_consulta_min, cant_prescripciones,
         monto_facturado, edad_paciente_al_momento)
    VALUES
        (DATE(NEW.fecha_consulta), NEW.id_paciente, NEW.id_medico, v_id_espec,
         v_id_os, NEW.duracion_consulta_min, 0,
         0, v_edad);
END //
DELIMITER ;


-- ============================================================
-- FIN DEL SCRIPT DE ESTRUCTURA
-- ============================================================
-- Siguiente paso: ejecutar tpfinal_datos_FedericoOscarGiglio.sql
-- ============================================================
