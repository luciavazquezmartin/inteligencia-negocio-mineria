-- ============================================================================
-- SCRIPT DE INSERCIÓN DE DATOS - MODELO HOSPITALARIO
-- ============================================================================

-- Limpiar datos existentes
DELETE FROM ATENCION_MEDICA;
DELETE FROM PROCEDIMIENTO;
DELETE FROM DIAGNOSTICO;
DELETE FROM SERVICIO;
DELETE FROM PACIENTE;
DELETE FROM MEDICO;
DELETE FROM HOSPITAL;
DELETE FROM HORA;
DELETE FROM FECHA;
COMMIT;

------------------------------ DIMENSIÓN FECHA ------------------------------
INSERT INTO FECHA VALUES (1, TO_DATE('2025-01-15', 'YYYY-MM-DD'), 15, 1, 2025, 'Miércoles', 'Enero', 3, 1, 'no_es_fin_semana', 'no_es_festivo', 'invierno');
INSERT INTO FECHA VALUES (2, TO_DATE('2025-02-20', 'YYYY-MM-DD'), 20, 2, 2025, 'Jueves', 'Febrero', 8, 1, 'no_es_fin_semana', 'no_es_festivo', 'invierno');
INSERT INTO FECHA VALUES (3, TO_DATE('2025-03-25', 'YYYY-MM-DD'), 25, 3, 2025, 'Martes', 'Marzo', 13, 1, 'no_es_fin_semana', 'no_es_festivo', 'primavera');
INSERT INTO FECHA VALUES (4, TO_DATE('2025-04-12', 'YYYY-MM-DD'), 12, 4, 2025, 'Sábado', 'Abril', 15, 2, 'es_fin_semana', 'no_es_festivo', 'primavera');
INSERT INTO FECHA VALUES (5, TO_DATE('2025-05-01', 'YYYY-MM-DD'), 1, 5, 2025, 'Jueves', 'Mayo', 18, 2, 'no_es_fin_semana', 'es_festivo', 'primavera');
INSERT INTO FECHA VALUES (6, TO_DATE('2025-06-15', 'YYYY-MM-DD'), 15, 6, 2025, 'Domingo', 'Junio', 24, 2, 'es_fin_semana', 'no_es_festivo', 'verano');
INSERT INTO FECHA VALUES (7, TO_DATE('2025-07-20', 'YYYY-MM-DD'), 20, 7, 2025, 'Domingo', 'Julio', 29, 3, 'es_fin_semana', 'no_es_festivo', 'verano');
INSERT INTO FECHA VALUES (8, TO_DATE('2025-08-15', 'YYYY-MM-DD'), 15, 8, 2025, 'Viernes', 'Agosto', 33, 3, 'no_es_fin_semana', 'es_festivo', 'verano');
INSERT INTO FECHA VALUES (9, TO_DATE('2025-09-10', 'YYYY-MM-DD'), 10, 9, 2025, 'Miércoles', 'Septiembre', 37, 3, 'no_es_fin_semana', 'no_es_festivo', 'otono');
INSERT INTO FECHA VALUES (10, TO_DATE('2025-10-12', 'YYYY-MM-DD'), 12, 10, 2025, 'Domingo', 'Octubre', 41, 4, 'es_fin_semana', 'es_festivo', 'otono');

