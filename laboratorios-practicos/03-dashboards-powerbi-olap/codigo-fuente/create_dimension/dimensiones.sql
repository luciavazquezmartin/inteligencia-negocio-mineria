-- ===================================================
-- SCRIPT: dimensiones.sql
-- Descripción: Crea dimensiones, índices y ejecuta consulta
-- Se puede ejecutar múltiples veces
-- ===================================================

-- ELIMINACIÓN DE DIMENSIONES EXISTENTES
BEGIN
    EXECUTE IMMEDIATE 'DROP DIMENSION dim_fecha';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN -- ORA-02289: dimension does not exist
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP DIMENSION dim_aeropuerto';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP DIMENSION dim_aerolinea';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP DIMENSION dim_operadora';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP DIMENSION dim_avion';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP DIMENSION dim_hora';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

-- ELIMINACIÓN DE ÍNDICES EXISTENTES
BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_vuelo_fecha';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1418 THEN -- ORA-01418: index does not exist
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_vuelo_hora';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1418 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_vuelo_avion';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1418 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_vuelo_aerolinea';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1418 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_vuelo_operadora';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1418 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_vuelo_aero_origen';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1418 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_vuelo_aero_destino';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1418 THEN
            RAISE;
        END IF;
END;
/

-- ===================================================
-- CREACIÓN DE DIMENSIONES
-- ===================================================

-- 1. DIMENSIÓN FECHA
CREATE DIMENSION dim_fecha
LEVEL fecha IS FECHA.id_fecha
LEVEL mes IS FECHA.mes
LEVEL trimestre IS FECHA.trimestre
LEVEL año IS FECHA.agno
HIERARCHY jerarquia_temporal (
    fecha CHILD OF mes CHILD OF trimestre CHILD OF año
)
ATTRIBUTE fecha DETERMINES (
    FECHA.fecha_completa,
    FECHA.dia,
    FECHA.nombre_dia,
    FECHA.nombre_mes,
    FECHA.es_fin_semana,
    FECHA.temporada
);

-- 2. DIMENSIÓN AEROPUERTO
CREATE DIMENSION dim_aeropuerto
LEVEL aeropuerto IS AEROPUERTO.id_aeropuerto
LEVEL ciudad IS AEROPUERTO.ciudad
LEVEL estado IS AEROPUERTO.estado
LEVEL pais IS AEROPUERTO.pais
HIERARCHY jerarquia_geografica (
    aeropuerto CHILD OF ciudad CHILD OF estado CHILD OF pais
)
ATTRIBUTE aeropuerto DETERMINES (
    AEROPUERTO.codigo_IATA,
    AEROPUERTO.nombre_aeropuerto,
    AEROPUERTO.latitud,
    AEROPUERTO.longitud,
    AEROPUERTO.num_habitantes,
    AEROPUERTO.zona_horaria,
    AEROPUERTO.codigo_estado
);

-- 3. DIMENSIÓN AEROLINEA
CREATE DIMENSION dim_aerolinea
LEVEL aerolinea IS AEROLINEA.id_aerolinea
ATTRIBUTE aerolinea DETERMINES (
    AEROLINEA.codigo_DOT,
    AEROLINEA.nombre_aerolinea,
    AEROLINEA.esta_activo
);

-- 4. DIMENSIÓN OPERADORA
CREATE DIMENSION dim_operadora
LEVEL operadora IS OPERADORA.id_operadora
ATTRIBUTE operadora DETERMINES (
    OPERADORA.codigo_IATA,
    OPERADORA.nombre_operadora,
    OPERADORA.esta_activo
);

-- 5. DIMENSIÓN AVION
CREATE DIMENSION dim_avion
LEVEL avion IS AVION.id_avion
LEVEL modelo IS AVION.nombre_modelo
LEVEL fabricante IS AVION.fabricante
HIERARCHY jerarquia_aviones (
    avion CHILD OF modelo CHILD OF fabricante
)
ATTRIBUTE avion DETERMINES (
    AVION.matricula,
    AVION.codigo_modelo,
    AVION.capacidad_maxima,
    AVION.agno_fabricacion,
    AVION.esta_activo
);

-- 6. DIMENSIÓN HORA
CREATE DIMENSION dim_hora
LEVEL hora IS HORA.id_hora
LEVEL franja IS HORA.franja_horaria
HIERARCHY jerarquia_temporal_hora (
    hora CHILD OF franja
)
ATTRIBUTE hora DETERMINES (
    HORA.hora_completa,
    HORA.hora,
    HORA.minuto,
    HORA.segundo,
    HORA.es_hora_punta
);

-- ===================================================
-- CREACIÓN DE ÍNDICES
-- ===================================================

CREATE INDEX idx_vuelo_fecha ON VUELO(id_fecha);
CREATE INDEX idx_vuelo_hora ON VUELO(id_hora);
CREATE INDEX idx_vuelo_avion ON VUELO(id_avion);
CREATE INDEX idx_vuelo_aerolinea ON VUELO(id_aerolinea);
CREATE INDEX idx_vuelo_operadora ON VUELO(id_operadora);
CREATE INDEX idx_vuelo_aero_origen ON VUELO(id_aeropuerto_origen);
CREATE INDEX idx_vuelo_aero_destino ON VUELO(id_aeropuerto_destino);

-- ===================================================
-- CONSULTA DE PRUEBA
-- ===================================================

SELECT
    ap_origen.estado,
    f.nombre_mes,
    COUNT(*) as total_vuelos,
    AVG(v.retardo_minutos) as retraso_promedio
FROM VUELO v
JOIN AEROPUERTO ap_origen ON v.id_aeropuerto_origen = ap_origen.id_aeropuerto
JOIN FECHA f ON v.id_fecha = f.id_fecha
WHERE ap_origen.estado IN ('California', 'Texas', 'Florida')
  AND f.trimestre = 1
GROUP BY ap_origen.estado, f.nombre_mes;
