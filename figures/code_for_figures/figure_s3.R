library(here)
library(tidyverse)
library(ggh4x)
library(MetBrewer)

setwd(here::here("results"))

# File too big to push to GitHub; download from link to local repo
# https://1drv.ms/u/s!AtvYBfNq7AMkg4lFAGeIc--nllbz_g?e=dX3CiS
load("leading_edge_analysis.RData")
# File too big to push to GitHub; download from link to local repo
# https://1drv.ms/u/s!AtvYBfNq7AMkg4lG4AFyCAWyMD1LTg?e=Q4z4ja
load("trailing_edge_analysis.RData")

coeff <- all_leading |> 
  dplyr::select(run, sample, b_ti_mean:b_ti_mean_rel_ncold) |> 
  tidyr::pivot_longer(b_ti_mean:b_ti_mean_rel_ncold) |> 
  dplyr::group_by(name) |> 
  dplyr::summarise( mean = mean(value), 
                    l95 = quantile(value, c(0.025)), 
                    u95 = quantile(value, c(0.975)), 
                    l68 = quantile(value, c(0.160)), 
                    u68 = quantile(value, c(0.840))) |> 
  tibble::add_column(edge = "Leading edge") |> 
  dplyr::full_join(
    all_trailing |> 
      dplyr::select(run, sample, b_ti_mean:b_ti_mean_rel_nwarm) |> 
      tidyr::pivot_longer(b_ti_mean:b_ti_mean_rel_nwarm) |> 
      dplyr::group_by(name) |> 
      dplyr::summarise( mean = mean(value), 
                        l95 = quantile(value, c(0.025)), 
                        u95 = quantile(value, c(0.975)), 
                        l68 = quantile(value, c(0.160)), 
                        u68 = quantile(value, c(0.840))) |> 
      tibble::add_column(edge = "Trailing edge")) |>
  dplyr::mutate(name_lab = ifelse(name == "b_ti_mean", "Temperature", 
                                  ifelse( name == "b_rel_ncold" | name == "b_rel_nwarm",
                                          "Edge hardness", "Edge hardness x Temperature"))) |> 
  dplyr::mutate(name_lab = factor(name_lab, 
                                  levels = c("Edge hardness x Temperature",
                                             "Temperature",
                                             "Edge hardness"))) |> 
  dplyr::mutate(edge = factor(edge, levels = c("Trailing edge", "Leading edge")))

strip <- ggh4x::strip_themed(text_x = elem_list_text(color = MetBrewer::MetPalettes$Isfahan1[[1]][c(1,7)]))

ggplot(coeff, aes(x = mean, y = name_lab, color = edge)) +
  facet_wrap2(~edge, strip = strip) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  geom_errorbar(aes(xmin = l95, xmax = u95), width = 0) +
  geom_errorbar(aes(xmin = l68, xmax = u68), width = 0, size = 1.5) +
  geom_point(size = 3) +
  ggplot2::scale_color_manual("Edge", 
                              values = MetBrewer::MetPalettes$Isfahan1[[1]][c(1,7)]) +
  theme_minimal() +
  labs(x = "Coefficient estimate") +
  theme(
    legend.position = "none",
    axis.title.y = element_blank(),
    axis.text = element_text(size = 10, color = "black"), 
    axis.title = element_text(size = 11, color = "black"), 
    strip.text = element_text(size = 11, face = "bold"),
    panel.background = element_rect(fill = "white", color = NA), 
    plot.background = element_rect(fill = "white", color = NA))

setwd(here::here("figures"))
ggsave(
  "figure_s3.png", 
  width = 5, 
  height = 2.5,
  units = "in", 
  dpi = 300
)