library(here)
library(raster)
library(tidyverse)
library(MetBrewer)
library(sf)

setwd(here::here("data"))
load("bird_site_1995-2023.RData")

sites <- d |> 
  dplyr::select(xcoord = X_COORD, 
                ycoord = Y_COORD) |> 
  dplyr::distinct() |> 
  dplyr::filter(!is.na(xcoord)) |> 
  dplyr::filter(!is.na(ycoord)) |> 
  sf::st_as_sf( coords = c("xcoord", 
                           "ycoord"), 
                crs = 2027)

clim <- raster::getData("worldclim", var = 'bio', res = 10)

setwd(here::here("data/ebird_abundance"))

map <- raster::raster("yetvir_abundance_seasonal_breeding_mean_2021.tif")

map84 <- raster::projectRaster( map, crs = crs(clim[[10]]))

abun <- raster::resample(map84, clim[[10]] )

abun[ abun == 0 ] <- NA

range <- abun

range[ range > 0 ] <- 1

ti <- range * ( clim[[10]] / 10 )

edges <- ti

edges[ edges > quantile( edges, c(0.10), na.rm = TRUE) & 
         edges < quantile( edges, c(0.90), na.rm = TRUE)] <- NA

edges[!is.na(edges)] <- 1

nedges <- edges * abun

abun_trim <- raster::trim(abun)
ti_trim <- raster::trim(ti)  
edges_trim <- raster::trim(edges)
nedges_trim <- raster::trim(nedges)

abun_spdf <- as(abun_trim, "SpatialPixelsDataFrame")

abun_df <- as.data.frame(abun_spdf)

abun_df |> 
  dplyr::filter(x > -104) |> 
  ggplot2::ggplot(aes(x = x, y = y, fill = breeding, color = breeding)) + 
  ggplot2::geom_tile() + 
  ggplot2::coord_fixed(1.3) +
  ggplot2::scale_fill_viridis_c("Abundance",
                                option = "B",
                                begin = 0.8,
                                end = 0.2,
                                breaks = c(0.08, 0.45),
                                labels = c("Low", "High")) +
  ggplot2::scale_color_viridis_c("Abundance",
                                 option = "B",
                                 begin = 0.8,
                                 end = 0.2,
                                 breaks = c(0.08, 0.45),
                                 labels = c("Low", "High")) +
  ggplot2::theme_void() +
  ggplot2::theme(legend.position = "bottom",
                 legend.text = element_text(color = "black", 
                                            size = 9), 
                 legend.title = element_text(color = "black", size = 9),
                 legend.margin = margin(-8, 0, 5, 0)) + 
  ggplot2::guides(fill = guide_colorbar(ticks = FALSE,
                                        barheight = 0.25,
                                        title.position = "top",
                                        barwidth = 3))

# saving panels individually and assembling in PowerPoint because I'm a dummy
setwd(here::here("figures"))
ggplot2::ggsave(
  filename = "figure_02a.png", 
  width = 1.75, 
  height = 1.75, 
  units = "in", 
  dpi = 300
)

ti_spdf <- as(ti_trim, "SpatialPixelsDataFrame")
ti_df <- as.data.frame(ti_spdf)

ti_df |> 
  dplyr::filter(x > -104) |> 
  ggplot2::ggplot(aes(x = x, y = y, fill = layer, color = layer)) + 
  ggplot2::geom_tile() + 
  ggplot2::coord_fixed(1.3) +
  ggplot2::scale_fill_gradientn("Temperature",
                                colours = c(MetBrewer::MetPalettes$Egypt[[1]][2],
                                            "gray70",
                                            MetBrewer::MetPalettes$Egypt[[1]][1]),
                                breaks = c(15.05, 28.95),
                                labels = c("Low", "High")) +
  ggplot2::scale_color_gradientn("Temperature",
                                 colours = c(MetBrewer::MetPalettes$Egypt[[1]][2],
                                             "gray70",
                                             MetBrewer::MetPalettes$Egypt[[1]][1]),
                                 breaks = c(15.05, 28.95),
                                 labels = c("Low", "High")) +
  ggplot2::theme_void() +
  ggplot2::theme(legend.position = "bottom",
                 legend.text = element_text(color = "black", 
                                            size = 9), 
                 legend.title = element_text(color = "black", size = 9),
                 legend.margin = margin(-8, 0, 5, 0)) + 
  ggplot2::guides(fill = guide_colorbar(ticks = FALSE,
                                        barheight = 0.25,
                                        title.position = "top",
                                        barwidth = 3))

setwd(here::here("figures"))
ggplot2::ggsave(
  filename = "figure_02b.png", 
  width = 1.75, 
  height = 1.75, 
  units = "in", 
  dpi = 300
)

edges_spdf <- as(edges_trim, "SpatialPixelsDataFrame")
edges_df <- as.data.frame(edges_spdf)

