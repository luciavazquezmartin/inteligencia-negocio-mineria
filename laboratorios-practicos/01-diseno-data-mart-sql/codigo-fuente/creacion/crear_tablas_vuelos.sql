-- ============================================================================
-- SCRIPT DE CREACIÓN: MODELO VUELOS SIN INFORMACIÓN DE PASAJEROS
-- ============================================================================

-- Eliminar tablas en orden inverso de dependencias
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE VUELO CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE AEROLINEA CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE OPERADORA CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE AVION CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE AEROPUERTO CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE HORA CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE FECHA CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/

------------------------------ CREAR TABLAS DE DIMENSIONES ------------------------------

-- 1. FECHA (dimensión temporal - día)
CREATE TABLE FECHA (
    id_fecha INTEGER PRIMARY KEY,
    fecha_completa DATE UNIQUE NOT NULL, -- Clave Natural
    dia INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    agno INTEGER NOT NULL,
    nombre_dia VARCHAR2(20) NOT NULL,
    nombre_mes VARCHAR2(20) NOT NULL,
    semana_agno INTEGER NOT NULL,
    trimestre INTEGER NOT NULL,
    es_fin_semana VARCHAR2(20) NOT NULL CHECK (es_fin_semana IN ('es_fin_semana', 'no_es_fin_semana')),
    es_festivo VARCHAR2(20) NOT NULL CHECK (es_festivo IN ('es_festivo', 'no_es_festivo')),
    temporada VARCHAR2(20) NOT NULL CHECK (temporada IN ('primavera', 'verano', 'otogno', 'invierno'))
);

-- 2. HORA (dimensión temporal - momento exacto)
CREATE TABLE HORA (
    id_hora INTEGER PRIMARY KEY,
    hora_completa DATE UNIQUE NOT NULL, -- Clave Natural
    hora INTEGER NOT NULL,
    minuto INTEGER NOT NULL,
    segundo INTEGER NOT NULL,
    franja_horaria VARCHAR2(20) NOT NULL CHECK (franja_horaria IN ('00:00 - 04:59','05:00 - 11:59','12:00 - 19:59','20:00 - 23:59')),
    es_hora_punta VARCHAR2(20) NOT NULL CHECK (es_hora_punta IN ('es_hora_punta', 'no_es_hora_punta'))
);

-- 3. AEROPUERTO (dimensión geográfica)
CREATE TABLE AEROPUERTO (
    id_aeropuerto INTEGER PRIMARY KEY,
    codigo_ICAO VARCHAR2(50) UNIQUE NOT NULL, -- Clave Natural
    nombre_aeropuerto VARCHAR2(100) NOT NULL,
    ciudad VARCHAR2(100) NOT NULL,
    estado VARCHAR2(100) NOT NULL,
    codigo_estado VARCHAR2(50) NOT NULL,
    region VARCHAR2(100) NOT NULL,
    pais VARCHAR2(100) NOT NULL,
    latitud REAL NOT NULL,
    longitud REAL NOT NULL,
    altitud REAL NOT NULL,
    zona_horaria VARCHAR2(50) NOT NULL,
    tipo_aeropuerto VARCHAR2(20) NOT NULL CHECK (tipo_aeropuerto IN ('internacional', 'nacional', 'regional'))
);

-- 4. AVION (dimensión de aeronaves)
CREATE TABLE AVION (
    id_avion INTEGER PRIMARY KEY,
    matricula VARCHAR2(50) UNIQUE NOT NULL, -- Clave Natural
    codigo_modelo VARCHAR2(50) NOT NULL,
    nombre_modelo VARCHAR2(100) NOT NULL,
    fabricante VARCHAR2(100) NOT NULL,
    tipo_de_motor VARCHAR2(50) NOT NULL,
    num_motores INTEGER NOT NULL,
    num_asientos INTEGER NOT NULL,
    velocidad_maxima REAL NOT NULL,
    agno_fabricacion INTEGER NOT NULL,
    agno_comienzo_uso INTEGER NOT NULL,
    esta_activo VARCHAR2(20) NOT NULL CHECK (esta_activo IN ('esta_activo', 'no_esta_activo'))
);

-- 5. OPERADORA (dimensión de compañías operadoras)
CREATE TABLE OPERADORA (
    id_operadora INTEGER PRIMARY KEY,
    codigo_ICAO VARCHAR2(50) UNIQUE NOT NULL, -- Clave Natural
    nombre_operadora VARCHAR2(100) NOT NULL,
    pais_origen VARCHAR2(100) NOT NULL,
    agno_fundacion VARCHAR2(50) NOT NULL,
    esta_activo VARCHAR2(20) NOT NULL CHECK (esta_activo IN ('esta_activo', 'no_esta_activo'))
);

-- 6. AEROLINEA (dimensión de aerolíneas comerciales)
CREATE TABLE AEROLINEA (
    id_aerolinea INTEGER PRIMARY KEY,
    codigo_ICAO VARCHAR2(50) UNIQUE NOT NULL, -- Clave Natural
    nombre_aerolinea VARCHAR2(100) NOT NULL,
    nombre_comercial VARCHAR2(100) NOT NULL,
    pais_origen VARCHAR2(100) NOT NULL,
    tipo_aerolinea VARCHAR2(20) NOT NULL CHECK (tipo_aerolinea IN ('internacional', 'nacional', 'regional')),
    agno_fundacion INTEGER NOT NULL,
    esta_activo VARCHAR2(20) NOT NULL CHECK (esta_activo IN ('esta_activo', 'no_esta_activo'))
);

------------------------------ CREAR TABLA DE HECHOS ------------------------------

-- 7. VUELO 
CREATE TABLE VUELO (
    codigo_vuelo VARCHAR2(50) NOT NULL,
    id_fecha INTEGER NOT NULL,
    id_hora INTEGER NOT NULL,
    id_avion INTEGER NOT NULL,
    id_aeropuerto_origen INTEGER NOT NULL,      
    id_aeropuerto_destino INTEGER NOT NULL,     
    id_aerolinea INTEGER NOT NULL,
    id_operadora INTEGER NOT NULL,
    tiempo_estimado_minutos REAL NOT NULL,
    tiempo_real_minutos REAL NOT NULL,
    retardo_minutos REAL NOT NULL,
    distancia_km REAL NOT NULL,
    PRIMARY KEY (codigo_vuelo, id_fecha),
    FOREIGN KEY (id_avion) REFERENCES AVION(id_avion) ON DELETE CASCADE,
    FOREIGN KEY (id_fecha) REFERENCES FECHA(id_fecha) ON DELETE CASCADE,
    FOREIGN KEY (id_hora) REFERENCES HORA(id_hora) ON DELETE CASCADE,
    FOREIGN KEY (id_aeropuerto_origen) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE,   -- ✅
    FOREIGN KEY (id_aeropuerto_destino) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE,  -- ✅
    FOREIGN KEY (id_aerolinea) REFERENCES AEROLINEA(id_aerolinea) ON DELETE CASCADE,
    FOREIGN KEY (id_operadora) REFERENCES OPERADORA(id_operadora) ON DELETE CASCADE,
    CONSTRAINT chk_tiempo_positivo CHECK (tiempo_estimado_minutos > 0 AND tiempo_real_minutos > 0),
    CONSTRAINT chk_distancia_positiva CHECK (distancia_km > 0),
    CONSTRAINT chk_retardo_no_negativo CHECK (retardo_minutos >= 0),
    CONSTRAINT chk_aeropuertos_diferentes CHECK (id_aeropuerto_origen != id_aeropuerto_destino)  -- ✅
);

COMMIT;

