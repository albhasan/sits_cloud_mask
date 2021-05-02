library(caret)
library(dplyr)
library(ggplot2)
library(raster)
library(sf)
library(tidyr)
library(tidymodels)
library(ggrepel)

samples_file <- "./data/samples/sample_points.shp"

mask_codes <- c(`0` = "land" ,
                `1` = "cloud",
                `2` = "shadow")

samples_sf <- samples_file %>%
    sf::read_sf()

# Extract the masks' values at the samples' locations.
data_tb <- "./results" %>%
    list.files(pattern = ".tif",
               all.files = TRUE,
               full.names = TRUE,
               recursive = TRUE) %>%
    tibble::as_tibble() %>%
    dplyr::rename(file_path = value) %>%
    dplyr::mutate(raster_r = purrr::map(file_path, raster::raster)) %>%
    dplyr::mutate(samples = purrr::map(raster_r,
                                       raster::extract,
                                       as(samples_sf, "Spatial"),
                                       df = TRUE)) %>%
    mutate(samples = purrr::map(samples, tibble::as_tibble)) %>%
    dplyr::mutate(samples_rcd = purrr::map(samples, function(x){
        recoded <- x %>%
            dplyr::select(-ID) %>%
            dplyr::pull() %>%
            dplyr::recode(!!!mask_codes)
        x[,2] <- recoded
        return(x)
    }))

# Format the samples' mask values.
results_tb <- data_tb %>%
    dplyr::pull(samples_rcd) %>%
    dplyr::bind_cols() %>%
    dplyr::select(-tidyselect::starts_with("ID")) %>%
    magrittr::set_colnames(paste0("test", 1:length(.)))

# Join the samples' mask values to the samples.
samples_sf <- samples_sf %>%
    dplyr::bind_cols(results_tb)

samples_sf <- samples_sf %>%
    dplyr::filter(label != "ocean") %>%
    dplyr::mutate(label_rcd = dplyr::recode(label,
                                            "city"         = "land",
                                            "cloud"        = "cloud",
                                            "land"         = "land",
                                            #"ocean"       = "land",
                                            "river"        = "land",
                                            "sand"         = "land",
                                            "shadow-land"  = "shadow",
                                            "shadow-ocean" = "shadow",
                                            "shadow-sand"  = "shadow",
                                            "smoke" = "cloud"))
data_ls <- samples_sf %>%
    sf::st_set_geometry(NULL) %>%
    dplyr::select(test1:test63) %>%
    as.list()
ref <- samples_sf %>%
    dplyr::pull(label_rcd)

conmat <- lapply(data_ls, function(x, ref){
    lev <- c(x, ref) %>%
        unlist() %>%
        unique() %>%
        sort()
    caret::confusionMatrix(data = factor(x, levels = lev),
                           ref = factor(ref, levels = lev)) %>%
        generics::tidy() %>%
        dplyr::filter(term %in% c("sensitivity", "pos_pred_value")) %>%
        dplyr::select(term, class, estimate) %>%
        # dplyr::mutate(prod_acc = sensitivity,
        #               user_acc = pos_pred_value) %>%
        return()
}, ref = ref)

res <- dplyr::bind_rows(conmat, .id = "test")

plot_tb <- res %>%
    dplyr::mutate(new_term = dplyr::recode(term,
                                           "sensitivity" = "prod_acc",
                                           "pos_pred_value" = "user_acc")) %>%
    dplyr::select(new_term, test, class, estimate) %>%
    pivot_wider(names_from = new_term,
                values_from = estimate)

plot_tb %>%
    drop_na() %>%
    ggplot(aes(x = prod_acc, y = user_acc, color = class, label = test)) +
    geom_point(position = "jitter") +
    coord_fixed() +
    geom_text_repel() +
    facet_wrap(~ class) +
    theme(text = element_text(size = 20))