------------------------------ DIMENSIÓN HORA ------------------------------
INSERT INTO HORA VALUES (1, TO_DATE('2025-01-01 08:30:00', 'YYYY-MM-DD HH24:MI:SS'), 8, 30, 0, '06:00-11:59', 'es_hora_punta');
INSERT INTO HORA VALUES (2, TO_DATE('2025-01-01 09:15:00', 'YYYY-MM-DD HH24:MI:SS'), 9, 15, 0, '06:00-11:59', 'es_hora_punta');
INSERT INTO HORA VALUES (3, TO_DATE('2025-01-01 10:45:00', 'YYYY-MM-DD HH24:MI:SS'), 10, 45, 0, '06:00-11:59', 'es_hora_punta');
INSERT INTO HORA VALUES (4, TO_DATE('2025-01-01 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 14, 0, 0, '12:00-17:59', 'no_es_hora_punta');
INSERT INTO HORA VALUES (5, TO_DATE('2025-01-01 15:30:00', 'YYYY-MM-DD HH24:MI:SS'), 15, 30, 0, '12:00-17:59', 'no_es_hora_punta');
INSERT INTO HORA VALUES (6, TO_DATE('2025-01-01 16:45:00', 'YYYY-MM-DD HH24:MI:SS'), 16, 45, 0, '12:00-17:59', 'no_es_hora_punta');
INSERT INTO HORA VALUES (7, TO_DATE('2025-01-01 19:00:00', 'YYYY-MM-DD HH24:MI:SS'), 19, 0, 0, '18:00-23:59', 'no_es_hora_punta');
INSERT INTO HORA VALUES (8, TO_DATE('2025-01-01 20:30:00', 'YYYY-MM-DD HH24:MI:SS'), 20, 30, 0, '18:00-23:59', 'no_es_hora_punta');

------------------------------ DIMENSIÓN HOSPITAL ------------------------------
INSERT INTO HOSPITAL VALUES (1, 'Calle Mayor 1, Madrid', 'Hospital Clínico San Carlos', 'publico', 'Madrid', 'Madrid', 28040, '1000+', 'si', 'si');
INSERT INTO HOSPITAL VALUES (2, 'Av. Diagonal 100, Barcelona', 'Hospital Clínic de Barcelona', 'publico', 'Barcelona', 'Barcelona', 8036, '1000+', 'si', 'si');
INSERT INTO HOSPITAL VALUES (3, 'Calle Sevilla 50, Sevilla', 'Hospital Virgen del Rocío', 'publico', 'Sevilla', 'Sevilla', 41013, '600-999', 'si', 'si');
INSERT INTO HOSPITAL VALUES (4, 'Av. Europa 20, Valencia', 'Clínica Quirón Valencia', 'privado', 'Valencia', 'Valencia', 46010, '100-299', 'si', 'no');
INSERT INTO HOSPITAL VALUES (5, 'Calle Principal 5, Zaragoza', 'Hospital Miguel Servet', 'publico', 'Zaragoza', 'Zaragoza', 50009, '600-999', 'si', 'si');

------------------------------ DIMENSIÓN MEDICO ------------------------------
INSERT INTO MEDICO VALUES (1, 'Ana', 'García', 'López', 'DNI', '12345678A', 'ana.garcia@hospital.es', '+34600111222', TO_DATE('1975-05-15', 'YYYY-MM-DD'), 'España', 'COL001', 'femenino', 'Cardiología', 20, 'jefe_servicio', 'activo');
INSERT INTO MEDICO VALUES (2, 'Carlos', 'Martínez', 'Ruiz', 'DNI', '23456789B', 'carlos.martinez@hospital.es', '+34600222333', TO_DATE('1980-08-20', 'YYYY-MM-DD'), 'España', 'COL002', 'masculino', 'Traumatología', 15, 'adjunto', 'activo');
INSERT INTO MEDICO VALUES (3, 'María', 'Fernández', 'Sánchez', 'DNI', '34567890C', 'maria.fernandez@hospital.es', '+34600333444', TO_DATE('1985-03-10', 'YYYY-MM-DD'), 'España', 'COL003', 'femenino', 'Pediatría', 10, 'adjunto', 'activo');
INSERT INTO MEDICO VALUES (4, 'Juan', 'López', 'González', 'DNI', '45678901D', 'juan.lopez@hospital.es', '+34600444555', TO_DATE('1990-11-25', 'YYYY-MM-DD'), 'España', 'COL004', 'masculino', 'Medicina Interna', 5, 'residente', 'activo');
INSERT INTO MEDICO VALUES (5, 'Laura', 'Rodríguez', 'Pérez', 'DNI', '56789012E', 'laura.rodriguez@hospital.es', '+34600555666', TO_DATE('1982-07-08', 'YYYY-MM-DD'), 'España', 'COL005', 'femenino', 'Neurología', 12, 'jefe_seccion', 'activo');

------------------------------ DIMENSIÓN PACIENTE ------------------------------
INSERT INTO PACIENTE VALUES (1, 'Pedro', 'Jiménez', 'Díaz', 'DNI', '11111111A', 'pedro.jimenez@email.com', '+34611111111', TO_DATE('1960-01-15', 'YYYY-MM-DD'), 'España', 'masculino', 28001, 'publico', 'estandar', 'A+');
INSERT INTO PACIENTE VALUES (2, 'Isabel', 'Moreno', 'Vázquez', 'DNI', '22222222B', 'isabel.moreno@email.com', '+34622222222', TO_DATE('1975-06-20', 'YYYY-MM-DD'), 'España', 'femenino', 8001, 'privado', 'vip', 'B+');
INSERT INTO PACIENTE VALUES (3, 'Miguel', 'Torres', 'Ramírez', 'DNI', '33333333C', 'miguel.torres@email.com', '+34633333333', TO_DATE('1988-09-10', 'YYYY-MM-DD'), 'España', 'masculino', 41001, 'publico', 'estandar', 'O+');
INSERT INTO PACIENTE VALUES (4, 'Carmen', 'Navarro', 'Gil', 'DNI', '44444444D', 'carmen.navarro@email.com', '+34644444444', TO_DATE('1995-03-25', 'YYYY-MM-DD'), 'España', 'femenino', 46001, 'mutua', 'estandar', 'AB+');
INSERT INTO PACIENTE VALUES (5, 'Antonio', 'Serrano', 'Castro', 'DNI', '55555555E', 'antonio.serrano@email.com', '+34655555555', TO_DATE('1970-12-05', 'YYYY-MM-DD'), 'España', 'masculino', 50001, 'publico', 'estandar', 'A-');
INSERT INTO PACIENTE VALUES (6, 'Rosa', 'Blanco', 'Ortega', 'DNI', '66666666F', 'rosa.blanco@email.com', '+34666666666', TO_DATE('1982-04-18', 'YYYY-MM-DD'), 'España', 'femenino', 28002, 'privado', 'vip', 'O-');
INSERT INTO PACIENTE VALUES (7, 'Francisco', 'Rubio', 'Suárez', 'DNI', '77777777G', 'francisco.rubio@email.com', '+34677777777', TO_DATE('1968-08-30', 'YYYY-MM-DD'), 'España', 'masculino', 8002, 'publico', 'estandar', 'B-');
INSERT INTO PACIENTE VALUES (8, 'Elena', 'Ramos', 'Delgado', 'DNI', '88888888H', 'elena.ramos@email.com', '+34688888888', TO_DATE('1992-11-12', 'YYYY-MM-DD'), 'España', 'femenino', 41002, 'publico', 'estandar', 'A+');

------------------------------ DIMENSIÓN SERVICIO ------------------------------
INSERT INTO SERVICIO VALUES (1, 'SRV-CARD-01', 'Cardiología', 'consulta_externa', 3, 'Edificio A', '10-19', 'no_tiene_uci', 'esta_activo');
INSERT INTO SERVICIO VALUES (2, 'SRV-TRAU-01', 'Traumatología', 'hospitalizacion', 2, 'Edificio B', '20-49', 'no_tiene_uci', 'esta_activo');
INSERT INTO SERVICIO VALUES (3, 'SRV-PEDI-01', 'Pediatría', 'consulta_externa', 1, 'Edificio C', '10-19', 'no_tiene_uci', 'esta_activo');
INSERT INTO SERVICIO VALUES (4, 'SRV-URG-01', 'Urgencias Generales', 'urgencias', 0, 'Edificio Central', '20-49', 'tiene_uci', 'esta_activo');
INSERT INTO SERVICIO VALUES (5, 'SRV-NEUR-01', 'Neurología', 'hospitalizacion', 4, 'Edificio A', '10-19', 'tiene_uci', 'esta_activo');

------------------------------ DIMENSIÓN DIAGNOSTICO ------------------------------
INSERT INTO DIAGNOSTICO VALUES (1, 'I10', 'Hipertensión arterial esencial', 'Enfermedades del sistema circulatorio', 'moderada', 'es_cronico', 'no_requiere_hospitalizacion');
INSERT INTO DIAGNOSTICO VALUES (2, 'M25.5', 'Dolor en articulación', 'Enfermedades del sistema osteomuscular', 'leve', 'no_es_cronico', 'no_requiere_hospitalizacion');
INSERT INTO DIAGNOSTICO VALUES (3, 'J06.9', 'Infección aguda de vías respiratorias superiores', 'Enfermedades del sistema respiratorio', 'leve', 'no_es_cronico', 'no_requiere_hospitalizacion');
INSERT INTO DIAGNOSTICO VALUES (4, 'S72.0', 'Fractura del cuello del fémur', 'Traumatismos y envenenamientos', 'grave', 'no_es_cronico', 'requiere_hospitalizacion');
INSERT INTO DIAGNOSTICO VALUES (5, 'G40.9', 'Epilepsia', 'Enfermedades del sistema nervioso', 'grave', 'es_cronico', 'requiere_hospitalizacion');
INSERT INTO DIAGNOSTICO VALUES (6, 'E11.9', 'Diabetes mellitus tipo 2', 'Enfermedades endocrinas', 'moderada', 'es_cronico', 'no_requiere_hospitalizacion');

------------------------------ DIMENSIÓN PROCEDIMIENTO ------------------------------
INSERT INTO PROCEDIMIENTO VALUES (1, 'PROC-001', 'Consulta de cardiología', 'consulta', 30, 'no_requiere_anestesia', 'es_ambulatorio');
INSERT INTO PROCEDIMIENTO VALUES (2, 'PROC-002', 'Reducción de fractura con osteosíntesis', 'cirugia_mayor', 180, 'requiere_anestesia', 'no_es_ambulatorio');
INSERT INTO PROCEDIMIENTO VALUES (3, 'PROC-003', 'Consulta pediátrica', 'consulta', 20, 'no_requiere_anestesia', 'es_ambulatorio');
INSERT INTO PROCEDIMIENTO VALUES (4, 'PROC-004', 'Radiografía de tórax', 'prueba_diagnostica', 15, 'no_requiere_anestesia', 'es_ambulatorio');
INSERT INTO PROCEDIMIENTO VALUES (5, 'PROC-005', 'Electroencefalograma', 'prueba_diagnostica', 60, 'no_requiere_anestesia', 'es_ambulatorio');
INSERT INTO PROCEDIMIENTO VALUES (6, 'PROC-006', 'Control de diabetes', 'tratamiento', 25, 'no_requiere_anestesia', 'es_ambulatorio');

------------------------------ TABLA DE HECHOS ATENCION_MEDICA ------------------------------
INSERT INTO ATENCION_MEDICA VALUES (1, 1, 1, 1, 1, 1, 1, 1, 35, 50.0, 15, 1, 2);
INSERT INTO ATENCION_MEDICA VALUES (2, 2, 2, 2, 4, 2, 4, 2, 200, 3500.0, 45, 3, 5);
INSERT INTO ATENCION_MEDICA VALUES (3, 3, 3, 3, 3, 3, 3, 3, 25, 30.0, 10, 0, 1);
INSERT INTO ATENCION_MEDICA VALUES (4, 4, 4, 4, 2, 2, 2, 4, 20, 25.0, 5, 1, 0);
INSERT INTO ATENCION_MEDICA VALUES (5, 5, 5, 5, 5, 5, 5, 5, 70, 150.0, 30, 2, 3);
INSERT INTO ATENCION_MEDICA VALUES (6, 6, 6, 1, 1, 1, 6, 6, 30, 45.0, 20, 1, 2);
INSERT INTO ATENCION_MEDICA VALUES (7, 7, 7, 2, 4, 4, 3, 4, 18, 20.0, 60, 1, 1);
INSERT INTO ATENCION_MEDICA VALUES (8, 8, 8, 3, 2, 2, 2, 4, 22, 28.0, 25, 1, 0);
INSERT INTO ATENCION_MEDICA VALUES (1, 9, 1, 1, 1, 1, 1, 1, 32, 50.0, 10, 1, 2);
INSERT INTO ATENCION_MEDICA VALUES (2, 10, 2, 2, 2, 2, 2, 2, 185, 3200.0, 30, 2, 4);

COMMIT;