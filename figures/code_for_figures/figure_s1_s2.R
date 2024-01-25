library(here)
library(tidyverse)
library(brms)
library(patchwork)
library(ggnewscale)
library(MetBrewer)

setwd(here::here("results"))
# this file is too large (~2GB) to store on GitHub
# Download from this onedrive link to "results" folder of repo
# https://1drv.ms/u/s!AtvYBfNq7AMkg4llzxN7tWMFyvXUCQ?e=IITVjK
m <- readRDS("brms_results_2023-11-01.rds")

sp_trends <- brms::ranef( m, pars = "yr")[[1]] |> 
  tibble::as_tibble(rownames = "sp") |> 
  setNames(c("sp", "mean", "sd", "l95", "u95")) |> 
  dplyr::mutate(sp = as.numeric(sp))

setwd(here::here("data"))

load("formatted_data_for_model.RData")

key <- readr::read_csv("code_key.csv")

eh <- readr::read_csv("edge_hardness_metrics.csv") |> 
  dplyr::left_join(key) |> 
  dplyr::rename(code4 = sp) |> 
  dplyr::right_join(
    ncap |> 
      dplyr::select(sp, code4) |> 
      dplyr::distinct())

trailing_sp <- eh |> 
  dplyr::filter(warm_mdist <= 100) |> 
  dplyr::mutate(rel_nwarm_sc = as.numeric(scale(log(nwarm_mean / avgn))), 
         ti_mean_sc = as.numeric(scale(ti_mean)))

leading_sp <- eh |> 
  dplyr::filter(cold_mdist <= 100) |> 
  dplyr::mutate(rel_ncold_sc = as.numeric(scale(log(ncold_mean / avgn))), 
                ti_mean_sc = as.numeric(scale(ti_mean)))

trailing_sp |> 
  dplyr::left_join(sp_trends) |> 
  dplyr::select(common, ti_mean, mean, l95, u95) |> 
  dplyr::arrange(mean) |> 
  dplyr::mutate(common = factor(common, levels = unique(common))) |> 
  
  ggplot2::ggplot(aes(x = mean, y = common, color = ti_mean)) +
  geom_vline(xintercept = 0, color = "black", linetype = "dashed") +
  geom_errorbar(aes(xmin = l95, xmax = u95), width = 0, size = 1) +
  geom_point(size = 3) +
  scale_color_gradientn("Temperature index",
                        colours = c(MetBrewer::MetPalettes$Johnson[[1]][4],
                                    "gray60",
                                    MetBrewer::MetPalettes$Johnson[[1]][2])) +
  theme_minimal() +
  labs(x = "Population trend") +
  theme(panel.background = element_rect(fill = "white", color = NA), 
        plot.background = element_rect(fill = "white", color = NA),
        legend.position = "bottom",
        axis.title.y = element_blank(),
        axis.text = element_text(size = 10, color = "black"),
        axis.title.x = element_text(size = 11, color = "black"), 
        legend.title = element_text(size = 10, color = "black"), 
        legend.text = element_text(size = 10, color = "black")) +
  guides(color = guide_colorbar(ticks = FALSE, 
                                title.position = "top"))

setwd(here::here("figures"))
ggplot2::ggsave(
  filename = "figure_s1.png", 
  width = 5, 
  height = 7, 
  units = "in", 
  dpi = 300
)

leading_sp |> 
  dplyr::left_join(sp_trends) |> 
  dplyr::select(common, ti_mean, mean, l95, u95) |> 
  dplyr::arrange(mean) |> 
  dplyr::mutate(common = factor(common, levels = unique(common))) |> 
  
  ggplot2::ggplot(aes(x = mean, y = common, color = ti_mean)) +
  geom_vline(xintercept = 0, color = "black", linetype = "dashed") +
  geom_errorbar(aes(xmin = l95, xmax = u95), width = 0, size = 1) +
  geom_point(size = 3) +
  scale_color_gradientn("Temperature index",
                        colours = c(MetBrewer::MetPalettes$Johnson[[1]][4],
                                    "gray60",
                                    MetBrewer::MetPalettes$Johnson[[1]][2])) +
  theme_minimal() +
  labs(x = "Population trend") +
  theme(panel.background = element_rect(fill = "white", color = NA), 
        plot.background = element_rect(fill = "white", color = NA),
        legend.position = "bottom",
        axis.title.y = element_blank(),
        axis.text = element_text(size = 10, color = "black"),
        axis.title.x = element_text(size = 11, color = "black"), 
        legend.title = element_text(size = 10, color = "black"), 
        legend.text = element_text(size = 10, color = "black")) +
  guides(color = guide_colorbar(ticks = FALSE, 
                                title.position = "top"))

setwd(here::here("figures"))
ggplot2::ggsave(
  filename = "figure_s2.png", 
  width = 5, 
  height = 5, 
  units = "in", 
  dpi = 300
)