#' Factor Model
#'
#' @description
#' Factor model object from \code{\link{features2}} data set using polychoric
#' correlations from \code{\link{rho2}}. This is the output of the `psych::fa` function.
#' This model has 12 features and 6 factors. See \code{vignette("legacy-2018-model", package = "governance")}
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
#' See Step 5 of \code{vignette("legacy-2018-model", package = "governance")} for detailed description of each of these features.
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
#' \code{vignette("legacy-2018-model", package = "governance")} for detailed
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
#' 2023 Bifactor Measurement Model
#'
#' @description
#' Item parameters of the 2023 bifactor measurement model used by
#' \code{get_scores(model = "2023")} for \code{gov_score_bf} and the \code{gov_s_*}
#' subscores (the governance index itself comes from \code{\link{gov_index_2023}}):
#' a bifactor two-parameter logistic item
#' response model (\code{mirt::bfactor}) fit to the 16 \code{GI_*} practice
#' items for every 501(c)(3) organization that e-filed a full Form 990 for tax
#' year 2023. Fitting code: \code{data-raw/fit-model-2023.R} in the package
#' source.
#'
#' @format A list with elements:
#' \describe{
#'   \item{values}{parameter table from \code{mirt::mod2values()}, used to rebuild
#'     the model with fixed parameters when scoring}
#'   \item{spec}{testlet assignment of each item (1 financial assurance,
#'     2 minutes, 3 written policies, 4 compensation, \code{NA} general only)}
#'   \item{items}{item names, in model order}
#'   \item{factors}{names of the score columns, in factor order}
#'   \item{year, n}{anchor tax year and number of organizations}
#'   \item{logLik, BIC}{fit statistics}
#'   \item{loadings}{standardized loadings on the general and specific factors}
#'   \item{item_means}{share of 2023 filers reporting each practice}
#'   \item{mirt_version, fitted}{mirt version used and date fitted}
#' }
"gov_model_2023"

#' 2023 Governance Index Model
#'
#' @description
#' Parameters of the model behind the governance index returned as
#' \code{gov_score} by \code{get_scores(model = "2023")}: a unidimensional
#' graded response model (\code{mirt::mirt}) fit to every 501(c)(3)
#' organization that e-filed a full Form 990 for tax year 2023. The 16
#' \code{GI_*} practices enter as ten items: nested practices are summed into
#' ordinal items (financial assurance 0--3, conflict-of-interest policy 0--3,
#' minutes 0--2, pay-setting process 0--2) and the other six are binary. The
#' estimates are placed on a scale with mean 100 and SD 15 among 2023 filers.
#' Fitting code: \code{data-raw/fit-index-2023.R} in the package source.
#'
#' @format A list with elements:
#' \describe{
#'   \item{values}{parameter table from \code{mirt::mod2values()}, used to rebuild
#'     the model with fixed parameters when scoring}
#'   \item{items, itemtype}{the ten index items, in model order, and their
#'     item types (\code{"graded"} or \code{"2PL"})}
#'   \item{bundles}{the \code{GI_*} practices summed into each item}
#'   \item{mu, sd}{mean and standard deviation of the 2023 EAP estimates;
#'     the index is \code{100 + 15 * (theta - mu) / sd}}
#'   \item{year, n}{anchor tax year and number of organizations}
#'   \item{fit}{limited-information fit (RMSEA, SRMSR, CFI, TLI) and empirical
#'     reliability}
#'   \item{coef}{item parameters in IRT form (slope \code{a}, thresholds)}
#'   \item{mirt_version, fitted}{mirt version used and date fitted}
#' }
#' @seealso \code{\link{get_scores}}, \code{\link{gov_model_2023}}.
"gov_index_2023"
