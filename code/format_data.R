library(here)
library(tidyverse)
library(lubridate)

setwd(here::here("data"))
# raw data cannot be shared - available upon request
d <- readxl::read_excel( "Bird_Site_1995-2023.xlsx" , sheet = 3)

dc <- d |> 
  dplyr::mutate( abbrev = ifelse( abbrev == "YWAR", "YEWA",
                                  ifelse( abbrev == "YSFL", "NOFL", 
                                          ifelse( abbrev == "WPWA", "PAWA", 
                                                  ifelse( abbrev == "SCJU", "DEJU", 
                                                          ifelse( abbrev == "MYWA", "YRWA", 
                                                                  ifelse( abbrev == "GRAJ", "CAJA", 
                                                                          ifelse( abbrev == "CAGO", "CANG",
                                                                                  ifelse( abbrev == "COSN", "WISN", 
                                                                                          abbrev))))))))) |> 
  dplyr::filter( outside == 0 ) |> 
  dplyr::filter(!is.na(X_COORD)) |> 
  dplyr::group_by(site) |> 
  dplyr::mutate(site_id = cur_group_id() ) |> 
  dplyr::ungroup() |> 
  dplyr::group_by(standunique) |> 
  dplyr::mutate( stand_id = cur_group_id() ) |> 
  dplyr::ungroup() |> 
  dplyr::mutate(date = as.Date(date)) |> 
  dplyr::mutate( year = lubridate::year(date) ) |> 
  dplyr::select( site_id, stand_id, sp = abbrev, common, year, date, distance, obs, time, temp, wind, sky, noise, xcoord = X_COORD, ycoord = Y_COORD) |> 
  dplyr::arrange(sp, site_id, year) |> 
  # compiled list of species to omit or keep
  # omitting random water birds, night birds, etc.
  dplyr::full_join( readr::read_csv("species_names_review.csv")) |> 
  dplyr::filter( omit == 0 ) |> 
  dplyr::select(-omit) |> 
  dplyr::mutate( year = as.integer(year(date)), 
                 month = as.integer(month(date)),
                 day = lubridate::day(date), 
                 hour = lubridate::hour(time),
                 minute = lubridate::minute(time)) |> 
  dplyr::mutate( date_time = lubridate::make_datetime(year = year, 
                                                      month = month, 
                                                      day = day, 
                                                      hour = hour,
                                                      min = minute, 
                                                      tz = "America/Chicago"),
                 doy = lubridate::yday(date)) |> 
  dplyr::filter(!is.na(xcoord)) |> 
  dplyr::select(site = site_id,
                stand = stand_id,
                sp, common, 
                year,
                date,
                date_time,
                doy,
                obs,
                distance, 
                temp,
                wind,
                sky,
                noise,
                xcoord,
                ycoord) |> 
  dplyr::filter(!(obs == 53 & site == 303 & year == 2000))

not_surveyed <- dc |> 
  dplyr::select(site, year, doy) |> 
  dplyr::distinct()  |> 
  dplyr::arrange(site, year) |> 
  tidyr::pivot_wider(names_from = year, values_from = doy) |> 
  tidyr::pivot_longer(2:30, names_to = "year", values_to = "doy") |> 
  dplyr::mutate(not_surveyed = ifelse(is.na(doy), 1, 0)) |> 
  dplyr::select(-doy) |> 
  dplyr::mutate(year = as.numeric(year))

ncap_template <- expand.grid(
  site = unique( dc$site ),
  year = unique( dc$year ),
  sp = unique( dc$sp ) ) |>
  tibble::as_tibble() |>
  dplyr::mutate(sp = as.character(sp)) |>
  dplyr::arrange(site, sp, year) |>
  dplyr::full_join(not_surveyed) |>
  dplyr::filter(not_surveyed == 0) |>
  dplyr::select(-not_surveyed) |> 
  dplyr::full_join( dplyr::distinct(dplyr::select(dc, sp, common) ) )

ncap <- dc |>
  dplyr::group_by( site, year, sp) |>
  dplyr::count() |>
  dplyr::right_join(ncap_template) |>
  dplyr::arrange( site, sp, year) |>
  dplyr::mutate(n = ifelse(is.na(n), 0, n)) |>
  dplyr::ungroup() |>
  dplyr::group_by(site) |>
  dplyr::mutate(site_id = cur_group_id()) |>
  dplyr::group_by(year) |>
  dplyr::mutate(year_id = cur_group_id()) |>
  dplyr::group_by( sp ) |>
  dplyr::mutate(sp_id = cur_group_id()) |>
  dplyr::ungroup() |>
  dplyr::arrange(sp_id, site_id, year_id) |>
  dplyr::mutate(yr = as.numeric(scale(year))) |> 
  dplyr::select(sp = sp_id,
                code4 = sp,
                common,
                site = site_id,
                yr,
                y = n )

setwd(here::here("data"))
save(ncap, file = "formatted_data_for_model.RData")
