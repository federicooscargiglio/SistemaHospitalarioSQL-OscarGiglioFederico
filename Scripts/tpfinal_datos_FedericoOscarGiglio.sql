-- ============================================================
-- PROYECTO: Sistema de Gestión Hospitalaria (SGH)
-- ARCHIVO:  tpfinal_datos_FedericoOscarGiglio.sql
-- AUTOR:    Federico Oscar Giglio
-- FECHA:    2026
-- ENTREGA:  Trabajo Práctico Final - Base de Datos
-- ============================================================
-- DESCRIPCIÓN:
-- Script de inserción de datos de prueba en todas las tablas
-- del esquema SistemaHospital.
--
-- PREREQUISITO: ejecutar previamente
-- tpfinal_estructura_FedericoOscarGiglio.sql
--
-- ORDEN DE INSERCIÓN:
-- Se respetan las dependencias de claves foráneas: primero
-- las tablas catálogo, luego médicos/pacientes/usuarios, y
-- por último las tablas transaccionales y facturación.
--
-- NOTA SOBRE HECHOS_ATENCIONES:
-- La tabla de hechos se puebla AUTOMÁTICAMENTE por el
-- trigger 'after_insert_historia'. Al final del script se
-- actualizan los campos que el trigger no conoce al momento
-- del insert (monto_facturado y cant_prescripciones).
-- ============================================================

USE SistemaHospital;


-- ============================================================
-- 1. OBRAS_SOCIALES
-- ============================================================
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
('Particular');


-- ============================================================
-- 2. ESPECIALIDADES
-- ============================================================
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


-- ============================================================
-- 3. CONSULTORIOS
-- ============================================================
INSERT INTO CONSULTORIOS (con_numero, con_piso, con_descripcion) VALUES
('101', 1, 'Consultorio general planta baja'),
('102', 1, 'Consultorio general planta baja'),
('201', 2, 'Consultorio de especialidades'),
('202', 2, 'Consultorio de especialidades'),
('301', 3, 'Consultorio de diagnóstico');


-- ============================================================
-- 4. PRESTACIONES (nomenclador)
-- ============================================================
INSERT INTO PRESTACIONES (pre_codigo, pre_descripcion, pre_precio_base) VALUES
('CON001', 'Consulta clínica general',                    12000.00),
('CON002', 'Consulta con especialista',                   18000.00),
('CON003', 'Consulta pediátrica',                         15000.00),
('DIA001', 'Electrocardiograma',                          22000.00),
('DIA002', 'Ecografía general',                           28000.00),
('DIA003', 'Análisis de laboratorio básico',              14000.00),
('PRA001', 'Control ginecológico',                        20000.00),
('PRA002', 'Curación simple',                              8000.00),
('PRA003', 'Sesión de kinesiología',                      10000.00),
('PRA004', 'Consulta nutricional con plan alimentario',   17000.00);


-- ============================================================
-- 5. MEDICAMENTOS
-- ============================================================
INSERT INTO MEDICAMENTOS (med_nombre_comercial, med_droga, med_presentacion) VALUES
('Amoxidal 500',      'Amoxicilina',         'Cápsulas x 16'),
('Ibupirac 600',      'Ibuprofeno',          'Comprimidos x 20'),
('Paracetamol Geniol','Paracetamol',         'Comprimidos x 16'),
('Losartan Genfar',   'Losartán',            'Comprimidos x 30'),
('Atenolol Fabra',    'Atenolol',            'Comprimidos x 30'),
('Omeprazol 20',      'Omeprazol',           'Cápsulas x 14'),
('Dermaglós Crema',   'Corticoide tópico',   'Pomo 50g'),
('Ventolin',          'Salbutamol',          'Aerosol 200 dosis'),
('Amoxidal Duo',      'Amoxicilina + Ac.',   'Suspensión 70ml'),
('Complejo B12',      'Vitamina B12',        'Comprimidos x 30');


-- ============================================================
-- 6. ROLES
-- ============================================================
INSERT INTO ROLES (rol_nombre) VALUES
('Administrador'),
('Recepcionista'),
('Médico'),
('Enfermería'),
('Facturación');


-- ============================================================
-- 7. MEDICOS
-- ============================================================
INSERT INTO MEDICOS (med_nombre, med_apellido, med_matri, id_espec, id_consultorio) VALUES
('Juan',    'Pérez',     'MN12345', 1,  3),
('María',   'García',    'MN23456', 2,  1),
('Ricardo', 'López',     'MN34567', 3,  4),
('Elena',   'Fernández', 'MN45678', 4,  3),
('Carlos',  'Sánchez',   'MN56789', 5,  4),
('Ana',     'Martínez',  'MN67890', 6,  3),
('Jorge',   'Rodríguez', 'MN78901', 7,  5),
('Lucía',   'Gómez',     'MN89012', 8,  2),
('Roberto', 'Díaz',      'MN90123', 9,  1),
('Sofía',   'Álvarez',   'MN01234', 10, 5);


