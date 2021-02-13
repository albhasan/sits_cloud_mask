# Call the cloud masking algorithm implements in the sits package.
#-------------------------------------------------------------------------------
# TODO:
# - Learn how to use STACK - Ask Rolf!
# - Run the CBERS cloud mask using the new sits!
#-------------------------------------------------------------------------------

library(dplyr)
library(sits)

data_dir <- "/home/alber.ipia/Documents/sits_cloud_mask/data/raster/CBERS4A/2020_10/CBERS_4A_WFI_RAW_2020_10_20.13_34_30_ETC2/205_116_0/4_BC_UTM_WGS84"

band_tb <- data_dir %>%
    list.files(full.names = TRUE) %>%
    tibble::as_tibble() %>%
    dplyr::rename(file_path = value) %>%
    dplyr::mutate(file_name = tools::file_path_sans_ext(basename(file_path))) %>%
    tidyr::separate(file_name,
                    into = c("satellite", "mission", "camara", "acquisition",
                             "x1", "x2", "x3", "band", "x5", "x6")) %>%
    dplyr::filter(band %in% c("BAND13", "BAND14", "BAND15", "BAND16")) %>%
    dplyr::mutate(acquisition = lubridate::as_date(acquisition)) %>%
    dplyr::mutate(band = stringr::str_c(stringr::str_sub(band, 1, 1),
                                        stringr::str_sub(band, -2, -1)))

band_vec <- band_tb %>%
    dplyr::pull(file_path)
names(band_vec) <- band_tb %>%
    dplyr::pull(band)

# create a raster cube file based on the information about the files
cbers_cube <- sits::sits_cube(
    type = "BRICK",
    name = "cbers",
    satellite = "CBERS-4",
    sensor = "AWFI",
    timeline = unique(band_tb$acquisition),
    bands = names(band_vec),
    files = band_vec
)

cbers_mask <- sits::sits_cloud_cbers(cube = cbers_cube,
                                     cld_band_name = "CMASK",
                                     t1 = 1,
                                     t2 = 0.125,
                                     t3 = 0.66,
                                     t4 = 0.8,
                                     t5 = 40,
                                     t6 = 5,
                                     memsize = 8,
                                     multicores = 1)



