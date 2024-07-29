library(here)
library(tidyverse)
library(brms)
library(MetBrewer)
library(ggh4x)
library(janitor)

setwd(here::here("results"))
# File too big to push to GitHub; download from link to local repo
# https://1drv.ms/u/s!AtvYBfNq7AMkhKgyHsRmtvRMK0WCbQ?e=brZbkY
m <- readRDS("brms_results_2024-05-15.rds")

sp_trends <- brms::ranef( m, pars = "year")[[1]] |> 
  tibble::as_tibble(rownames = "sp") |> 
  setNames(c("sp", "mean", "sd", "l95", "u95")) |> 
  dplyr::mutate(sp = as.numeric(sp))

rm(m)

# File too big to push to GitHub; download from link to local repo
# https://1drv.ms/u/s!AtvYBfNq7AMkhKsz13VTqKFps_McQg?e=ARAvj8
load("edge_analysis_leading.RData")

all_leading <- dplyr::bind_rows(leading_results) |> 
  janitor::clean_names()

# File too big to push to GitHub; download from link to local repo
# https://1drv.ms/u/s!AtvYBfNq7AMkhKsyxZokyDlvJtbZTA?e=sb7jw2
load("edge_analysis_trailing.RData")

all_trailing <- dplyr::bind_rows(trailing_results) |> 
  janitor::clean_names()

setwd(here::here("data"))

load("brms_data_revision.RData")

key <- readr::read_csv("code_key.csv")

eh <- readr::read_csv("edge_hardness_metrics.csv") |> 
  dplyr::left_join(key) |> 
  dplyr::rename(code4 = sp) |> 
  dplyr::right_join( 
    df |> 
      dplyr::select(sp, code4 = code) |> 
      dplyr::distinct() )

trailing_sp <- eh |> 
  dplyr::filter(warm_mdist <= 100) |> 
  dplyr::mutate(rel_nwarm_sc = as.numeric(scale(log(nwarm_mean / avgn))), 
                ti_mean_sc = as.numeric(scale(ti_mean)))

leading_sp <- eh |> 
  dplyr::filter(cold_mdist <= 100) |> 
  dplyr::mutate(rel_ncold_sc = as.numeric(scale(log(ncold_mean / avgn))), 
                ti_mean_sc = as.numeric(scale(ti_mean)))


sp_trends |> 
  full_join(trailing_sp) |> 
  dplyr::select(sp, code6, mean ) |> 
  dplyr::mutate(type = ifelse(is.na(code6), "Leading", "Trailing")) |> 
  
  ggplot(aes(x = type, y = mean, fill = type, color = type)) +
  geom_hline(yintercept = 0, color = "black", linetype = "dashed") +
  geom_boxplot() +
  theme_classic() +
  labs(x = "Range edge",
       y = "Population trend (posterior mean)") +
  ggplot2::scale_fill_manual("Edge", 
                             values = MetBrewer::MetPalettes$Isfahan1[[1]][c(6,2)]) +
  ggplot2::scale_color_manual("Edge", 
                             values = MetBrewer::MetPalettes$Isfahan1[[1]][c(7,1)]) +
  theme(axis.text = element_text(size = 10, color = "black"), 
        axis.title = element_text(size = 11, color = "black"), 
        # strip.text = element_text(size = 11, color = "black", face = "bold"),
        panel.background = element_rect(fill = "white", color = NA), 
        plot.background = element_rect(fill = "white", color = NA),
        panel.spacing = unit(1.5, "lines"),
        plot.margin = margin(0.25, 1, 0.25, 0.25, unit = "lines"),
        legend.position = "none")

setwd(here::here("figures"))
ggsave(
  filename = "figure_s02.png",
  width = 4,
  height = 3, 
  units = "in", 
  dpi = 600
)