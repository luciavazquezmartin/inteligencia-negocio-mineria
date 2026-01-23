-- ============================================================================
-- SCRIPT DE CONSULTAS
-- ============================================================================

-- 1. Análisis de pasajeros por categoría (VIP vs Estándar)
SELECT 
    p.categoria_cliente,
    COUNT(DISTINCT p.id_pasajero) as total_pasajeros,
    COUNT(DISTINCT v.codigo_vuelo) as total_vuelos,
    ROUND(AVG(v.distancia_km), 2) as distancia_promedio,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio,
    ROUND(AVG(v.tiempo_real_minutos), 2) as duracion_promedio
FROM PASAJERO p
JOIN GRUPO_PASAJEROS gp ON p.id_pasajero = gp.id_pasajero
JOIN VUELO v ON gp.id_grupo = v.id_grupo
GROUP BY p.categoria_cliente
ORDER BY total_vuelos DESC;

-- 2. Tamaño de grupos de pasajeros y su relación con los vuelos
SELECT 
    CASE 
        WHEN num_pasajeros = 1 THEN 'Individual'
        WHEN num_pasajeros = 2 THEN 'Pareja'
        WHEN num_pasajeros BETWEEN 3 AND 4 THEN 'Familia pequeña'
        WHEN num_pasajeros >= 5 THEN 'Familia grande'
    END as tipo_grupo,
    COUNT(*) as cantidad_grupos,
    ROUND(AVG(v.distancia_km), 2) as distancia_promedio,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio
FROM (
    SELECT 
        g.id_grupo,
        COUNT(gp.id_pasajero) as num_pasajeros
    FROM GRUPO g
    JOIN GRUPO_PASAJEROS gp ON g.id_grupo = gp.id_grupo
    GROUP BY g.id_grupo
) grupos
JOIN VUELO v ON grupos.id_grupo = v.id_grupo
GROUP BY 
    CASE 
        WHEN num_pasajeros = 1 THEN 'Individual'
        WHEN num_pasajeros = 2 THEN 'Pareja'
        WHEN num_pasajeros BETWEEN 3 AND 4 THEN 'Grupo pequeño'
        WHEN num_pasajeros >= 5 THEN 'Grupo grande'
    END
ORDER BY cantidad_grupos DESC;

-- 3. Pasajeros más frecuentes y sus patrones de viaje
SELECT 
    p.nombre,
    p.apellido1,
    p.categoria_cliente,
    p.nacionalidad,
    COUNT(DISTINCT v.codigo_vuelo) as vuelos_realizados,
    ROUND(SUM(v.distancia_km), 2) as distancia_total,
    ROUND(AVG(v.distancia_km), 2) as distancia_promedio,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio_experimentado
FROM PASAJERO p
JOIN GRUPO_PASAJEROS gp ON p.id_pasajero = gp.id_pasajero
JOIN VUELO v ON gp.id_grupo = v.id_grupo
GROUP BY p.id_pasajero, p.nombre, p.apellido1, p.categoria_cliente, p.nacionalidad
HAVING COUNT(DISTINCT v.codigo_vuelo) > 1
ORDER BY vuelos_realizados DESC, distancia_total DESC;

-- 4. Análisis de nacionalidades de pasajeros y destinos preferidos
SELECT 
    p.nacionalidad,
    COUNT(DISTINCT p.id_pasajero) as total_pasajeros,
    COUNT(DISTINCT v.codigo_vuelo) as vuelos_totales,
    ao.region as region_origen_mas_comun,
    COUNT(*) as vuelos_desde_region,
    ROUND(AVG(v.distancia_km), 2) as distancia_promedio,
    ROUND(AVG(v.retardo_minutos), 2) as retraso_promedio
FROM PASAJERO p
JOIN GRUPO_PASAJEROS gp ON p.id_pasajero = gp.id_pasajero
JOIN VUELO v ON gp.id_grupo = v.id_grupo
JOIN AEROPUERTO ao ON v.id_aeropuerto_origen = ao.id_aeropuerto
GROUP BY p.nacionalidad, ao.region
HAVING COUNT(DISTINCT p.id_pasajero) >= 1
ORDER BY p.nacionalidad, vuelos_desde_region DESC;

COMMIT;