edges_df |> 
  dplyr::filter(x > -104) |> 
  dplyr::mutate(edge = ifelse(y > 39, "Leading", "Trailing")) |> 
  ggplot2::ggplot(aes(x = x, y = y, fill = edge, color = edge)) + 
  ggplot2::geom_tile() + 
  ggplot2::coord_fixed(1.3) +
  ggplot2::scale_color_manual("Edge", 
                              values = MetBrewer::MetPalettes$Isfahan1[[1]][c(7,1)]) +
  ggplot2::scale_fill_manual("Edge", 
                             values = MetBrewer::MetPalettes$Isfahan1[[1]][c(7,1)]) +
  ggplot2::theme_void() +
  ggplot2::theme(legend.position = "bottom",
                 legend.text = element_text(color = "black",size = 9), 
                 legend.key.size = unit(0.1, "cm"),
                 legend.title = element_text(color = "white", size = 9),
                 legend.margin = margin(-8, 0, 5, 0)) +
  ggplot2::guides(fill = guide_legend(title.position = "top"),
                  color = guide_legend(title.position = "top"))

setwd(here::here("figures"))
ggplot2::ggsave(
  filename = "figure_02c.png", 
  width = 1.64, 
  height = 1.64, 
  units = "in", 
  dpi = 300
)

nedges_spdf <- as(nedges_trim, "SpatialPixelsDataFrame")
nedges_df <- as.data.frame(nedges_spdf)

nedges_df |> 
  dplyr::filter(x > -104) |> 
  ggplot2::ggplot(aes(x = x, y = y, fill = layer, color = layer)) + 
  ggplot2::geom_tile() + 
  ggplot2::coord_fixed(1.3) +
  ggplot2::scale_fill_viridis_c("Abundance",
                                option = "B",
                                begin = 0.8,
                                end = 0.2,
                                breaks = c(0.08, 0.27),
                                labels = c("Low", "High")) +
  ggplot2::scale_color_viridis_c("Abundance",
                                 option = "B",
                                 begin = 0.8,
                                 end = 0.2,
                                 breaks = c(0.08, 0.27),
                                 labels = c("Low", "High")) +
  ggplot2::theme_void() +
  ggplot2::theme(legend.position = "bottom",
                 legend.text = element_text(color = "black", 
                                            size = 9), 
                 legend.title = element_text(color = "black", size = 9),
                 legend.margin = margin(-8, 0, 5, 0)) + 
  ggplot2::guides(fill = guide_colorbar(ticks = FALSE,
                                        barheight = 0.25,
                                        title.position = "top",
                                        barwidth = 3))
setwd(here::here("figures"))
ggplot2::ggsave(
  filename = "figure_02d.png", 
  width = 1.75, 
  height = 1.75, 
  units = "in", 
  dpi = 300
)

setwd(here::here("data"))

key <- readr::read_csv("code_key.csv")

eh <- readr::read_csv("edge_hardness_metrics.csv") |> 
  dplyr::left_join(key) |> 
  dplyr::rename(code4 = sp)

eh |> 
  dplyr::mutate( eh_leading = ncold_mean / avgn,
                 eh_trailing = nwarm_mean / avgn ) |> 
  dplyr::select( code4, avgn, ti_mean, ti_sd, eh_leading, eh_trailing, cold_mdist, warm_mdist ) |> 
  dplyr::filter(warm_mdist < 100 ) |> 
  dplyr::select(code4, avgn, ti_mean, ti_sd, eh_trailing) |> 
  dplyr::full_join(
    eh |> 
      dplyr::mutate( eh_leading = ncold_mean / avgn,
                     eh_trailing = nwarm_mean / avgn ) |>
      dplyr::select( code4, avgn, ti_mean, ti_sd, eh_leading, eh_trailing, cold_mdist, warm_mdist ) |> 
      dplyr::filter(cold_mdist < 100 ) |> 
      dplyr::select(code4, avgn, ti_mean, ti_sd, eh_leading)) |> 
  tidyr::pivot_longer(eh_trailing:eh_leading, names_to = "edge", values_to = "hardness") |> 
  dplyr::filter(!is.na(hardness)) |> 
  dplyr::mutate(edge = ifelse(grepl("leading", edge), "Leading edge", "Trailing edge")) |>
  dplyr::mutate(edge = factor(edge, levels = c("Trailing edge", "Leading edge"))) |> 
  ggplot2::ggplot(aes(x = hardness, fill = edge, color = edge)) + 
  ggplot2::facet_wrap(~edge) + 
  ggplot2::geom_histogram(alpha = 0.5) +
  geom_vline(xintercept = 1, linetype = "dashed", linewidth = 0.75) +
  ggplot2::scale_fill_manual(values = MetBrewer::MetPalettes$Isfahan1[[1]][c(1,7)]) +
  ggplot2::scale_color_manual(values = MetBrewer::MetPalettes$Isfahan1[[1]][c(1,7)]) +
  ggplot2::theme_minimal() +
  ggplot2::labs(x = "Range edge hardness", 
                y = "Frequency") +
  ggplot2::theme(legend.position = "none",
                 axis.text = element_text(color = "black", size = 11),
                 axis.title = element_text(color = "black", size = 12), 
                 strip.text = element_text(color = "black", size = 13), 
                 panel.background = element_rect(fill = "white", color = NA), 
                 plot.background = element_rect(fill = "white", color = NA))

setwd(here::here("figures"))
ggplot2::ggsave(
  filename = "figure_02e.png",  width = 5, 
  height = 2.5,
  units = "in", 
  dpi = 300
)  