# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Translator functions
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************


.translate_plausability <- function(value) {
    if (is.na(value))
        return(value)

    if (value == 10)
        return("unknown mechanism")
    if (value == 20)
        return("plausible mechanism")
    if (value == 30)
        return("Mechanismus belegt")

    return(NA)
}

.translate_relevance <- function(value) {
    if (is.na(value))
        return(value)

    if (value == 0)
        return("no statement possible")
    if (value == 10)
        return("no interaction expected")
    if (value == 20)
        return("product-specific warning")
    if (value == 30)
        return("minor")
    if (value == 40)
        return("moderate")
    if (value == 50)
        return("severe")
    if (value == 60)
        return("contraindicated")

    return(NA)
}


.translate_frequency <- function(value) {
    if (is.na(value))
        return(value)

    if (value == 1)
        return("very common")
    if (value == 2)
        return("common")
    if (value == 3)
        return("occasionally")
    if (value == 4)
        return("rare")
    if (value == 5)
        return("very rare")
    if (value == 6)
        return("not known")

    return(NA)
}


.translate_credebility <- function(value) {
    if (is.na(value))
        return(value)

    if (value == 10)
        return("data situation not known")
    if (value == 20)
        return("data situation insufficient")
    if (value == 30)
        return("data situation weak")
    if (value == 40)
        return("data situation adequate")
    if (value == 50)
        return("data situation good")

    return(NA)
}


.translate_direction <- function(value) {
    if (is.na(value))
        return(value)

    if (value == 0)
        return("undirected interaction")
    if (value == 1)
        return("unidirectional interaction")
    if (value == 2)
        return("bidirectional interaction")

    return(NA)
}


translate_interaction_table <- function(df) {

    df$plausibility <- purrr::map_vec(df$plausibility, ~.translate_plausability(.))
    df$relevance  <- purrr::map_vec(df$relevance, ~.translate_relevance(.))
    df$frequency  <- purrr::map_vec(df$frequency, ~.translate_frequency(.))
    df$credibility  <- purrr::map_vec(df$credibility, ~.translate_credebility(.))
    df$direction <- purrr::map_vec(df$direction, ~.translate_direction(.))

    return(df)
}
