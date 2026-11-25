#' Calculate Governance Scores
#'
#' Scores organizations on the nonprofit governance index. By default
#' (\code{model = "2023"}) the function applies the 2023 anchor model: a
#' bifactor item response model fit to all 501(c)(3) full Form 990 filers in
#' tax year 2023. It appends a general governance score, four specific-factor
#' scores, and a simple count of practices. The original 2018 six-factor model
#' remains available as \code{model = "legacy-2018"}.
#'
#' @param feature.matrix A data.frame of features, the output of
#'   \code{\link{get_features}}. For \code{model = "2023"} it must contain the
#'   16 \code{GI_*} item columns; for \code{model = "legacy-2018"} the 12 legacy
#'   features (\code{"P12_LINE_1"}, \code{"P4_LINE_12"}, ...).
#' @param model Which scoring model to apply: \code{"2023"} (default) or
#'   \code{"legacy-2018"}.
#' @param missing,impute,scores.by.hand Used only by \code{model = "legacy-2018"};
#'   passed to \code{psych::factor.scores} as in earlier versions. With
#'   \code{missing = FALSE}, rows with \code{NA} features are dropped.
#'
#' @return The input data frame with appended columns.
#'
#' For \code{model = "2023"}:
#' \describe{
#'   \item{gov_score}{General governance score (EAP estimate of the general
#'     factor). On the latent scale, 2023 501(c)(3) filers have mean 0 and
#'     SD 1. Higher means more of the recommended practices.}
#'   \item{gov_score_se}{Standard error of \code{gov_score}.}
#'   \item{gov_s_finance, gov_s_minutes, gov_s_policy, gov_s_comp}{Specific-factor
#'     scores for financial assurance, meeting minutes, written policies, and
#'     compensation process. These are \emph{residual} dimensions, orthogonal
#'     to \code{gov_score}: a positive value means the organization does
#'     more in that area than its general score predicts. They are not
#'     standalone subscales.}
#'   \item{gov_count}{Number of the 16 practices present (0--16), a transparent
#'     alternative that correlates about .96 with \code{gov_score}.}
#'   \item{gov_n_items}{Number of the 16 items answered. Rows with no answered
#'     items get \code{NA} scores.}
#' }
#'
#' For \code{model = "legacy-2018"}: six factor scores and \code{total.score},
#' as in earlier versions of the package.
#'
#' @details
#' \strong{2023 model.} The model has a general factor and four specific
#' factors (testlets) that absorb the strong dependence among nested items:
#' \itemize{
#'   \item financial assurance: review/audit, audit, audit committee, accrual;
#'   \item minutes: board and committee minutes;
#'   \item written policies: conflict-of-interest policy, disclosure,
#'     monitoring, whistleblower, retention;
#'   \item compensation: CEO and other-officer pay process.
#' }
#' Board independence, Form 990 review by the board, and posting the 990 online
#' load on the general factor only. Item parameters are fixed at their 2023
#' values (\code{\link{gov_model_2023}}), so scores for other tax years are on
#' the 2023 scale and can be compared over time; the items show no meaningful
#' differential functioning across tax years 2021--2024. Missing items are
#' handled by the IRT model (scores use the answered items). Scores are
#' expected a posteriori (EAP) estimates computed with \code{mirt::fscores}.
#'
#' Three financial-assurance items (audit, review or audit, accrual) show
#' moderate differential item functioning by organization size: at the same
#' general level, larger organizations are more likely to be audited, in part
#' because of legal and funder audit thresholds. Keep this in mind when
#' comparing organizations of very different size.
#'
#' \strong{Legacy model.} The 2018 model has known problems, including negative
#' implied weights on several good-practice features and a training sample that
#' excluded fully independent boards. It is kept for reproducing earlier work.
#' See "Known issues" in \code{vignette("legacy-2018-model", package = "governance")}.
#'
#' @seealso \code{\link{get_features}}, \code{\link{gov_model_2023}}.
#'
#' @examples
#' data("dat_example", package = "governance")
#' set.seed(57)
#' dat_example <- dat_example[sample(seq_len(nrow(dat_example)), 200), ]
#' features_example <- get_features(dat_example)
#'
#' # 2023 index (default)
#' scores_example <- get_scores(features_example)
#' summary(scores_example$gov_score)
#'
#' # legacy 2018 model
#' legacy <- get_scores(features_example, model = "legacy-2018")
#'
#' @export
get_scores <- function(feature.matrix, model = c("2023", "legacy-2018"),
                       missing = TRUE, impute = "median", scores.by.hand = FALSE) {
  model <- match.arg(model)
  if (model == "legacy-2018") {
    return(.get_scores_legacy(feature.matrix, missing = missing, impute = impute,
                              scores.by.hand = scores.by.hand))
  }
  .get_scores_2023(feature.matrix)
}


