# ============================================================================
# PROYECTO FINAL: MINERÍA DE DATOS SOBRE COVID-19
# TEMA: Relación entre la gestión gubernamental y el impacto en mortalidad
# NOTA: Uso K=5 clusters con identidades fijas para mantener consistencia visual
# ============================================================================

# --- 1. PREPARACIÓN DEL ENTORNO DE TRABAJO ---------------------------------
# Cargo todas las librerías necesarias para el análisis y los gráficos.
# Incluyo verificaciones de instalación por si cambio de ordenador.
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("ggthemes")) install.packages("ggthemes")
if (!require("scales")) install.packages("scales")
if (!require("gridExtra")) install.packages("gridExtra")
if (!require("ggrepel")) install.packages("ggrepel")
if (!require("dplyr")) install.packages("dplyr")
if (!require("corrplot")) install.packages("corrplot")
if (!require("RColorBrewer")) install.packages("RColorBrewer")
if (!require("grid")) install.packages("grid")
if (!require("dendextend")) install.packages("dendextend") 

library(ggplot2)
library(ggthemes)
library(scales)
library(gridExtra)
library(ggrepel)
library(dplyr)
library(corrplot)
library(RColorBrewer)
library(grid)
library(dendextend)

# ============================================================================
# PARTE 1: OBTENCIÓN Y LIMPIEZA DEL DATASET (ETL)
# ============================================================================
options(timeout = 600)
print(">>> 1. DESCARGANDO DATOS DESDE OWID...")

# Conecto directamente con el repositorio de Our World in Data
url_datos <- "https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv"
datos_crudos <- read.csv(url_datos)

# Limpieza: Me quedo solo con los países, eliminando agrupaciones como "World" o "Europe"
datos_filtrados <- datos_crudos[(!grepl("^OWID", datos_crudos$iso_code)) | 
                                  (datos_crudos$iso_code == "OWID_KOS"), ]

# Selecciono las variables clave para mi estudio
cols_interes <- c("location", "total_deaths_per_million", "stringency_index",
                  "gdp_per_capita", "population_density", "median_age",
                  "hospital_beds_per_thousand", "population")

df_temp <- datos_filtrados[, cols_interes]

# Agregación de datos:
# - Para muertes uso el MAX (acumulado total)
# - Para las demás métricas uso la MEDIA (promedio del periodo)
agg_max <- aggregate(cbind(total_deaths_per_million, population) ~ location, 
                     data = df_temp, FUN = function(x) max(x, na.rm = TRUE))
agg_mean <- aggregate(cbind(stringency_index, gdp_per_capita, population_density,
                            median_age, hospital_beds_per_thousand) ~ location, 
                      data = df_temp, FUN = function(x) mean(x, na.rm = TRUE))

# Uno todo en un único dataframe final por país y limpio nulos
datos_paises <- merge(agg_max, agg_mean, by = "location")
datos_paises <- na.omit(datos_paises)
names(datos_paises) <- c("Pais", "Muertes_Millon", "Poblacion", "Rigurosidad_Media",
                         "PIB_per_Capita", "Densidad", "Edad_Media", "Camas_Hosp")

print(paste(" -> Analizando", nrow(datos_paises), "países."))

# ============================================================================
# PARTE 2: MODELADO (K-MEANS) Y ASIGNACIÓN DE IDENTIDADES
# ============================================================================
print(">>> 2. EJECUTANDO K-MEANS CON ASIGNACIÓN DE IDENTIDAD FIJA...")

# Preparo los datos para el algoritmo (saco el nombre del país)
datos_clustering <- datos_paises[, c("Muertes_Millon", "Rigurosidad_Media",
                                     "PIB_per_Capita", "Densidad", 
                                     "Edad_Media", "Camas_Hosp")]
# IMPORTANTE: Escalo los datos para que el PIB no domine sobre las variables pequeñas
datos_escalados <- scale(datos_clustering)

