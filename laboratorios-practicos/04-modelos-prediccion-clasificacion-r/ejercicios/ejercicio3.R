# ============================================================================
# PROBLEMA 3: LIGA NACIONAL DE KÁRATE - Análisis de sesgo por orden de salida
# ============================================================================

setwd("C:/Users/irene/OneDrive/Escritorio/datasetsPractica4/datasets")

library(readxl)
library(dplyr)

# ----------------------------------------------------------------------------
# PASO 1: Cargar y consolidar datos de 2020 y 2021
# ----------------------------------------------------------------------------

columnas_karate <- c(
  "id_Competicion", "id_Competidor", "ronda", "grupo", "ordenSalida", 
  paste0("puntosTecJuez", 1:7), 
  paste0("puntosAtlJuez", 1:7), 
  "puntosExtra", 
  "totalPuntosTec", "totalPuntosAtl", "totalComputado", "totalDesempate", 
  "totalDesempateLimite", "puesto", "estadoSigRonda", "columnaExtra"
)

datos_karate <- data.frame()
ficheros <- c("Karate2020.xlsx", "Karate2021.xlsx")

# Silenciar los avisos de readxl durante la carga
suppressMessages({
  for (fichero in ficheros) {
    hojas <- excel_sheets(fichero)
    
    for (hoja in hojas) {
      datos_hoja <- as.data.frame(read_xlsx(fichero, hoja, skip = 4, col_names = FALSE))
      
      if (ncol(datos_hoja) < 28) {
        datos_hoja$columnaExtra <- NA
      } else if (ncol(datos_hoja) > 28) {
        next
      }
      
      names(datos_hoja) <- columnas_karate
      
      datos_hoja$anyo <- as.numeric(substr(hoja, 1, 4))
      datos_hoja$jornada <- as.numeric(substr(hoja, 6, 6))
      datos_hoja$modalidad <- as.factor(substr(hoja, 7, 7))
      
      datos_karate <- rbind(datos_karate, datos_hoja)
    }
  }
})

# Crear variable objetivo: ¿clasifica a la siguiente ronda?
datos_karate <- datos_karate %>%
  mutate(pasa = ifelse(puesto <= 4, "SI", "NO"))

datos_karate$pasa <- factor(datos_karate$pasa, levels = c("SI", "NO"))
datos_karate$modalidad <- factor(datos_karate$modalidad, levels = c("F", "M"))

cat("\n=== DATOS CARGADOS ===\n")
cat("Total de observaciones:", nrow(datos_karate), "\n")
cat("Años:", unique(datos_karate$anyo), "\n\n")

# ----------------------------------------------------------------------------
# PASO 2: Filtrar y preparar datos de la Ronda 1
# ----------------------------------------------------------------------------

datos_ronda1 <- datos_karate %>%
  filter(ronda == 1, !is.na(totalComputado)) %>%
  mutate(grupo_orden = ifelse(ordenSalida <= 3, "Primeros", "Últimos"))

datos_ronda1$grupo_orden <- factor(datos_ronda1$grupo_orden, 
                                   levels = c("Primeros", "Últimos"))

cat("=== DISTRIBUCIÓN EN RONDA 1 ===\n")
print(table(datos_ronda1$grupo_orden))

# ----------------------------------------------------------------------------
# PASO 3: Pregunta 1 - ¿Difieren las puntuaciones medias?
# ----------------------------------------------------------------------------

cat("\n\n=== PREGUNTA 1: PUNTUACIONES MEDIAS ===\n\n")

estadisticas <- datos_ronda1 %>%
  group_by(grupo_orden) %>%
  summarise(
    n = n(),
    media = round(mean(totalComputado, na.rm = TRUE), 2),
    desv = round(sd(totalComputado, na.rm = TRUE), 2)
  )

print(estadisticas)

# Prueba t de Student
resultado_t <- t.test(totalComputado ~ grupo_orden, data = datos_ronda1)

cat("\nPrueba t de Student:\n")
cat("Diferencia de medias:", round(diff(resultado_t$estimate), 2), "\n")
cat("t =", round(resultado_t$statistic, 2), "\n")
cat("p-valor =", format(resultado_t$p.value, scientific = TRUE, digits = 3), "\n")

if (resultado_t$p.value < 0.05) {
  cat("SÍ existe diferencia significativa (p < 0.05)\n")
} else {
  cat("NO existe diferencia significativa (p >= 0.05)\n")
}

