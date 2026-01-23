-- ============================================================================
-- SCRIPT DE CREACIÓN: MODELO EN ESTRELLA SISTEMA HOSPITALARIO
-- ============================================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ATENCION_MEDICA CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PROCEDIMIENTO CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DIAGNOSTICO CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE SERVICIO CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PACIENTE CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE MEDICO CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE HOSPITAL CASCADE CONSTRAINTS';
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
-- 1. FECHA 
CREATE TABLE FECHA (
    id_fecha INTEGER PRIMARY KEY,
    fecha_completa DATE UNIQUE NOT NULL,
    dia INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    agno INTEGER NOT NULL,
    nombre_dia VARCHAR2(20) NOT NULL,
    nombre_mes VARCHAR2(20) NOT NULL,
    semana_agno INTEGER NOT NULL,
    trimestre INTEGER NOT NULL,
    es_fin_semana VARCHAR2(20) NOT NULL CHECK (es_fin_semana IN ('es_fin_semana', 'no_es_fin_semana')),
    es_festivo VARCHAR2(20) NOT NULL CHECK (es_festivo IN ('es_festivo', 'no_es_festivo')),
    temporada VARCHAR2(20) NOT NULL CHECK (temporada IN ('primavera', 'verano', 'otono', 'invierno'))
);

-- 2. HORA
CREATE TABLE HORA (
    id_hora INTEGER PRIMARY KEY,
    hora_completa DATE UNIQUE NOT NULL,
    hora INTEGER NOT NULL,
    minuto INTEGER NOT NULL,
    segundo INTEGER NOT NULL,
    franja_horaria VARCHAR2(20) NOT NULL CHECK (franja_horaria IN ('00:00-05:59', '06:00-11:59', '12:00-17:59', '18:00-23:59')),
    es_hora_punta VARCHAR2(20) NOT NULL CHECK (es_hora_punta IN ('es_hora_punta', 'no_es_hora_punta'))
);

-- 3. HOSPITAL
CREATE TABLE HOSPITAL (
    id_hospital INTEGER PRIMARY KEY, 
    direccion_completa VARCHAR2(50) UNIQUE NOT NULL, 
    nombre_hospital VARCHAR2(100) NOT NULL,
    tipo_hospital VARCHAR2(30) CHECK (tipo_hospital IN ('publico', 'privado')),
    ciudad VARCHAR2(100) NOT NULL,
    provincia VARCHAR2(100) NOT NULL,
    codigo_postal INTEGER NOT NULL,
    num_camas VARCHAR2(20) CHECK (num_camas IN ('0-99', '100-299', '300-599', '600-999', '1000+')),
    tiene_urgencias VARCHAR2(20) CHECK (tiene_urgencias IN ('si', 'no')),
    tiene_uci VARCHAR2(20) CHECK (tiene_uci IN ('si', 'no'))
);

-- 4. MEDICO (dimensión de profesionales médicos)
CREATE TABLE MEDICO (
    id_medico INTEGER PRIMARY KEY, 
    nombre VARCHAR2(100) NOT NULL,
    apellido1 VARCHAR2(150) NOT NULL,
    apellido2 VARCHAR2(150) NOT NULL,
    tipo_documento VARCHAR2(20) NOT NULL CHECK (tipo_documento IN ('DNI', 'NIE', 'pasaporte')),
    num_documento VARCHAR2(50) UNIQUE NOT NULL,
    email VARCHAR2(100),
    telefono VARCHAR2(20),
    fecha_nacimiento DATE NOT NULL,
    nacionalidad VARCHAR2(100) NOT NULL,
    num_colegiado VARCHAR2(50) NOT NULL UNIQUE,
    genero VARCHAR2(20) CHECK (genero IN ('masculino', 'femenino', 'otro')),
    especialidad VARCHAR2(100) NOT NULL,
    anos_experiencia INTEGER,
    categoria VARCHAR2(50) CHECK (categoria IN ('residente', 'adjunto', 'jefe_servicio', 'jefe_seccion')),
    esta_activo VARCHAR2(20) CHECK (esta_activo IN ('activo', 'inactivo'))
);

-- 5. PACIENTE (dimensión de pacientes)
CREATE TABLE PACIENTE (
    id_paciente INTEGER PRIMARY KEY, 
    nombre VARCHAR2(100) NOT NULL,
    apellido1 VARCHAR2(150) NOT NULL,
    apellido2 VARCHAR2(150) NOT NULL,
    tipo_documento VARCHAR2(20) NOT NULL CHECK (tipo_documento IN ('DNI', 'NIE', 'pasaporte', 'otro')),
    num_documento VARCHAR2(50) UNIQUE NOT NULL,
    email VARCHAR2(100),
    telefono VARCHAR2(20),
    fecha_nacimiento DATE NOT NULL,
    nacionalidad VARCHAR2(100) NOT NULL,
    genero VARCHAR2(20) CHECK (genero IN ('masculino', 'femenino', 'otro')),
    codigo_postal INTEGER NOT NULL,
    tipo_seguro VARCHAR2(30) CHECK (tipo_seguro IN ('publico', 'privado', 'mutua', 'sin_seguro')),
    categoria_cliente VARCHAR2(30) CHECK (categoria_cliente IN ('estandar', 'vip')),
    tipo_sanguineo VARCHAR2(10) CHECK (tipo_sanguineo IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'desconocido'))
);

