library(here)
library(tidyverse)
library(brms)
library(MetBrewer)

setwd(here::here("data"))
load("brms_data_revision.RData")

key <- readr::read_csv("code_key.csv")

eh <- readr::read_csv("edge_hardness_metrics_v02.csv") |> 
  dplyr::left_join(key) |> 
  dplyr::rename(code4 = sp)

setwd(here::here("results"))
# this file is too large (~2GB) to store on GitHub
# Download from this onedrive link to "results" folder of repo
# https://1drv.ms/u/s!AtvYBfNq7AMkg4llzxN7tWMFyvXUCQ?e=IITVjK
m <- readRDS("brms_results_2024-05-15.rds")

sp_trends <- brms::ranef( m, pars = "year", probs = c(0.025, 0.160, 0.840, 0.975))[[1]] |> 
  tibble::as_tibble(rownames = "sp") |> 
  stats::setNames(c("sp", "mean", "sd", "l95", "l68", "u68", "u95")) |> 
  dplyr::mutate(sp = as.numeric(sp)) |> 
  dplyr::left_join( df |> dplyr::select(sp, code, common) |> dplyr::distinct())


eh |> 
  dplyr::mutate(type = ifelse( warm_mdist <= 100, "Trailing",
                               ifelse(cold_mdist <= 100, "Leading", "Omit"))) |> 
  dplyr::filter(!type == "Omit") |> 
  dplyr::mutate( eh = ifelse(type == "Trailing", nwarm_mean/avgn, ncold_mean/avgn)) |> 
  dplyr::select(code4, common, scientific, type, ti_mean, eh) |> 
  dplyr::left_join(sp_trends) |> 
  dplyr::arrange(type, mean) |> 
  dplyr::mutate(common = factor(common, levels = unique(common))) |> 
  
  ggplot2::ggplot( aes(x = mean, y = common, color = ti_mean)) +
  ggplot2::facet_grid(type~., scales = "free_y", space = "free") +
  ggplot2::geom_vline(xintercept = 0, color = "black", linetype = "dashed") +
  ggplot2::geom_errorbar(aes(xmin = l95, xmax = u95), width = 0) +
  ggplot2::geom_errorbar(aes(xmin = l68, xmax = u68), width = 0, size = 1) +
  ggplot2::geom_point() +
  ggplot2::scale_color_gradientn("Temperature index",
                                 colours = c(MetBrewer::MetPalettes$Johnson[[1]][4],
                                             "gray60",
                                             MetBrewer::MetPalettes$Johnson[[1]][2])) +
  ggplot2::theme_minimal() +
  ggplot2::labs(x = "Population trend") +
  ggplot2::theme(panel.background = element_rect(fill = "white", color = NA), 
                 plot.background = element_rect(fill = "white", color = NA),
                 legend.position = "bottom",
                 axis.title.y = element_blank(),
                 axis.text = element_text(size = 10, color = "black"),
                 axis.title.x = element_text(size = 11, color = "black"), 
                 legend.title = element_text(size = 10, color = "black"), 
                 legend.text = element_text(size = 10, color = "black"),
                 legend.ticks = element_blank()) +
  ggplot2::guides(color = guide_colorbar(title.vjust = 0.75))

setwd(here::here("figures"))
ggplot2::ggsave(
  filename = "figure_s01.png", 
  width = 5, 
  height = 7.5, 
  units = "in", 
  dpi = 300
)