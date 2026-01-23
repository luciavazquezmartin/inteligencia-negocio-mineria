# --- CONFIGURACIÓN INICIAL ---
# setwd("C:/Users/irene/OneDrive/Documentos") # Descomentar si es necesario

# --- CARGA DE LIBRERÍAS ---
if(!require(arules)) install.packages("arules")
library(arules)

# --- CARGA Y LIMPIEZA DE DATOS ---
datos <- read.csv("vuelos.csv", na.strings = "")
datos <- na.omit(datos) # Eliminamos registros incompletos

# Cargamos las tablas auxiliares
tabla_hora <- read.csv("hora.csv")
tabla_aerolineas <- read.csv("aerolinea.csv")
tabla_aeropuertos <- read.csv("aeropuerto.csv")

# -------------------
# --- EJERCICIO 1 ---
# -------------------

variables <- c("id_aerolinea", "id_operadora", "id_aeropuerto_origen", 
               "id_aeropuerto_destino", "id_avion", "distancia_km", "id_hora")

resultados <- data.frame()

# Bucle principal: iteramos por tamaño del subconjunto (de 1 a 7 variables)
for (p in 1:length(variables)) {
  combinaciones <- combn(variables, p, simplify = FALSE)
  
  for (combo in combinaciones) {
    # Construcción dinámica de la fórmula
    formula_str <- paste("retardo_minutos ~", paste(combo, collapse = "+"))
    
    # Ajuste del modelo
    modelo <- lm(as.formula(formula_str), data = datos)
    
    # Extraer métricas
    s <- summary(modelo)
    resultados <- rbind(resultados, data.frame(
      Num_Variables = p,
      Variables = paste(combo, collapse = " + "),
      R2_Ajustado = s$adj.r.squared,
      AIC = AIC(modelo),
      BIC = BIC(modelo)
    ))
  }
}

# Selección del mejor modelo (Menor AIC)
mejor_global <- resultados[which.min(resultados$AIC), ]
print("--- EL MEJOR MODELO DE TODOS (Menor AIC) ---")
print(mejor_global)


# -------------------
# --- EJERCICIO 2 ---
# -------------------

# Diccionarios para IDs a Nombres
dict_aeropuertos <- c("1"="Abilene Regional", "235"="Palm Beach Intl", "191"="Midland Regional")
dict_aerolineas  <- c("7"="JetBlue Airways", "14"="Southwest Airlines", "3"="Delta Air Lines")
dict_aviones     <- c("545"="Airbus Industrie", "55"="Boeing Co.", "539"="Embraer")

# Identificamos aeropuertos de referencia para tracking
media_origen <- aggregate(retardo_minutos ~ id_aeropuerto_origen, data = datos, FUN = mean)
media_origen <- media_origen[order(media_origen$retardo_minutos), ]
ids_rastreo <- c(media_origen$id_aeropuerto_origen[1], 
                 media_origen$id_aeropuerto_origen[round(nrow(media_origen)/2)], 
                 media_origen$id_aeropuerto_origen[nrow(media_origen)])

# Función para gráficos (VERSIÓN CORREGIDA con márgenes bien)
grafico_final_pulido <- function(df, columna, titulo, ids_fijos = NULL) {
  form <- as.formula(paste("retardo_minutos ~", columna))
  medias <- aggregate(form, data = df, FUN = mean)
  
  set.seed(123)
  km <- kmeans(medias$retardo_minutos, centers = 3)
  medias$Grupo <- km$cluster
  
  info <- aggregate(retardo_minutos ~ Grupo, data = medias, FUN = mean)
  ranking <- order(info$retardo_minutos)
  colores <- rep(NA, 3)
  colores[ranking] <- c("green3", "orange", "red")
  medias$Color <- colores[medias$Grupo]
  medias <- medias[order(medias$retardo_minutos), ]
  
  n_puntos <- nrow(medias)
  limite_x <- c(1 - (n_puntos * 0.08), n_puntos + (n_puntos * 0.08)) 
  y_max <- max(medias$retardo_minutos) * 1.3
  
  # Márgenes ajustados para que se vea el título
  par(mar = c(4, 4, 4.5, 1)) 
  
  plot(1:n_puntos, medias$retardo_minutos,
       pch = 19, col = medias$Color, type = "o", lwd = 1,
       xlim = limite_x, ylim = c(0, y_max),
       main = titulo, ylab = "Retraso (min)", xlab = "",
       cex.main = 1.2, xaxt = "n", las = 1)
  
  grid()
  
  # Etiquetado
  if (!is.null(ids_fijos)) {
    filas <- which(medias[[columna]] %in% ids_fijos)
    idx_puntos <- if(length(filas)>0) filas else c(1, n_puntos)
  } else {
    idx_puntos <- c(1, round(n_puntos/2), n_puntos)
  }
  
  ids_reales <- medias[[columna]][idx_puntos]
  diccionario_uso <- NULL
  if (grepl("aeropuerto", columna)) diccionario_uso <- dict_aeropuertos
  else if (grepl("aerolinea", columna)) diccionario_uso <- dict_aerolineas
  else if (grepl("avion", columna))     diccionario_uso <- dict_aviones
  
  etiquetas <- sapply(ids_reales, function(id) {
    id_char <- as.character(id)
    if (!is.null(diccionario_uso) && id_char %in% names(diccionario_uso)) {
      return(diccionario_uso[id_char])
    } else { return(paste("ID:", id)) }
  })
  
  for(i in seq_along(idx_puntos)) {
    text(x = idx_puntos[i], y = medias$retardo_minutos[idx_puntos[i]], 
         labels = etiquetas[i], pos = 3, cex = 0.8, font = 2, offset = 0.8)
  }
}

