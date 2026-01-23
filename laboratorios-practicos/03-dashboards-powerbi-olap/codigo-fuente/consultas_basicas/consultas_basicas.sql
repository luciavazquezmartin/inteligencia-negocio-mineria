-- ============================================================================
-- SCRIPT DE CONSULTAS BÁSICAS
-- ============================================================================

-- CONSULTA 1
SELECT 
    t1.aeropuerto_origen,
    t1.ciudad_destino,
    t1.retraso_medio_minutos,
    t2.retraso_total_aeropuerto
FROM (
    -- Retraso medio por ruta (aeropuerto origen -> ciudad destino)
    SELECT 
        ao.id_aeropuerto,
        ao.codigo_IATA AS codigo_iata_origen,
        ao.nombre_aeropuerto AS aeropuerto_origen,
        ao.ciudad AS ciudad_origen,
        ad.ciudad AS ciudad_destino,
        ROUND(AVG(v.retardo_minutos), 2) AS retraso_medio_minutos
    FROM VUELO v
        INNER JOIN AEROPUERTO ao ON v.id_aeropuerto_origen = ao.id_aeropuerto
        INNER JOIN AEROPUERTO ad ON v.id_aeropuerto_destino = ad.id_aeropuerto
    GROUP BY ao.id_aeropuerto, ao.codigo_IATA, ao.nombre_aeropuerto, ao.ciudad, ad.id_aeropuerto, ad.ciudad
) t1
INNER JOIN (
    -- Retraso medio total por aeropuerto origen (independiente del destino)
    SELECT 
        ao.id_aeropuerto,
        ROUND(AVG(v.retardo_minutos), 2) AS retraso_total_aeropuerto
    FROM VUELO v
        INNER JOIN AEROPUERTO ao ON v.id_aeropuerto_origen = ao.id_aeropuerto
    GROUP BY ao.id_aeropuerto
) t2 ON t1.id_aeropuerto = t2.id_aeropuerto
ORDER BY t1.aeropuerto_origen, t1.ciudad_destino;

-- CONSULTA 2
SELECT 
    t1.aeropuerto_origen,
    t1.ciudad_destino,
    t1.retraso_medio_ruta,
    t2.retraso_total_aeropuerto,
    t3.retraso_total_destino
FROM (
    -- Retraso medio por ruta (aeropuerto origen -> ciudad destino)
    SELECT 
        ao.id_aeropuerto AS id_aeropuerto_origen,
        ao.codigo_IATA AS codigo_iata_origen,
        ao.nombre_aeropuerto AS aeropuerto_origen,
        ao.ciudad AS ciudad_origen,
        ad.id_aeropuerto AS id_aeropuerto_destino,
        ad.ciudad AS ciudad_destino,
        ROUND(AVG(v.retardo_minutos), 2) AS retraso_medio_ruta
    FROM VUELO v
        INNER JOIN AEROPUERTO ao ON v.id_aeropuerto_origen = ao.id_aeropuerto
        INNER JOIN AEROPUERTO ad ON v.id_aeropuerto_destino = ad.id_aeropuerto
    GROUP BY ao.id_aeropuerto, ao.codigo_IATA, ao.nombre_aeropuerto, ao.ciudad, ad.id_aeropuerto, ad.ciudad
) t1
INNER JOIN (
    -- Retraso medio total por aeropuerto origen (independiente del destino)
    SELECT 
        ao.id_aeropuerto,
        ROUND(AVG(v.retardo_minutos), 2) AS retraso_total_aeropuerto
    FROM VUELO v
        INNER JOIN AEROPUERTO ao ON v.id_aeropuerto_origen = ao.id_aeropuerto
    GROUP BY ao.id_aeropuerto
) t2 ON t1.id_aeropuerto_origen = t2.id_aeropuerto
INNER JOIN (
    -- Retraso medio total por ciudad destino (independiente del aeropuerto origen)
    SELECT 
        ad.ciudad,
        ROUND(AVG(v.retardo_minutos), 2) AS retraso_total_destino
    FROM VUELO v
        INNER JOIN AEROPUERTO ad ON v.id_aeropuerto_destino = ad.id_aeropuerto
    GROUP BY ad.ciudad
) t3 ON t1.ciudad_destino = t3.ciudad
ORDER BY t1.aeropuerto_origen, t1.ciudad_destino;