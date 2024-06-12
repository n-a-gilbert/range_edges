library(here)
library(tidyverse)
library(sf)
library(ggspatial)
library(MetBrewer)
library(cowplot)

sp_list <- c("Alder Flycatcher", "Baltimore Oriole", "Bay-breasted Warbler", 
             "Black-backed Woodpecker", "Blackburnian Warbler", "Blue-winged Warbler", 
             "Boreal Chickadee", "Brown Thrasher", "Canada Jay", "Canada Warbler", 
             "Cape May Warbler", "Connecticut Warbler", "Dark-eyed Junco", 
             "Eastern Bluebird", "Eastern Towhee", "Eastern Wood-Pewee", "Evening Grosbeak", 
             "Golden-crowned Kinglet", "Golden-winged Warbler", "Great Crested Flycatcher", 
             "Hermit Thrush", "Indigo Bunting", "Lincoln's Sparrow", "Magnolia Warbler", 
             "Mourning Dove", "Mourning Warbler", "Nashville Warbler", "Northern Waterthrush", 
             "Olive-sided Flycatcher", "Palm Warbler", "Pine Warbler", "Purple Finch", 
             "Red-bellied Woodpecker", "Red-breasted Nuthatch", "Red Crossbill", 
             "Ruby-crowned Kinglet", "Ruby-throated Hummingbird", "Ruffed Grouse", 
             "Scarlet Tanager", "Sedge Wren", "Spruce Grouse", "Swainson's Thrush", 
             "Tennessee Warbler", "White-throated Sparrow", "White-winged Crossbill", 
             "Wilson's Warbler", "Winter Wren", "Wood Thrush", "Yellow-bellied Flycatcher", 
             "Yellow-bellied Sapsucker", "Yellow-billed Cuckoo", "Yellow-rumped Warbler", 
             "Yellow-throated Vireo")

setwd(here::here("data"))

coords <- readr::read_csv("coordinates.csv") |> 
  sf::st_as_sf( coords = c("xcoord", 
                           "ycoord"), 
                crs = 2027)

key <- readr::read_csv("code_key.csv") |> 
  dplyr::filter(common %in% sp_list)

d <- list(list())
setwd(here::here("data"))
for(i in 1:length(unique(key$code6))){
  setwd(here::here(paste0("data/ebird_ranges/", key[[i, "code6"]], "/ranges")))
  d[[i]] <- sf::st_read(paste0(key[[i, "code6"]], "_range_smooth_27km_2022.gpkg"))
}
cold_sp <- c("Alder Flycatcher", "Bay-breasted Warbler", "Blackburnian Warbler", 
             "Black-backed Woodpecker", "Boreal Chickadee", "Cape May Warbler", 
             "Canada Warbler", "Connecticut Warbler", "Dark-eyed Junco", "Evening Grosbeak", 
             "Golden-crowned Kinglet", "Canada Jay", "Hermit Thrush", "Lincoln's Sparrow", 
             "Magnolia Warbler", "Mourning Warbler", "Nashville Warbler", 
             "Northern Waterthrush", "Olive-sided Flycatcher", "Palm Warbler", 
             "Purple Finch", "Red-breasted Nuthatch", "Red Crossbill", "Ruby-crowned Kinglet", 
             "Ruffed Grouse", "Spruce Grouse", "Swainson's Thrush", "Tennessee Warbler", 
             "White-throated Sparrow", "White-winged Crossbill", "Winter Wren", 
             "Wilson's Warbler", "Yellow-bellied Flycatcher", "Yellow-bellied Sapsucker", 
             "Yellow-rumped Warbler")

all <- dplyr::bind_rows(d) |> 
  dplyr::group_by(species_code) |> 
  dplyr::mutate( breeding = ifelse(grepl("breeding", season), 1, 0)) |> 
  dplyr::filter(case_when(breeding == 1 ~ season == "breeding",
                          T ~ season == "resident")) |> 
  dplyr::mutate(edge = ifelse(common_name %in% cold_sp, "Trailing edge", "Leading edge")) |> 
  sf::st_make_valid()

usa <- sf::st_as_sf(maps::map("state", fill=TRUE, plot =FALSE)) 

mn <- dplyr::filter(usa, ID == "minnesota") |> 
  sf::st_transform(crs = st_crs(all))

mn_bbox <- sf::st_as_sfc( st_bbox( mn ) )

all_crop <- sf::st_intersection( all, mn )

pts <- coords |> 
  sf::st_transform(crs = st_crs(all))

( main_map <- ggplot2::ggplot() + 
    ggplot2::geom_sf(data = all_crop, aes(geometry = geom, fill = edge, color = edge), alpha = 0.2) +
    ggplot2::geom_sf(data = mn, aes(geometry = geom), fill = NA, color = "black", linewidth = 1) +
    ggplot2::geom_sf(data = pts, pch = 21, color = "black", fill = "white") +
    ggplot2::scale_color_manual("Edge",
                                values = MetBrewer::MetPalettes$Isfahan1[[1]][c(5,1)]) +
    ggplot2::scale_fill_manual("Edge",
                               values = MetBrewer::MetPalettes$Isfahan1[[1]][c(5,1)]) +
    ggplot2::theme_void()+
    ggplot2::guides(fill = guide_legend(override.aes = list(alpha = 1))) +
    ggplot2::theme(legend.position = "bottom",
                   legend.title = element_blank(),
                   legend.text = element_text(size = 11, color = "black"),
                   plot.background = element_rect(fill = "white", color = NA), 
                   panel.background = element_rect(fill = "white", color = NA),
                   plot.margin = margin(0, 0, 5, 0, unit = "pt")) +
    ggspatial::annotation_scale(location = "tr") )

( inset <- ggplot() +
    geom_sf(data = usa) +
    geom_sf(data = filter(usa, ID == "minnesota"), fill = "gray20") +
    theme_void() +
    theme(plot.background = element_rect(color = "black", 
                                         fill = "white")) )


( figure_02 <- cowplot::ggdraw(main_map) +
    cowplot::draw_plot(
      {
        inset
      },
      x = 0.65,
      y = 0.3, 
      width = 0.3,
      height = 0.3
    )
)

setwd(here::here("figures"))
ggsave(
  filename = "figure_02.png", 
  plot = figure_02,
  width = 4, 
  height = 4.75, 
  units ="in", 
  dpi = 600
)