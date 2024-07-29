# plot trends on phylogeny

library(here)
library(tidyverse)
library(brms)
library(avotrex)
library(MetBrewer)
library(ggtree)

data(BirdTree_trees)

phy <- BirdTree_trees[[1]]
tax <- BirdTree_tax |> 
  tibble::as_tibble()

setwd(here::here("data"))

load("brms_data_revision.RData")

key <- df |> 
  dplyr::select(sp, code, common) |> 
  dplyr::distinct()

setwd(here::here("results"))
# too big for github
# available for download: https://1drv.ms/u/s!AtvYBfNq7AMkhKgyHsRmtvRMK0WCbQ?e=7CjAgm
m <- readRDS("brms_results_2024-05-15.rds")

trends <- brms::ranef( m, pars = "year")[[1]] |> 
  tibble::as_tibble(rownames = "sp") |> 
  stats::setNames(c("sp", "mean", "sd", "l95", "u95")) |> 
  dplyr::mutate(sp = as.numeric(sp)) |> 
  dplyr::full_join(key) |> 
  dplyr::mutate(English = common) |> 
  dplyr::mutate( English = ifelse(common == "Canada Jay", "Grey Jay", English)) |>   
  dplyr::mutate( English = ifelse(common == "Eastern Wood-Pewee",
                                  "Eastern Wood-pewee", English))|> 
  dplyr::select(sp, code, common, English, mean:u95)

not_data <- tax |> 
  dplyr::anti_join(trends)

mytree <- ape::drop.tip( phy, not_data$TipLabel)

final <- trends |>
  dplyr::left_join(tax) |>
  dplyr::select(sp, code, common, tip.label = TipLabel, mean:u95)

info <- tibble(tip.label = mytree$tip.label) |>
  dplyr::left_join(final)

ggtree(mytree, layout = "circular") %<+% info +
  geom_tippoint(aes(color = mean), size = 3) + 
  geom_tiplab(aes(label = code), offset = 5) +
  scale_color_gradient2(
    "Trend",
    low = MetBrewer::MetPalettes$Ingres[[1]][7], 
    mid = "gray95", 
    high = MetBrewer::MetPalettes$Ingres[[1]][4]) +
  theme(legend.ticks = element_blank())

setwd(here::here("figures"))
ggsave(
  filename = "figure_s5.png", 
  width = 5, 
  height = 5, 
  units = "in", 
  dpi = 600
)