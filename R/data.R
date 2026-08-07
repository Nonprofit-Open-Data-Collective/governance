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
#' A 5,000-organization sample of raw 990 efile fields (tax year 2022), used as a
#' worked example for building features and running the factor model. Contains the
#' Part IV, VI, and XII and Schedule M fields that \code{\link{get_features}}
#' consumes, plus organization name / return type / tax year for illustration.
#' Values are unmodified from the source (e.g. yes/no fields as
#' \code{"true"}/\code{"false"}, flags as \code{"X"}, blanks as \code{""}).
#'
#' Pulled directly from the NCCS 990 efile v2.1 archive; see
#' `data-raw/make-dat-example.R` for the exact provenance and the
#' [efile v2.1 catalog](https://nccs.urban.org/nccs/catalogs/catalog-efile-v2_1.html).
#'
"dat_example"

#' 2018 990 Data
#'
#' All data used to generate \code{\link{model6}}.
#' Contains raw 990 data, features, and factor scores.
"dat.2018"