# 1. Ejecución del K-Means
set.seed(123) # Semilla fija para reproducibilidad
modelo_raw <- kmeans(datos_escalados, centers = 5, nstart = 50)
centros_raw <- modelo_raw$centers

# 2. LOGICA DE REORDENAMIENTO:
# Aquí fuerzo que los clusters tengan siempre el mismo número según su perfil.
# Así me aseguro de que el cluster "Viejo" sea siempre el C1 (Morado), etc.

# A) Identifico C5 (AZUL): El que tiene máxima Densidad
idx_5 <- which.max(centros_raw[, "Densidad"])

# B) Identifico C1 (MORADO): De los que quedan, el más envejecido
restantes <- setdiff(1:5, idx_5)
idx_1 <- restantes[which.max(centros_raw[restantes, "Edad_Media"])]

# C) Identifico C2 (VERDE): De los que quedan, el más joven
restantes <- setdiff(restantes, idx_1)
idx_2 <- restantes[which.min(centros_raw[restantes, "Edad_Media"])]

# D) Identifico C4 (GRIS): De los que quedan, el más rico
restantes <- setdiff(restantes, idx_2)
idx_4 <- restantes[which.max(centros_raw[restantes, "PIB_per_Capita"])]

# E) Identifico C3 (ROJO): El bloque restante (Intermedio)
idx_3 <- setdiff(restantes, idx_4)

# 3. Creo el mapa de traducción de IDs originales a mis IDs deseados
mapa_cambio <- numeric(5)
mapa_cambio[idx_1] <- 1 # Edad Avanzada -> 1
mapa_cambio[idx_2] <- 2 # Joven -> 2
mapa_cambio[idx_3] <- 3 # Resto -> 3
mapa_cambio[idx_4] <- 4 # Altos Ingresos -> 4
mapa_cambio[idx_5] <- 5 # Densidad -> 5

# 4. Aplico los nuevos IDs al dataframe
datos_paises$Grupo_Cluster <- as.factor(mapa_cambio[modelo_raw$cluster])

# 5. Defino mi paleta de colores corporativa para todo el trabajo
# 1:Morado, 2:Verde, 3:Rojo, 4:Gris, 5:Azul
colores_clusters <- c("#8E44AD", "#27AE60", "#E74C3C", "#7F8C8D", "#3498DB")

# Preparo carpeta de salida
dir.create("graficos_covid", showWarnings = FALSE)
print(">>> Clusters reordenados correctamente.")

# ============================================================================
# PARTE 3: GENERACIÓN DE GRÁFICOS PARA EL INFORME
# ============================================================================

# --- CONFIGURACIÓN DE LEYENDA GLOBAL ---
# Defino aquí los nombres para que sean idénticos en todas las figuras
etiquetas_leyenda_global <- c(
  "C1: Edad Avanzada / Occidente", 
  "C2: Población Joven / Desarrollo",
  "C3: Estándar Global / Intermedio",
  "C4: Altos Ingresos / Estables",
  "C5: Alta Densidad / Microestados"
)
titulo_leyenda_global <- "Perfiles Demográficos"

# ----------------------------------------------------------------------------
# GRÁFICO 1: JUSTIFICACIÓN DE K (MÉTODO DEL CODO)
# ----------------------------------------------------------------------------
print(">>> Generando Gráfico 1: Espectro Completo con Selección...")

# Calculo la inercia para todos los K posibles para ver la curva completa
max_k <- nrow(datos_escalados) - 1 
inercias <- numeric(max_k)

print(paste("    Calculando curva completa hasta K =", max_k))

for(k in 1:max_k) {
  inercias[k] <- kmeans(datos_escalados, centers = k, nstart = 10)$tot.withinss
}

df_codo <- data.frame(K = 1:max_k, Inercia = inercias)

