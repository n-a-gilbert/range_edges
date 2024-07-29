library(here)
library(tidyverse)
library(brms)
library(MetBrewer)
library(ggh4x)
library(janitor)

setwd(here::here("results"))
# File too big to push to GitHub; download from link to local repo
# https://1drv.ms/u/s!AtvYBfNq7AMkhKgyHsRmtvRMK0WCbQ?e=Bl9yfZ
m <- readRDS("brms_results_2024-05-15.rds")

sp_trends <- brms::ranef( m, pars = "year")[[1]] |> 
  tibble::as_tibble(rownames = "sp") |> 
  setNames(c("sp", "mean", "sd", "l95", "u95")) |> 
  dplyr::mutate(sp = as.numeric(sp))

rm(m)
# File too big to push to GitHub; download from link to local repo
# https://1drv.ms/u/s!AtvYBfNq7AMkhKsz13VTqKFps_McQg?e=TP4Ulo
load("edge_analysis_leading.RData")

all_leading <- dplyr::bind_rows(leading_results) |> 
  janitor::clean_names()

# File too big to push to GitHub; download from link to local repo
# https://1drv.ms/u/s!AtvYBfNq7AMkhKsxdttorVStYyPSUg?e=IBti26
# analysis with Connecticut Warbler dropped (influential point)
load("edge_analysis_trailing_no_conw.RData")

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
  dplyr::filter(!code4 == "CONW") |> 
  dplyr::mutate(rel_nwarm_sc = as.numeric(scale(log(nwarm_mean / avgn))), 
                ti_mean_sc = as.numeric(scale(ti_mean)))

leading_sp <- eh |> 
  dplyr::filter(cold_mdist <= 100) |> 
  dplyr::mutate(rel_ncold_sc = as.numeric(scale(log(ncold_mean / avgn))), 
                ti_mean_sc = as.numeric(scale(ti_mean)))

pdat_trailing <- tibble::as_tibble(
  expand.grid(
    ti_mean = c(mean(trailing_sp$ti_mean_sc)),
    rel_nwarm = seq( from = min(trailing_sp$rel_nwarm_sc) - 0.2, 
                     to = max(trailing_sp$rel_nwarm_sc) + 0.2,
                     by = 0.2)))

plot_trailing <- all_trailing |> 
  dplyr::select(sample:b_ti_eh) |> 
  dplyr::cross_join(pdat_trailing) |> 
  dplyr::mutate( p = b_intercept + b_ti*ti_mean + b_eh * rel_nwarm + b_ti_eh*ti_mean * rel_nwarm) |> 
  dplyr::group_by(ti_mean, rel_nwarm) |> 
  dplyr::summarise(mean = mean(p), 
                   l95 = quantile(p, c(0.025)), 
                   u95 = quantile(p, c(0.975)))

trailing_trends_for_plot <- trailing_sp |> 
  dplyr::mutate(rel_nwarm_unscaled = log(nwarm_mean / avgn),
                rel_nwarm_raw = nwarm_mean / avgn) |> 
  dplyr::select(sp, code4, ti_mean, rel_nwarm_sc, rel_nwarm_unscaled, rel_nwarm_raw) |> 
  dplyr::left_join(sp_trends)

trailing_ti_mean_scaled <- scale(trailing_trends_for_plot$ti_mean )
trailing_eh_scaled <- scale(trailing_trends_for_plot$rel_nwarm_unscaled )

plot_trailing_unscaled <- plot_trailing |> 
  dplyr::mutate(ti_mean_unscaled = ti_mean * attr(trailing_ti_mean_scaled, "scaled:scale") + 
                  attr(trailing_ti_mean_scaled , "scaled:center"),
                rel_nwarm_unscaled = rel_nwarm * attr(trailing_eh_scaled , "scaled:scale") +
                  attr(trailing_eh_scaled , "scaled:center")) |> 
  dplyr::mutate(rel_nwarm_raw = exp(rel_nwarm_unscaled))

pdat_leading <- tibble::as_tibble(
  expand.grid(
    ti_mean = c(mean(leading_sp$ti_mean_sc)),
    rel_ncold = seq( from = min(leading_sp$rel_ncold_sc) - 0.2, 
                     to = max(leading_sp$rel_ncold_sc) + 0.2,
                     by = 0.2)))

plot_leading <- all_leading |> 
  dplyr::select(sample:b_ti_eh) |> 
  dplyr::cross_join(pdat_leading) |> 
  dplyr::mutate( p = b_intercept + b_ti*ti_mean + b_eh*rel_ncold + b_ti_eh*ti_mean * rel_ncold) |> 
  dplyr::group_by(ti_mean, rel_ncold) |> 
  dplyr::summarise(mean = mean(p), 
                   l95 = quantile(p, c(0.025)), 
                   u95 = quantile(p, c(0.975)))

