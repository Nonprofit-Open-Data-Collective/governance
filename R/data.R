#' Factor Model
#'
#' @description
#' Factor model object from \code{\link{features2}} data set using polychoric
#' correlations from \code{\link{rho2}}. This is the output of the `psych::fa` function.
#' This model has 12 features and 6 factors. See \code{vignette("making-gov-scores", package = "governance")}
#' for a detailed description of how and why this model was chosen.
#'
#' Most notable internal objects include
#' \describe{
#'    \item{loadings}{Loadings from the factor analysis using polychoric correlations of `features2`.}
#'    \item{scores}{Scores using the PEARSON correlations. Note, we do not use the
#'    scores generated from the `psych::fa` function as they always use the Pearson
#'    correlation, even if the factor loadings were caclulated using the polychoric correlations.}
#' }
"model6"

#' Features for Training Data
#'
#' @description
#' Training data used to generate factor model \code{\link{model6}}.
#' See Step 5 of \code{vignette("making-gov-scores", package = "governance")} for detailed description of each of these features.
#'
"features2"

#' Training Polychoric Correlations
#'
#' @description
#' Polychoric correlations for \code{\link{features2}}. Generated useing `psych::polychoric(features2)`.
#'
"rho2"

#' Training Factor Scores
#'
#' @description
#' The factor scores from factor model \code{\link{model6}} of the  \code{\link{features2}} training data.
#' These are NOT the scores from `model6`, but are rather the factor scores calculated
#' using the `psych::facotor.scores` function using polychoric correlations
#' \code{\link{rho2}} and `method == "Thurstone"`. See step 6 of
#' \code{vignette("making-gov-scores", package = "governance")} for detailed
#' information on how this was generated.
#'
"scores"

#' Example Data
#'
#' @description
#' Raw 990 data from 2013 to be used as an example for how to make features and run the factor model.
#' See `data-raw/01-get-example-data.R` and \code{vignette("download-data", package = "governance")} for details on how this data was downloaded.
#' Data is from NCCS 990 data download website [here](https://nccs.urban.org/nccs/catalogs/catalog-efile.html).
#'
"dat_example"