# Configuración layout y generación de gráficos
m <- matrix(c(1, 2, 5, 3, 4, 5), nrow = 2, byrow = TRUE)
layout(m, widths = c(1, 1, 0.5))

grafico_final_pulido(datos, "id_aeropuerto_origen", "Aeropuerto Origen", ids_fijos = ids_rastreo)
grafico_final_pulido(datos, "id_aeropuerto_destino", "Aeropuerto Destino", ids_fijos = ids_rastreo)
grafico_final_pulido(datos, "id_aerolinea", "Aerolínea", ids_fijos = NULL)
grafico_final_pulido(datos, "id_avion", "Avión", ids_fijos = NULL)

# Leyenda
par(mar = c(0, 0, 0, 0)) 
plot(1, type = "n", axes = FALSE, xlab = "", ylab = "") 
legend("left", legend = c("Bajo", "Medio", "Alto"),
       col = c("green3", "orange", "red"), pch = 19, pt.cex = 2,
       title = "LEYENDA", title.adj = 0.1, bty = "o", bg = "white", cex = 1, 
       inset = 0.05, x.intersp = 0.6, y.intersp = 1.5)

par(mfrow = c(1, 1))


# -------------------
# --- EJERCICIO 3 ---
# -------------------

# --- Asignamos 'datos' a 'vuelos' ---
vuelos <- datos 

# Merge de tablas (Necesario para ANOVA y Reglas)
datos_completos <- merge(vuelos, tabla_hora, by = "id_hora")
datos_completos <- merge(datos_completos, tabla_aerolineas, by = "id_aerolinea")
datos_completos <- merge(datos_completos, tabla_aeropuertos, 
                         by.x = "id_aeropuerto_origen", by.y = "id_aeropuerto")
names(datos_completos)[names(datos_completos) == "nombre_aeropuerto"] <- "nombre_origen"

# Crear franja horaria
datos_completos$franja <- cut(datos_completos$hora, 
                              breaks = c(-1, 6, 14, 20, 24), 
                              labels = c("Noche", "Mañana", "Tarde", "Noche_tardia"))
levels(datos_completos$franja)[levels(datos_completos$franja) == "Noche_tardia"] <- "Noche"

# Gráfico Boxplot
boxplot(retardo_minutos ~ franja, data = datos_completos, 
        main = "Retrasos por Franja Horaria",
        col = c("lightblue", "orange", "grey"),
        ylab = "Retraso (min)")

# ANOVA
modelo_anova <- aov(retardo_minutos ~ franja, data = datos_completos)
print("--- RESULTADOS DEL ANOVA ---")
print(summary(modelo_anova))
print(TukeyHSD(modelo_anova))


# -------------------
# --- EJERCICIO 4 ---
# -------------------

# Selección y discretización
datos_reglas <- datos_completos[, c("nombre_aerolinea", "nombre_origen", "franja")]
datos_reglas$tipo_retraso <- cut(datos_completos$retardo_minutos,
                                 breaks = c(-Inf, 0, 15, Inf),
                                 labels = c("Sin_Retraso", "Leve", "Grave"))

datos_reglas <- as.data.frame(lapply(datos_reglas, as.factor))

# Apriori
reglas <- apriori(datos_reglas, 
                  parameter = list(supp = 0.001, conf = 0.1, minlen = 2),
                  appearance = list(rhs = "tipo_retraso=Grave", default = "lhs"))

reglas_ordenadas <- sort(reglas, by = "lift")

print("--- TOP 10 REGLAS DE ASOCIACIÓN ---")
inspect(head(reglas_ordenadas, 10))