leading_trends_for_plot <- leading_sp |> 
  dplyr::mutate(rel_ncold_unscaled = log(ncold_mean / avgn),
                rel_ncold_raw = ncold_mean / avgn) |> 
  dplyr::select(sp, code4, ti_mean, rel_ncold_sc, rel_ncold_unscaled, rel_ncold_raw) |> 
  dplyr::left_join(sp_trends)

leading_ti_mean_scaled <- scale(leading_trends_for_plot$ti_mean )
leading_eh_scaled <- scale(leading_trends_for_plot$rel_ncold_unscaled )

plot_leading_unscaled <- plot_leading |> 
  dplyr::mutate(ti_mean_unscaled = ti_mean * attr(leading_ti_mean_scaled, "scaled:scale") + 
                  attr(leading_ti_mean_scaled , "scaled:center"),
                rel_ncold_unscaled = rel_ncold * attr(leading_eh_scaled , "scaled:scale") +
                  attr(leading_eh_scaled , "scaled:center")) |> 
  dplyr::mutate(rel_ncold_raw = exp(rel_ncold_unscaled))

strip <- ggh4x::strip_themed(text_x = elem_list_text(color = MetBrewer::MetPalettes$Isfahan1[[1]][c(1,7)]))

model_predictions <- plot_leading_unscaled |> 
  dplyr::rename( edge_hardness = rel_ncold_raw) |> 
  tibble::add_column( edge = "Leading edge") |> 
  dplyr::ungroup() |> 
  dplyr::select(ti_mean_unscaled, edge_hardness, edge, mean:u95) |> 
  dplyr::full_join(
    plot_trailing_unscaled |>
      dplyr::rename( edge_hardness = rel_nwarm_raw) |> 
      tibble::add_column( edge = "Trailing edge") |> 
      dplyr::ungroup() |> 
      dplyr::select(ti_mean_unscaled, edge_hardness, edge, mean:u95)) |> 
  dplyr::mutate(edge = factor(edge, levels = c("Trailing edge", "Leading edge")))

model_trends <- trailing_trends_for_plot |> 
  dplyr::select(code4, ti_mean, edge_hardness = rel_nwarm_raw, mean, l95, u95) |> 
  tibble::add_column( edge = "Trailing edge") |> 
  dplyr::full_join(
    leading_trends_for_plot |> 
      dplyr::select(code4, ti_mean, edge_hardness = rel_ncold_raw, mean, l95, u95) |> 
      tibble::add_column(edge = "Leading edge")) |> 
  dplyr::mutate(edge = factor(edge, levels = c("Trailing edge", "Leading edge")))

ggplot() + 
  facet_wrap2(~edge, strip = strip, ncol = 1) +
  geom_errorbar(data = model_trends, 
                aes(x = edge_hardness, 
                    ymin = l95, 
                    ymax = u95), 
                width = 0,
                color = "gray40",
                size = 0.5) +
  geom_point(data = model_trends, 
             aes(x = edge_hardness, y = mean),
             color = "gray40",
             size = 1.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = MetBrewer::MetPalettes$Johnson[[1]][5]) +
  geom_ribbon(data = model_predictions, 
              aes(x = edge_hardness,
                  ymin = l95,
                  ymax = u95,
                  fill = edge), color = NA, alpha = 0.2, show.legend = FALSE) +
  geom_line(data = model_predictions, 
            aes(x = edge_hardness, 
                y = mean, 
                color = edge),
            size = 2, show.legend = FALSE) +
  ggplot2::scale_color_manual("Edge", 
                              values = MetBrewer::MetPalettes$Isfahan1[[1]][c(1,7)]) +
  ggplot2::scale_fill_manual("Edge", 
                             values = MetBrewer::MetPalettes$Isfahan1[[1]][c(1,7)]) +
  
  labs(
    x = "Range edge hardness",
    y = "Population trend") +
  theme_minimal() +
  theme(axis.text = element_text(size = 10, color = "black"), 
        axis.title = element_text(size = 11, color = "black"), 
        strip.text = element_text(size = 11, color = "black", face = "bold"),
        panel.background = element_rect(fill = "white", color = NA), 
        plot.background = element_rect(fill = "white", color = NA),
        panel.spacing = unit(1.5, "lines"),
        plot.margin = margin(0.25, 1, 0.25, 0.25, unit = "lines"))

setwd(here::here("figures"))
ggsave(
  "figure_s3.png", 
  width = 4, 
  height = 6, 
  units = "in", 
  dpi = 600)