# Visualizo el codo y marco mi elección (K=5)
grafico_codo_full <- ggplot(df_codo, aes(x = K, y = Inercia)) +
  # Trazado de la curva (linewidth)
  geom_line(color = "#2C3E50", linewidth = 0.8) +
  geom_point(color = "#2C3E50", size = 1, alpha = 0.3) +
  
  # Destaco el punto elegido (K=5)
  geom_point(data = df_codo[df_codo$K == 5, ], 
             aes(x = K, y = Inercia), 
             color = "#E74C3C", size = 5, shape = 21, fill = "white", stroke = 2) +
  
  # Flecha señalizadora (linewidth)
  annotate("segment", 
           x = 15, y = inercias[5] + 200, 
           xend = 5.5, yend = inercias[5] + 20,
           arrow = arrow(length = unit(0.3, "cm")), 
           color = "#E74C3C", linewidth = 1.2) +
  
  # Anotación justificativa
  annotate("text", x = 16, y = inercias[5] + 200, 
           label = "Elección: K=5\n(Inicio de la estabilidad)", 
           color = "#E74C3C", size = 5, fontface = "bold", hjust = 0) +
  
  labs(title = "Método del Codo: Análisis de Espectro Completo",
       subtitle = "Justificación: Se observa claramente que aumentar la complejidad más allá de K=5 no aporta valor significativo",
       x = "Número de Clusters (K)",
       y = "Inercia Total (Varianza Intra-Clase)") +
  
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
        plot.subtitle = element_text(size = 11, hjust = 0.5, color = "gray40"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "gray90"))

ggsave("graficos_covid/01_metodo_codo_seleccion.png", grafico_codo_full, 
       width = 12, height = 7, dpi = 300, bg = "white")

print(">>> Gráfico generado: 01_metodo_codo_seleccion.png")

# ----------------------------------------------------------------------------
# GRÁFICO 2: DENDROGRAMA (JERARQUÍA VISUAL)
# ----------------------------------------------------------------------------
print(">>> Generando Gráfico 2: Dendrograma Completo Ajustado...")

# Preparo clustering jerárquico para comparar
datos_dendro <- datos_escalados
rownames(datos_dendro) <- datos_paises$Pais
hc <- hclust(dist(datos_dendro), method = "ward.D2")

# Lógica para colorear las cajas del dendrograma según mis clusters de K-Means
grupos_hc <- cutree(hc, k = 5)
mapa_color_rectangulo <- character(5)

for(g in 1:5) {
  paises_en_grupo <- names(grupos_hc)[grupos_hc == g]
  clusters_reales <- datos_paises$Grupo_Cluster[datos_paises$Pais %in% paises_en_grupo]
  # Asigno el color según la mayoría de países en esa rama
  cluster_ganador <- names(sort(table(clusters_reales), decreasing = TRUE))[1]
  mapa_color_rectangulo[g] <- colores_clusters[as.numeric(cluster_ganador)]
}
orden_visual <- unique(grupos_hc[hc$order])
colores_bordes_ordenados <- mapa_color_rectangulo[orden_visual]

# Generación del plot (uso PNG base porque dendrogramas en ggplot son complejos)
png("graficos_covid/02_dendrograma.png", width = 8000, height = 3500, res = 300)
par(mar = c(17, 5, 6, 2)) 

# A) Dibujo estructura
plot(as.dendrogram(hc), 
     main = "", sub = "", xlab = "", ylab = "Altura (Disimilitud)",
     cex.lab = 1.5, font.lab = 2, leaflab = "none") 

# B) Añado títulos
mtext("Dendrograma Global Ajustado", side = 3, line = 3, cex = 2.5, font = 2, col = "#2C3E50")
mtext("Países coloreados según K-Means", 
      side = 3, line = 1, cex = 1.8, font = 3, col = "gray40")

# C) Recuadros de colores
par(lwd = 3) # Trazo grueso
rect.hclust(hc, k = 5, border = colores_bordes_ordenados)
par(lwd = 1) # Restauro trazo

# D) Etiquetas de los países
par(xpd = TRUE) 
etiquetas_ordenadas <- labels(as.dendrogram(hc))
n_puntos <- length(etiquetas_ordenadas)
grupos_del_pais <- datos_paises$Grupo_Cluster[match(etiquetas_ordenadas, datos_paises$Pais)]
colores_texto <- colores_clusters[as.numeric(grupos_del_pais)]

