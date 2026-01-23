import csv

def generar_inserts(archivo_entrada='hora.csv', archivo_salida='inserts_hora.sql'):
    """
    Lee un archivo CSV de horas y genera un archivo SQL con sentencias INSERT.
    
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
                    hora_completa = row['hora_completa'].strip()
                    hora = row['hora'].strip()
                    minuto = row['minuto'].strip()
                    segundo = row['segundo'].strip()
                    franja_horaria = row['franja_horaria'].strip()
                    es_hora_punta = row['es_hora_punta'].strip()
                    id_hora = row['id_hora'].strip()

                    # Generar la sentencia INSERT
                    insert = (
                        f"INSERT INTO HORA VALUES "
                        f"({id_hora}, '{hora_completa}', {hora}, "
                        f"{minuto}, {segundo}, "
                        f"'{franja_horaria}', '{es_hora_punta}');\n"
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