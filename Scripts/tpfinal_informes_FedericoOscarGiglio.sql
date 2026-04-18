-- ============================================================
-- PROYECTO: Sistema de Gestión Hospitalaria (SGH)
-- ARCHIVO:  tpfinal_informes_FedericoOscarGiglio.sql
-- AUTOR:    Federico Oscar Giglio
-- FECHA:    2026
-- ENTREGA:  Trabajo Práctico Final - Base de Datos
-- ============================================================
-- DESCRIPCIÓN:
-- Consultas de informes y reportes analíticos sobre los datos
-- cargados en la base SistemaHospital. Se utilizan vistas,
-- funciones y la tabla de hechos para demostrar el valor
-- analítico del modelo.
--
-- PREREQUISITOS:
--   1) tpfinal_estructura_FedericoOscarGiglio.sql
--   2) tpfinal_datos_FedericoOscarGiglio.sql
-- ============================================================

USE SistemaHospital;


-- ============================================================
-- INFORME 1: AGENDA OPERATIVA DEL DÍA
-- ------------------------------------------------------------
-- Utiliza la vista v_turnos_completos. Muestra los turnos
-- pendientes/confirmados ordenados por fecha y hora. Es la
-- consulta diaria típica de recepción.
-- ============================================================
SELECT 
    fecha, hora, estado, paciente, medico, especialidad, consultorio
FROM v_turnos_completos
WHERE estado IN ('Pendiente', 'Confirmado')
ORDER BY fecha, hora;


-- ============================================================
-- INFORME 2: DISTRIBUCIÓN DE PACIENTES POR OBRA SOCIAL
-- ------------------------------------------------------------
-- Cuántos pacientes tiene cada prestadora. Útil para
-- análisis comercial y renegociación de convenios.
-- ============================================================
SELECT 
    os.os_nombre        AS obra_social,
    COUNT(p.id_paciente) AS cantidad_pacientes,
    ROUND(COUNT(p.id_paciente) * 100.0 / 
          (SELECT COUNT(*) FROM PACIENTES), 2) AS porcentaje
FROM OBRAS_SOCIALES os
LEFT JOIN PACIENTES p ON p.id_os = os.id_os
GROUP BY os.id_os, os.os_nombre
ORDER BY cantidad_pacientes DESC;


-- ============================================================
-- INFORME 3: PRODUCTIVIDAD MÉDICA (TOP 5)
-- ------------------------------------------------------------
-- Ranking de los 5 médicos con mayor carga de consultas
-- registradas. Utiliza la vista v_productividad_medicos.
-- ============================================================
SELECT 
    medico, especialidad, total_turnos, total_consultas, minutos_atendidos
FROM v_productividad_medicos
ORDER BY total_consultas DESC, total_turnos DESC
LIMIT 5;


-- ============================================================
-- INFORME 4: FACTURACIÓN POR OBRA SOCIAL
-- ------------------------------------------------------------
-- Monto facturado y cantidad de facturas por prestadora.
-- Usa la vista v_facturacion_por_os.
-- ============================================================
SELECT 
    obra_social, 
    cant_facturas, 
    total_facturado,
    ROUND(total_facturado / NULLIF(cant_facturas,0), 2) AS ticket_promedio
FROM v_facturacion_por_os;


-- ============================================================
-- INFORME 5: ESPECIALIDADES MÁS DEMANDADAS
-- ------------------------------------------------------------
-- Ranking de especialidades según la cantidad de atenciones
-- realizadas. Utiliza la tabla de HECHOS.
-- ============================================================
SELECT 
    especialidad, 
    cant_atenciones, 
    promedio_minutos, 
    monto_total,
    edad_promedio
FROM v_resumen_atenciones;


-- ============================================================
-- INFORME 6: EDAD DE LOS PACIENTES
-- ------------------------------------------------------------
-- Utiliza la función calcular_edad para armar un perfil
-- demográfico. Permite segmentar por rangos etarios.
-- ============================================================
SELECT 
    CONCAT(pac_nombre, ' ', pac_apellido) AS paciente,
    calcular_edad(pac_fecha_nac)          AS edad,
    CASE
        WHEN calcular_edad(pac_fecha_nac) < 18 THEN 'Pediátrico'
        WHEN calcular_edad(pac_fecha_nac) BETWEEN 18 AND 39 THEN 'Adulto joven'
        WHEN calcular_edad(pac_fecha_nac) BETWEEN 40 AND 64 THEN 'Adulto'
        ELSE 'Adulto mayor'
    END AS segmento_etario
FROM PACIENTES
ORDER BY edad DESC;


-- ============================================================
-- INFORME 7: RECUENTO DE TURNOS POR MÉDICO
-- ------------------------------------------------------------
-- Utiliza la función contar_turnos_medico.
-- ============================================================
SELECT 
    CONCAT(med_nombre, ' ', med_apellido) AS medico,
    contar_turnos_medico(id_medico)       AS total_turnos
FROM MEDICOS
ORDER BY total_turnos DESC;


