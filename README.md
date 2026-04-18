# SistemaHospitalarioSQL-OscarGiglioFederico

Sistema de Gestión Hospitalaria (SGH)

Proyecto de la cursada de Base de Datos SQL (UTN). Diseño y desarrollo 
de una base de datos relacional para una clínica privada de mediana 
complejidad.

## Organización del Repositorio

- **scripts/** → Scripts SQL del proyecto
  - `tpfinal_estructura_...sql` → DDL + vistas + funciones + SPs + triggers
  - `tpfinal_datos_...sql` → Poblado de todas las tablas
  - `tpfinal_informes_...sql` → 13 consultas analíticas
- **Docs/** → Documentación PDF del proyecto
- **Img/** → Diagrama Entidad-Relación

## Orden de ejecución

1. `scripts/tpfinal_estructura_FedericoOscarGiglio.sql`
2. `scripts/tpfinal_datos_FedericoOscarGiglio.sql`
3. `scripts/tpfinal_informes_FedericoOscarGiglio.sql` (opcional)

## Características

- 16 tablas (1 de hechos, 2 transaccionales, 1 de auditoría, 12 entidades/catálogo)
- 6 vistas, 3 funciones, 4 stored procedures, 3 triggers
- Tabla de hechos poblada automáticamente vía trigger
- Stored procedure con transacción para facturación