.get_scores_2023 <- function(feature.matrix) {
  if (!requireNamespace("mirt", quietly = TRUE)) {
    stop("The 'mirt' package is required for model = \"2023\". ",
         "Install it with install.packages(\"mirt\").", call. = FALSE)
  }
  m <- governance::gov_model_2023
  feature.matrix <- as.data.frame(feature.matrix)
  miss <- setdiff(m$items, names(feature.matrix))
  if (length(miss)) {
    stop("feature.matrix is missing the 2023 index items: ", paste(miss, collapse = ", "),
         ". Build features with get_features().", call. = FALSE)
  }
  X <- as.data.frame(lapply(feature.matrix[, m$items], function(v) as.numeric(as.character(v))))
  bad <- vapply(X, function(v) any(!is.na(v) & !(v %in% c(0, 1))), logical(1))
  if (any(bad)) {
    stop("2023 index items must be 0, 1, or NA: ", paste(m$items[bad], collapse = ", "),
         call. = FALSE)
  }

  n_items <- rowSums(!is.na(X))
  count <- rowSums(X, na.rm = TRUE)
  out <- data.frame(gov_score = rep(NA_real_, nrow(X)), gov_score_se = NA_real_,
                    gov_s_finance = NA_real_, gov_s_minutes = NA_real_,
                    gov_s_policy = NA_real_, gov_s_comp = NA_real_)
  ok <- n_items > 0
  if (any(ok)) {
    # Two anchor rows guarantee both response categories for every item, which
    # mirt needs to rebuild the model; their scores are discarded.
    anchor <- as.data.frame(matrix(c(0, 1), nrow = 2, ncol = length(m$items),
                                   dimnames = list(NULL, m$items)))
    Y <- rbind(anchor, X[ok, , drop = FALSE])
    fixed <- mirt::bfactor(Y, m$spec, pars = m$values, TOL = NaN, verbose = FALSE)
    sc <- mirt::fscores(fixed, method = "EAP", QMC = TRUE, full.scores.SE = TRUE)
    sc <- sc[-(1:2), , drop = FALSE]
    out$gov_score[ok]     <- sc[, 1]
    out$gov_score_se[ok]  <- sc[, ncol(sc) / 2 + 1]
    out$gov_s_finance[ok] <- sc[, 2]
    out$gov_s_minutes[ok] <- sc[, 3]
    out$gov_s_policy[ok]  <- sc[, 4]
    out$gov_s_comp[ok]    <- sc[, 5]
  }
  out$gov_count   <- ifelse(ok, count, NA_real_)
  out$gov_n_items <- n_items
  cbind(feature.matrix, out)
}


# Legacy 2018 six-factor model ----------------------------------------------
.get_scores_legacy <- function(feature.matrix, missing = TRUE, impute = "median", scores.by.hand = FALSE){
  ### Function to read in new data, and return appended scores.

  ### Inputs
  # feature.matrix - a n*12 matrix responses to the questions for the orgs you wish to get a score for
    # output of get_data function
    # rows are each org
    # cols are the responses to (in this order)
    # "P12_LINE_1", "P4_LINE_12", "P4_LINE_28", "P4_LINE_29_30", "P6_LINE_1", "P6_LINE_11A",
    # "P6_LINE_15A", "P6_LINE_18", "P6_LINE_2", "P6_LINE_3", "P6_LINE_8A", "P6_LINE_12_13_14"

  ### Outputs
  # feature.matrix with appended 6 factor scores and total score


  utils::data("factor-objects", package = "governance", envir = environment())

  ### Make sure data is formatted correctly -------------------------------------
  col.names.correct <- colnames(features2[, 1:12])

  #does data have the correct colnames
  feature.matrix <- as.data.frame(feature.matrix)

  if(all(col.names.correct %in% colnames(feature.matrix))){
    temp.dat <- feature.matrix[, col.names.correct]
  }else{
    which.missing <- !(col.names.correct %in% colnames(feature.matrix))
    which.missing <- col.names.correct[which.missing]
    stop(paste("data object does not include necessary factors as columns.",which.missing,"is missing." ))
  }

  # check matrix is entirely of 0 and 1's
  temp.dat <- as.data.frame(sapply(feature.matrix[, col.names.correct], as.integer))
  all.0.or.1 <- all(temp.dat == 0 | temp.dat == 1, na.rm = T)
  if(!all.0.or.1){
    stop("data object must only have 0 or 1 entries for all factors")
  }

  # Guard against a broken upstream normalization: a feature that is entirely NA
  # cannot be scored or imputed and usually signals a field that failed to parse
  # (e.g. a format change in the raw 990 data). Fail loudly rather than return
  # silently garbage scores.
  all.na.cols <- col.names.correct[colSums(!is.na(temp.dat)) == 0]
  if(length(all.na.cols) > 0){
    stop(paste0("These feature columns are entirely NA and cannot be scored: ",
                paste(all.na.cols, collapse = ", "),
                ". Check the normalization step (get_features)."))
  }

  # removing NA rows
  has.na <- apply(temp.dat, 1, function(row) any(is.na(row)))
  if(any(has.na) & missing == FALSE){
    temp.dat <- temp.dat[!has.na, ]
    output.sting <- paste((1:nrow(temp.dat))[has.na], collapse = ",")
    message(paste("Rows", output.sting, "have NA values in the features. They will not be included in the output."))

  }


  ### Get New Factor Scores -------------------------
  if(scores.by.hand == FALSE){
    #if data is full rank, we can directly use the factor.scores function
    scores <- psych::factor.scores(temp.dat, #new data
                                   model6, #original fitted model of features2
                                   rho = rho2, #polychoric correlation of features2
                                   method = "Thurstone", #using regression equation to "predict" new scores.
                                   missing = missing,
                                   impute = impute)

    scores.keep <- as.data.frame(scores$scores)

  }else{ #if data is not full rank, we can do the calculation by hand

    #cannot have NA values
    if(any(has.na)){
      stop("Cannot calculate scores by hand if input data contains any NA values.")
    }

    #set up matrix multiplication
    D <- as.matrix(temp.dat)
    C <- rho2
    L <- model6$loadings

    W <- solve(C) %*% L
    S <- D %*% W

    scores.keep <- as.data.frame(S)
  }


  ### Append scores to data object
  scores.keep$total.score <- rowSums(scores.keep)

  if(missing == FALSE){
    feature.matrix <- cbind(feature.matrix[!has.na, ], scores.keep)
  }else{
    feature.matrix <- cbind(feature.matrix, scores.keep)
  }


  ### Return
  return(feature.matrix)


}