-- ============================================================
-- 8. PACIENTES
-- ============================================================
INSERT INTO PACIENTES (pac_nombre, pac_apellido, pac_dni, pac_fecha_nac, id_os) VALUES
('Federico', 'Giglio',   '35123456', '1990-05-15', 1),
('Laura',    'Mazzini',  '38234567', '1985-08-22', 2),
('Andrés',   'Castro',   '40345678', '1998-01-10', 10),
('Patricia', 'Sosa',     '25456789', '1970-11-03', 3),
('Mariano',  'Closs',    '30567890', '1975-03-20', 4),
('Jimena',   'Barón',    '33678901', '1987-05-24', 5),
('Oscar',    'Ruggeri',  '15789012', '1962-01-26', 6),
('Mónica',   'Ayos',     '28890123', '1972-06-19', 7),
('Diego',    'Torres',   '22901234', '1971-03-09', 8),
('Natalia',  'Oreiro',   '27012345', '1977-05-19', 9);


-- ============================================================
-- 9. USUARIOS (personal del sistema)
-- ============================================================
INSERT INTO USUARIOS (usu_username, usu_nombre_completo, usu_email, id_rol) VALUES
('fgiglio',   'Federico Giglio',   'fgiglio@clinica.com',     1),
('mperez',    'Marcela Pérez',     'mperez@clinica.com',      2),
('jlopez',    'Javier López',      'jlopez@clinica.com',      2),
('cruiz',     'Carolina Ruiz',     'cruiz@clinica.com',       4),
('dmartin',   'Daniel Martín',     'dmartin@clinica.com',     5);


-- ============================================================
-- 10. TURNOS
-- ============================================================
INSERT INTO TURNOS (fecha, hora, estado, id_paciente, id_medico, id_consultorio) VALUES
('2026-03-20', '09:00:00', 'Pendiente',  1,  1, 3),
('2026-03-20', '10:30:00', 'Pendiente',  2,  2, 1),
('2026-03-21', '11:00:00', 'Confirmado', 3,  8, 2),
('2026-03-21', '15:00:00', 'Pendiente',  4,  4, 3),
('2026-03-22', '08:30:00', 'Pendiente',  5, 10, 5),
('2026-03-22', '09:30:00', 'Confirmado', 6,  5, 4),
('2026-03-23', '10:00:00', 'Pendiente',  7,  1, 3),
('2026-03-23', '14:00:00', 'Atendido',   8,  6, 3),
('2026-03-24', '11:30:00', 'Pendiente',  9,  3, 4),
('2026-03-24', '16:00:00', 'Confirmado',10,  7, 5);


-- ============================================================
-- 11. HISTORIAS_CLINICAS
-- NOTA: al insertar cada historia se dispara el trigger
-- 'after_insert_historia' que puebla HECHOS_ATENCIONES.
-- ============================================================
INSERT INTO HISTORIAS_CLINICAS 
    (fecha_consulta, diagnostico, tratamiento, duracion_consulta_min, id_paciente, id_medico) VALUES
('2026-01-10 10:00:00', 'Chequeo preventivo. Presión arterial normal.',      'Sin tratamiento indicado',                     25,  1,  1),
('2026-01-15 11:30:00', 'Control pediátrico de rutina. Crecimiento normal.', 'Seguir dieta habitual',                        30,  2,  2),
('2026-02-01 09:15:00', 'Cuadro de gripe estacional.',                        'Reposo relativo y analgésicos',                20,  3,  8),
('2026-02-10 16:45:00', 'Dermatitis por contacto detectada.',                 'Aplicación de crema con corticoides',          25,  4,  4),
('2026-02-20 08:00:00', 'Inicio de consulta nutricional.',                    'Se entrega plan de alimentación personalizado',45, 10,  9),
('2026-02-25 10:30:00', 'Hipertensión arterial leve.',                        'Losartán 50mg diarios. Control en 30 días.',   30,  7,  1),
('2026-03-05 14:00:00', 'Esguince de tobillo grado I.',                       'Reposo, hielo, antiinflamatorio y kinesiología',30,  9,  3),
('2026-03-10 09:00:00', 'Control ginecológico anual. Sin hallazgos.',         'Continuar controles anuales',                  40,  6,  5),
('2026-03-15 11:00:00', 'Cefalea tensional recurrente.',                      'Ibuprofeno 600mg según dolor. Estudios.',      25,  8,  6),
('2026-03-18 15:30:00', 'Reflujo gastroesofágico.',                           'Omeprazol 20mg en ayunas por 30 días',         20,  5,  8);


