library(avotrex)
library(tidyverse)
library(here)
library(ape)
library(phyr)

data(BirdTree_trees)

phy <- BirdTree_trees[[1]]
tax <- BirdTree_tax |> 
  tibble::as_tibble()

setwd(here::here("data"))

load("brms_data_revision2.RData")

fe <- list(list())
re <- list(list())

for(i in 1:100){
  
  sites <- sample(unique(df$site), 2, replace = FALSE)
  
  smalld <- df |> 
    dplyr::filter( site %in% sites) |> 
    dplyr::rename(TipLabel = tip.label) |> 
    dplyr::rename(yr = year) |> 
    dplyr::mutate(yr = as.numeric(scale(yr)),
                  doy = as.numeric(scale(doy)), 
                  time = as.numeric(scale(time)))
  
  not_data <- tax |> 
    dplyr::anti_join(smalld)
  
  mytree <- ape::drop.tip( phy, not_data$TipLabel)
  
  m1 <- phyr::pglmm( formula = y ~ 1 + yr + doy + time + (1|TipLabel__) + (yr|TipLabel__) + (doy|TipLabel) + (time|TipLabel) + (1|obs),
                     family = "poisson",
                     data = smalld, 
                     cov_ranef = list(TipLabel = mytree), 
                     add.obs.re = FALSE)
  
  fe[[i]] <- phyr::fixef(m1) |> 
    tibble::as_tibble(rownames = "param") |> 
    tibble::add_column(run = i)
  
  re[[i]] <- phyr::ranef(m1) |> 
    tibble::as_tibble(rownames = "param") |> 
    tibble::add_column(run = i)
  
}

setwd(here::here("results"))

dplyr::bind_rows( fe ) |> 
  readr::write_csv("fe_phylogenetic_regression_subsets_v01.csv")

dplyr::bind_rows( re ) |> 
  readr::write_csv("re_phylogenetic_regression_subsets_v01.csv")