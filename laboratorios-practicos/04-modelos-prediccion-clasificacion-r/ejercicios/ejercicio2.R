# ============================================================================
# PROBLEMA 2: CLASIFICACIÓN DE FARDOS - Regresión Logística Multinomial
# ============================================================================

setwd("C:/Users/irene/OneDrive/Escritorio/datasetsPractica4/datasets")

# install.packages("nnet")  # Descomentar si no lo tienes instalado
library(nnet)

# Cargar datos y convertir la variable respuesta a factor
cala.data <- read.csv("datacala.csv")
cala.data$cala <- as.factor(cala.data$cala)

# ----------------------------------------------------------------------------
# PASO 1: Identificar los extremos de la playa
# ----------------------------------------------------------------------------

idx_sur <- which.min(cala.data$latitud.y)
punto_sur <- cala.data[idx_sur, c("longitud.x", "latitud.y")]

idx_norte <- which.max(cala.data$latitud.y)
punto_norte <- cala.data[idx_norte, c("longitud.x", "latitud.y")]

cat("\n=== PUNTOS EXTREMOS ===\n")
cat("Sur: ", punto_sur$longitud.x, ",", punto_sur$latitud.y, "\n")
cat("Norte:", punto_norte$longitud.x, ",", punto_norte$latitud.y, "\n\n")

# ----------------------------------------------------------------------------
# PASO 2: Entrenar el modelo
# ----------------------------------------------------------------------------

modelo_multinom <- multinom(cala ~ longitud.x + latitud.y, data = cala.data)

# ----------------------------------------------------------------------------
# PASO 3: Funciones auxiliares para predecir
# ----------------------------------------------------------------------------

# Devuelve la cala predicha (0, 1 o 2)
predict_cala_clase <- function(x_coord, y_coord, model) {
  new_data <- data.frame(longitud.x = x_coord, latitud.y = y_coord)
  return(predict(model, newdata = new_data, type = "class"))
}

# Devuelve las probabilidades de cada cala
predict_cala_prob <- function(x_coord, y_coord, model) {
  new_data <- data.frame(longitud.x = x_coord, latitud.y = y_coord)
  pred_probs <- predict(model, newdata = new_data, type = "probs")
  
  # Convertir a matriz si es necesario
  if (is.vector(pred_probs)) {
    pred_probs <- t(as.matrix(pred_probs))
  }
  
  colnames(pred_probs) <- c("Cala 0", "Cala 1", "Cala 2")
  return(pred_probs)
}

# ----------------------------------------------------------------------------
# PASO 4: Calcular los puntos de separación entre calas
# ----------------------------------------------------------------------------

# Modelar la playa como una línea recta de Sur a Norte
dx <- punto_norte$longitud.x - punto_sur$longitud.x
dy <- punto_norte$latitud.y - punto_sur$latitud.y

# Función para moverse por la playa: t=0 es Sur, t=1 es Norte
get_coords <- function(t) {
  x <- punto_sur$longitud.x + t * dx
  y <- punto_sur$latitud.y + t * dy
  return(data.frame(x=x, y=y))
}

# Buscar donde las probabilidades de Cala 0 y Cala 1 se cruzan
diferencia_01 <- function(t) {
  if (t < 0 | t > 1) return(NA)
  coords <- get_coords(t)
  probs <- predict_cala_prob(coords$x, coords$y, modelo_multinom)
  return(abs(probs[1, 1] - probs[1, 2]))
}

# Buscar donde las probabilidades de Cala 1 y Cala 2 se cruzan
diferencia_12 <- function(t) {
  if (t < 0 | t > 1) return(NA)
  coords <- get_coords(t)
  probs <- predict_cala_prob(coords$x, coords$y, modelo_multinom)
  return(abs(probs[1, 2] - probs[1, 3]))
}

# Optimizar para encontrar los puntos exactos
t1_opt <- optimize(diferencia_01, interval = c(0, 0.5))$minimum
punto_separacion_1 <- get_coords(t1_opt)
colnames(punto_separacion_1) <- c("longitud.x", "latitud.y")