text(x = 1:n_puntos, y = -max(hc$height) * 0.05,    
     labels = etiquetas_ordenadas, srt = 90, adj = c(1, 0.5),          
     cex = 1.1, font = 2, col = colores_texto)

# E) Leyenda manual
legend("topleft", 
       legend = etiquetas_leyenda_global,
       title = titulo_leyenda_global,
       col = colores_clusters,        
       pch = 19,                      
       pt.cex = 2.4,                    
       cex = 1.4,                       
       text.col = "black",  
       title.font = 2,
       bty = "n",                     
       inset = c(0.025, -0.08))           

dev.off()

print(">>> Gráfico generado: 02_dendrograma.png")

# ----------------------------------------------------------------------------
# GRÁFICO 3: ANÁLISIS CENTRAL (RIGUROSIDAD VS MUERTES)
# ----------------------------------------------------------------------------
print(">>> Generando Gráfico 3: Regresión Central...")

# Selección de países clave para etiquetar en el gráfico
conf_paises_vip <- c("Peru", "Spain", "Italy", "United Kingdom", "Belgium", 
                     "Australia", "United States", "Sweden",
                     "Kenya", "Ethiopia", "Ghana",                     
                     "Brazil", "India", "China",
                     "Afghanistan", "Tanzania", "Yemen",
                     "Singapore")

# Textos explicativos para el gráfico
conf_txt_paradoja <- "Paradoja: A más restricciones, más mortalidad (Pendiente +"
conf_txt_clave    <- "CLAVE DEL ANÁLISIS:\n\nLos puntos morados (C1)\nestán arriba: Países\nenvejecidos con alto impacto.\n\nLos puntos verdes (C2)\nestán abajo: Países\njóvenes con baja mortalidad."

# Cálculo de la pendiente de regresión para mostrarla
datos_vip <- datos_paises[datos_paises$Pais %in% conf_paises_vip, ]
modelo <- lm(Muertes_Millon ~ Rigurosidad_Media, data = datos_paises)
pendiente <- round(coef(modelo)[2], 2)
conf_txt_paradoja_full <- paste0(conf_txt_paradoja, pendiente, ")")

# Ajustes visuales de ejes
limite_eje_x <- 118        
centro_barra_lateral <- 98 

# Construcción del Scatter Plot
grafico_central <- ggplot(datos_paises, aes(x = Rigurosidad_Media, y = Muertes_Millon)) +
  
  # 1. Puntos y Línea de Tendencia (linewidth)
  geom_point(aes(color = Grupo_Cluster), size = 4.5, alpha = 0.8) +
  geom_smooth(method = "lm", se = TRUE, color = "#E67E22", 
              fill = "#E67E22", alpha = 0.15, linetype = "dashed", linewidth = 1.2) +
  
  # 2. Etiquetas de países VIP (evitando solapamientos)
  geom_text_repel(data = datos_vip, aes(label = Pais), 
                  size = 3.5, fontface = "bold", color = "#2C3E50",
                  box.padding = 0.5, max.overlaps = 30) +
  
  # 3. Configuración de colores
  scale_color_manual(values = colores_clusters, 
                     labels = etiquetas_leyenda_global,
                     name = titulo_leyenda_global) +
  
  # Eje X
  scale_x_continuous(breaks = seq(0, 100, 20)) + 
  
  # 4. Anotación de la Paradoja
  annotate("text", x = 0, y = 6000,
           label = conf_txt_paradoja_full,
           color = "#C0392B", size = 5, fontface = "bold", hjust = 0) +
  
  # 5. Caja explicativa lateral (AQUÍ ESTABA EL ERROR DE LABEL.SIZE)
  geom_label(data = data.frame(x = centro_barra_lateral, y = 1800, label = conf_txt_clave),
             aes(x = x, y = y, label = label),
             color = "gray20", size = 4.1, fontface = "italic", hjust = 0.5,
             fill = "#ECF0F1", 
             linewidth = NA,  # <--- CORREGIDO: Usamos linewidth = NA para quitar borde
             label.padding = unit(1, "lines"),
             inherit.aes = FALSE) + 
  
  # Títulos y Etiquetas
  labs(title = "Rigurosidad vs. Mortalidad",
       x = "Índice de Rigurosidad Promedio (0-100)", y = "Muertes Totales por Millón") +
  
  # Ajuste de coordenadas (clip off para pintar fuera de margen si es necesario)
  coord_cartesian(xlim = c(0, limite_eje_x), ylim = c(-100, 6500), clip = "off") + 
  
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold", size = 18, hjust = 0.5, color = "#2C3E50"),
        plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray50"),
        
        legend.position = c(0.8, 0.75), 
        legend.justification = "center",
        legend.title = element_text(face = "bold", size = 13, hjust = 0.5),
        legend.text = element_text(size = 12),                              
        legend.key.height = unit(0.6, "cm"), 
        
        panel.grid.minor = element_blank(),
        plot.margin = margin(t = 10, r = 10, b = 10, l = 10)) 

