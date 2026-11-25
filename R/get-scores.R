#' Calculate Governance Scores
#'
#' Scores organizations on the nonprofit governance index. By default
#' (\code{model = "2023"}) the function returns the 2023 governance index, an
#' item response score on a scale with mean 100 and standard deviation 15
#' among all 501(c)(3) full Form 990 filers in tax year 2023, together with the
#' scores from the 2023 bifactor measurement model and a simple count of
#' practices. The original 2018 six-factor model remains available as
#' \code{model = "legacy-2018"}.
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
#'   \item{gov_score}{The governance index: mean 100 and SD 15 among 2023
#'     501(c)(3) full-990 filers, so 115 is one standard deviation above the
#'     average 2023 filer. It ranges from about 67 (none of the 16 practices)
#'     to about 128 (all 16), and adding a practice never lowers it.}
#'   \item{gov_score_se}{Standard error of \code{gov_score}, in index points
#'     (about 4 in the middle of the distribution, about 10 at the extremes).}
#'   \item{gov_score_bf}{General factor of the 2023 bifactor model (latent
#'     scale, 2023 mean 0). This was \code{gov_score} in version 0.1.0. It
#'     correlates .99 with the index but can fall when a practice is added, so
#'     it is not recommended as a published score.}
#'   \item{gov_s_finance, gov_s_minutes, gov_s_policy, gov_s_comp}{Specific-factor
#'     scores of the bifactor model for financial assurance, meeting minutes,
#'     written policies, and compensation process. These are \emph{residual}
#'     dimensions, orthogonal to \code{gov_score_bf}: a positive value means the
#'     organization does more in that area than its general level predicts.
#'     They are not standalone subscales, and they are much less reliable than
#'     the index (empirical reliability among 2023 filers: finance .57,
#'     compensation .48, minutes .41, policy .29). Only \code{gov_s_finance}
#'     carries substantial variance of its own. \strong{Do not use
#'     \code{gov_s_policy}}: the written-policy items are the core of the
#'     general factor, and the policy factor has almost no variance of its own
#'     (omega-hierarchical < .01); it only contrasts the conflict-of-interest
#'     items with the whistleblower and retention policies. It is returned for
#'     completeness.}
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
#' \strong{The index (\code{gov_score}).} The index is the expected a
#' posteriori (EAP) estimate from a unidimensional graded response model
#' (\code{\link{gov_index_2023}}). Nested practices are scored as ordinal items:
#' \itemize{
#'   \item financial assurance: compiled or reviewed, audited, audited with an
#'     audit committee (0--3);
#'   \item conflict-of-interest policy: policy, annual disclosure, monitoring (0--3);
#'   \item minutes: board and committee minutes (0--2);
#'   \item pay-setting process: CEO and other officers (0--2);
#' }
#' and accrual accounting, a majority-independent board, Form 990 review by the
#' board, whistleblower and document retention policies, and posting the 990
#' online are binary items. Because the model has one dimension and positive
#' slopes, an organization's index can only rise when it reports another
#' practice. Its value is \code{100 + 15 * (theta - mu) / sd}, where \code{mu}
#' and \code{sd} are the mean and standard deviation of the 2023 estimates.
#' Item parameters and both constants are fixed at their 2023 values, so the
#' index for other tax years is on the 2023 scale; the items show no meaningful
#' differential functioning across tax years 2021--2024. Missing items are
#' handled by the model (scores use the answered items).
#'
#' How much a practice adds depends on which practice it is and where an
#' organization starts: in 2023 the written policies added 7 to 12 points on
#' average and most other practices 1 to 4. See
#' \code{vignette("making-gov-scores", package = "governance")} for the points
#' per practice, interpretation, and limitations, including the ceiling at
#' about 128.
#'
#' \strong{Bifactor scores.} \code{gov_score_bf} and the \code{gov_s_*} columns
#' come from the 2023 bifactor model (\code{\link{gov_model_2023}}), a general
#' factor plus four testlets (financial assurance; minutes; written policies;
#' compensation). It describes how the items covary better than the index model
#' does and supports a single score, but its EAP estimates are not monotone in
#' the items (Hooker, Finkelman and Schwartzman 2009): in 2023 data, adding
#' committee minutes lowered \code{gov_score_bf} for most organizations that
#' lacked them.
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
#' @references Hooker, G., Finkelman, M., and Schwartzman, A. (2009).
#'   Paradoxical results in multidimensional item response theory.
#'   \emph{Psychometrika}, 74(3), 419--442.
#'
#' @seealso \code{\link{get_features}}, \code{\link{gov_index_2023}},
#'   \code{\link{gov_model_2023}}.
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


