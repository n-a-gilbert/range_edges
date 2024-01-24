library(brms)
library(here)

setwd(here::here("data"))

load("formatted_data_for_model.RData")

setwd(here::here("results"))

m1 <- brms::brm(
  data = ncap,
  family = poisson(),
  formula = y ~ 1 + yr + ( 1 + yr | sp ) + ( 1 | sp:site),
  prior = c( prior(normal(0, 2), class = Intercept), 
             prior(normal(0, 0.25), class = b),
             prior(exponential(1), class = sd), 
             prior(lkj(2), class = cor)),
  iter = 5000, 
  warnup = 3000,
  chains = 4, 
  cores = 4, 
  file = paste0("brms_results_", Sys.Date()))