-- ============================================================
-- INFORME 8: PACIENTES CON FACTURACIÓN HISTÓRICA
-- ------------------------------------------------------------
-- Usa la función monto_facturado_paciente.
-- ============================================================
SELECT 
    CONCAT(pac_nombre, ' ', pac_apellido) AS paciente,
    monto_facturado_paciente(id_paciente) AS facturacion_total
FROM PACIENTES
ORDER BY facturacion_total DESC;


-- ============================================================
-- INFORME 9: PRESCRIPCIONES POR MEDICAMENTO
-- ------------------------------------------------------------
-- Los medicamentos más prescritos. Insumo clave para
-- gestión de stock y convenios con farmacia.
-- ============================================================
SELECT 
    m.med_nombre_comercial AS medicamento,
    m.med_droga            AS droga,
    COUNT(pr.id_prescripcion) AS veces_prescripto
FROM MEDICAMENTOS m
LEFT JOIN PRESCRIPCIONES pr ON pr.id_medicamento = m.id_medicamento
GROUP BY m.id_medicamento, m.med_nombre_comercial, m.med_droga
HAVING veces_prescripto > 0
ORDER BY veces_prescripto DESC;


-- ============================================================
-- INFORME 10: AUDITORÍA DE CANCELACIONES
-- ------------------------------------------------------------
-- Listado de turnos cancelados con su fecha de cancelación,
-- paciente afectado y médico involucrado.
-- ============================================================
SELECT 
    ac.id_auditoria,
    ac.id_turno,
    ac.fecha_cancelacion,
    CONCAT(p.pac_nombre, ' ', p.pac_apellido) AS paciente,
    CONCAT(m.med_nombre, ' ', m.med_apellido) AS medico,
    t.fecha AS fecha_turno_original
FROM AUDITORIA_CANCELACIONES ac
JOIN TURNOS t    ON ac.id_turno   = t.id_turno
JOIN PACIENTES p ON t.id_paciente = p.id_paciente
JOIN MEDICOS   m ON t.id_medico   = m.id_medico
ORDER BY ac.fecha_cancelacion DESC;


-- ============================================================
-- INFORME 11: ANÁLISIS MENSUAL DE ATENCIONES
-- ------------------------------------------------------------
-- Serie temporal: atenciones y facturación por mes.
-- Usa la tabla de HECHOS.
-- ============================================================
SELECT 
    DATE_FORMAT(fecha_atencion, '%Y-%m') AS periodo,
    COUNT(*)                             AS cant_atenciones,
    SUM(monto_facturado)                 AS facturacion_mes,
    ROUND(AVG(duracion_consulta_min), 1) AS duracion_promedio
FROM HECHOS_ATENCIONES
GROUP BY periodo
ORDER BY periodo;


-- ============================================================
-- INFORME 12: PACIENTES QUE NUNCA TUVIERON TURNO
-- ------------------------------------------------------------
-- Identifica pacientes "fantasma": se dieron de alta pero
-- no utilizaron el servicio.
-- ============================================================
SELECT 
    p.id_paciente,
    CONCAT(p.pac_nombre, ' ', p.pac_apellido) AS paciente,
    p.pac_dni
FROM PACIENTES p
LEFT JOIN TURNOS t ON p.id_paciente = t.id_paciente
WHERE t.id_turno IS NULL;


-- ============================================================
-- INFORME 13: CRUCE ESPECIALIDAD × OBRA SOCIAL
-- ------------------------------------------------------------
-- Tabla cruzada (pivot) útil para analítica. Muestra cuántas
-- atenciones generó cada combinación.
-- ============================================================
SELECT 
    e.esp_nombre  AS especialidad,
    os.os_nombre  AS obra_social,
    COUNT(h.id_hecho) AS atenciones,
    COALESCE(SUM(h.monto_facturado), 0) AS facturado
FROM HECHOS_ATENCIONES h
JOIN ESPECIALIDADES    e  ON h.id_especialidad = e.id_espec
LEFT JOIN OBRAS_SOCIALES os ON h.id_obra_social = os.id_os
GROUP BY e.esp_nombre, os.os_nombre
ORDER BY atenciones DESC, facturado DESC;


-- ============================================================
-- DEMOSTRACIÓN DE STORED PROCEDURES
-- ============================================================
-- Ejemplos de uso de los SPs definidos en el script de
-- estructura. Descomentar para ejecutar.
-- ============================================================

-- CALL registrar_turno('2026-04-15', '10:00:00', 1, 1, 3);

-- CALL agregar_historia_clinica(1, 1, 
--     'Control post-tratamiento. Mejora evidente.', 
--     'Continuar medicación 15 días más.', 
--     20);

-- CALL generar_factura('A-0001-00000011', 1, 1, 1, 1);

-- CALL cancelar_turno(9);
-- SELECT * FROM AUDITORIA_CANCELACIONES;  -- verifica trigger

-- ============================================================
-- FIN DEL SCRIPT DE INFORMES
-- ============================================================
