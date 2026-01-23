import csv

def generar_inserts(archivo_entrada='fecha.csv', archivo_salida='inserts_fecha.sql'):
    """
    Lee un archivo CSV de fechas y genera un archivo SQL con sentencias INSERT.
    
    Args:
        archivo_entrada: Ruta al archivo CSV de entrada
        archivo_salida: Ruta al archivo SQL de salida
    """
    try:
        with open(archivo_entrada, 'r', encoding='utf-8') as f_entrada:
            # Leer el CSV
            reader = csv.DictReader(f_entrada)
            
            # Abrir archivo de salida
            with open(archivo_salida, 'w', encoding='utf-8') as f_salida:
                for row in reader:
                    # Extraer los valores del CSV (con espacios eliminados)
                    fecha_completa = row['fecha_completa'].strip()
                    agno = row['agno'].strip()
                    mes = row['mes'].strip()
                    dia = row['dia'].strip()
                    nombre_dia = row['nombre_dia'].strip()
                    nombre_mes = row['nombre_mes'].strip()
                    trimestre = row['trimestre'].strip()
                    temporada = row['temporada'].strip()
                    es_fin_semana = row['es_fin_semana'].strip()
                    id_fecha = row['id_fecha'].strip()                    
                 
                    # Generar la sentencia INSERT siguiendo el orden de la tabla
                    insert = (
                        f"INSERT INTO FECHA VALUES "
                        f"({id_fecha}, '{fecha_completa}', {dia}, "
                        f"{mes}, {agno}, '{nombre_dia}', "
                        f"'{nombre_mes}', {trimestre}, "
                        f"'{es_fin_semana}', '{temporada}');\n"
                    )
                    
                    f_salida.write(insert)
                
                print(f"Archivo generado exitosamente: {archivo_salida}")
                
    except FileNotFoundError:
        print(f"Error: No se encontró el archivo '{archivo_entrada}'")
    except KeyError as e:
        print(f"Error: Columna no encontrada en el CSV: {e}")
    except Exception as e:
        print(f"Error inesperado: {e}")

if __name__ == "__main__":
    # Ejecutar la función
    generar_inserts()