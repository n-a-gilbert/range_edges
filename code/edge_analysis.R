library(brms)
library(here)
library(tidyverse)
library(janitor)

setwd(here::here("results"))
# this file is too large (~2GB) to store on GitHub
# Download from this onedrive link to "results" folder of repo
# https://1drv.ms/u/s!AtvYBfNq7AMkhKgyHsRmtvRMK0WCbQ?e=wWFud5
m <- readRDS("brms_results_2024-05-15.rds")

sp_trends <- brms::ranef( m, pars = "year")[[1]] |> 
  tibble::as_tibble(rownames = "sp") |> 
  setNames(c("sp", "mean", "sd", "l95", "u95")) |> 
  dplyr::mutate(sp = as.numeric(sp))

setwd(here::here("data"))

load("brms_data_revision.RData")

key <- read_csv("code_key.csv")

eh <- read_csv("edge_hardness_metrics.csv") |> 
  dplyr::left_join(key) |> 
  dplyr::rename(code4 = sp) |> 
  dplyr::right_join( 
    df |> 
      dplyr::select(sp, code4 = code) |> 
      dplyr::distinct() )

trailing_sp <- eh |> 
  dplyr::filter(warm_mdist <= 100) |> 
  dplyr::mutate(rel_nwarm = as.numeric(scale(log(nwarm_mean / avgn))), 
                ti_mean = as.numeric(scale(ti_mean)))

leading_sp <- eh |> 
  dplyr::filter(cold_mdist <= 100) |> 
  dplyr::mutate(rel_ncold = as.numeric(scale(log(nwarm_mean / avgn))), 
                ti_mean = as.numeric(scale(ti_mean)))

trailing_trends <- trailing_sp |> 
  left_join(sp_trends)

leading_trends <- leading_sp |> 
  left_join(sp_trends)

trend_posterior <- brms::posterior_samples( m, pars = "year") |> 
  tibble::as_tibble(rownames = "iter") |> 
  tidyr::pivot_longer(2:59, names_to = "param", values_to = "value") |> 
  dplyr::filter( grepl("r_sp\\[", param)) |> 
  dplyr::mutate(sp = readr::parse_number(param)) |> 
  dplyr::select(sp, value) |> 
  dplyr::group_by( sp ) |> 
  dplyr::mutate( sample = dplyr::row_number()) |> 
  dplyr::ungroup() |> 
  dplyr::select(sp, sample, value)

samples_to_select <- sort(sample(1:max(trend_posterior$sample), 1000, replace = FALSE ))

final_leading <- trend_posterior |> 
  dplyr::filter( sample %in% samples_to_select ) |> 
  dplyr::group_by(sp ) |> 
  dplyr::mutate(new_sample = row_number()) |> 
  dplyr::select( sp, sample = new_sample, trend = value,) |> 
  dplyr::right_join(leading_sp) |> 
  dplyr::select(sp,
                code4,
                sample,
                trend,
                eh = rel_ncold,
                ti = ti_mean ) |> 
  ungroup()

final_trailing <- trend_posterior |> 
  dplyr::filter( sample %in% samples_to_select ) |> 
  dplyr::group_by(sp ) |> 
  dplyr::mutate(new_sample = row_number()) |> 
  dplyr::select( sp, sample = new_sample, trend = value) |> 
  dplyr::right_join(trailing_sp) |> 
  dplyr::select(sp,
                code4,
                sample,
                trend,
                eh = rel_nwarm,
                ti = ti_mean ) |> 
  dplyr::ungroup() 

res_trailing <- list(list())
res_leading <- list(list())

for( i in 1:1000){
  
  leading <- brm( 
    trend ~ 1 + ti + eh + ti:eh,
    data = dplyr::filter(final_leading, sample == i),
    family = gaussian(), 
    prior = c(prior(normal(0, 2), class = Intercept), 
              prior(normal(0, 1), class = b))
  )
  
  res_leading[[i]] <- brms::posterior_samples( leading ) |> 
    tibble::as_tibble(rownames = "sample") |> 
    tibble::add_column( run = i)
  
  trailing <- brm( 
    trend ~ 1 + ti + eh + ti:eh,
    data = dplyr::filter(final_trailing, sample == i),
    family = gaussian(), 
    prior = c(prior(normal(0, 2), class = Intercept), 
              prior(normal(0, 1), class = b))
  )
  
  res_trailing[[i]] <- brms::posterior_samples( trailing ) |> 
    tibble::as_tibble(rownames = "sample") |> 
    tibble::add_column( run = i)
  
  print( paste("Finished run", i, "of 1000"))
}

setwd(here::here("results"))

save(res_trailing, file = "edge_analysis_trailing.RData")

save(res_leading, file = "edge_analysis_leading.RData")