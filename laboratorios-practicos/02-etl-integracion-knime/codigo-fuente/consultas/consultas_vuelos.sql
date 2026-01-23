-- ============================================================================
-- SCRIPT DE CONSULTAS
-- ============================================================================

-- 1. Aerolíneas con más de 1 vuelo, mostrando total de vuelos, retraso y duracion promedio y distancia total.
SELECT 
    a.nombre_aerolinea,
    COUNT(*) as total_vuelos,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio,
    ROUND(AVG(v.tiempo_real_minutos), 2) as duracion_promedio,
    ROUND(SUM(v.distancia_km), 2) as distancia_total_km
FROM VUELO v
JOIN AEROLINEA a ON v.id_aerolinea = a.id_aerolinea
GROUP BY a.nombre_aerolinea
HAVING COUNT(*) > 1
ORDER BY total_vuelos DESC;

-- 2. Análisis jerárquico por aerolínea y operadora
SELECT 
    a.nombre_aerolinea as aerolinea,
    o.nombre_operadora as operadora,
    COUNT(*) as num_vuelos,
    ROUND(SUM(v.distancia_km), 2) as distancia_total_km,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio,
    ROUND(AVG(v.tiempo_real_minutos), 2) as duracion_promedio
FROM VUELO v
JOIN AEROLINEA a ON v.id_aerolinea = a.id_aerolinea
JOIN OPERADORA o ON v.id_operadora = o.id_operadora
GROUP BY ROLLUP(a.nombre_aerolinea, o.nombre_operadora)
ORDER BY a.nombre_aerolinea NULLS LAST, o.nombre_operadora NULLS LAST;

-- 3. Análisis multidimensional por temporada y fin de semana
SELECT 
    f.temporada,
    f.es_fin_semana,
    COUNT(*) as total_vuelos,
    ROUND(AVG(v.tiempo_real_minutos), 2) as duracion_promedio,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio,
    ROUND(SUM(v.distancia_km), 2) as distancia_total,
    ROUND(AVG(v.tiempo_real_minutos - v.tiempo_estimado_minutos), 2) as diferencia_tiempo
FROM VUELO v
JOIN FECHA f ON v.id_fecha = f.id_fecha
GROUP BY CUBE(f.temporada, f.es_fin_semana)
ORDER BY f.temporada NULLS LAST, f.es_fin_semana NULLS LAST;

-- 4. Aeropuertos de ORIGEN con distancia promedio mayor a 600km
SELECT 
    ap.ciudad,
    ap.nombre_aeropuerto,
    COUNT(*) as num_vuelos,
    ROUND(AVG(v.distancia_km), 2) as distancia_promedio_km,
    ROUND(MIN(v.distancia_km), 2) as distancia_minima,
    ROUND(MAX(v.distancia_km), 2) as distancia_maxima,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio
FROM VUELO v
JOIN AEROPUERTO ap ON v.id_aeropuerto_origen = ap.id_aeropuerto
GROUP BY ap.ciudad, ap.nombre_aeropuerto
HAVING AVG(v.distancia_km) > 600
ORDER BY distancia_promedio_km DESC;

-- 5. Análisis por estado de ORIGEN (DRILL DOWN Nivel 1)
SELECT 
    ap.estado,
    COUNT(*) as total_vuelos,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio,
    ROUND(SUM(v.distancia_km), 2) as distancia_total,
    ROUND(AVG(v.tiempo_real_minutos), 2) as duracion_promedio
FROM VUELO v
JOIN AEROPUERTO ap ON v.id_aeropuerto_origen = ap.id_aeropuerto
GROUP BY ap.estado
ORDER BY total_vuelos DESC;

-- 6. Análisis por estado → ciudad de ORIGEN (DRILL DOWN Nivel 2)
SELECT 
    ap.estado,
    ap.ciudad,
    COUNT(*) as total_vuelos,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio,
    ROUND(SUM(v.distancia_km), 2) as distancia_total,
    ROUND(AVG(v.tiempo_real_minutos), 2) as duracion_promedio
FROM VUELO v
JOIN AEROPUERTO ap ON v.id_aeropuerto_origen = ap.id_aeropuerto
GROUP BY ap.estado, ap.ciudad
ORDER BY ap.estado, total_vuelos DESC;

-- 7. Análisis por estado → ciudad → aeropuerto de ORIGEN (DRILL DOWN Nivel 3)
SELECT 
    ap.estado,
    ap.ciudad,
    ap.nombre_aeropuerto,
    COUNT(*) as total_vuelos,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio,
    ROUND(SUM(v.distancia_km), 2) as distancia_total
FROM VUELO v
JOIN AEROPUERTO ap ON v.id_aeropuerto_origen = ap.id_aeropuerto
GROUP BY ap.estado, ap.ciudad, ap.nombre_aeropuerto
ORDER BY ap.estado, ap.ciudad, total_vuelos DESC;

-- 8. Análisis jerárquico año → trimestre → mes
SELECT 
    f.agno,
    f.trimestre,
    f.nombre_mes,
    COUNT(*) as num_vuelos,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio,
    ROUND(SUM(v.distancia_km), 2) as km_totales,
    ROUND(AVG(v.tiempo_real_minutos), 2) as duracion_promedio
FROM VUELO v
JOIN FECHA f ON v.id_fecha = f.id_fecha
GROUP BY ROLLUP(f.agno, f.trimestre, f.nombre_mes)
ORDER BY f.agno NULLS LAST, f.trimestre NULLS LAST, f.nombre_mes NULLS LAST;

-- 9. Análisis multidimensional de vuelos por hora y fines de semana
SELECT 
    h.franja_horaria,
    f.es_fin_semana,
    COUNT(*) as total_vuelos,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio,
    ROUND(AVG(v.tiempo_real_minutos - v.tiempo_estimado_minutos), 2) as diferencia_tiempo,
    ROUND(SUM(v.distancia_km), 2) as distancia_total,
    ROUND(AVG(v.distancia_km), 2) as distancia_promedio
FROM VUELO v
JOIN HORA h ON v.id_hora = h.id_hora
JOIN FECHA f ON v.id_fecha = f.id_fecha
GROUP BY CUBE(h.franja_horaria, f.es_fin_semana)
ORDER BY h.franja_horaria NULLS LAST, f.es_fin_semana NULLS LAST;

-- 10. Modelos con más de 1 vuelo y más modernos
SELECT 
    av.fabricante,
    av.nombre_modelo,
    av.capacidad_maxima,
    av.agno_fabricacion,
    COUNT(*) as vuelos_realizados,
    ROUND(AVG(v.distancia_km), 2) as distancia_promedio,
    ROUND(AVG(v.tiempo_real_minutos), 2) as duracion_real_promedio,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio,
    ROUND(AVG(v.distancia_km / v.tiempo_real_minutos * 60), 2) as velocidad_efectiva_kmh,
    ROUND(SUM(v.distancia_km), 2) as distancia_total_recorrida
FROM VUELO v
JOIN AVION av ON v.id_avion = av.id_avion
GROUP BY av.fabricante, av.nombre_modelo, av.capacidad_maxima, av.agno_fabricacion
HAVING COUNT(*) > 1
ORDER BY vuelos_realizados DESC, distancia_promedio DESC;


COMMIT;