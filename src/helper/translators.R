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

    df$Plausibility <- purrr::map_vec(df$Plausibility, ~.translate_plausability(.))
    df$Relevance  <- purrr::map_vec(df$Relevance, ~.translate_relevance(.))
    df$Frequency  <- purrr::map_vec(df$Frequency, ~.translate_frequency(.))
    df$Credibility  <- purrr::map_vec(df$Credibility, ~.translate_credebility(.))
    df$Direction <- purrr::map_vec(df$Direction, ~.translate_direction(.))

    return(df)
}
