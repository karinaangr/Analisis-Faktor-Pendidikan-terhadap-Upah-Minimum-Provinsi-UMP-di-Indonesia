# Education-Related Factors Associated with Provincial Minimum Wage in Indonesia

**Faculty of Mathematics and Natural Sciences (FMIPA), Universitas Gadjah Mada**
Applied Regression Analysis Practicum — Mid-term Exam Project (2025)

## Overview

This project builds a **cross-sectional multiple linear regression model** to identify education-related
factors that explain variation in **Provincial Minimum Wage (Upah Minimum Provinsi / UMP)** across all
**38 provinces in Indonesia**, using 2024 provincial-level data from **BPS (Statistics Indonesia)** and
**Kemnaker RI (Ministry of Manpower)**.

The analysis covers the full applied-statistics workflow: data preprocessing, variable selection,
classical regression assumption testing, backward elimination, diagnostic checking, and translation of
the final model into policy-relevant recommendations for education quality and labor-market planning.

## Data Sources

Five provincial-level datasets (2024, unless noted) were merged on `Provinsi`:

| # | Dataset | Source |
|---|---------|--------|
| 1 | UMP (Provincial Minimum Wage) 2024 | Kemnaker RI |
| 2 | Gross Enrollment Ratio (APK) — Higher Education | BPS |
| 3 | Number of Higher Education Institutions, Lecturers, and Students (Public & Private) | Kemendiktisaintek |
| 4 | Number of Senior High Schools (SMA), Teachers, and Students (Public & Private), 2024/2025 | Kemendikbudristek |
| 5 | Number of Vocational High Schools (SMK), Teachers, and Students (Public & Private), 2024/2025 | Kemendikbudristek |

> Raw data files are not included in this repository (institutional/personal downloads). See
> `data/README.md` for the expected file names and structure so the scripts run out of the box.

## Methodology

1. **Data preprocessing** — merged 5 provincial datasets by `Provinsi`; missing values imputed to 0.
2. **Variable selection** — 10 candidate education-related predictors selected based on theoretical
   relevance to labor productivity and wage-setting.
3. **Assumption testing (initial)** — linearity (scatterplots, `ggpairs`), correlation matrix, R².
4. **Model building — backward elimination** — iteratively removed the least significant predictor
   (highest p-value > 0.05) across 6 model iterations (Model I → Model VI).
5. **Hypothesis testing** — overall F-test, partial t-tests (intercept and coefficients) for every model.
6. **Model selection criteria** — R², Adjusted R², Residual Standard Error, AIC, SBC/BIC, Mallows' Cp,
   PRESS statistic (see `scripts/helpers.R` for the `model_criterion()` implementation).
7. **Diagnostic checking on the best model** — linearity, normality of residuals (Q-Q plot,
   Shapiro-Wilk), homoscedasticity (residual plot, Breusch-Pagan test), independence of errors
   (Durbin-Watson, Runs test), and multicollinearity (VIF/Tolerance).
8. **Policy interpretation** — translated significant coefficients into education and labor-market
   policy recommendations.

## Key Results

**Best model: Model III** (8 predictors, selected via Mallows' Cp / SBC / AIC trade-off among the 6
backward-elimination candidates)

```
Upah_Minimum = 4,315,616.32
               − 30,097.325 × APK_PT_Provinsi_2024
               + 30,716.112 × PT_Negeri_Swasta
               − 16.711     × Jumlah_Murid_SMA
               − 354.392    × Jumlah_Guru_SMK
               + 14.88      × Jumlah_Murid_SMK
               + 965.664    × Jumlah_Sekolah_SMK
               + 161.862    × Jumlah_Guru_SMA
               − 141.091    × Jumlah_Pendidik_Kemendikti
```

| Metric | Value |
|---|---|
| R² | 0.8246 (82.46%) |
| Adjusted R² | 0.7763 (77.63%) |
| Residual Std. Error | 303,566.7 |
| F-statistic p-value | 4.75 × 10⁻⁹ |

**Diagnostic checking:** 5 of 6 classical assumptions satisfied (linearity, normality, homoscedasticity,
no autocorrelation). Multicollinearity was detected among several education-count predictors (expected,
given that counts of institutions/teachers/students are naturally correlated), but this does not
invalidate the model's predictive/interpretive use — it is flagged transparently in the diagnostics.

### Significant drivers of UMP
- **Positive:** number of higher-education institutions, number of SMK schools, number of SMK students,
  number of SMA teachers.
- **Negative:** APK (gross enrollment ratio) in higher education, number of SMK teachers, number of SMA
  students, number of education personnel under Kemendiktisaintek.

## Policy Implications

- Expand access to higher education in provinces with low APK, since low APK correlates with lower UMP.
- Improve SMK (vocational) teacher quality and align curricula with local industry needs, rather than
  simply increasing teacher headcount.
- Provide fiscal incentives to provinces with strong higher-education and vocational-school ecosystems.
- Launch subsidized apprenticeship programs linking SMK/university graduates to strategic industries.

## Tools & Packages

R, with `openxlsx`, `dplyr`, `ggplot2`, `GGally`, `lmtest`, `car`, `runstest`.

## Repository Structure

```
UMP-Education-Regression/
├── README.md
├── data/
│   └── README.md          # expected data files & structure
├── scripts/
│   ├── helpers.R           # model_criterion() helper function
│   └── ump_regression_analysis.R
├── outputs/
│   └── model_summary.md    # full model-by-model results table
└── figures/                # place generated plots here (Q-Q plot, residuals vs fitted, etc.)
```

## Author

**Karina Dwi Anggraini**
Undergraduate, Mathematics, Universitas Gadjah Mada
Supervised by: Era Setya Cahyati, S.Si., M.Sc. (course instructor)
