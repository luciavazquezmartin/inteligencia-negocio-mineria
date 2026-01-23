import csv

def generar_inserts(archivo_entrada='aerolinea.csv', archivo_salida='inserts_aerolinea.sql'):
    """
    Lee un archivo CSV de aerolíneas y genera un archivo SQL con sentencias INSERT.
    
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
                    codigo_dot = row['codigo_DOT'].strip()
                    nombre = row['nombre_aerolinea'].strip()
                    activo = row['esta_activo'].strip()
                    id_aerolinea = row['id_aerolinea'].strip()
                    
                    # Generar la sentencia INSERT con el orden solicitado
                    insert = (
                        f"INSERT INTO AEROLINEA VALUES "
                        f"({id_aerolinea}, '{codigo_dot}', '{nombre}', '{activo}');\n"
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
    