# Index items: nested practices summed into ordinal items ---------------------
.index_bundles <- list(
  assurance = c("GI_REVIEW_AUDIT", "GI_AUDIT", "GI_AUDIT_CMTE"),
  accrual   = "GI_ACCRUAL",
  indep     = "GI_INDEP_MAJOR",
  minutes   = c("GI_MINUTES_BOARD", "GI_MINUTES_CMTE"),
  f990      = "GI_990_BOARD",
  coi       = c("GI_COI", "GI_COI_DISCLOSE", "GI_COI_MONITOR"),
  whistle   = "GI_WHISTLE",
  retention = "GI_RETENTION",
  pay       = c("GI_COMP_CEO", "GI_COMP_OTH"),
  web990    = "GI_990_WEB"
)

# 16 GI_* columns -> 10 index items (NA only when every practice in the bundle is NA)
.bundle_index_items <- function(feature.matrix) {
  X <- as.data.frame(feature.matrix)
  as.data.frame(lapply(.index_bundles, function(cols) {
    x <- as.matrix(X[, cols, drop = FALSE])
    ifelse(rowSums(!is.na(x)) == 0, NA_real_, rowSums(x, na.rm = TRUE))
  }))
}

# EAP index on the 100/15 scale, with fixed 2023 parameters
.score_index <- function(X16) {
  m <- governance::gov_index_2023
  Y <- .bundle_index_items(X16)[, m$items, drop = FALSE]
  maxcat <- vapply(seq_along(m$items), function(j) ifelse(m$itemtype[j] == "graded",
    sum(grepl("^d[0-9]+$", m$values$name[m$values$item == m$items[j]])), 1), numeric(1))
  # anchor rows give every item all of its categories, which mirt needs to
  # rebuild the model; their scores are discarded
  anchor <- as.data.frame(t(vapply(0:max(maxcat), function(k) pmin(k, maxcat), numeric(length(maxcat)))))
  names(anchor) <- m$items
  fixed <- mirt::mirt(rbind(anchor, Y), 1, itemtype = m$itemtype, pars = m$values,
                      TOL = NaN, verbose = FALSE)
  sc <- mirt::fscores(fixed, method = "EAP", full.scores.SE = TRUE)[-seq_len(nrow(anchor)), , drop = FALSE]
  data.frame(index = 100 + 15 * (sc[, 1] - m$mu) / m$sd, index_se = 15 * sc[, 2] / m$sd)
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
                    gov_score_bf = NA_real_,
                    gov_s_finance = NA_real_, gov_s_minutes = NA_real_,
                    gov_s_policy = NA_real_, gov_s_comp = NA_real_)
  ok <- n_items > 0
  if (any(ok)) {
    ix <- .score_index(X[ok, , drop = FALSE])
    out$gov_score[ok]    <- ix$index
    out$gov_score_se[ok] <- ix$index_se
    # Two anchor rows guarantee both response categories for every item, which
    # mirt needs to rebuild the model; their scores are discarded.
    anchor <- as.data.frame(matrix(c(0, 1), nrow = 2, ncol = length(m$items),
                                   dimnames = list(NULL, m$items)))
    Y <- rbind(anchor, X[ok, , drop = FALSE])
    fixed <- mirt::bfactor(Y, m$spec, pars = m$values, TOL = NaN, verbose = FALSE)
    sc <- mirt::fscores(fixed, method = "EAP", QMC = TRUE, full.scores.SE = TRUE)
    sc <- sc[-(1:2), , drop = FALSE]
    out$gov_score_bf[ok]  <- sc[, 1]
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



