# ============================================================================
# SCRIPT FINAL: ANÁLISIS DE EVOLUCIÓN TEMPORAL
# OBJETIVO: Visualizar la serie temporal manteniendo coherencia con los clusters
# ============================================================================

# 1. PREPARACIÓN DEL ENTORNO
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("dplyr")) install.packages("dplyr")
if (!require("zoo")) install.packages("zoo")

library(ggplot2)
library(dplyr)
library(zoo)

# 2. OBTENCIÓN DE DATOS
print(">>> Descargando datos...")
url_datos <- "https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv"
datos_crudos <- read.csv(url_datos)

# Filtramos para quedarnos solo con países, eliminando agregados continentales
datos_filtrados <- datos_crudos[(!grepl("^OWID", datos_crudos$iso_code)) | 
                                  (datos_crudos$iso_code == "OWID_KOS"), ]

# 3. PROCESAMIENTO Y AGREGACIÓN DE DATOS
print(">>> Replicando lógica de agregación del Script 1...")

cols_interes <- c("location", "total_deaths_per_million", "stringency_index",
                  "gdp_per_capita", "population_density", "median_age",
                  "hospital_beds_per_thousand", "population")

df_temp <- datos_filtrados[, cols_interes]

# Calculamos métricas por país (máximos para acumulados, medias para índices)
agg_max <- aggregate(cbind(total_deaths_per_million, population) ~ location, 
                     data = df_temp, FUN = function(x) max(x, na.rm = TRUE))
agg_mean <- aggregate(cbind(stringency_index, gdp_per_capita, population_density,
                            median_age, hospital_beds_per_thousand) ~ location, 
                      data = df_temp, FUN = function(x) mean(x, na.rm = TRUE))

datos_paises <- merge(agg_max, agg_mean, by = "location")
datos_paises <- na.omit(datos_paises) # Limpieza de valores nulos
names(datos_paises) <- c("Pais", "Muertes_Millon", "Poblacion", "Rigurosidad_Media",
                         "PIB_per_Capita", "Densidad", "Edad_Media", "Camas_Hosp")

# 4. EJECUCIÓN DEL CLUSTERING (K-MEANS)
print(">>> Replicando Clustering...")

datos_clustering <- datos_paises[, c("Muertes_Millon", "Rigurosidad_Media",
                                     "PIB_per_Capita", "Densidad", 
                                     "Edad_Media", "Camas_Hosp")]
datos_escalados <- scale(datos_clustering)

set.seed(123) # Fijamos semilla para asegurar reproducibilidad
modelo_raw <- kmeans(datos_escalados, centers = 5, nstart = 50)
centros_raw <- modelo_raw$centers

# Reordenamos los clusters para mantener las mismas etiquetas que en el análisis previo
idx_5 <- which.max(centros_raw[, "Densidad"])
restantes <- setdiff(1:5, idx_5)
idx_1 <- restantes[which.max(centros_raw[restantes, "Edad_Media"])]
restantes <- setdiff(restantes, idx_1)
idx_2 <- restantes[which.min(centros_raw[restantes, "Edad_Media"])]
restantes <- setdiff(restantes, idx_2)
idx_4 <- restantes[which.max(centros_raw[restantes, "PIB_per_Capita"])]
idx_3 <- setdiff(restantes, idx_4)

mapa_cambio <- numeric(5)
mapa_cambio[idx_1] <- 1; mapa_cambio[idx_2] <- 2; mapa_cambio[idx_3] <- 3
mapa_cambio[idx_4] <- 4; mapa_cambio[idx_5] <- 5

datos_paises$Grupo_Cluster <- as.factor(mapa_cambio[modelo_raw$cluster])

# 5. CONSTRUCCIÓN DE LA SERIE TEMPORAL
print(">>> Cruzando datos temporales con los Clusters calculados...")

# Recuperamos la variable fecha del dataset original
df_tiempo_raw <- datos_filtrados[, c("location", "date", "stringency_index")]
df_tiempo_raw$date <- as.Date(df_tiempo_raw$date)

# Cruzamos la información diaria con el cluster asignado a cada país
datos_grafico <- df_tiempo_raw %>%
  inner_join(datos_paises[, c("Pais", "Grupo_Cluster")], by = c("location" = "Pais")) %>%
  filter(date >= "2020-03-01" & date <= "2021-05-01")

# Calculamos la evolución diaria y suavizamos la curva (media móvil 7 días)
curvas_tiempo <- datos_grafico %>%
  group_by(Grupo_Cluster, date) %>%
  summarise(Rigor_Diario = mean(stringency_index, na.rm = TRUE), .groups = 'drop') %>%
  group_by(Grupo_Cluster) %>%
  mutate(Rigor_Suavizado = rollmean(Rigor_Diario, k = 7, fill = NA)) %>%
  na.omit()

# 6. CÁLCULO DE ETIQUETAS DE REFERENCIA
# Usamos los datos agregados por país para que la media mostrada coincida con la tabla resumen
etiquetas_medias <- datos_paises %>%
  group_by(Grupo_Cluster) %>%
  summarise(
    Media_Oficial = round(mean(Rigurosidad_Media), 1)
  )

# Posicionamiento de la etiqueta en el gráfico
etiquetas_medias$date <- as.Date("2021-04-15") # Coordenada X
etiquetas_medias$y <- 90                        # Coordenada Y

# 7. GENERACIÓN DEL GRÁFICO
print(">>> Generando gráfico sincronizado...")

colores <- c("#8E44AD", "#27AE60", "#E74C3C", "#7F8C8D", "#3498DB")
nombres <- c("1"="C1: Europa/Viejos", "2"="C2: Jóvenes", "3"="C3: Estándar", 
             "4"="C4: Ricos", "5"="C5: Densos")

g_sync <- ggplot(curvas_tiempo, aes(x = date, y = Rigor_Suavizado)) +
  
  # Trazado de la línea temporal (usamos linewidth para evitar warning)
  geom_line(aes(color = Grupo_Cluster), linewidth = 1.2) +
  
  # Añadimos la etiqueta con la media calculada previamente
  geom_label(data = etiquetas_medias, 
             aes(x = date, y = y, 
                 label = paste("Media:", Media_Oficial),
                 color = Grupo_Cluster),
             fill = "white", fontface = "bold", size = 3.5, hjust = 1) +
  
  # Separación por paneles (uno por cluster)
  facet_wrap(~ Grupo_Cluster, ncol = 1, labeller = as_labeller(nombres)) +
  
  # Ajustes de estilo y escalas
  scale_color_manual(values = colores) +
  scale_y_continuous(limits = c(0, 100), name = "Índice de Rigurosidad") +
  scale_x_date(date_breaks = "2 months", date_labels = "%b %y") +
  
  # Títulos limpios
  labs(title = "Evolución de la 'Mano Dura'",
       x = "") +
  
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    strip.text = element_text(face = "bold", size = 11, color = "white"),
    strip.background = element_rect(fill = "#2C3E50"),
    panel.grid.minor = element_blank(),
    # Centramos el título (hjust=0.5) y lo ponemos en negrita (face="bold")
    plot.title = element_text(face = "bold", hjust = 0.5)
  )

dir.create("graficos_covid", showWarnings = FALSE)
ggsave("graficos_covid/09_rigurosidad_sincronizada.png", g_sync, width = 10, height = 12, bg = "white")

print(">>> Gráfico generado: 09_rigurosidad_sincronizada.png")
