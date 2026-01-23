import csv

def generar_inserts(archivo_entrada='avion.csv', archivo_salida='inserts_avion.sql'):
    """
    Lee un archivo CSV de aviones y genera un archivo SQL con sentencias INSERT.
    
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
                    matricula = row['matricula'].strip()
                    agno = row['agno_fabricacion'].strip()
                    activo = row['esta_activo'].strip()
                    capacidad = row['capacidad_maxima'].strip()
                    fabricante = row['fabricante'].strip()
                    codigo_modelo = row['codigo_modelo'].strip()
                    nombre_modelo = row['nombre_modelo'].strip()
                    id_avion = row['id_avion'].strip()
                    
                    # Generar la sentencia INSERT
                    insert = (
                        f"INSERT INTO AVION VALUES "
                        f"({id_avion}, '{matricula}', '{codigo_modelo}', "
                        f"'{nombre_modelo}', '{fabricante}', {capacidad}, "
                        f"{agno}, '{activo}');\n"
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