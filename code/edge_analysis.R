library(brms)
library(here)
library(tidyverse)
library(janitor)

setwd(here::here("results"))
# this file is too large (~2GB) to store on GitHub
# Download it from Google Drive and save it in the "results" folder of your local repo
m <- readRDS("brms_results_2023-11-01.rds")

sp_trends <- brms::ranef( m, pars = "yr")[[1]] |> 
  tibble::as_tibble(rownames = "sp") |> 
  setNames(c("sp", "mean", "sd", "l95", "u95")) |> 
  dplyr::mutate(sp = as.numeric(sp))

setwd(here::here("data"))

load("formatted_data_for_model.RData")

key <- read_csv("code_key.csv")

eh <- read_csv("edge_hardness_metrics.csv") |> 
  dplyr::left_join(key) |> 
  dplyr::rename(code4 = sp) |> 
  dplyr::right_join( 
    ncap |> 
      dplyr::select(sp, code4) |> 
      dplyr::distinct() )

# "Cold" species, aka trailing-edge species
cold_sp <- eh |> 
  dplyr::filter(warm_mdist <= 100) |> 
  dplyr::mutate(rel_nwarm = as.numeric(scale(log(nwarm_mean / avgn))), 
                ti_mean = as.numeric(scale(ti_mean)))

# "Warm" species, aka leading-edge species
warm_sp <- eh |> 
  dplyr::filter(cold_mdist <= 100) |> 
  dplyr::mutate(rel_ncold = as.numeric(scale(log(nwarm_mean / avgn))), 
                ti_mean = as.numeric(scale(ti_mean)))


cold_trends <- cold_sp |> 
  left_join(sp_trends)

warm_trends <- warm_sp |> 
  left_join(sp_trends)

trend_posterior <- brms::posterior_samples( m, pars = "yr") |> 
  tibble::as_tibble(rownames = "iter") |> 
  tidyr::pivot_longer(2:100, names_to = "param", values_to = "value") |> 
  dplyr::filter( grepl("r_sp\\[", param)) |> 
  dplyr::mutate(sp = readr::parse_number(param)) |> 
  dplyr::select(sp, value) |> 
  dplyr::group_by( sp ) |> 
  dplyr::mutate( sample = dplyr::row_number()) |> 
  dplyr::ungroup() |> 
  dplyr::select(sp, sample, value)

samples_to_select <- sort(sample(1:max(trend_posterior$sample), 1000, replace = FALSE ))

final_warm <- trend_posterior |> 
  dplyr::filter( sample %in% samples_to_select ) |> 
  dplyr::group_by(sp ) |> 
  dplyr::mutate(new_sample = row_number()) |> 
  dplyr::select( sp, sample = new_sample, value) |> 
  dplyr::right_join(warm_sp) |> 
  dplyr::select(sp, code4,
                sample, value,
                rel_ncold, ti_mean ) |> 
  dplyr::ungroup() 

final_cold <- trend_posterior |> 
  dplyr::filter( sample %in% samples_to_select ) |> 
  dplyr::group_by(sp ) |> 
  dplyr::mutate(new_sample = row_number()) |> 
  dplyr::select( sp, sample = new_sample, value) |> 
  dplyr::right_join(cold_sp) |> 
  dplyr::select(sp, code4,
                sample, value,
                rel_nwarm, ti_mean ) |> 
  dplyr::ungroup() 

rm(m)

res_trailing <- list(list())
res_leading <- list(list())

for( i in 1:1000){
  
  leading <- brm( 
    value ~ ti_mean + rel_ncold + ti_mean:rel_ncold,
    data = dplyr::filter(final_warm, sample == i),
    family = gaussian(), 
    prior = c(prior(normal(0, 1), class = Intercept), 
              prior(normal(0, 0.25), class = b))
  )
  
  res_leading[[i]] <- brms::posterior_samples( leading ) |> 
    tibble::as_tibble(rownames = "sample") |> 
    tibble::add_column( run = i)
  
  trailing <- brm( 
    value ~ ti_mean + rel_nwarm + ti_mean:rel_nwarm,
    data = dplyr::filter(final_cold, sample == i),
    family = gaussian(), 
    prior = c(prior(normal(0, 1), class = Intercept), 
              prior(normal(0, 0.25), class = b))
  )
  
  res_trailing[[i]] <- brms::posterior_samples( trailing ) |> 
    tibble::as_tibble(rownames = "sample") |> 
    tibble::add_column( run = i)
  
  print( paste("Finished run", i, "of 1000"))
}

setwd(here::here("results"))

all_trailing <- dplyr::bind_rows(res_trailing) |> 
  janitor::clean_names()

save(all_trailing, file = "trailing_edge_analysis.RData")

all_leading <- dplyr::bind_rows(res_leading) |> 
  janitor::clean_names()

save(all_leading, file = "leading_edge_analysis.RData")