-- ============================================================
-- 12. PRESCRIPCIONES (medicamentos recetados)
-- ============================================================
INSERT INTO PRESCRIPCIONES (id_historia, id_medicamento, pre_dosis, pre_duracion_dias) VALUES
(3,  2, '1 comprimido cada 8 hs',      5),   -- Ibupirac - gripe
(3,  3, '1 comprimido cada 6 hs',      5),   -- Paracetamol - gripe
(4,  7, 'Aplicar 2 veces por día',     10),  -- Dermaglós - dermatitis
(6,  4, '1 comprimido diario',         30),  -- Losartán - HTA
(7,  2, '1 comprimido cada 8 hs',      7),   -- Ibupirac - esguince
(9,  2, '1 comprimido ante dolor',     15),  -- Ibupirac - cefalea
(10, 6, '1 cápsula en ayunas',         30),  -- Omeprazol - reflujo
(2,  10, '1 comprimido diario',        30),  -- Complejo B12 - pediátrico
(6,  5, '1 comprimido diario',         30),  -- Atenolol - HTA
(3,  1, '1 cápsula cada 8 hs',         7);   -- Amoxidal - gripe complicada


-- ============================================================
-- 13. FACTURAS + DETALLE_FACTURAS
-- Facturas generadas por las consultas registradas.
-- Se insertan cabecera y detalle en la misma transacción.
-- ============================================================
INSERT INTO FACTURAS (fac_numero, fac_fecha_emision, fac_total, id_paciente, id_os) VALUES
('A-0001-00000001', '2026-01-10', 12000.00,  1, 1),
('A-0001-00000002', '2026-01-15', 15000.00,  2, 2),
('A-0001-00000003', '2026-02-01', 12000.00,  3, 10),
('A-0001-00000004', '2026-02-10', 18000.00,  4, 3),
('A-0001-00000005', '2026-02-20', 17000.00, 10, 9),
('A-0001-00000006', '2026-02-25', 34000.00,  7, 6),  -- consulta + ECG
('A-0001-00000007', '2026-03-05', 18000.00,  9, 8),
('A-0001-00000008', '2026-03-10', 20000.00,  6, 5),
('A-0001-00000009', '2026-03-15', 32000.00,  8, 7),  -- consulta + eco
('A-0001-00000010', '2026-03-18', 12000.00,  5, 4);

INSERT INTO DETALLE_FACTURAS (id_factura, id_prestacion, det_cantidad, det_precio_unitario) VALUES
(1,  1, 1, 12000.00),  -- F1: consulta clínica
(2,  3, 1, 15000.00),  -- F2: consulta pediátrica
(3,  1, 1, 12000.00),  -- F3: consulta clínica
(4,  2, 1, 18000.00),  -- F4: consulta con especialista
(5, 10, 1, 17000.00),  -- F5: consulta nutricional
(6,  2, 1, 18000.00),  -- F6: especialista (cardio)
(6,  4, 1, 22000.00),  -- F6: electrocardiograma
(7,  2, 1, 18000.00),  -- F7: especialista (traumato)
(8,  7, 1, 20000.00),  -- F8: control ginecológico
(9,  2, 1, 18000.00),  -- F9: especialista (neuro)
(9,  5, 1, 14000.00),  -- F9: laboratorio
(10, 1, 1, 12000.00);  -- F10: consulta clínica


-- ============================================================
-- 14. ACTUALIZACIÓN DE LA TABLA DE HECHOS
-- ------------------------------------------------------------
-- El trigger after_insert_historia pobló HECHOS_ATENCIONES
-- con los datos básicos de cada consulta. Aquí se completan
-- los campos que el trigger no conoce al momento del insert:
--   - cant_prescripciones: se calcula desde PRESCRIPCIONES
--   - monto_facturado: se calcula desde FACTURAS por
--     paciente + fecha
-- ============================================================

-- Actualizar cantidad de prescripciones por historia
UPDATE HECHOS_ATENCIONES h
JOIN HISTORIAS_CLINICAS hc
  ON h.id_paciente = hc.id_paciente
 AND h.fecha_atencion = DATE(hc.fecha_consulta)
SET h.cant_prescripciones = (
    SELECT COUNT(*) FROM PRESCRIPCIONES pr WHERE pr.id_historia = hc.id_historia
);

-- Actualizar monto facturado por paciente y fecha
UPDATE HECHOS_ATENCIONES h
JOIN (
    SELECT id_paciente, fac_fecha_emision, SUM(fac_total) AS total
    FROM FACTURAS
    GROUP BY id_paciente, fac_fecha_emision
) f ON h.id_paciente = f.id_paciente
   AND h.fecha_atencion = f.fac_fecha_emision
SET h.monto_facturado = f.total;


-- ============================================================
-- FIN DEL SCRIPT DE DATOS
-- ============================================================
-- Siguiente paso (opcional): ejecutar
-- tpfinal_informes_FedericoOscarGiglio.sql para ver los
-- reportes analíticos sobre los datos cargados.
-- ============================================================
