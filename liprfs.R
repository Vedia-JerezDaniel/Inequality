library(lpirfs)
library(tidyverse)
library(readxl)
library(lmtest)

https://adaemmerp.github.io/lpirfs/README_docs.html

ine <- read_excel("E:/ECB/INEQUALITY/2020/FINAL 04.xlsx", sheet = "log (2)")

ine <-  as.data.frame(ine)
ine2 <- tibble(drop_na(ine))

endog_data <- interest_rules_var_data


results_lin <- lp_lin(endog_data = endog_data,
                      lags_endog_lin = 4,
                      trend = 0,
                      shock_type = 1,
                      confint = 1.96,
                      hor = 9)
plot(results_lin)

summary(results_lin)[[1]][1]

# Nonlinearities

library(dplyr)
library(gridExtra)
library(ggpubr)

switching_data <- if_else(dplyr::lag(endog_data$Infl, 3) > 4.75, 1, 0)

results_nl <- lp_nl(endog_data,
                    lags_endog_lin = 4, lags_endog_nl = 4,
                    trend = 1, shock_type = 0,
                    confint = 1.67, hor = 12,
                    switching = switching_data, lag_switching = FALSE,
                    use_logistic = FALSE)

nl_plots <- plot_nl(results_nl)

single_plots <- nl_plots$gg_s1[c(3, 6, 9)] # toma los FF on rest of vars
single_plots[4:6] <- nl_plots$gg_s2[c(3, 6, 9)]
all_plots <- sapply(single_plots, ggplotGrob)
marrangeGrob(all_plots, nrow = 3, ncol = 2, top = NULL)