# ----------------------------------------------------------------------------
# PASO 4: Pregunta 2 - ¿Difieren las proporciones de clasificación?
# ----------------------------------------------------------------------------

cat("\n\n=== PREGUNTA 2: PROPORCIONES DE CLASIFICACIÓN ===\n\n")

tabla_cont <- table(datos_ronda1$grupo_orden, datos_ronda1$pasa)
print(tabla_cont)

cat("\nProporciones:\n")
print(round(prop.table(tabla_cont, margin = 1), 3))

# Prueba de proporciones
resultado_prop <- prop.test(tabla_cont)

cat("\nPrueba de proporciones:\n")
cat("X² =", round(resultado_prop$statistic, 2), "\n")
cat("p-valor =", format(resultado_prop$p.value, scientific = TRUE, digits = 3), "\n")

if (resultado_prop$p.value < 0.05) {
  cat("SÍ existe diferencia significativa (p < 0.05)\n")
} else {
  cat("NO existe diferencia significativa (p >= 0.05)\n")
}

# ----------------------------------------------------------------------------
# PASO 5: Regresión logística simple
# ----------------------------------------------------------------------------

cat("\n\n=== MODELO 1: REGRESIÓN LOGÍSTICA SIMPLE ===\n")
cat("Fórmula: pasa ~ ordenSalida\n\n")

datos_ronda1$pasa_binario <- ifelse(datos_ronda1$pasa == "SI", 1, 0)

modelo_simple <- glm(pasa_binario ~ ordenSalida, 
                     data = datos_ronda1, 
                     family = binomial)

coef_orden <- coef(modelo_simple)["ordenSalida"]
odds_ratio <- exp(coef_orden)
cambio_pct <- (odds_ratio - 1) * 100

cat("Coeficiente ordenSalida:", round(coef_orden, 4), "\n")
cat("Odds Ratio:", round(odds_ratio, 4), "\n")
cat("Cambio porcentual:", round(cambio_pct, 2), "%\n")
cat("p-valor:", format(summary(modelo_simple)$coefficients["ordenSalida", "Pr(>|z|)"], 
                       scientific = TRUE, digits = 3), "\n")

cat("\nInterpretación: Por cada posición que se retrasa la salida,\n")
cat("las probabilidades de clasificar aumentan un", round(cambio_pct, 1), "%\n")

# ----------------------------------------------------------------------------
# PASO 6: Regresión logística con interacción (género)
# ----------------------------------------------------------------------------

cat("\n\n=== MODELO 2: CON INTERACCIÓN (GÉNERO) ===\n")
cat("Fórmula: pasa ~ ordenSalida * modalidad\n\n")

modelo_interaccion <- glm(pasa_binario ~ ordenSalida * modalidad, 
                          data = datos_ronda1, 
                          family = binomial)

coef_int <- summary(modelo_interaccion)$coefficients["ordenSalida:modalidadM", ]

cat("Término de interacción (ordenSalida:modalidadM):\n")
cat("Coeficiente:", round(coef_int[1], 4), "\n")
cat("p-valor:", round(coef_int[4], 4), "\n")

if (coef_int[4] < 0.05) {
  cat("El efecto del orden SÍ varía según género (p < 0.05)\n")
  cat("Se requieren intervenciones diferenciadas\n")
} else {
  cat("El efecto del orden NO varía según género (p >= 0.05)\n")
  cat("El sesgo afecta igual a ambas categorías\n")
}

# ----------------------------------------------------------------------------
# PASO 7: Resumen final
# ----------------------------------------------------------------------------

cat("\n\n=== RESUMEN FINAL ===\n\n")

resumen <- data.frame(
  Pregunta = c(
    "¿Difieren las puntuaciones medias?",
    "¿Difieren las proporciones de clasificación?",
    "¿Varía el efecto según género?"
  ),
  P_valor = c(
    format(resultado_t$p.value, scientific = TRUE, digits = 3),
    format(resultado_prop$p.value, scientific = TRUE, digits = 3),
    round(coef_int[4], 4)
  ),
  Significativo = c(
    ifelse(resultado_t$p.value < 0.05, "SÍ", "NO"),
    ifelse(resultado_prop$p.value < 0.05, "SÍ", "NO"),
    ifelse(coef_int[4] < 0.05, "SÍ", "NO")
  )
)

print(resumen)

# Guardar resultados
write.csv(resumen, "resumen_karate.csv", row.names = FALSE)
write.csv(estadisticas, "estadisticas_karate.csv", row.names = FALSE)