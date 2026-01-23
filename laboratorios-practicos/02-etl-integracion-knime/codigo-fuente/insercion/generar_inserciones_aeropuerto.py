import csv

def generar_inserts(archivo_entrada='aeropuerto.csv', archivo_salida='inserts_aeropuerto.sql'):
    """
    Lee un archivo CSV de aeropuertos y genera un archivo SQL con sentencias INSERT.
    
    Args:
        archivo_entrada: Ruta al archivo CSV de entrada
        archivo_salida: Ruta al archivo SQL de salida
    """
    try:
        with open(archivo_entrada, 'r', encoding='utf-8') as f_entrada:
            # Leer el CSV
            reader = csv.DictReader(f_entrada)
            
            # Diccionario de códigos para territorios
            codigos_territorios = {
                'Puerto Rico': 'PR',
                'Guam': 'GU',
                'American Samoa': 'AS',
                'Northern Mariana Islands': 'MP',
                'Virgin Islands': 'VI'
            }
            
            # Abrir archivo de salida
            with open(archivo_salida, 'w', encoding='utf-8') as f_salida:
                for row in reader:
                    # Extraer los valores del CSV (con espacios eliminados)
                    codigo_IATA = row['codigo_IATA'].strip()
                    nombre_aeropuerto = row['nombre_aeropuerto'].strip().replace("'", "''")
                    pais = row['pais'].strip().replace("'", "''")
                    estado = row['estado'].strip().replace("'", "''")
                    codigo_estado = row['codigo_estado'].strip()
                    ciudad = row['ciudad'].strip().replace("'", "''")
                    latitud = row['latitud'].strip()    
                    longitud = row['longitud'].strip()  
                    id_aeropuerto = row['id_aeropuerto'].strip()
                    zona_horaria = row['zona_horaria'].strip()
                    num_habitantes = row['num_habitantes'].strip() if row['num_habitantes'].strip() else 'NULL'

                    
                    # Si estado está vacío, usar el nombre del país como estado
                    if not estado or estado == '':
                        estado = pais
                    
                    # Si código de estado está vacío, buscar en el diccionario o usar el del país
                    if not codigo_estado or codigo_estado == '':
                        codigo_estado = codigos_territorios.get(pais, pais[:2].upper())
                    
                    # Generar la sentencia INSERT
                    insert = (
                        f"INSERT INTO AEROPUERTO VALUES "
                        f"({id_aeropuerto}, '{codigo_IATA}', '{nombre_aeropuerto}', "
                        f"'{ciudad}', '{estado}', "
                        f"'{codigo_estado}', '{pais}', "
                        f"{latitud}, {longitud}, {num_habitantes}, '{zona_horaria}');\n"
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