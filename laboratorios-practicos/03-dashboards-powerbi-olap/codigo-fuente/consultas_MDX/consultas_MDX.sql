-- ============================================================================
-- SCRIPT DE CONSULTAS MDX
-- ============================================================================

-- CONSULTA 1
SELECT
  -- ON COLUMS especifica las métricas que queremos ver
  {[Measures].[Total Vuelos], [Measures].[Retraso Promedio]} ON COLUMNS,

  -- ON ROWS define el eje de las filas 
  -- NON EMPTY elimina filas donde no hay datos 
  -- Crossjoin obtiene producto cartesiano de todos los estados y los meses 
  NON EMPTY Crossjoin(
    [Aeropuerto Origen].[Estado].Members,
    [Fecha].[Mes].Members
  ) ON ROWS
  
FROM [CuboVuelos]
-- WHERE es el filtro
WHERE ([Fecha].[Año].&[2025])

-- CONSULTA 2
SELECT
  {[Measures].[Total Vuelos]} ON COLUMNS,
  
-- TopCount toma un conjunto de datos (todas las combinaciones de rutas con Crossjoin), un número (5) y la métrica por la que ordenar
TopCount(
    Crossjoin(
      [Aeropuerto Origen].[Ciudad].Members,
      [Aeropuerto Destino].[Ciudad].Members
    ),
    5,
    [Measures].[Total Vuelos]
  ) ON ROWS
FROM [CuboVuelos]

-- CONSULTA 3
-- WITH MEMBER crea una medida calculada al vuelo (Retraso Total (Horas))
WITH
  MEMBER [Measures].[Retraso Total (Horas)] AS
   ([Measures].[Retraso Promedio] * [Measures].[Total Vuelos]) / 60,
   FORMAT_STRING = "#,##0.0 'h'"

SELECT
  {[Measures].[Total Vuelos], [Measures].[Retraso Promedio], [Measures].[Retraso Total (Horas)]} ON COLUMNS,
  
-- DrilldownLevel es una función jerárquica que coge "California" y    expande hacia abajo, mostrando sus "hijos" (ciudades)
-- Hierarchize asegura que la salida mantenga un orden jerárquico
  Hierarchize(
    DrilldownLevel(
      {[Aeropuerto Origen].[Estado].&[California]},
      [Aeropuerto Origen].[Ciudad]
    )
  ) ON ROWS
FROM [CuboVuelos]
WHERE ([Fecha].[Trimestre].&[1])
