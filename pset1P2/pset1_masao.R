library("ipumsr")
library("haven")
library("dplyr")
library("tidyr")
library("lubridate")
library("ggplot2")
library("knitr")
library("xtable")

dir_path <- "/Users/veronica/Dropbox/PhD/2024_1/EC_704_Macro_Theory"

setwd(dir_path)
# data_u <- read.table("cps_00002.csv", header = TRUE, sep = ",")
# 
# save(data_u, file = "data_u.RData")
load("data_u.RData")

head(data_u, 10)

table(data_u$EDUC)

# recode education

# Define a function to recode education levels
educ_recoded <- function(education) {
 if (education >= 2 && education <= 72) {
    return("Some schooling, less than highschool")
  } else if (education == 73) {
    return("High-school diploma")
  } else if (education >= 74 && education <= 110) {
    return("Some college or Associate's degree")
  } else if (education == 111) {
    return("Bachelor's degree")
  } else if (education >= 110 && education <= 122) {
    return("Some college or Associate's degree")
  } else if (education >= 123 && education <= 125) {
    return("Graduate/Professional Degree")
  } else {
    return(NA)
  }
}

# Recode the EDUC variable using the defined function
data_u$educ_recoded <- sapply(data_u$EDUC, educ_recoded)

# View the updated dataset
table(data_u$educ_recoded)

head(data_u,10)

table(data_u$EMPSTAT)

#employment

empl_recoded <- function(employment) {
  if (employment == 1 || employment >=30) {
    return("NLF")
  } else if (employment >= 10 && employment <= 12) {
    return("EMPLOYED")
  } else if (employment >= 20 && employment <= 22) {
    return("UNEMPLOYED")
  } else {
    return(NA)
  }
}

# Recode the EDUC variable using the defined function
data_u$empl_recoded <- sapply(data_u$EMPSTAT, empl_recoded)

# fix date
data_u$date <- as.Date(paste(data_u$YEAR, data_u$MONTH, "01", sep = "-"))

#keep active population only

EAP <- data_u %>%
  filter(empl_recoded != "NLF" | is.na(empl_recoded))

# Calculate unemployment rate
unemployment <- EAP %>%
  mutate(Unemployment_Rate = if_else(empl_recoded == "UNEMPLOYED", 1, 0)) %>%
  group_by(educ_recoded, date) %>%
  summarise(Avg_Unemployment_Rate = weighted.mean(Unemployment_Rate, na.rm = TRUE))

unemployment$Avg_Unemployment_Rate <- unemployment$Avg_Unemployment_Rate * 100

plot1 <- ggplot(unemployment, aes(x = date, y = Avg_Unemployment_Rate, color = educ_recoded)) +
  geom_line() +
  labs(title = "Unemployment Rate Trends by Education",
       x = "Date",
       y = "Unemployment Rate",
       color = "Education Level") +
  theme_minimal() + 
  theme(legend.position = "bottom")

plot1

ggsave("/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_1_2/ps12_2_1.pdf", 
       plot = plot1, width = 10, height = 5, 
       units = "in", device = "pdf")

# great recession
great_rec <- subset(unemployment, date >= as.Date("2007-12-01") & date <= as.Date("2009-06-30"))

# after covid 
covid_rec <- subset(unemployment, date >= as.Date("2020-02-01") & date <= as.Date("2020-04-30"))

# great recession

plot2 <- ggplot(great_rec, aes(x = date, y = Avg_Unemployment_Rate, color = educ_recoded)) +
  geom_line() +
  labs(title = "Unemployment Rate Trends by Education",
       x = "Date",
       y = "Unemployment Rate",
       color = "Education Level") +
  theme_minimal() + 
  theme(legend.position = "bottom")

plot2

ggsave("/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_1_2/ps12_2_1_2.pdf", 
       plot = plot2, width = 10, height = 5, 
       units = "in", device = "pdf")

# covid

plot3 <- ggplot(covid_rec, aes(x = date, y = Avg_Unemployment_Rate, color = educ_recoded)) +
  geom_line() +
  labs(title = "Unemployment Rate Trends by Education",
       x = "Date",
       y = "Unemployment Rate",
       color = "Education Level") +
  theme_minimal() + 
  theme(legend.position = "bottom")

plot3

ggsave("/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_1_2/ps12_2_1_3.pdf", 
       plot = plot3, width = 10, height = 5, 
       units = "in", device = "pdf")

## Table the unemployment

# Calcular el promedio ponderado de desempleo para cada grupo en educ_recoded en el conjunto de datos original
original_unemployment <- unemployment %>%
  group_by(educ_recoded) %>%
  summarise(Avg_Unemployment_Original = weighted.mean(Avg_Unemployment_Rate, na.rm = TRUE))