-- 6. SERVICIO (dimensión de servicios/departamentos hospitalarios)
CREATE TABLE SERVICIO (
    id_servicio INTEGER PRIMARY KEY, 
    codigo_servicio VARCHAR2(50) UNIQUE NOT NULL,
    nombre_servicio VARCHAR2(100) NOT NULL,
    tipo_servicio VARCHAR2(50) CHECK (tipo_servicio IN ('consulta_externa', 'hospitalizacion', 'urgencias', 'quirofano', 'diagnostico', 'rehabilitacion')),
    planta INTEGER,
    edificio VARCHAR2(50),
    num_camas_servicio VARCHAR2(20) CHECK (num_camas_servicio IN ('0-9', '10-19', '20-49', '50-99', '100+')),
    tiene_uci VARCHAR2(20) CHECK (tiene_uci IN ('tiene_uci', 'no_tiene_uci')),
    esta_activo VARCHAR2(20) CHECK (esta_activo IN ('esta_activo', 'no_esta_activo'))
);

-- 7. DIAGNOSTICO (dimensión de diagnósticos - CIE-10)
CREATE TABLE DIAGNOSTICO (
    id_diagnostico INTEGER PRIMARY KEY,
    codigo_diagnostico VARCHAR2(50) UNIQUE NOT NULL,
    nombre_diagnostico VARCHAR2(300) NOT NULL,
    categoria_principal VARCHAR2(100) NOT NULL,
    gravedad VARCHAR2(20) CHECK (gravedad IN ('leve', 'moderada', 'grave', 'critica')),
    es_cronico VARCHAR2(20) CHECK (es_cronico IN ('es_cronico', 'no_es_cronico')),
    requiere_hospitalizacion VARCHAR2(30) CHECK (requiere_hospitalizacion IN ('requiere_hospitalizacion', 'no_requiere_hospitalizacion')) 
);

-- 8. PROCEDIMIENTO (dimensión de procedimientos médicos)
CREATE TABLE PROCEDIMIENTO (
    id_procedimiento INTEGER PRIMARY KEY,
    codigo_procedimiento VARCHAR2(50) UNIQUE NOT NULL,
    nombre_procedimiento VARCHAR2(300) NOT NULL,
    tipo_procedimiento VARCHAR2(50) CHECK (tipo_procedimiento IN ('consulta', 'cirugia_menor', 'cirugia_mayor', 'prueba_diagnostica', 'tratamiento', 'vacunacion', 'rehabilitacion')),
    duracion_estimada_minutos INTEGER,
    requiere_anestesia VARCHAR2(25) CHECK (requiere_anestesia IN ('requiere_anestesia', 'no_requiere_anestesia')), 
    es_ambulatorio VARCHAR2(20) CHECK (es_ambulatorio IN ('es_ambulatorio', 'no_es_ambulatorio'))
);

------------------------------ CREAR TABLA DE HECHOS ------------------------------

-- 9. ATENCION_MEDICA (tabla de hechos central)
CREATE TABLE ATENCION_MEDICA (
    id_paciente INTEGER NOT NULL,
    id_fecha INTEGER NOT NULL,
    id_hora INTEGER NOT NULL,
    id_hospital INTEGER NOT NULL,
    id_servicio INTEGER NOT NULL,
    id_medico INTEGER NOT NULL,
    id_diagnostico INTEGER NOT NULL,
    id_procedimiento INTEGER NOT NULL,
    duracion_atencion_minutos REAL NOT NULL,
    coste_procedimiento REAL NOT NULL,
    tiempo_espera_minutos REAL DEFAULT 0,
    num_pruebas_realizadas INTEGER DEFAULT 0,
    num_medicamentos_prescritos INTEGER DEFAULT 0,
    PRIMARY KEY (id_paciente, id_fecha, id_hora),
    FOREIGN KEY (id_paciente) REFERENCES PACIENTE(id_paciente) ON DELETE CASCADE,
    FOREIGN KEY (id_fecha) REFERENCES FECHA(id_fecha) ON DELETE CASCADE,
    FOREIGN KEY (id_hora) REFERENCES HORA(id_hora) ON DELETE CASCADE,
    FOREIGN KEY (id_hospital) REFERENCES HOSPITAL(id_hospital) ON DELETE CASCADE,
    FOREIGN KEY (id_servicio) REFERENCES SERVICIO(id_servicio) ON DELETE CASCADE,
    FOREIGN KEY (id_medico) REFERENCES MEDICO(id_medico) ON DELETE CASCADE,
    FOREIGN KEY (id_diagnostico) REFERENCES DIAGNOSTICO(id_diagnostico) ON DELETE CASCADE,
    FOREIGN KEY (id_procedimiento) REFERENCES PROCEDIMIENTO(id_procedimiento) ON DELETE CASCADE,
    CONSTRAINT chk_duracion_positiva CHECK (duracion_atencion_minutos > 0),
    CONSTRAINT chk_coste_positivo CHECK (coste_procedimiento >= 0),
    CONSTRAINT chk_espera_positiva CHECK (tiempo_espera_minutos >= 0)
);


COMMIT;
