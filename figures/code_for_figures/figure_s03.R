library(tidyverse)
library(here)
library(ggh4x)
library(janitor)
library(MetBrewer)

setwd(here::here("results"))

load("edge_analysis_leading.RData")

all_leading <- dplyr::bind_rows(leading_results) |> 
  janitor::clean_names()

load("edge_analysis_trailing_no_CONW.RData")

all_trailing <- dplyr::bind_rows(trailing_results) |> 
  janitor::clean_names()

est <- all_leading |> 
  dplyr::select(run, sample, b_ti:b_ti_eh) |> 
  tidyr::pivot_longer(b_ti:b_ti_eh, names_to = "param", values_to = "val") |> 
  dplyr::group_by(param) |> 
  dplyr::summarise( mean = mean(val), 
                    l95 = quantile(val, c(0.025)), 
                    l68 = quantile(val, c(0.160)), 
                    u68 = quantile(val, c(0.840)), 
                    u95 = quantile(val, c(0.975))) |> 
  dplyr::mutate(param = ifelse(param == "b_eh", "Edge hardness", 
                               ifelse(param == "b_ti", "Temperature", "Edge hardness x Temperature"))) |> 
  tibble::add_column( edge = "Leading edge") |> 
  dplyr::full_join(
    all_trailing |> 
      dplyr::select(run, sample, b_ti:b_ti_eh) |> 
      tidyr::pivot_longer(b_ti:b_ti_eh, names_to = "param", values_to = "val") |> 
      dplyr::group_by(param) |> 
      dplyr::summarise( mean = mean(val), 
                        l95 = quantile(val, c(0.025)), 
                        l68 = quantile(val, c(0.160)), 
                        u68 = quantile(val, c(0.840)), 
                        u95 = quantile(val, c(0.975))) |> 
      dplyr::mutate(param = ifelse(param == "b_eh", "Edge hardness", 
                                   ifelse(param == "b_ti", "Temperature", "Edge hardness x Temperature"))) |> 
      tibble::add_column( edge = "Trailing edge")
  ) |> 
  dplyr::mutate(param = factor(param, levels = c("Edge hardness x Temperature",
                                                 "Temperature",
                                                 "Edge hardness"))) |> 
  dplyr::mutate(edge = factor(edge, levels = c("Trailing edge", "Leading edge")))

strip <- ggh4x::strip_themed(text_x = elem_list_text(color = MetBrewer::MetPalettes$Isfahan1[[1]][c(1,5)]))

ggplot2::ggplot( est, aes(x = mean, y = param, color = edge)) + 
  ggh4x::facet_wrap2(~edge, strip = strip) +
  ggplot2::geom_vline(xintercept = 0, linetype = "dashed") +
  ggplot2::geom_errorbar(aes(xmin = l95, xmax = u95), width = 0) +
  ggplot2::geom_errorbar(aes(xmin = l68, xmax = u68), width = 0, size = 1.5) +
  ggplot2::geom_point(size = 3) +
  ggplot2::scale_color_manual("Edge", 
                              values = MetBrewer::MetPalettes$Isfahan1[[1]][c(1,5)]) +
  ggplot2::theme_minimal() +
  ggplot2::labs(x = "Coefficient estimate") +
  ggplot2::theme(
    legend.position = "none",
    axis.title.y = element_blank(),
    axis.text = element_text(size = 10, color = "black"), 
    axis.title = element_text(size = 11, color = "black"), 
    strip.text = element_text(size = 11, face = "bold"),
    panel.background = element_rect(fill = "white", color = NA), 
    plot.background = element_rect(fill = "white", color = NA))

setwd(here::here("figures"))
ggplot2::ggsave(
  "figure_s3.png", 
  width = 5, 
  height = 2.5,
  units = "in", 
  dpi = 600
)