# Calcular el promedio ponderado de desempleo para cada grupo en educ_recoded en el conjunto de datos durante la Gran Recesión
great_rec_unemployment <- great_rec %>%
  group_by(educ_recoded) %>%
  summarise(Avg_Unemployment_Great_Rec = weighted.mean(Avg_Unemployment_Rate, na.rm = TRUE))

# Calcular el promedio ponderado de desempleo para cada grupo en educ_recoded en el conjunto de datos durante la recesión de COVID
covid_rec_unemployment <- covid_rec %>%
  group_by(educ_recoded) %>%
  summarise(Avg_Unemployment_COVID_Rec = weighted.mean(Avg_Unemployment_Rate, na.rm = TRUE))

# Combinar los tres conjuntos de datos en uno solo por 'educ_recoded'
combined_unemployment <- merge(merge(original_unemployment, great_rec_unemployment, by = "educ_recoded", all = TRUE),
                               covid_rec_unemployment, by = "educ_recoded", all = TRUE)

# Formatear los números con dos decimales
combined_unemployment[, -1] <- lapply(combined_unemployment[, -1], function(x) {
  sprintf("%.4f", x)
})

combined_unemployment <- combined_unemployment %>%
  na.omit()

# Convertir la tabla a formato LaTeX sin incluir los comandos de tabla
latex_table <- xtable(combined_unemployment, include.rownames = FALSE, include.colnames = FALSE,digits=c(0,3,3,3,3))

# Capturar la salida de la tabla LaTeX sin incluir los comandos de tabla y los índices
table_content <- print(latex_table, sanitize.text.function = identity, only.contents = TRUE, include.rownames = FALSE, include.colnames = FALSE, hline.after = c(-1, 0))

# Guardar solo el contenido de la tabla LaTeX en un archivo de texto
writeLines(table_content, "/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_1_2/pset12_21.tex")


# 2_2 ---------------------------------------------------------------------

# Supongamos que dt es tu conjunto de datos

# Calcular el estado laboral del próximo mes
data_u_rates <- data_u %>%
  mutate(next_month = floor_date(date + 31L, "month"),
         future_emp = lag(empl_recoded))  # Lagging 'emp' to get the future employment status

# Calcular las probabilidades de encontrar y perder un trabajo
data_u_rates <- data_u_rates %>%
  group_by(next_month,educ_recoded) %>%
  summarise(prob_find = sum(empl_recoded == "UNEMPLOYED" & future_emp == "EMPLOYED", na.rm = TRUE) / sum(empl_recoded == "UNEMPLOYED", na.rm = TRUE),
            prob_lose = sum(empl_recoded == "EMPLOYED" & future_emp == "UNEMPLOYED", na.rm = TRUE) / sum(empl_recoded == "EMPLOYED", na.rm = TRUE))

# Calcular las tasas de flujo de encontrar y perder un trabajo
data_u_rates <- data_u_rates %>%
  mutate(rate_find = -log(1 - prob_find - prob_lose) * prob_find / (prob_find + prob_lose),
         rate_lose = -log(1 - prob_find - prob_lose) * prob_lose / (prob_find + prob_lose))

# Probabilities

plot4 <- ggplot(data_u_rates, aes(x = next_month, y = prob_find, color = educ_recoded)) +
  geom_line() +
  labs(title = "job-finding probability by educational group",
       x = "Date",
       y = "Job-Finding probability",
       color = "Education Level") +
  theme_minimal() + 
  theme(legend.position = "bottom")

plot4

ggsave("/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_1_2/ps12_2_2_1.pdf", 
       plot = plot4, width = 10, height = 5, 
       units = "in", device = "pdf")


plot5 <- ggplot(data_u_rates, aes(x = next_month, y = prob_lose, color = educ_recoded)) +
  geom_line() +
  labs(title = "Job-losing probability by educational group",
       x = "Date",
       y = "Job-losing probability",
       color = "Education Level") +
  theme_minimal() + 
  theme(legend.position = "bottom")

plot5

ggsave("/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_1_2/ps12_2_2.pdf", 
       plot = plot5, width = 10, height = 5, 
       units = "in", device = "pdf")



# 2_3 ---------------------------------------------------------------------


plot6 <- ggplot(data_u_rates, aes(x = next_month, y = rate_find, color = educ_recoded)) +
  geom_line() +
  labs(title = "Job-finding rate by educational group",
       x = "Date",
       y = "Job-finding rate",
       color = "Education Level") +
  theme_minimal() + 
  theme(legend.position = "bottom")

plot6