t2_opt <- optimize(diferencia_12, interval = c(0.5, 1))$minimum
punto_separacion_2 <- get_coords(t2_opt)
colnames(punto_separacion_2) <- c("longitud.x", "latitud.y")

cat("\n=== FRONTERAS ENTRE CALAS ===\n")
cat("Sur/Centro:", punto_separacion_1$longitud.x, ",", punto_separacion_1$latitud.y, "\n")
cat("Centro/Norte:", punto_separacion_2$longitud.x, ",", punto_separacion_2$latitud.y, "\n\n")

# ----------------------------------------------------------------------------
# PASO 5: Matriz de confusión
# ----------------------------------------------------------------------------

predicciones_clase <- predict(modelo_multinom, newdata = cala.data, type = "class")
matriz_confusion <- table(Prediccion = predicciones_clase, Real = cala.data$cala)

colnames(matriz_confusion) <- c("sur", "centro", "norte")
rownames(matriz_confusion) <- c("sur", "centro", "norte")

cat("\n=== MATRIZ DE CONFUSIÓN ===\n")
print(matriz_confusion)

# Calcular precisión
precision <- sum(diag(matriz_confusion)) / sum(matriz_confusion)
cat("\nPrecisión global:", round(precision * 100, 2), "%\n\n")

# ----------------------------------------------------------------------------
# PASO 6: Predicciones para puntos específicos
# ----------------------------------------------------------------------------

puntos_prueba <- data.frame(
  x = c(9.558359, 9.564329, 9.568671),
  y = c(1.100, 1.089, 1.081)
)

cat("\n=== PREDICCIONES PARA PUNTOS DE PRUEBA ===\n")
for (i in 1:nrow(puntos_prueba)) {
  x_p <- puntos_prueba[i, "x"]
  y_p <- puntos_prueba[i, "y"]
  
  cala_predicha <- predict_cala_clase(x_p, y_p, modelo_multinom)
  probs_predichas <- predict_cala_prob(x_p, y_p, modelo_multinom)
  
  cat(sprintf("\nPunto %d: (%.6f, %.3f)\n", i, x_p, y_p))
  cat("Destino predicho: Cala", cala_predicha, "\n")
  cat("Probabilidades:", sprintf("%.1f%%", probs_predichas * 100), "\n")
}

# ----------------------------------------------------------------------------
# PASO 7: Visualización
# ----------------------------------------------------------------------------

plot(cala.data$longitud.x, cala.data$latitud.y,
     col = as.numeric(cala.data$cala) + 1,
     pch = 19,
     xlab = "Longitud", ylab = "Latitud",
     main = "Distribución de Fardos por Cala")

# Línea de costa
segments(punto_sur$longitud.x, punto_sur$latitud.y, 
         punto_norte$longitud.x, punto_norte$latitud.y, 
         col = "black", lwd = 2)

# Puntos extremos
points(punto_sur$longitud.x, punto_sur$latitud.y, col = "black", pch = 17, cex = 1.5)
text(punto_sur$longitud.x, punto_sur$latitud.y, "SUR", pos = 4)

points(punto_norte$longitud.x, punto_norte$latitud.y, col = "black", pch = 15, cex = 1.5)
text(punto_norte$longitud.x, punto_norte$latitud.y, "NORTE", pos = 4)

# Puntos de separación
points(punto_separacion_1$longitud.x, punto_separacion_1$latitud.y, col = "black", pch = 8, cex = 2)
text(punto_separacion_1$longitud.x, punto_separacion_1$latitud.y, "Sur/Centro", pos = 4)

points(punto_separacion_2$longitud.x, punto_separacion_2$latitud.y, col = "black", pch = 8, cex = 2)
text(punto_separacion_2$longitud.x, punto_separacion_2$latitud.y, "Centro/Norte", pos = 4)

legend("topright",
       legend = c("Cala 0 (Sur)", "Cala 1 (Centro)", "Cala 2 (Norte)", "Costa", "Frontera"),
       col = c(2, 3, 4, "black", "black"),
       pch = c(19, 19, 19, NA, 8),
       lty = c(NA, NA, NA, 1, NA))