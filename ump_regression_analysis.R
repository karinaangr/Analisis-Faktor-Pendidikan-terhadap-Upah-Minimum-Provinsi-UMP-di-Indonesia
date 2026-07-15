# ump_regression_analysis.R
# Education-Related Factors Associated with Provincial Minimum Wage (UMP) in Indonesia, 2024
# Author: Karina Dwi Anggraini | FMIPA UGM

## Load libraries -------------------------------------------------------------
library(openxlsx)
library(dplyr)
library(ggplot2)
library(GGally)
library(lmtest)
library(car)

source("scripts/helpers.R")   # model_criterion()

## 1. Input data ----------------------------------------------------------------
data1 <- read.xlsx("data/UMP_2024.xlsx")
data2 <- read.xlsx("data/APK_PT_2024.xlsx")
data3 <- read.xlsx("data/PT_Dosen_Mahasiswa_2024.xlsx")
data4 <- read.xlsx("data/SMA_2024_2025.xlsx")
data5 <- read.xlsx("data/SMK_2024_2025.xlsx")

## 2. Merge datasets by Provinsi --------------------------------------------------
gabungan1 <- merge(data1, data2, by = "Provinsi")
gabungan2 <- merge(gabungan1, data3, by = "Provinsi")
gabungan3 <- merge(gabungan2, data4, by = "Provinsi")
data_gabungan_lengkap <- merge(gabungan3, data5, by = "Provinsi")
head(data_gabungan_lengkap)

# Impute missing values with 0
data_gabungan_lengkap[is.na(data_gabungan_lengkap)] <- 0
head(data_gabungan_lengkap)

## 3. Variable selection: 10 candidate predictors ---------------------------------
X <- data_gabungan_lengkap[, c(4, 7, 10, 13, 16, 19, 22, 25, 28, 31)]
Y <- data_gabungan_lengkap$Upah_Minimum

## 4. Linearity assumption --------------------------------------------------------
pairs(data_gabungan_lengkap[, c(3, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31)],
      main = "Matriks Scatterplot Upah Minimum", pch = 19)

ggpairs(data_gabungan_lengkap[, c(3, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31)],
        title = "Matriks Scatterplot Upah Minimum", axisLabels = "show")

cor(data_gabungan_lengkap[, c(3, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31)],
    method = "pearson")

# Simple R-squared for each individual predictor vs Upah_Minimum
X_num <- X[]
R2 <- data.frame(matrix(ncol = ncol(X_num), nrow = 1))
colnames(R2) <- colnames(X_num)
for (i in 1:ncol(X_num)) {
  R2[i] <- summary(lm(Upah_Minimum ~ X_num[, i], data = data_gabungan_lengkap))$r.squared
}
print(R2)

## 5. Model building — backward elimination ---------------------------------------
data_gab_modelling <- data_gabungan_lengkap[, c(3, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31)]
head(data_gab_modelling)

# Model 1 (all 10 predictors)
model1 <- lm(Upah_Minimum ~ ., data = data_gab_modelling)
summary(model1)

# Model 2: drop Mahasiswa.dibwh.kemendikti.Negeri.+.swasta
data_gab_modelling <- select(data_gab_modelling, -`Mahasiswa.dibwh.kemendikti.Negeri.+.swasta`)
model2 <- lm(Upah_Minimum ~ ., data = data_gab_modelling)
summary(model2)

# Model 3: drop Jumlah.Sekolah.SMA.(Negeri+Swasta)
data_gab_modelling <- select(data_gab_modelling, -`Jumlah.Sekolah.SMA.(Negeri+Swasta)`)
model3 <- lm(Upah_Minimum ~ ., data = data_gab_modelling)
summary(model3)

# Model 4: drop Jumlah.Sekolah.SMK.(Negeri+Swasta)
data_gab_modelling <- select(data_gab_modelling, -`Jumlah.Sekolah.SMK.(Negeri+Swasta)`)
model4 <- lm(Upah_Minimum ~ ., data = data_gab_modelling)
summary(model4)

# Model 5: drop Jumlah.Guru.SMA.(Negeri+Swasta)
data_gab_modelling <- select(data_gab_modelling, -`Jumlah.Guru.SMA.(Negeri+Swasta)`)
model5 <- lm(Upah_Minimum ~ ., data = data_gab_modelling)
summary(model5)

