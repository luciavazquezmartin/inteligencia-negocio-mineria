-- ============================================================================
-- SCRIPT DE CONSULTAS PROPUESTAS 
-- ============================================================================

-- CONSULTA 1
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

-- CONSULTA 2
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

-- CONSULTA 3
SELECT 
    ap_origen.estado,
    ap_origen.ciudad,
    ap_destino.estado as estado_destino,
    COUNT(*) as total_vuelos,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio,
    ROUND(AVG(v.distancia_km), 2) as distancia_promedio,
    ROUND(SUM(v.distancia_km), 2) as distancia_total,
    GROUPING(ap_origen.estado) as grp_estado_origen,
    GROUPING(ap_origen.ciudad) as grp_ciudad_origen,
    GROUPING(ap_destino.estado) as grp_estado_destino
FROM VUELO v
JOIN AEROPUERTO ap_origen ON v.id_aeropuerto_origen = ap_origen.id_aeropuerto
JOIN AEROPUERTO ap_destino ON v.id_aeropuerto_destino = ap_destino.id_aeropuerto
GROUP BY GROUPING SETS (
    (ap_origen.estado, ap_origen.ciudad),  -- Vuelos por ciudad origen
    (ap_origen.estado, ap_destino.estado), -- Flujo entre estados
    (ap_origen.estado),                     -- Total por estado origen
    ()                                      -- Total general
)
ORDER BY grp_estado_origen, grp_ciudad_origen, grp_estado_destino;

-- CONSULTA 4
SELECT *
FROM (
    SELECT 
        ap_origen.ciudad || ' → ' || ap_destino.ciudad as ruta,
        ap_origen.ciudad as ciudad_origen,
        ap_destino.ciudad as ciudad_destino,
        COUNT(*) as total_vuelos,
        ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio,
        ROUND(AVG(v.distancia_km), 2) as distancia_km,
        ROUND(AVG(v.tiempo_real_minutos), 2) as duracion_promedio,
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) as ranking,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) as ranking_denso,
        ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 2) as porcentaje_trafico,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as pct_manual,
        PERCENT_RANK() OVER (ORDER BY COUNT(*)) as percentil
    FROM VUELO v
    JOIN AEROPUERTO ap_origen ON v.id_aeropuerto_origen = ap_origen.id_aeropuerto
    JOIN AEROPUERTO ap_destino ON v.id_aeropuerto_destino = ap_destino.id_aeropuerto
    GROUP BY ap_origen.ciudad, ap_destino.ciudad
)
WHERE ranking <= 3
ORDER BY ranking;

-- CONSULTA 5
SELECT 
    a.nombre_aerolinea,
    av.fabricante,
    av.nombre_modelo,
    h.franja_horaria,
    COUNT(*) as total_vuelos,
    ROUND(AVG(v.distancia_km / NULLIF(v.tiempo_real_minutos, 0) * 60), 2) as velocidad_promedio_kmh,
    ROUND(AVG(v.tiempo_real_minutos - v.tiempo_estimado_minutos), 2) as desviacion_tiempo,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio,
    ROUND(STDDEV(v.retardo_minutos), 2) as desviacion_std_retraso,
    GROUPING(a.nombre_aerolinea) as grp_aerolinea,
    GROUPING(av.fabricante) as grp_fabricante,
    GROUPING(av.nombre_modelo) as grp_modelo,
    GROUPING(h.franja_horaria) as grp_franja
FROM VUELO v
JOIN AEROLINEA a ON v.id_aerolinea = a.id_aerolinea
JOIN AVION av ON v.id_avion = av.id_avion
JOIN HORA h ON v.id_hora = h.id_hora
GROUP BY CUBE(a.nombre_aerolinea, av.fabricante, av.nombre_modelo, h.franja_horaria)
HAVING COUNT(*) >= 1
ORDER BY grp_aerolinea, grp_fabricante, grp_modelo, grp_franja, total_vuelos DESC;