ggsave("graficos_covid/03_analisis_central.png", grafico_central, 
       width = 14, height = 9, dpi = 300, bg = "white")

print(">>> Gráfico generado: 03_analisis_central.png")

# ----------------------------------------------------------------------------
# GRÁFICO 4: BOXPLOTS COMPARATIVOS
# ----------------------------------------------------------------------------
print(">>> Generando Gráfico 4: Boxplots...")

datos_edad <- datos_paises %>% mutate(Cluster_Nombre = paste("C", Grupo_Cluster))

# Sub-gráfico 1: Distribución de Edad por cluster
g_edad <- ggplot(datos_edad, aes(x = Cluster_Nombre, y = Edad_Media, fill = Grupo_Cluster)) +
  geom_boxplot(alpha = 0.7) + 
  scale_fill_manual(values = colores_clusters, 
                    labels = etiquetas_leyenda_global, name = titulo_leyenda_global) +
  labs(title = "Edad Media", x = "") + 
  theme_minimal() + 
  theme(
    legend.position = "none",
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold") 
  )

# Sub-gráfico 2: Distribución de Mortalidad por cluster
g_mort <- ggplot(datos_edad, aes(x = Cluster_Nombre, y = Muertes_Millon, fill = Grupo_Cluster)) +
  geom_boxplot(alpha = 0.7) + 
  scale_fill_manual(values = colores_clusters,
                    labels = etiquetas_leyenda_global, name = titulo_leyenda_global) +
  labs(title = "Mortalidad", x = "") + 
  theme_minimal() + 
  theme(
    legend.position = "none",
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold") 
  )

# Combino ambos en una sola imagen
g_box <- grid.arrange(g_edad, g_mort, ncol = 2,
                      top = textGrob("Distribución de Edad y Mortalidad por Cluster", 
                                     gp = gpar(fontsize=16, fontface="bold")))

ggsave("graficos_covid/04_boxplots_edad_mortalidad.png", g_box, width = 14, height = 7, dpi = 300, bg = "white")

print(">>> Gráfico generado: 04_boxplots_edad_mortalidad.png")

# ----------------------------------------------------------------------------
# GRÁFICOS 5 y 6: ANÁLISIS ECONÓMICO Y POBLACIONAL
# ----------------------------------------------------------------------------
print(">>> Generando Gráficos 5 y 6...")

# Lista extendida de países para estos gráficos específicos
conf_paises_vip_ext <- c("Peru", "Spain", "Italy", "United Kingdom", "Belgium", 
                         "Australia", "United States", "Sweden",
                         "Kenya", "Ethiopia", "Ghana",                     
                         "Brazil", "India",
                         "Afghanistan", "Tanzania", "Yemen",
                         "Singapore")

datos_vip_ext <- datos_paises[datos_paises$Pais %in% conf_paises_vip_ext, ]