# Model 6: drop Jumlah.Pendidik.dibwh.kemendikti.-.Negeri.+.Swasta
data_gab_modelling <- select(data_gab_modelling, -`Jumlah.Pendidik.dibwh.kemendikti.-.Negeri.+.Swasta`)
model6 <- lm(Upah_Minimum ~ ., data = data_gab_modelling)
summary(model6)

## 6. Hypothesis testing -----------------------------------------------------------

# Overall F-test across all 6 models
overall_p <- function(my_model) {
  f <- summary(my_model)$fstatistic
  p <- pf(f[1], f[2], f[3], lower.tail = FALSE)
  attributes(p) <- NULL
  return(p)
}

overall_test <- data.frame(matrix(ncol = 2, nrow = 6))
colnames(overall_test) <- c("Model", "P.Value")
overall_test$Model <- c("Model 1", "Model 2", "Model 3", "Model 4", "Model 5", "Model 6")
overall_test$P.Value <- c(overall_p(model1), overall_p(model2), overall_p(model3),
                           overall_p(model4), overall_p(model5), overall_p(model6))
print(overall_test)

# Partial test for intercept
intercept_p <- function(my_model) summary(my_model)$coefficients[1, 4]
partial_test <- data.frame(matrix(ncol = 2, nrow = 6))
colnames(partial_test) <- c("Model", "P.Value")
partial_test$Model <- c("Model 1", "Model 2", "Model 3", "Model 4", "Model 5", "Model 6")
partial_test$P.Value <- c(intercept_p(model1), intercept_p(model2), intercept_p(model3),
                           intercept_p(model4), intercept_p(model5), intercept_p(model6))
partial_test

# Partial test for coefficients
coef_p <- function(my_model) round(summary(my_model)$coefficients[-1, 4], 3)
coef_p(model1); coef_p(model2); coef_p(model3)
coef_p(model4); coef_p(model5); coef_p(model6)

# Estimated coefficients for each model
est_coef <- function(my_model) round(summary(my_model)$coefficients[, 1], 3)
est_coef(model1); est_coef(model2); est_coef(model3)
est_coef(model4); est_coef(model5); est_coef(model6)

## 7. Model selection criteria --------------------------------------------------------
model_criterion(data_gab_modelling, model1, full_model = model1)
model_criterion(data_gab_modelling, model2, full_model = model1)
model_criterion(data_gab_modelling, model3, full_model = model1)
model_criterion(data_gab_modelling, model4, full_model = model1)
model_criterion(data_gab_modelling, model5, full_model = model1)
model_criterion(data_gab_modelling, model6, full_model = model1)

## 8. Diagnostic checking on the best model (Model III) --------------------------------
df_diagnostic <- select(data_gabungan_lengkap, c(
  "Upah_Minimum", "APK.PT.Provinsi.2024",
  "PT.dibwh.kemendikti.Negeri.+.Swasta",
  "Jumlah.Murid.SMA.Negeri+Swasta",
  "Jumlah.Guru.SMK.(Negeri+Swasta)",
  "Jumlah.Murid.SMK.(Negeri+Swasta)",
  "Jumlah.Sekolah.SMK.(Negeri+Swasta)",
  "Jumlah.Guru.SMA.(Negeri+Swasta)",
  "Jumlah.Pendidik.dibwh.kemendikti.-.Negeri.+.Swasta"
))
model3 <- lm(Upah_Minimum ~ ., data = df_diagnostic)
summary(model3)
model_criterion(df_diagnostic, model3, full_model = model1)

# Linearity
y <- df_diagnostic$Upah_Minimum
X <- select(df_diagnostic, -c("Upah_Minimum"))
pairs(df_diagnostic, main = "Matriks Scatterplot Upah Minimum", pch = 19)
ggpairs(df_diagnostic, title = "Matriks Scatterplot Upah Minimum", axisLabels = "show")
cor(df_diagnostic[, -1], method = "pearson")

# Normality of residuals (Shapiro-Wilk, n < 50)
qqnorm(model3$residuals, main = "Normal Q-Q Plot Residual")
qqline(model3$residuals)
shapiro.test(model3$residuals)

# Homoscedasticity
plot(model3, 1)
bptest(model3)

# Independence of errors
durbinWatsonTest(model3)
# library(runstest)  # if Durbin-Watson is inconclusive, follow up with a Runs test
# runsTest(model3)

# Multicollinearity
vif_values <- vif(model3)
print(vif_values)
tolerance_values <- 1 / vif_values
print(tolerance_values)
