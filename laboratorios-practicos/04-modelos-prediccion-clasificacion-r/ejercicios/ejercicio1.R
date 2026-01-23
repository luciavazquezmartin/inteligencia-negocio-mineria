# ============================================================================
# PROBLEMA 1: CALIDAD DE LA CERVEZA - Selección automática de predictores
# ============================================================================

# Configurar directorio y cargar datos
setwd("C:/Users/irene/OneDrive/Escritorio/datasetsPractica4/datasets")
beer.data <- read.csv("lagerdata.csv", sep=";")

# Definir el modelo más complejo posible (con los 3 predictores)
formula_completa <- as.formula("~ tpc + ma + tso2")

# ----------------------------------------------------------------------------
# PASO 1: Entrenar modelos para cada ensayo
# ----------------------------------------------------------------------------
# El algoritmo step() prueba todas las combinaciones y se queda con la mejor
# según el criterio AIC (penaliza modelos innecesariamente complejos)

# DSA
modelo_dsa_completo <- lm(dsa ~ tpc + ma + tso2, data=beer.data)
modelo_dsa_optimo <- step(modelo_dsa_completo, 
                          scope = list(lower = ~1, upper = formula_completa), 
                          direction = "both", trace = 0)

# ASA
modelo_asa_completo <- lm(asa ~ tpc + ma + tso2, data=beer.data)
modelo_asa_optimo <- step(modelo_asa_completo, 
                          scope = list(lower = ~1, upper = formula_completa), 
                          direction = "both", trace = 0)

# ORAC
modelo_orac_completo <- lm(orac ~ tpc + ma + tso2, data=beer.data)
modelo_orac_optimo <- step(modelo_orac_completo, 
                           scope = list(lower = ~1, upper = formula_completa), 
                           direction = "both", trace = 0)

# RP
modelo_rp_completo <- lm(rp ~ tpc + ma + tso2, data=beer.data)
modelo_rp_optimo <- step(modelo_rp_completo, 
                         scope = list(lower = ~1, upper = formula_completa), 
                         direction = "both", trace = 0)

# MCA
modelo_mca_completo <- lm(mca ~ tpc + ma + tso2, data=beer.data)
modelo_mca_optimo <- step(modelo_mca_completo, 
                          scope = list(lower = ~1, upper = formula_completa), 
                          direction = "both", trace = 0)

# ----------------------------------------------------------------------------
# PASO 2: Crear tabla resumen con los resultados
# ----------------------------------------------------------------------------

# Función auxiliar: extrae qué predictores quedaron en el modelo final
extraer_predictores <- function(modelo) {
  coefs <- names(coef(modelo))
  predictores <- coefs[coefs != "(Intercept)"]
  if (length(predictores) == 0) return("Ninguno")
  return(paste(predictores, collapse = " + "))
}

# Construir la tabla comparativa
resultados <- data.frame(
  Ensayo = c("dsa", "asa", "orac", "rp", "mca"),
  Predictores = c(
    extraer_predictores(modelo_dsa_optimo),
    extraer_predictores(modelo_asa_optimo),
    extraer_predictores(modelo_orac_optimo),
    extraer_predictores(modelo_rp_optimo),
    extraer_predictores(modelo_mca_optimo)
  ),
  R2_Ajustado = round(c(
    summary(modelo_dsa_optimo)$adj.r.squared,
    summary(modelo_asa_optimo)$adj.r.squared,
    summary(modelo_orac_optimo)$adj.r.squared,
    summary(modelo_rp_optimo)$adj.r.squared,
    summary(modelo_mca_optimo)$adj.r.squared
  ), 4)
)

print(resultados)

# ----------------------------------------------------------------------------
# PASO 3: Ver los detalles estadísticos de cada modelo
# ----------------------------------------------------------------------------

cat("\n=== MODELO DSA ===\n")
summary(modelo_dsa_optimo)

cat("\n=== MODELO ASA ===\n")
summary(modelo_asa_optimo)

cat("\n=== MODELO ORAC ===\n")
summary(modelo_orac_optimo)

cat("\n=== MODELO RP ===\n")
summary(modelo_rp_optimo)

cat("\n=== MODELO MCA ===\n")
summary(modelo_mca_optimo)