# --- GRÁFICO 5: PARADOJA DE LA RIQUEZA (PIB vs Muertes) ---
g_pib <- ggplot(datos_paises, aes(x = log(PIB_per_Capita), y = Muertes_Millon)) +
  
  # Capa de puntos
  geom_point(aes(color = Grupo_Cluster), size = 3.5, alpha = 0.7) +
  
  # Línea de tendencia (linewidth)
  geom_smooth(method = "lm", se = TRUE, color = "#E67E22", 
              fill = "#E67E22", alpha = 0.15, linetype = "dashed", linewidth = 1.2) +
  
  # Etiquetas de países
  geom_text_repel(data = datos_vip_ext, aes(label = Pais), 
                  size = 3.5, fontface = "bold", color = "#2C3E50",
                  box.padding = 0.5, point.padding = 0.3,
                  max.overlaps = 50, min.segment.length = 0) +
  
  # Colores
  scale_color_manual(values = colores_clusters,
                     labels = etiquetas_leyenda_global, 
                     name = titulo_leyenda_global) +
  
  # Títulos
  labs(title = "Paradoja de la Riqueza", 
       subtitle = "Relación entre PIB (Log) y Mortalidad",
       x = "PIB per Cápita (Escala Logarítmica)", 
       y = "Muertes por Millón") + 
  
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16, color = "#2C3E50", hjust = 0.5),
    plot.subtitle = element_text(size = 12, color = "gray50", hjust = 0.5),
    legend.position = c(0.02, 0.98), 
    legend.justification = c("left", "top"),
    legend.title = element_text(face = "bold", size = 11, hjust = 0.5), 
    legend.text = element_text(size = 10),                              
    legend.background = element_rect(fill = alpha("white", 0.8), color = NA),
    legend.key = element_blank()
  )

ggsave("graficos_covid/05_paradoja_riqueza.png", g_pib, width = 14, height = 8, bg = "white")


# --- GRÁFICO 6: TAMAÑO POBLACIONAL (Control) ---
g_pob <- ggplot(datos_paises, aes(x = log(Poblacion), y = Muertes_Millon)) +
  
  # Capa de puntos
  geom_point(aes(color = Grupo_Cluster), size = 3.5, alpha = 0.7) +
  
  # Línea de tendencia (linewidth)
  geom_smooth(method = "lm", se = TRUE, color = "#E67E22", 
              fill = "#E67E22", alpha = 0.15, linetype = "dashed", linewidth = 1.2) +
  
  # Etiquetas
  geom_text_repel(data = datos_vip_ext, aes(label = Pais), 
                  size = 3.5, fontface = "bold", color = "#2C3E50",
                  box.padding = 0.5, point.padding = 0.3,
                  max.overlaps = 50, min.segment.length = 0) +
  
  # Colores
  scale_color_manual(values = colores_clusters,
                     labels = etiquetas_leyenda_global, 
                     name = titulo_leyenda_global) +
  
  # Títulos
  labs(title = "Control Poblacional", 
       subtitle = "Relación entre Población (Log) y Mortalidad",
       x = "Población (log)", y = "Muertes por Millón") + 
  
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16, color = "#2C3E50", hjust = 0.5),
    plot.subtitle = element_text(size = 12, color = "gray50", hjust = 0.5),
    legend.position = c(0.02, 0.98), 
    legend.justification = c("left", "top"),
    legend.title = element_text(face = "bold", size = 11, hjust = 0.5),
    legend.text = element_text(size = 10),                              
    
    legend.background = element_rect(fill = alpha("white", 0.8), color = NA)
  )

ggsave("graficos_covid/06_poblacion_control.png", g_pob, width = 14, height = 8, bg = "white")

print(">>> Gráficos generados: 05_paradoja_poblacion.png y 06_poblacion_control.png")

# ----------------------------------------------------------------------------
# EXTRAS: MATRIZ DE CORRELACIÓN Y TABLA FINAL
# ----------------------------------------------------------------------------

# GRÁFICO EXTRA 1: MATRIZ DE CORRELACIONES
print(">>> Generando Gráfico Extra 1: Matriz...")

