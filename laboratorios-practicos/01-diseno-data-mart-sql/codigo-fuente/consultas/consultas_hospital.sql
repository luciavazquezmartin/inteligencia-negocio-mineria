-- ============================================================================
-- SCRIPT DE CONSULTAS - MODELO HOSPITALARIO
-- ============================================================================

-- 1. Hospitales con más de 2 atenciones: rendimiento y costes
SELECT 
    h.nombre_hospital,
    h.tipo_hospital,
    h.ciudad,
    COUNT(*) as total_atenciones,
    ROUND(AVG(am.duracion_atencion_minutos), 2) as duracion_promedio,
    ROUND(AVG(am.tiempo_espera_minutos), 2) as espera_promedio,
    ROUND(SUM(am.coste_procedimiento), 2) as coste_total,
    ROUND(AVG(am.coste_procedimiento), 2) as coste_promedio
FROM ATENCION_MEDICA am
JOIN HOSPITAL h ON am.id_hospital = h.id_hospital
GROUP BY h.nombre_hospital, h.tipo_hospital, h.ciudad
HAVING COUNT(*) > 2
ORDER BY total_atenciones DESC, coste_total DESC;

-- 2. Análisis jerárquico por especialidad y categoría médica (ROLLUP)
SELECT 
    m.especialidad,
    m.categoria,
    COUNT(*) as num_atenciones,
    ROUND(AVG(am.duracion_atencion_minutos), 2) as duracion_promedio,
    ROUND(AVG(am.coste_procedimiento), 2) as coste_promedio,
    ROUND(SUM(am.coste_procedimiento), 2) as facturacion_total,
    ROUND(AVG(am.tiempo_espera_minutos), 2) as espera_promedio
FROM ATENCION_MEDICA am
JOIN MEDICO m ON am.id_medico = m.id_medico
GROUP BY ROLLUP(m.especialidad, m.categoria)
ORDER BY m.especialidad NULLS LAST, m.categoria NULLS LAST;

-- 3. Análisis multidimensional por tipo de seguro y gravedad (CUBE)
SELECT 
    p.tipo_seguro,
    d.gravedad,
    COUNT(*) as total_casos,
    ROUND(AVG(am.coste_procedimiento), 2) as coste_promedio,
    ROUND(AVG(am.duracion_atencion_minutos), 2) as duracion_promedio,
    ROUND(AVG(am.tiempo_espera_minutos), 2) as espera_promedio,
    ROUND(SUM(am.num_medicamentos_prescritos), 0) as medicamentos_totales
FROM ATENCION_MEDICA am
JOIN PACIENTE p ON am.id_paciente = p.id_paciente
JOIN DIAGNOSTICO d ON am.id_diagnostico = d.id_diagnostico
GROUP BY CUBE(p.tipo_seguro, d.gravedad)
ORDER BY p.tipo_seguro NULLS LAST, d.gravedad NULLS LAST;

-- 4. Servicios con coste promedio superior a 100€
SELECT 
    s.nombre_servicio,
    s.tipo_servicio,
    COUNT(*) as num_atenciones,
    ROUND(AVG(am.coste_procedimiento), 2) as coste_promedio,
    ROUND(MIN(am.coste_procedimiento), 2) as coste_minimo,
    ROUND(MAX(am.coste_procedimiento), 2) as coste_maximo,
    ROUND(AVG(am.duracion_atencion_minutos), 2) as duracion_promedio,
    ROUND(AVG(am.tiempo_espera_minutos), 2) as espera_promedio
FROM ATENCION_MEDICA am
JOIN SERVICIO s ON am.id_servicio = s.id_servicio
GROUP BY s.nombre_servicio, s.tipo_servicio
HAVING AVG(am.coste_procedimiento) > 100
ORDER BY coste_promedio DESC;

-- 5. Análisis temporal: temporada y franja horaria (CUBE)
SELECT 
    f.temporada,
    h.franja_horaria,
    COUNT(*) as total_atenciones,
    ROUND(AVG(am.tiempo_espera_minutos), 2) as espera_promedio,
    ROUND(AVG(am.duracion_atencion_minutos), 2) as duracion_promedio,
    ROUND(AVG(am.coste_procedimiento), 2) as coste_promedio,
    ROUND(SUM(am.num_medicamentos_prescritos), 0) as medicamentos_totales
FROM ATENCION_MEDICA am
JOIN FECHA f ON am.id_fecha = f.id_fecha
JOIN HORA h ON am.id_hora = h.id_hora
GROUP BY CUBE(f.temporada, h.franja_horaria)
ORDER BY f.temporada NULLS LAST, h.franja_horaria NULLS LAST;

COMMIT;