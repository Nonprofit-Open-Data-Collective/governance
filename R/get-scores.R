#' Calculate Governance Scores
#'
#' This function takes a data.frame of features appends 6 factor scores
#' along with a total score.
#'
#' @param feature.matrix A matrix containing responses to questions for organizations.
#' Output from `get_features` function.
#' Rows represent each organization, and must contain columns that represent responses
#' to the following questions:
#' "P12_LINE_1", "P4_LINE_12", "P4_LINE_28", "P4_LINE_29_30", "P6_LINE_1", "P6_LINE_11A",
#' "P6_LINE_15A", "P6_LINE_18", "P6_LINE_2", "P6_LINE_3", "P6_LINE_8A", "P6_LINE_12_13_14".
#' See \code{vignette("making-gov-scores", package = "governance")} for details on these features.
#'
#' @param missing From psych::factor.scores. If missing is TRUE, missing items
#' are imputed using either the median or mean. If missing is FALSE, the default,
#' scores are found based upon the mean of the available items for each subject.
#' If missing is FALSE, input rows with NA values will not be included in the output.
#'
#' @param imput From psych::factor.scores. If missing == TRUE, then missing data
#' can be imputed using "median" or "mean". The number of missing by subject is
#' reported. If impute = "none", missing data are not scored.
#' Median is the default for our usage because all of our feature values are binary.
#'
#' @param scores.by.hand If FALSE, psych::factor.scores is used to calculate features scores.
#' If TRUE, manual calculations are used to calculate the factors scores. This option
#' should only be used if `features.matrix` has no missing values AND is not of full rank
#' (i.e. at least one column is all 0's or 1's).
#' See Appendix of See \code{vignette("making-gov-scores", package = "governance")} for
#' details on this calculation.
#'
#' @return A data frame with the original `features.matrix` input data and
#' appended 6 factor scores along with a total score.
#'
#' @details This function generates factor scores for observations in the input
#' `feature.matrix` from pre-loaded factor model ( in `data/factor-objects.Rdata`)
#'
#' @references
#' Factor objects are loaded from "governance/pkg-funcs/factor-objects.Rdata".
#'
#' @seealso
#' \code{\link{get_features}} for formatting `feature.matrix`.
#'
#'
#' @examples
#' # get data
#' data("dat_example", package = "governance")
#' set.seed(57)
#' keep_rows <- sample(1:nrow(dat_example), 200)
#' dat_example <- dat_example[keep_rows, ]
#'
#' # get features
#' features_example <- get_features(dat_example)
#'
#' # get scores
#' scores_example <- get_scores(features_example)
#'
#' @export


get_scores <- function(feature.matrix, missing = TRUE, impute = "median", scores.by.hand = FALSE){
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


  data("factor-objects", envir=environment())

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
                                   model2.6, #original fitted model of features2
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
    L <- model2.6$loadings

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



