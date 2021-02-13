# Get values from the image to the samples.

# CBERS bands
# https://directory.eoportal.org/web/eoportal/satellite-missions/c-missions/cbers-3-4
# blue  B13: 450 – 520 nm
# green B14: 520 – 590 nm
# red   B15: 630 – 690 nm
# nir   B16: 770 – 890 nm

library(dplyr)
library(purrr)
library(sf)
library(raster)


sample_sf <- "/home/alber.ipia/Documents/sits_cloud_mask/data/samples/sample_points.shp" %>%
    sf::read_sf() %>%
    dplyr::mutate(sample_id = 1:nrow(.))

image_tb <- "/home/alber.ipia/Documents/sits_cloud_mask/data/raster/CBERS4A/2020_10/CBERS_4A_WFI_RAW_2020_10_20.13_34_30_ETC2/205_116_0/4_BC_UTM_WGS84" %>%
    list.files(full.names = TRUE) %>%
    tibble::as_tibble() %>%
    dplyr::rename(file_path = value) %>%
    dplyr::mutate(file_name = tools::file_path_sans_ext(basename(file_path))) %>%
    tidyr::separate(file_name,
                    into = c("satellite", "mission", "camara", "acquisition",
                             "x1", "x2", "x3", "band", "x5", "x6")) %>%
    dplyr::mutate(img_raster = purrr::map(file_path, raster::raster))

# Get sample values from the raster.
sample_tb <- image_tb %>%
    dplyr::mutate(sample_values = purrr::map(img_raster, raster::extract,
                                             y  = as(sample_sf, "Spatial"),
                                             sp = TRUE)) %>%
    dplyr::mutate(n_samples = purrr::map_int(sample_values, length)) %>%
    ensurer::ensure(length(unique(.$n_samples)) == 1,
                    err_desc = "Missmatch in the number of samples!") %>%
    dplyr::select(band, sample_values) %>%
    dplyr::mutate(samples = purrr::map(sample_values, function(x){
       x %>%
            sf::st_as_sf(x) %>%
            sf::st_set_geometry(NULL) %>%
            tibble::as_tibble() %>%
            dplyr::select(-id) %>%
            return()
    })) %>%
    dplyr::select(-sample_values) %>%
    dplyr::mutate(samples = purrr::map(samples, function(x){
        names(x) <- c("label", "sample_id", "value")
        return(x)
    })) %>%
    tidyr::unnest(samples) %>%
    tidyr::pivot_wider(id_cols = tidyselect::contains(c("sample_id", "label")),
                       names_from = band,
                       values_from = value)

threshold1 <- 1
threshold2 <- 0.125
threshold3 <- 0.66
threshold4 <- 0.8

sample_tb <- sample_tb %>%
    dplyr::mutate(ci1 = 3 * BAND16 /(BAND13 + BAND14 + BAND15),
                  ci2 = (BAND13 + BAND14 + BAND15 + BAND16)/4,
                  cloud = (abs(ci1 - 1) < threshold1) || (ci2 > threshold2),
                  csi = BAND16,
                  shadow = (csi < threshold3) && (BAND13 < threshold4))

