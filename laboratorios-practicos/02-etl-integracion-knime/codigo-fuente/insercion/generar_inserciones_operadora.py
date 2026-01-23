import csv

def generar_inserts(archivo_entrada='operadora.csv', archivo_salida='inserts_operadora.sql'):
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
                    nombre_operadora = row['nombre_operadora'].strip()
                    esta_activo = row['esta_activo'].strip()
                    codigo_IATA = row['codigo_IATA'].strip()
                    id_operadora = row['id_operadora'].strip()
                    
                    # Generar la sentencia INSERT
                    insert = (
                        f"INSERT INTO OPERADORA VALUES "
                        f"({id_operadora}, '{codigo_IATA}', "
                        f" '{nombre_operadora}', '{esta_activo}');\n"
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