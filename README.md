# inteligencia-negocio-mineria

Repositorio que consolida el aprendizaje práctico en el ciclo de vida del dato. Este portafolio combina la **Ciencia de Datos programática (R)** aplicada en el proyecto final, con técnicas de Business Intelligence (ETL/OLAP) desarrolladas en los laboratorios.

---

## Proyecto Principal: Análisis de Minería de Datos COVID-19
**Carpeta:** `00-proyecto-final-covid19`

Estudio analítico sobre los determinantes socioeconómicos y demográficos en la letalidad y gestión global de la pandemia. Se buscó aislar variables (como la riqueza o la edad) para entender patrones reales de comportamiento del virus.

### Metodología y Técnicas (Stack: R)
El proyecto se ejecutó íntegramente en lenguaje **R**, siguiendo un flujo de trabajo científico:

1.  **Segmentación (Clustering Avanzado):**
    * Aplicación del algoritmo **K-Means** (K=5) para agrupar países según su comportamiento.
    * Optimización del modelo mediante la técnica del **Codo (Elbow Method)**.
    * Validación de la consistencia de los grupos usando **Dendrogramas Jerárquicos**.

2.  **Validación Estadística y Predicción:**
    * **Análisis de Correlación** para filtrar variables redundantes.
    * **Regresión Lineal Múltiple:** Utilizada para aislar el factor "Edad" del factor "PIB".
    * *Hallazgo clave:* Se demostró estadísticamente que, al descontar el efecto del envejecimiento poblacional, la riqueza actúa como un factor protector real contra la mortalidad.

---

## Laboratorios Prácticos (Learning Path)
**Carpeta:** `laboratorios-practicos`

Colección de prácticas independientes donde se perfeccionaron las técnicas de ingeniería de datos y análisis estadístico antes de abordar el proyecto final.

| Práctica | Habilidad Técnica Adquirida | Herramienta/Stack |
| :--- | :--- | :--- |
| **Lab 01** | **Diseño de Data Marts:** Modelado dimensional (Esquema en Estrella) para contextos de aviación y hospitalario. Creación física de tablas y carga inicial. | SQL (DDL/DML) |
| **Lab 02** | **Procesos ETL:** Diseño de flujos de trabajo para la limpieza, transformación y carga de datos reales de vuelos. Gestión de cargas incrementales. | **KNIME** |
| **Lab 03** | **Business Intelligence (BI):** Creación de cuadros de mando interactivos (Dashboards), consultas analíticas avanzadas (CUBE, ROLLUP) y consultas multidimensionales (MDX). | **Power BI**, SQL Avanzado |
| **Lab 04** | **Machine Learning (Supervisado):** Implementación de modelos lineales de Regresión (predicción de calidad) y Clasificación (Logistic Regression) evaluados con matrices de confusión. | **Lenguaje R** |
| **Lab 05** | **Minería de Datos Avanzada:** Segmentación de vuelos mediante Clustering (**K-Means**), análisis de varianza (**ANOVA**) para dependencias horarias y descubrimiento de patrones ocultos con **Reglas de Asociación**. | **Lenguaje R** |
