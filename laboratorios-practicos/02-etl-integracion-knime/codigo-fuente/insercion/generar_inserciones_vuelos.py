import csv

def generar_inserts(archivo_entrada='vuelos.csv', archivo_salida='inserts_vuelos.sql'):
    """
    Lee un archivo CSV de vuelos y genera un archivo SQL con sentencias INSERT.
    Solo inserta vuelos con datos completos.
    
    Args:
        archivo_entrada: Ruta al archivo CSV de entrada
        archivo_salida: Ruta al archivo SQL de salida
    """
    try:
        with open(archivo_entrada, 'r', encoding='utf-8') as f_entrada:
            # Leer el CSV
            reader = csv.DictReader(f_entrada)
            
            # Contadores
            total_filas = 0
            filas_insertadas = 0
            filas_omitidas = 0
            
            # Abrir archivo de salida
            with open(archivo_salida, 'w', encoding='utf-8') as f_salida:
                for row in reader:
                    total_filas += 1
                    
                    # Extraer los valores del CSV (con espacios eliminados)
                    codigo_vuelo = row['codigo_vuelo'].strip().replace("'", "''")
                    id_fecha = row['id_fecha'].strip()
                    id_hora = row['id_hora'].strip()
                    id_avion = row['id_avion'].strip()
                    id_aeropuerto_origen = row['id_aeropuerto_origen'].strip()
                    id_aeropuerto_destino = row['id_aeropuerto_destino'].strip()
                    id_aerolinea = row['id_aerolinea'].strip()
                    id_operadora = row['id_operadora'].strip()
                    tiempo_estimado_minutos = row['tiempo_estimado_minutos'].strip()
                    tiempo_real_minutos = row['tiempo_real_minutos'].strip()
                    retardo_minutos = row['retardo_minutos'].strip()
                    distancia_km = row['distancia_km'].strip()
                    
                    # Verificar que todos los campos obligatorios estén completos
                    if not all([codigo_vuelo, id_fecha, id_hora, id_avion, 
                               id_aeropuerto_origen, id_aeropuerto_destino,
                               id_aerolinea, id_operadora, tiempo_estimado_minutos,
                               tiempo_real_minutos, retardo_minutos, distancia_km]):
                        filas_omitidas += 1
                        print(f"Fila {total_filas} omitida - Datos incompletos: {codigo_vuelo}")
                        continue
                    
                    # Generar la sentencia INSERT siguiendo el orden del CREATE TABLE
                    insert = (
                        f"INSERT INTO VUELO VALUES "
                        f"('{codigo_vuelo}', {id_fecha}, {id_hora}, "
                        f"{id_avion}, {id_aeropuerto_origen}, {id_aeropuerto_destino}, "
                        f"{id_aerolinea}, {id_operadora}, "
                        f"{tiempo_estimado_minutos}, {tiempo_real_minutos}, "
                        f"{retardo_minutos}, {distancia_km});\n"
                    )
                    
                    f_salida.write(insert)
                    filas_insertadas += 1
                
                print(f"\n{'='*50}")
                print(f"Archivo generado exitosamente: {archivo_salida}")
                print(f"Total de filas procesadas: {total_filas}")
                print(f"Filas insertadas: {filas_insertadas}")
                print(f"Filas omitidas (datos incompletos): {filas_omitidas}")
                print(f"{'='*50}")
                
    except FileNotFoundError:
        print(f"Error: No se encontró el archivo '{archivo_entrada}'")
    except KeyError as e:
        print(f"Error: Columna no encontrada en el CSV: {e}")
    except Exception as e:
        print(f"Error inesperado: {e}")

if __name__ == "__main__":
    # Ejecutar la función
    generar_inserts()