ggsave("/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_1_2/ps12_2_3.pdf", 
       plot = plot6, width = 10, height = 5, 
       units = "in", device = "pdf")

plot7 <- ggplot(data_u_rates, aes(x = next_month, y = rate_lose, color = educ_recoded)) +
  geom_line() +
  labs(title = "Job-losing rate by educational group",
       x = "Date",
       y = "Job-losing rate",
       color = "Education Level") +
  theme_minimal() + 
  theme(legend.position = "bottom")

plot7

ggsave("/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_1_2/ps12_2_4.pdf", 
       plot = plot7, width = 10, height = 5, 
       units = "in", device = "pdf")

# Calcular la diferencia absoluta entre rate_find y prob_find
diff_table <- data_u_rates %>%
  mutate(abs_diff_find = abs(rate_find - prob_find),
         abs_diff_lose = abs(rate_lose - prob_lose)) %>%
  group_by(educ_recoded) %>%
  summarise(mean_abs_diff_find = round(mean(abs_diff_find, na.rm = TRUE), 4),
            mean_abs_diff_lose = round(mean(abs_diff_lose, na.rm = TRUE), 4)) %>%
  na.omit()

# Generar la tabla LaTeX
latex_table_2 <- xtable(diff_table, include.rownames = FALSE, include.colnames = FALSE,digits=c(0,3,3,3))

# Capturar la salida de la tabla LaTeX sin incluir los comandos de tabla y los índices
table_content <- print(latex_table_2,  only.contents = TRUE, sanitize.text.function = identity, include.rownames = FALSE, include.colnames = FALSE, hline.after = c(-1, 0))

# Guardar solo el contenido de la tabla LaTeX en un archivo de texto
writeLines(table_content, "/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_1_2/pset12_22.tex")


# 2_4 ---------------------------------------------------------------------

# Función para calcular la descomposición de la varianza transversal
calculate_variance_decomposition <- function(data, period_name, period_start, period_end) {
  # Filtrar los datos dentro del período especificado
  data <- data %>%
    filter(next_month >= period_start & next_month <= period_end) %>%
    drop_na(educ_recoded, rate_lose, rate_find)  # Eliminar filas con valores faltantes en las columnas relevantes
  
  # Calcular u_hat
  data <- data %>%
    mutate(u_hat = rate_lose / (rate_lose + rate_find)) 
  
  # Calcular log_unemployment
  data <- data %>%
    mutate(log_unemployment = log(u_hat / (1 - u_hat))) 
  
  # Calcular la varianza de log_unemployment
  var_llunemp <- var(data$log_unemployment)
  
  # Calcular la covarianza entre log_unemployment y log(rate_find)
  cov_lrfind_llunemp <- cov(data$log_unemployment, log(data$rate_find))
  
  # Calcular la proporción de varianza debida a rate_find
  finding <- cov_lrfind_llunemp / var_llunemp
  
  # Calcular la proporción de varianza debida a rate_lose
  losing <- 1 - finding
  
  # Devolver los resultados como un data.frame
  result <- data.frame(period = period_name, losing = losing * 100, finding = finding * 100)
  
  return(result)
}


# Calcular la descomposición de la varianza transversal para cada período
decomposition_overall <- calculate_variance_decomposition(data_u_rates, "Overall", as.Date("2000-02-01"), as.Date("2024-03-01"))
decomposition_recess <- calculate_variance_decomposition(data_u_rates, "Great Recession", as.Date("2007-12-01"), as.Date("2009-06-01"))
decomposition_covid <- calculate_variance_decomposition(data_u_rates, "COVID", as.Date("2020-02-01"), as.Date("2020-04-01"))

# Unir los resultados en un único data.frame
decomposition <- bind_rows(decomposition_overall, decomposition_recess, decomposition_covid)

# Renombrar los períodos
decomposition$period <- case_when(
  decomposition$period == "Overall" ~ "(a) Overall",
  decomposition$period == "Great Recession" ~ "(b) Great Recession",
  decomposition$period == "COVID" ~ "(c) COVID Recession"
)

# Generar la tabla LaTeX
latex_table_3 <- xtable(decomposition, include.rownames = FALSE, include.colnames = FALSE,digits=c(0,3,3,3))

# Capturar la salida de la tabla LaTeX sin incluir los comandos de tabla y los índices
table_content <- print(latex_table_3,  only.contents = TRUE, sanitize.text.function = identity, include.rownames = FALSE, include.colnames = FALSE, hline.after = c(-1, 0))

# Guardar solo el contenido de la tabla LaTeX en un archivo de texto
writeLines(table_content, "/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_1_2/pset12_23.tex")

