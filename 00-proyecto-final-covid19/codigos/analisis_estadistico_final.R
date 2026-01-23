# ============================================================================
# ANÁLISIS ESTADÍSTICO FINAL
# OBJETIVO: Demostrar R2 individual, R2 Múltiple
# ============================================================================

# 1. CARGA DE DATOS
if (!require("dplyr")) install.packages("dplyr")
library(dplyr)

print("Cargando datos...")
url <- "https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv"
datos_crudos <- read.csv(url)

# Filtrado inicial
df <- datos_crudos[(!grepl("^OWID", datos_crudos$iso_code)) | (datos_crudos$iso_code == "OWID_KOS"), ]
df <- df[, c("location", "total_deaths_per_million", "stringency_index", "gdp_per_capita", "median_age")]

# Agregación por país
datos_pais <- df %>%
  group_by(location) %>%
  summarise(
    Muertes = suppressWarnings(max(total_deaths_per_million, na.rm = TRUE)),
    Rigor = mean(stringency_index, na.rm = TRUE),
    PIB = mean(gdp_per_capita, na.rm = TRUE),
    Edad = mean(median_age, na.rm = TRUE)
  ) %>%
  filter(is.finite(Muertes) & is.finite(Rigor) & is.finite(PIB) & is.finite(Edad))

# ============================================================================
# PARTE 1: ANÁLISIS INDIVIDUAL
# ============================================================================

# A. LA EDAD
modelo_edad <- lm(Muertes ~ Edad, data = datos_pais)
s_edad <- summary(modelo_edad)
print(paste("1. EDAD -> R2:", round(s_edad$r.squared * 100, 2), "% | P-Valor:", format(s_edad$coefficients[2,4], digits=3)))

# B. LA RIGUROSIDAD
modelo_rigor <- lm(Muertes ~ Rigor, data = datos_pais)
s_rigor <- summary(modelo_rigor)
print(paste("2. RIGOR -> R2:", round(s_rigor$r.squared * 100, 2), "% | P-Valor:", format(s_rigor$coefficients[2,4], digits=3)))

# C. EL PIB (Solo)
modelo_pib <- lm(Muertes ~ log(PIB), data = datos_pais)
s_pib <- summary(modelo_pib)
coef_pib_simple <- s_pib$coefficients[2,1]
efecto_pib <- ifelse(coef_pib_simple > 0, "AUMENTA Muertes (+)", "BAJA Muertes (-)")
print(paste("3. PIB (Solo) -> R2:", round(s_pib$r.squared * 100, 2), "% | P-Valor:", format(s_pib$coefficients[2,4], digits=3)))

print("----------------------------------------------------------------")

# ============================================================================
# PARTE 2: LA PRUEBA DE LA VERDAD (REGRESIÓN MÚLTIPLE)
# ============================================================================

print(">>> 4. MODELO COMBINADO (Muertes ~ PIB + Edad)")
modelo_multiple <- lm(Muertes ~ log(PIB) + Edad, data = datos_pais)
resumen_multi <- summary(modelo_multiple)

r2_multi <- resumen_multi$r.squared
r2_ajustado <- resumen_multi$adj.r.squared
coefs <- resumen_multi$coefficients
coef_pib_real <- coefs["log(PIB)", "Estimate"]
pval_pib_real <- coefs["log(PIB)", "Pr(>|t|)"]

print(paste("> R-CUADRADO DEL MODELO:", round(r2_multi * 100, 2), "%"))
print(paste("> R-CUADRADO AJUSTADO:", round(r2_ajustado * 100, 2), "%"))
print(paste("> P-Valor:", format(pval_pib_real, digits=4)))
