-- ============================================================================
-- SCRIPT DE INSERCIÓN DE DATOS - MODELO CON PASAJEROS
-- ============================================================================

-- Limpiar datos existentes
DELETE FROM VUELO;
DELETE FROM GRUPO_PASAJEROS;
DELETE FROM GRUPO;
DELETE FROM PASAJERO;
DELETE FROM AEROLINEA;
DELETE FROM OPERADORA;
DELETE FROM AVION;
DELETE FROM AEROPUERTO;
DELETE FROM HORA;
DELETE FROM FECHA;
COMMIT;

------------------------------ DIMENSIÓN FECHA ------------------------------
INSERT INTO FECHA VALUES (1, TO_DATE('2025-01-15', 'YYYY-MM-DD'), 15, 1, 2025, 'Miércoles', 'Enero', 3, 1, 'no_es_fin_semana', 'no_es_festivo', 'primavera');
INSERT INTO FECHA VALUES (2, TO_DATE('2025-01-16', 'YYYY-MM-DD'), 16, 1, 2025, 'Jueves', 'Enero', 3, 1, 'no_es_fin_semana', 'no_es_festivo', 'otogno');
INSERT INTO FECHA VALUES (3, TO_DATE('2025-07-20', 'YYYY-MM-DD'), 20, 7, 2025, 'Domingo', 'Julio', 29, 3, 'es_fin_semana', 'no_es_festivo', 'verano');
INSERT INTO FECHA VALUES (4, TO_DATE('2025-08-15', 'YYYY-MM-DD'), 15, 8, 2025, 'Viernes', 'Agosto', 33, 3, 'no_es_fin_semana', 'es_festivo', 'primavera');
INSERT INTO FECHA VALUES (5, TO_DATE('2025-12-25', 'YYYY-MM-DD'), 25, 12, 2025, 'Jueves', 'Diciembre', 52, 4, 'no_es_fin_semana', 'es_festivo', 'invierno');
INSERT INTO FECHA VALUES (6, TO_DATE('2025-01-18', 'YYYY-MM-DD'), 18, 1, 2025, 'Sábado', 'Enero', 3, 1, 'es_fin_semana', 'no_es_festivo', 'verano');
INSERT INTO FECHA VALUES (7, TO_DATE('2025-03-21', 'YYYY-MM-DD'), 21, 3, 2025, 'Viernes', 'Marzo', 12, 1, 'no_es_fin_semana', 'no_es_festivo', 'primavera');
INSERT INTO FECHA VALUES (8, TO_DATE('2025-04-10', 'YYYY-MM-DD'), 10, 4, 2025, 'Jueves', 'Abril', 15, 2, 'no_es_fin_semana', 'no_es_festivo', 'primavera');
INSERT INTO FECHA VALUES (9, TO_DATE('2025-06-15', 'YYYY-MM-DD'), 15, 6, 2025, 'Domingo', 'Junio', 24, 2, 'es_fin_semana', 'no_es_festivo', 'verano');
INSERT INTO FECHA VALUES (10, TO_DATE('2025-07-21', 'YYYY-MM-DD'), 21, 7, 2025, 'Lunes', 'Julio', 30, 3, 'no_es_fin_semana', 'no_es_festivo', 'verano');
INSERT INTO FECHA VALUES (11, TO_DATE('2025-09-12', 'YYYY-MM-DD'), 12, 9, 2025, 'Viernes', 'Septiembre', 37, 3, 'no_es_fin_semana', 'no_es_festivo', 'otogno');
INSERT INTO FECHA VALUES (12, TO_DATE('2025-10-12', 'YYYY-MM-DD'), 12, 10, 2025, 'Domingo', 'Octubre', 41, 4, 'es_fin_semana', 'es_festivo', 'otogno');
INSERT INTO FECHA VALUES (13, TO_DATE('2025-11-01', 'YYYY-MM-DD'), 1, 11, 2025, 'Sábado', 'Noviembre', 44, 4, 'es_fin_semana', 'es_festivo', 'otogno');

