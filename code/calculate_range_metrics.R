library(here)
library(raster)
library(tidyverse)
library(sf)

setwd(here::here("data"))
d <- read_csv("coordinates.csv")

sites <- d |> 
  dplyr::filter(!is.na(xcoord)) |> 
  dplyr::filter(!is.na(ycoord)) |> 
  sf::st_as_sf( coords = c("xcoord", 
                           "ycoord"), 
                crs = 2027)

clim <- raster::getData("worldclim", var = 'bio', res = 10)

setwd(here::here("data/ebird_abundance"))

filenames <- list.files( pattern = "*.tif")

eh <- list(list())
for( i in 1:length(filenames)){
  map <- raster::raster(filenames[i])
  map84 <- raster::projectRaster( map, crs = crs(clim[[10]]))
  abun <- raster::resample(map84, clim[[10]] )
  abun[ abun == 0 ] <- NA
  range <- abun
  range[ range > 0 ] <- 1
  ti <- range * ( clim[[10]] / 10 )
  cold <- ti
  warm <- ti
  cold[ cold > quantile( cold, c(0.10), na.rm = TRUE) ] <- NA
  warm[ warm < quantile( warm, c(0.90), na.rm = TRUE) ] <- NA
  cold[ !is.na(cold) ] <- 1
  warm[ !is.na(warm) ] <- 1
  ncold <- cold * abun
  nwarm <- warm * abun
  ti_mean <- mean( values( ti ), na.rm = TRUE )
  ti_sd <- sd( values( ti ), na.rm = TRUE )
  ti_range <- max( values( ti ), na.rm = TRUE ) - min( values( ti ), na.rm = TRUE)
  ncold_mean <- mean( values( ncold ), na.rm = TRUE )
  ncold_sd <- sd( values( ncold ), na.rm = TRUE )
  ncold_range <- max( values( ncold), na.rm = TRUE) - min( values( ncold), na.rm = TRUE)
  nwarm_mean <- mean( values( nwarm ), na.rm = TRUE )
  nwarm_sd <- sd( values( nwarm ), na.rm = TRUE )
  nwarm_range <- max( values( nwarm), na.rm = TRUE) - min( values( nwarm), na.rm = TRUE)
  avgn <- mean( values( abun ), na.rm = TRUE)
  code6 <- substr( filenames[i], 1, 6)
  sites2 <- sites %>% 
    sf::st_transform(., crs = sf::st_crs(cold))
  cold_edge_min_distance <-
    raster::xyFromCell(cold, which(cold[]==1)) %>%
    tibble::as_tibble() %>% 
    sf::st_as_sf(., 
                 coords = c("x", "y"), 
                 crs = sf::st_crs(cold)) %>%
    sf::st_distance(sites2) %>% 
    min(./1000) %>%
    as.numeric()
  warm_edge_min_distance <- 
    raster::xyFromCell(warm, which(warm[]==1)) %>%
    tibble::as_tibble() %>% 
    sf::st_as_sf(., 
                 coords = c("x", "y"), 
                 crs = sf::st_crs(cold)) %>%
    sf::st_distance(sites2) %>% 
    min(./1000) %>%
    as.numeric()
  eh[[i]] <- tibble(
    code6 = code6, 
    avgn = avgn,
    ti_mean = ti_mean, 
    ti_sd = ti_sd, 
    ti_range = ti_range, 
    ncold_mean = ncold_mean, 
    ncold_sd = ncold_sd, 
    ncold_range = ncold_range, 
    nwarm_mean = nwarm_mean, 
    nwarm_sd = nwarm_sd, 
    nwarm_range = nwarm_sd,
    cold_mdist = cold_edge_min_distance, 
    warm_mdist = warm_edge_min_distance)
  print( paste0("Finished ", i, " of ", length(filenames), " (", code6, ")"))
}

all <- dplyr::bind_rows(eh)

setwd(here::here("data"))
readr::write_csv(all, "edge_hardness_metrics.csv")