# Selecciono variables y renombro para la matriz
vars_correlacion <- datos_paises[, c("Muertes_Millon", "Rigurosidad_Media", 
                                     "PIB_per_Capita", "Edad_Media", 
                                     "Densidad", "Camas_Hosp")]
colnames(vars_correlacion) <- c("Muertes", "Rigurosidad", "PIB", "Edad", "Densidad", "Camas")
correlaciones <- cor(vars_correlacion, use = "complete.obs")

# Guardo el plot
png("graficos_covid/07_matriz_correlaciones.png", width = 2800, height = 2800, res = 300)
corrplot(correlaciones, method = "color", type = "upper", addCoef.col = "black",
         tl.col = "black", tl.srt = 45, col = colorRampPalette(c("#3498DB", "white", "#E74C3C"))(200),
         title = "Matriz de Correlaciones", mar = c(0, 0, 2, 0))
dev.off()

print(">>> Gráfico generado: 07_matriz_correlaciones.png")

# GRÁFICO EXTRA 2: TABLA RESUMEN EJECUTIVA
print(">>> Generando la Gran Tabla Resumen...")

# 1. Calculo las medias por cluster para ver los perfiles
resumen_clusters <- datos_paises %>%
  group_by(Grupo_Cluster) %>%
  summarise(
    N = n(),
    Edad = round(mean(Edad_Media), 1),
    PIB = round(mean(PIB_per_Capita), 0),
    Densidad = round(mean(Densidad), 0),
    Rigor = round(mean(Rigurosidad_Media), 1),
    Mortalidad = round(mean(Muertes_Millon), 0)
  )

# 2. Añado los nombres descriptivos
nombres_perfiles <- c(
  "Edad Avanzada / Occidente",   # C1
  "Población Joven / Desarrollo",# C2
  "Estándar Global / Intermedio",# C3
  "Altos Ingresos / Estables",   # C4
  "Alta Densidad / Microestados" # C5
)

resumen_clusters$Perfil <- nombres_perfiles

# 3. Reordeno columnas para contar la historia de izquierda a derecha
tabla_final <- resumen_clusters[, c("Grupo_Cluster", "Perfil", "N", "Edad", "PIB", "Densidad", "Rigor", "Mortalidad")]

# 4. Nombres limpios para la cabecera
colnames(tabla_final) <- c("ID", "Perfil Demográfico", "Nº Países", "Edad Media", "PIB p.c.", "Densidad", "Rigurosidad", "Muertes/Millón")

# 5. Estilo visual de la tabla
t1 <- ttheme_default(
  core = list(
    fg_params = list(fontsize = 9, hjust = 0, x = 0.1), 
    bg_params = list(fill = c("white", "#F4F6F7"))
  ),
  colhead = list(
    fg_params = list(fontsize = 10, fontface = "bold", col = "white"),
    bg_params = list(fill = "#2C3E50")
  )
)

# Renderizado de la tabla en imagen
png("graficos_covid/08_tabla_clusters.png", width = 4800, height = 1200, res = 300)

grid.arrange(
  tableGrob(tabla_final, rows = NULL, theme = t1),
  top = textGrob("Resumen Ejecutivo: Perfiles, Gestión e Impacto", 
                 gp = gpar(fontsize = 18, fontface = "bold", col = "#2C3E50")),
  bottom = textGrob("Nota: La 'Densidad' explica el Cluster 5. La 'Edad' correlaciona fuertemente con la 'Mortalidad' (C1 vs C2).", 
                    gp = gpar(fontsize = 10, fontface = "italic", col = "gray50"))
)

dev.off()

print(">>> Gráfico generado: 08_tabla_clusters.png")

# ============================================================================
# FINALIZACIÓN DEL SCRIPT
# ============================================================================
write.csv(datos_paises, "graficos_covid/datos_finales_k5.csv", row.names = FALSE)
print(">>> PROCESO FINALIZADO.")
print("    Revisa la carpeta 'graficos_covid'.")