------------------------------ DIMENSIÓN HORA ------------------------------
INSERT INTO HORA VALUES (1, TO_DATE('2025-01-01 08:30:00', 'YYYY-MM-DD HH24:MI:SS'), 8, 30, 0, '05:00 - 11:59', 'es_hora_punta');
INSERT INTO HORA VALUES (2, TO_DATE('2025-01-01 14:45:00', 'YYYY-MM-DD HH24:MI:SS'), 14, 45, 0, '12:00 - 19:59', 'no_es_hora_punta');
INSERT INTO HORA VALUES (3, TO_DATE('2025-01-01 18:15:00', 'YYYY-MM-DD HH24:MI:SS'), 18, 15, 0, '12:00 - 19:59', 'es_hora_punta');
INSERT INTO HORA VALUES (4, TO_DATE('2025-01-01 21:00:00', 'YYYY-MM-DD HH24:MI:SS'), 21, 0, 0, '20:00 - 23:59', 'no_es_hora_punta');
INSERT INTO HORA VALUES (5, TO_DATE('2025-01-01 06:00:00', 'YYYY-MM-DD HH24:MI:SS'), 6, 0, 0, '05:00 - 11:59', 'es_hora_punta');
INSERT INTO HORA VALUES (6, TO_DATE('2025-01-01 07:15:00', 'YYYY-MM-DD HH24:MI:SS'), 7, 15, 0, '05:00 - 11:59', 'es_hora_punta');
INSERT INTO HORA VALUES (7, TO_DATE('2025-01-01 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), 10, 30, 0, '05:00 - 11:59', 'es_hora_punta');
INSERT INTO HORA VALUES (8, TO_DATE('2025-01-01 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), 13, 0, 0, '12:00 - 19:59', 'no_es_hora_punta');
INSERT INTO HORA VALUES (9, TO_DATE('2025-01-01 16:45:00', 'YYYY-MM-DD HH24:MI:SS'), 16, 45, 0, '12:00 - 19:59', 'no_es_hora_punta');
INSERT INTO HORA VALUES (10, TO_DATE('2025-01-01 22:30:00', 'YYYY-MM-DD HH24:MI:SS'), 22, 30, 0, '20:00 - 23:59', 'no_es_hora_punta');
INSERT INTO HORA VALUES (11, TO_DATE('2025-01-01 03:15:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 15, 0, '00:00 - 04:59', 'no_es_hora_punta');

------------------------------ DIMENSIÓN AEROPUERTO ------------------------------
INSERT INTO AEROPUERTO VALUES (1, 'LEMD', 'Aeropuerto Adolfo Suárez Madrid-Barajas', 'Madrid', 'Comunidad de Madrid', 'MD', 'Centro', 'España', 40.4983, -3.5676, 610.0, 'Europe/Madrid', 'internacional');
INSERT INTO AEROPUERTO VALUES (2, 'LEBL', 'Aeropuerto de Barcelona-El Prat', 'Barcelona', 'Cataluña', 'CT', 'Noreste', 'España', 41.2974, 2.0833, 4.0, 'Europe/Madrid', 'internacional');
INSERT INTO AEROPUERTO VALUES (3, 'LEZL', 'Aeropuerto de Sevilla-San Pablo', 'Sevilla', 'Andalucía', 'AN', 'Sur', 'España', 37.4180, -5.8931, 34.0, 'Europe/Madrid', 'nacional');
INSERT INTO AEROPUERTO VALUES (4, 'LEVC', 'Aeropuerto de Valencia', 'Valencia', 'Comunidad Valenciana', 'VC', 'Este', 'España', 39.4893, -0.4817, 69.0, 'Europe/Madrid', 'nacional');
INSERT INTO AEROPUERTO VALUES (5, 'LEAL', 'Aeropuerto de Alicante-Elche', 'Alicante', 'Comunidad Valenciana', 'VC', 'Este', 'España', 38.2822, -0.5581, 43.0, 'Europe/Madrid', 'internacional');

------------------------------ DIMENSIÓN AVION ------------------------------
INSERT INTO AVION VALUES (1, 'EC-MFZ', 'A320-214', 'Airbus A320-200', 'Airbus', 'Turbofan', 2, 180, 871.0, 2010, 2011, 'esta_activo');
INSERT INTO AVION VALUES (2, 'EC-JFN', 'B737-800', 'Boeing 737-800', 'Boeing', 'Turbofan', 2, 189, 842.0, 2012, 2013, 'esta_activo');
INSERT INTO AVION VALUES (3, 'EC-LUN', 'A321-211', 'Airbus A321-200', 'Airbus', 'Turbofan', 2, 220, 903.0, 2015, 2016, 'esta_activo');
INSERT INTO AVION VALUES (4, 'EC-MIG', 'B787-8', 'Boeing 787-8 Dreamliner', 'Boeing', 'Turbofan', 2, 296, 954.0, 2018, 2019, 'esta_activo');
INSERT INTO AVION VALUES (5, 'EC-LXR', 'A330-300', 'Airbus A330-300', 'Airbus', 'Turbofan', 2, 335, 913.0, 2008, 2009, 'no_esta_activo');

------------------------------ DIMENSIÓN OPERADORA ------------------------------
INSERT INTO OPERADORA VALUES (1, 'IBE', 'Iberia', 'España', '1927', 'esta_activo');
INSERT INTO OPERADORA VALUES (2, 'VLG', 'Vueling', 'España', '2004', 'esta_activo');
INSERT INTO OPERADORA VALUES (3, 'AEA', 'Air Europa', 'España', '1986', 'esta_activo');
INSERT INTO OPERADORA VALUES (4, 'RYR', 'Ryanair', 'Irlanda', '1984', 'esta_activo');
INSERT INTO OPERADORA VALUES (5, 'EZY', 'easyJet', 'Reino Unido', '1995', 'esta_activo');

------------------------------ DIMENSIÓN AEROLINEA ------------------------------
INSERT INTO AEROLINEA VALUES (1, 'IBE', 'Iberia Líneas Aéreas de España', 'Iberia', 'España', 'internacional', 1927, 'esta_activo');
INSERT INTO AEROLINEA VALUES (2, 'VLG', 'Vueling Airlines', 'Vueling', 'España', 'internacional', 2004, 'esta_activo');
INSERT INTO AEROLINEA VALUES (3, 'AEA', 'Air Europa Líneas Aéreas', 'Air Europa', 'España', 'internacional', 1986, 'esta_activo');
INSERT INTO AEROLINEA VALUES (4, 'RYR', 'Ryanair DAC', 'Ryanair', 'Irlanda', 'internacional', 1984, 'esta_activo');
INSERT INTO AEROLINEA VALUES (5, 'EZY', 'easyJet Airline Company Limited', 'easyJet', 'Reino Unido', 'internacional', 1995, 'esta_activo');

------------------------------ DIMENSIÓN PASAJERO ------------------------------
-- Pasajeros VIP
INSERT INTO PASAJERO VALUES (1, 'Carlos', 'García', 'López', 'DNI', '12345678A', '+34600111222', TO_DATE('1980-05-15', 'YYYY-MM-DD'), 'España', 'vip');
INSERT INTO PASAJERO VALUES (2, 'María', 'Rodríguez', 'Martín', 'DNI', '23456789B', '+34600222333', TO_DATE('1985-08-20', 'YYYY-MM-DD'), 'España', 'vip');
INSERT INTO PASAJERO VALUES (3, 'John', 'Smith', NULL, 'pasaporte', 'AB123456', '+44700111222', TO_DATE('1978-03-10', 'YYYY-MM-DD'), 'Reino Unido', 'vip');
INSERT INTO PASAJERO VALUES (4, 'Sophie', 'Dubois', NULL, 'pasaporte', 'FR987654', '+33600111222', TO_DATE('1990-11-25', 'YYYY-MM-DD'), 'Francia', 'vip');
INSERT INTO PASAJERO VALUES (5, 'Hans', 'Müller', NULL, 'pasaporte', 'DE456789', '+49170111222', TO_DATE('1975-07-08', 'YYYY-MM-DD'), 'Alemania', 'vip');

-- Pasajeros estándar
INSERT INTO PASAJERO VALUES (6, 'Ana', 'López', 'Fernández', 'DNI', '34567890C', '+34600333444', TO_DATE('1992-02-14', 'YYYY-MM-DD'), 'España', 'estandar');
INSERT INTO PASAJERO VALUES (7, 'Pedro', 'Sánchez', 'García', 'DNI', '45678901D', '+34600444555', TO_DATE('1988-06-22', 'YYYY-MM-DD'), 'España', 'estandar');
INSERT INTO PASAJERO VALUES (8, 'Laura', 'Martínez', 'Ruiz', 'DNI', '56789012E', '+34600555666', TO_DATE('1995-09-30', 'YYYY-MM-DD'), 'España', 'estandar');
INSERT INTO PASAJERO VALUES (9, 'David', 'González', 'Pérez', 'DNI', '67890123F', '+34600666777', TO_DATE('1982-12-05', 'YYYY-MM-DD'), 'España', 'estandar');
INSERT INTO PASAJERO VALUES (10, 'Elena', 'Hernández', 'Díaz', 'DNI', '78901234G', '+34600777888', TO_DATE('1991-04-18', 'YYYY-MM-DD'), 'España', 'estandar');
INSERT INTO PASAJERO VALUES (11, 'Miguel', 'Jiménez', 'Moreno', 'DNI', '89012345H', '+34600888999', TO_DATE('1987-01-27', 'YYYY-MM-DD'), 'España', 'estandar');
INSERT INTO PASAJERO VALUES (12, 'Isabel', 'Álvarez', 'Romero', 'DNI', '90123456I', '+34600999000', TO_DATE('1993-08-13', 'YYYY-MM-DD'), 'España', 'estandar');
INSERT INTO PASAJERO VALUES (13, 'Javier', 'Torres', 'Navarro', 'DNI', '01234567J', '+34601000111', TO_DATE('1984-10-09', 'YYYY-MM-DD'), 'España', 'estandar');
INSERT INTO PASAJERO VALUES (14, 'Carmen', 'Ramírez', 'Gil', 'DNI', '11234567K', '+34601111222', TO_DATE('1996-03-21', 'YYYY-MM-DD'), 'España', 'estandar');
INSERT INTO PASAJERO VALUES (15, 'Antonio', 'Vázquez', 'Serrano', 'DNI', '21234567L', '+34601222333', TO_DATE('1989-07-16', 'YYYY-MM-DD'), 'España', 'estandar');
INSERT INTO PASAJERO VALUES (16, 'Lucía', 'Ramos', 'Blanco', 'DNI', '31234567M', '+34601333444', TO_DATE('1994-11-02', 'YYYY-MM-DD'), 'España', 'estandar');
INSERT INTO PASAJERO VALUES (17, 'Francisco', 'Castro', 'Suárez', 'DNI', '41234567N', '+34601444555', TO_DATE('1981-05-28', 'YYYY-MM-DD'), 'España', 'estandar');
INSERT INTO PASAJERO VALUES (18, 'Marta', 'Ortega', 'Rubio', 'DNI', '51234567O', '+34601555666', TO_DATE('1997-09-14', 'YYYY-MM-DD'), 'España', 'estandar');
INSERT INTO PASAJERO VALUES (19, 'Raúl', 'Delgado', 'Molina', 'DNI', '61234567P', '+34601666777', TO_DATE('1986-02-07', 'YYYY-MM-DD'), 'España', 'estandar');
INSERT INTO PASAJERO VALUES (20, 'Beatriz', 'Morales', 'Ortiz', 'DNI', '71234567Q', '+34601777888', TO_DATE('1992-06-19', 'YYYY-MM-DD'), 'España', 'estandar');

------------------------------ TABLA GRUPO ------------------------------
-- Crear 23 grupos (uno por cada vuelo)
INSERT INTO GRUPO VALUES (1);
INSERT INTO GRUPO VALUES (2);
INSERT INTO GRUPO VALUES (3);
INSERT INTO GRUPO VALUES (4);
INSERT INTO GRUPO VALUES (5);
INSERT INTO GRUPO VALUES (6);
INSERT INTO GRUPO VALUES (7);
INSERT INTO GRUPO VALUES (8);
INSERT INTO GRUPO VALUES (9);
INSERT INTO GRUPO VALUES (10);
INSERT INTO GRUPO VALUES (11);
INSERT INTO GRUPO VALUES (12);
INSERT INTO GRUPO VALUES (13);
INSERT INTO GRUPO VALUES (14);
INSERT INTO GRUPO VALUES (15);
INSERT INTO GRUPO VALUES (16);
INSERT INTO GRUPO VALUES (17);
INSERT INTO GRUPO VALUES (18);
INSERT INTO GRUPO VALUES (19);
INSERT INTO GRUPO VALUES (20);
INSERT INTO GRUPO VALUES (21);
INSERT INTO GRUPO VALUES (22);
INSERT INTO GRUPO VALUES (23);

------------------------------ TABLA PUENTE GRUPO_PASAJEROS ------------------------------
INSERT INTO GRUPO_PASAJEROS VALUES (1, 1);
INSERT INTO GRUPO_PASAJEROS VALUES (2, 2);
INSERT INTO GRUPO_PASAJEROS VALUES (2, 6);
INSERT INTO GRUPO_PASAJEROS VALUES (3, 7);
INSERT INTO GRUPO_PASAJEROS VALUES (3, 8);
INSERT INTO GRUPO_PASAJEROS VALUES (3, 14);
INSERT INTO GRUPO_PASAJEROS VALUES (3, 18);
INSERT INTO GRUPO_PASAJEROS VALUES (4, 3);
INSERT INTO GRUPO_PASAJEROS VALUES (5, 9);
INSERT INTO GRUPO_PASAJEROS VALUES (5, 10);
INSERT INTO GRUPO_PASAJEROS VALUES (6, 11);
INSERT INTO GRUPO_PASAJEROS VALUES (6, 12);
INSERT INTO GRUPO_PASAJEROS VALUES (6, 13);
INSERT INTO GRUPO_PASAJEROS VALUES (7, 4);
INSERT INTO GRUPO_PASAJEROS VALUES (8, 15);
INSERT INTO GRUPO_PASAJEROS VALUES (8, 16);
INSERT INTO GRUPO_PASAJEROS VALUES (8, 17);
INSERT INTO GRUPO_PASAJEROS VALUES (8, 19);
INSERT INTO GRUPO_PASAJEROS VALUES (8, 20);
INSERT INTO GRUPO_PASAJEROS VALUES (9, 5);
INSERT INTO GRUPO_PASAJEROS VALUES (10, 6);
INSERT INTO GRUPO_PASAJEROS VALUES (10, 7);
INSERT INTO GRUPO_PASAJEROS VALUES (11, 8);
INSERT INTO GRUPO_PASAJEROS VALUES (12, 9);
INSERT INTO GRUPO_PASAJEROS VALUES (12, 10);
INSERT INTO GRUPO_PASAJEROS VALUES (12, 11);
INSERT INTO GRUPO_PASAJEROS VALUES (13, 1);
INSERT INTO GRUPO_PASAJEROS VALUES (13, 2);
INSERT INTO GRUPO_PASAJEROS VALUES (14, 12);
INSERT INTO GRUPO_PASAJEROS VALUES (15, 13);
INSERT INTO GRUPO_PASAJEROS VALUES (15, 14);
INSERT INTO GRUPO_PASAJEROS VALUES (15, 15);
INSERT INTO GRUPO_PASAJEROS VALUES (15, 16);
INSERT INTO GRUPO_PASAJEROS VALUES (16, 3);
INSERT INTO GRUPO_PASAJEROS VALUES (17, 17);
INSERT INTO GRUPO_PASAJEROS VALUES (17, 18);
INSERT INTO GRUPO_PASAJEROS VALUES (18, 19);
INSERT INTO GRUPO_PASAJEROS VALUES (19, 1);
INSERT INTO GRUPO_PASAJEROS VALUES (19, 3);
INSERT INTO GRUPO_PASAJEROS VALUES (19, 4);
INSERT INTO GRUPO_PASAJEROS VALUES (20, 20);
INSERT INTO GRUPO_PASAJEROS VALUES (20, 6);
INSERT INTO GRUPO_PASAJEROS VALUES (21, 5);
INSERT INTO GRUPO_PASAJEROS VALUES (22, 7);
INSERT INTO GRUPO_PASAJEROS VALUES (22, 8);
INSERT INTO GRUPO_PASAJEROS VALUES (22, 9);
INSERT INTO GRUPO_PASAJEROS VALUES (22, 10);
INSERT INTO GRUPO_PASAJEROS VALUES (23, 11);
INSERT INTO GRUPO_PASAJEROS VALUES (23, 12);
INSERT INTO GRUPO_PASAJEROS VALUES (23, 13);

------------------------------ TABLA DE HECHOS VUELO ------------------------------
INSERT INTO VUELO VALUES ('IB3425', 1, 1, 1, 1, 2, 1, 1, 1, 75.0, 78.5, 3.5, 505.0);  
INSERT INTO VUELO VALUES ('VY2105', 2, 1, 2, 2, 1, 2, 2, 2, 85.0, 82.0, 0, 620.0);        
INSERT INTO VUELO VALUES ('UX5032', 3, 2, 3, 3, 1, 3, 3, 3, 125.0, 130.0, 5.0, 920.0);    
INSERT INTO VUELO VALUES ('IB6721', 1, 3, 4, 4, 1, 1, 1, 4, 95.0, 98.0, 3.0, 680.0); 
INSERT INTO VUELO VALUES ('FR4582', 4, 4, 5, 5, 2, 4, 4, 5, 110.0, 105.0, 0, 780.0);  
INSERT INTO VUELO VALUES ('VY8934', 2, 5, 1, 1, 3, 2, 2, 6, 90.0, 95.0, 5.0, 625.0); 
INSERT INTO VUELO VALUES ('U28217', 3, 2, 2, 2, 4, 5, 5, 7, 80.0, 85.0, 5.0, 600.0);   
INSERT INTO VUELO VALUES ('UX7654', 5, 3, 3, 3, 1, 3, 3, 8, 140.0, 145.0, 5.0, 1050.0); 
INSERT INTO VUELO VALUES ('IB2301', 6, 6, 1, 2, 3, 1, 1, 9, 80.0, 82.0, 2.0, 620.0);  
INSERT INTO VUELO VALUES ('IB5512', 7, 7, 4, 1, 5, 1, 1, 10, 95.0, 100.0, 5.0, 680.0);
INSERT INTO VUELO VALUES ('IB9200', 8, 8, 1, 3, 2, 1, 2, 11, 120.0, 118.0, 0, 920.0);   
INSERT INTO VUELO VALUES ('VY1234', 9, 3, 2, 2, 5, 2, 2, 12, 85.0, 90.0, 5.0, 620.0);     
INSERT INTO VUELO VALUES ('VY7788', 10, 6, 2, 4, 1, 2, 1, 13, 70.0, 68.0, 0, 505.0);    
INSERT INTO VUELO VALUES ('VY3456', 11, 9, 1, 5, 3, 2, 2, 14, 100.0, 105.0, 5.0, 780.0);  
INSERT INTO VUELO VALUES ('UX1111', 12, 3, 3, 1, 4, 3, 3, 15, 140.0, 138.0, 0, 1050.0);  
INSERT INTO VUELO VALUES ('UX2222', 13, 10, 5, 2, 1, 3, 3, 16, 90.0, 95.0, 5.0, 625.0);  
INSERT INTO VUELO VALUES ('FR7890', 7, 11, 2, 5, 1, 4, 4, 17, 110.0, 115.0, 5.0, 780.0); 
INSERT INTO VUELO VALUES ('FR1122', 11, 8, 2, 3, 2, 4, 4, 18, 125.0, 122.0, 0, 920.0);  
INSERT INTO VUELO VALUES ('U23344', 8, 2, 1, 4, 2, 5, 5, 19, 95.0, 98.0, 3.0, 680.0);  
INSERT INTO VUELO VALUES ('U25566', 9, 7, 2, 1, 5, 5, 5, 20, 82.0, 85.0, 3.0, 600.0);  
INSERT INTO VUELO VALUES ('IB7001', 6, 1, 2, 3, 1, 1, 1, 21, 125.0, 130.0, 5.0, 920.0);  
INSERT INTO VUELO VALUES ('VY8002', 10, 4, 2, 1, 2, 2, 2, 22, 80.0, 75.0, 0, 505.0);     
INSERT INTO VUELO VALUES ('UX9003', 12, 9, 4, 5, 3, 3, 3, 23, 110.0, 108.0, 0, 780.0);   

COMMIT;