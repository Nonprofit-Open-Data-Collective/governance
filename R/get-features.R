# Internal: normalize an EIN to a 9-digit zero-padded character string.
# Accepts integer/numeric EINs (which may have dropped leading zeros) and
# formatted strings such as "EIN-43-2031361"; returns NA for blanks/non-EINs.
.pad_ein <- function(x) {
  digits <- gsub("\\D", "", as.character(x))
  digits[digits == ""] <- NA_character_
  ifelse(is.na(digits), NA_character_, sprintf("%09d", as.integer(digits)))
}


#' Function to calculate features matrix
#'
#' This function takes input from raw 990 Part IV, VI, and XII, then output a original data frame appended with columns as features needed to calculate governance score.
#'
#' @param dat A data.frame containing columns ORG_EIN and correct inputs from 990 Part IV, VI, and XII. See details below.
#'   ORG_EIN must be a character string of 9 digits. (This data.frame can contain other columns).
#'   See details below for which variable from the 990 efile data must be included to run this function.
#'
#' @details
#' 990 Efiler data can be downloaded from the NCCS website \href{https://nccs.urban.org/nccs/catalogs/catalog-efile.html}{here}.
#' Documentation for the 990 Efiler data can be found \href{https://nccs.urban.org/nccs/datasets/efile/}{here}
#' with the data dictionary found \href{https://nonprofit-open-data-collective.github.io/irs990efile/data-dictionary/data-dictionary.html}{here}.
#'
#' These are the variables from each Part/Schedule that are needed as inputs to run this function:
#'
#' Variables from Part IV:
#'
#' \itemize{
#'  \item{F9_04_AFS_IND_X}
#'  \item{F9_04_BIZ_TRANSAC_DTK_X}
#'  \item{F9_04_BIZ_TRANSAC_DTK_FAM_X}
#'  \item{F9_04_BIZ_TRANSAC_DTK_ENTITY_X}
#'  \item{F9_04_CONTR_NONCSH_MT_25K_X}
#'  \item{F9_04_CONTR_ART_HIST_X}
#' }
#'
#'
#' Variables from Part VI:
#'
#' \itemize{
#'  \item{F9_06_GVRN_NUM_VOTING_MEMB}
#'  \item{F9_06_GVRN_NUM_VOTING_MEMB_IND}
#'  \item{F9_06_GVRN_DTK_FAMBIZ_RELATION_X}
#'  \item{F9_06_GVRN_DELEGATE_MGMT_DUTY_X}
#'  \item{F9_06_GVRN_DOC_GVRN_BODY_X}
#'  \item{F9_06_POLICY_FORM990_GVRN_BODY_X}
#'  \item{F9_06_POLICY_COI_X}
#'  \item{F9_06_POLICY_COI_DISCLOSURE_X}
#'  \item{F9_06_POLICY_COI_MONITOR_X}
#'  \item{F9_06_POLICY_WHSTLBLWR_X}
#'  \item{F9_06_POLICY_DOC_RETENTION_X}
#'  \item{F9_06_POLICY_COMP_PROCESS_CEO_X}
#'  \item{F9_06_DISCLOSURE_AVBL_OTH_X}
#'  \item{F9_06_DISCLOSURE_AVBL_OTH_WEB_X}
#'  \item{F9_06_DISCLOSURE_AVBL_REQUEST_X}
#'  \item{F9_06_DISCLOSURE_AVBL_OWN_WEB_X}
#' }
#'
#' Variables from Part XII:
#'
#' \itemize{
#'  \item{F9_12_FINSTAT_METHOD_ACC_OTH}
#'  \item{F9_12_FINSTAT_METHOD_ACC_ACCRU_X}
#'  \item{F9_12_FINSTAT_METHOD_ACC_CASH_X}
#' }
#'
#' Variables from Schedule M:
#'
#' \itemize{
#'  \item{SM_01_REVIEW_PROCESS_UNUSUAL_X}
#' }
#'
#' Input values may be encoded as \code{"true"}/\code{"false"}, \code{"1"}/\code{"0"},
#' \code{"X"} flags, or blanks; blanks may arrive as \code{NA} or \code{""}
#' depending on how the tables were read. Blank or missing yes/no responses are
#' treated as \code{0} (the governance property is absent), and the result does
#' not depend on the blank encoding. Two derived features can still be \code{NA}
#' when their inputs are genuinely unavailable: \code{P6_LINE_1} (share of
#' independent voting members, undefined when the voting-member count is 0 or
#' missing) and \code{P12_LINE_1} (accounting method, when none is reported);
#' \code{\link{get_scores}} imputes these.
#'
#' @return
#' A data.frame appended with features needed to run the \code{\link{get_scores}} function.
#'
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
#' @export


get_features <- function(dat){

  ### Input
  # dat = data.frame with columns ORG_EIN and correct inputs from 990 Part IV, VI, and XII
    # ORG_EIN must be a character string of 9 digits

  # Variables from Part IV : "F9_04_AFS_IND_X", "F9_04_AFS_CONSOL_X",
  # "F9_04_BIZ_TRANSAC_DTK_X", "F9_04_BIZ_TRANSAC_DTK_FAM_X", "F9_04_BIZ_TRANSAC_DTK_ENTITY_X",
  # "F9_04_CONTR_NONCSH_MT_25K_X",
  # "F9_04_CONTR_ART_HIST_X"

  # Variables from Part VI
  # "F9_06_GVRN_NUM_VOTING_MEMB", "F9_06_GVRN_NUM_VOTING_MEMB_IND", "F9_06_GVRN_DTK_FAMBIZ_RELATION_X",
  # "F9_06_GVRN_DELEGATE_MGMT_DUTY_X", "F9_06_GVRN_DOC_GVRN_BODY_X", "F9_06_POLICY_FORM990_GVRN_BODY_X",
  # "F9_06_POLICY_COI_X", "F9_06_POLICY_COI_DISCLOSURE_X", "F9_06_POLICY_COI_MONITOR_X",
  # "F9_06_POLICY_WHSTLBLWR_X", "F9_06_POLICY_DOC_RETENTION_X", "F9_06_POLICY_COMP_PROCESS_CEO_X",
  # "F9_06_DISCLOSURE_AVBL_OTH_X", "F9_06_DISCLOSURE_AVBL_OTH_WEB_X",  "F9_06_DISCLOSURE_AVBL_REQUEST_X",
  # "F9_06_DISCLOSURE_AVBL_OWN_WEB_X"

  # Variables from Part XII
  # "F9_12_FINSTAT_METHOD_ACC_OTH", "F9_12_FINSTAT_METHOD_ACC_ACCRU_X", "F9_12_FINSTAT_METHOD_ACC_CASH_X"

  # Variables from Schedule M
  # SM_01_REVIEW_PROCESS_UNUSUAL_X

  ### Outputs
  # dat appended with features needed to run get_scores function

  ### Column names to keep and rename --------------------------------------

  keep_cols_part12 <- c("ORG_EIN", "F9_12_FINSTAT_METHOD_ACC_OTH", "F9_12_FINSTAT_METHOD_ACC_ACCRU_X", "F9_12_FINSTAT_METHOD_ACC_CASH_X")

  cols_partM <- data.frame(new = c("ORG_EIN","PM_LINE_31"),
                           old = c("ORG_EIN","SM_01_REVIEW_PROCESS_UNUSUAL_X"))


  cols_part4 <- data.frame(
    new = c("ORG_EIN", "P4_LINE_12A", "P4_LINE_28A", "P4_LINE_28B", "P4_LINE_28C", "P4_LINE_29", "P4_LINE_30"),
    old = c("ORG_EIN", "F9_04_AFS_IND_X", "F9_04_BIZ_TRANSAC_DTK_X", "F9_04_BIZ_TRANSAC_DTK_FAM_X", "F9_04_BIZ_TRANSAC_DTK_ENTITY_X", "F9_04_CONTR_NONCSH_MT_25K_X", "F9_04_CONTR_ART_HIST_X")
  )


  cols_part6 <- data.frame(
    new = c("ORG_EIN",  "P6_LINE_1A", "P6_LINE_1B", "P6_LINE_2", "P6_LINE_3", "P6_LINE_8A", "P6_LINE_11A", "P6_LINE_12A", "P6_LINE_12B", "P6_LINE_12C", "P6_LINE_13", "P6_LINE_14", "P6_LINE_15A",  "P6_LINE_18_other", "P6_LINE_18_other_web", "P6_LINE_18_req", "P6_LINE_18_own_web"),
    old = c("ORG_EIN",  "F9_06_GVRN_NUM_VOTING_MEMB", "F9_06_GVRN_NUM_VOTING_MEMB_IND", "F9_06_GVRN_DTK_FAMBIZ_RELATION_X", "F9_06_GVRN_DELEGATE_MGMT_DUTY_X", "F9_06_GVRN_DOC_GVRN_BODY_X", "F9_06_POLICY_FORM990_GVRN_BODY_X", "F9_06_POLICY_COI_X", "F9_06_POLICY_COI_DISCLOSURE_X", "F9_06_POLICY_COI_MONITOR_X", "F9_06_POLICY_WHSTLBLWR_X", "F9_06_POLICY_DOC_RETENTION_X", "F9_06_POLICY_COMP_PROCESS_CEO_X", "F9_06_DISCLOSURE_AVBL_OTH_X", "F9_06_DISCLOSURE_AVBL_OTH_WEB_X",  "F9_06_DISCLOSURE_AVBL_REQUEST_X", "F9_06_DISCLOSURE_AVBL_OWN_WEB_X")
  )


  ### Checking input data has the correct columns ----------------------------
  dat <- as.data.frame(dat)

  # Save Original
  dat_orig <- dat

  #checking part M
  has_col_M <- cols_partM$old %in% colnames(dat)
  if(!all(has_col_M)){
    which_missing_M <- cols_partM$old[!has_col_M ]
    stop(paste("input data frame is missing column", which_missing_M,
               ". See documentation for details."))
  }

  #Checking part 4
  has_col_4 <- cols_part4$old %in% colnames(dat)
  if(!all(has_col_4)){
    which_missing_4 <- cols_part4$old[!has_col_4 ]
    stop(paste("input data frame is missing column", which_missing_4,
               ". See documentation for details."))
  }

  #Checking part 6
  has_col_6 <- cols_part6$old %in% colnames(dat)
  if(!all(has_col_6)){
    which_missing_6 <- cols_part6$old[!has_col_6 ]
    stop(paste("input data frame is missing column", which_missing_6,
               ". See documentation for details."))
  }

  #Checking part 12
  has_col_12 <- keep_cols_part12 %in% colnames(dat)
  if(!all(has_col_12)){
    which_missing_12 <- keep_cols_part12[!has_col_12 ]
    stop(paste("input data frame is missing column", which_missing_12,
               ". See documentation for details."))
  }


  ### Schedule M wrangling ----------------------------------------------
  dat_M <- dat[ , cols_partM$old ]
  colnames(dat_M) <- cols_partM$new

  dat_M <-
    dat_M %>%
    dplyr::mutate(PM_LINE_31 = dplyr::case_when(
      PM_LINE_31 %in% c("true", "1") ~ "yes",
      PM_LINE_31 %in% c("false", "0") ~ "no",
      TRUE ~ NA
    ))


  ### Part IV Wrangling ----------------------------------------------------
  dat_4 <- dat[, cols_part4$old ]
  colnames(dat_4) <- cols_part4$new

  #join with datM$PM_LINE_31
  dat_4$PM_LINE_31 <- dat_M$PM_LINE_31

  #wrangling
  dat_4 <-
    dat_4  %>%
    #make everything yes/no
    # Map to yes/no. Blank/missing (NA or "" depending on how the data were
    # read) falls to "no" so the result does not depend on the read method.
    dplyr::mutate(dplyr::across(dplyr::starts_with("P4"),
                  ~ dplyr::case_when(
                    . %in% c("true", "1") ~ "yes",
                    . %in% c("false", "0") ~ "no",
                    TRUE ~ "no"
                  )))  %>%
    #P4 Line 12A
    dplyr::mutate(P4_LINE_12A = ifelse(P4_LINE_12A == "yes" , 1, 0)) %>%
    dplyr::rename(P4_LINE_12 = P4_LINE_12A) %>%
    #P4 line 28
    dplyr::mutate(P4_LINE_28 = ifelse(
      P4_LINE_28A == "yes" |
        P4_LINE_28B == "yes" |
        P4_LINE_28C == "yes" , 0, 1)) %>%
    dplyr::select(-c(P4_LINE_28A, P4_LINE_28B, P4_LINE_28C)) %>%
    #P4 line 29 and 30, Schedule M
    dplyr::mutate(P4_LINE_29_30 = dplyr::case_when(
      P4_LINE_29 == "yes" & PM_LINE_31 == "no" ~ 0,
      P4_LINE_30 == "yes" & PM_LINE_31 == "no" ~ 0,
      TRUE ~ 1)) %>%
    dplyr::select(-c(P4_LINE_29, P4_LINE_30, PM_LINE_31)) %>%
    #order columns
    dplyr::select(sort(colnames(.))) %>%
    dplyr::relocate(ORG_EIN)


  ### Part VI Wrangling ----------------------------------------------------

  dat_6 <- dat[, cols_part6$old ]
  colnames(dat_6) <- cols_part6$new


  #P6_LINE_1
  dat_6 <-
    dat_6 %>%
    # member counts arrive as character when read via data.table::fread; coerce
    # so the ratio below is numeric rather than erroring on strings
    dplyr::mutate(P6_LINE_1A = as.numeric(P6_LINE_1A),
                  P6_LINE_1B = as.numeric(P6_LINE_1B)) %>%
    # remove divide by 0 errors
    # only mutate cases where we have more members than independent members
    dplyr::mutate(divide.by.0 = P6_LINE_1A == 0 | P6_LINE_1A < P6_LINE_1B)  %>%
    #make P6_LINE_1 is percent of independent members > 0.5
    dplyr::mutate(P6_LINE_1 = dplyr::case_when(
      divide.by.0 ~ NA,
      P6_LINE_1B / P6_LINE_1A >= 0.5 ~ 1,
      P6_LINE_1B / P6_LINE_1A < 0.5 ~ 0,
      TRUE ~ NA
    )) %>%
    dplyr::select(-c(P6_LINE_1B , P6_LINE_1A, divide.by.0 )) %>%
    #need to be transformed from (1/0) and (true/false) to yes/no
    # P6_LINE_2, P6_LINE_3, P6_LINE_8A, P6_LINE_11A, P6_LINE_12A, P6_LINE_12B, P6_LINE_12C, P6_LINE_13, P6_LINE_14, P6_LINE_15A
    # Blank/missing (NA or "") maps to "no" so results do not depend on whether
    # the data were read with NA or "" for empty cells.
    dplyr::mutate_at(dplyr::vars( paste0("P6_LINE_", c("2", "3", "8A","11A", "12A", "12B", "12C", "13", "14", "15A"))),
                     ~  ifelse(!is.na(.) & (. == "true" | . == "1"), "yes", "no")) %>%
    #P6_LINE_2, 3, have no as good and yes as bad
    dplyr::mutate_at(dplyr::vars("P6_LINE_2", "P6_LINE_3" ) ,
              ~ ifelse(. == "no", 1, 0))%>%
    # P6_LINE_8A, 11A, 12A, 13, 14, yes is good, no is bad
    dplyr::mutate_at(dplyr::vars( paste0("P6_LINE_", c("8A","11A", "12A", "13", "14", "15A"))),
              ~  ifelse(. == "yes", 1, 0)) %>%
    dplyr::rowwise() %>%
    #P6_LINE_12B #P6_LINE_12A == "yes" & P6_LINE_12B == "no" is the bad case, every other case is good
    dplyr::mutate(P6_LINE_12B = ifelse(P6_LINE_12A == "yes" & P6_LINE_12B == "no", 0, 1)) %>%
    # dplyr::mutate(P6_LINE_12B = dplyr::case_when(
    #   P6_LINE_12A == "no"  ~ 1,
    #   P6_LINE_12A == "yes" & P6_LINE_12B == "yes" ~ 1,
    #   P6_LINE_12A == "yes" & P6_LINE_12B == "no"  ~ 0
    # )) %>%
    #P6_LINE_12C #P6_LINE_12A == "yes" & P6_LINE_12C == "no" is the bad case, everything else is good
    dplyr::mutate(P6_LINE_12C = ifelse(P6_LINE_12A == "yes" & P6_LINE_12C == "no", 0 , 1)) %>%
    # dplyr::mutate(P6_LINE_12C = dplyr::case_when(
    #   P6_LINE_12A == "no"  ~ 1,
    #   P6_LINE_12A == "yes" & P6_LINE_12C == "yes" ~ 1,
    #   P6_LINE_12A == "yes" & P6_LINE_12C == "no"  ~ 0
    # )) %>%
    #P6_Line_12 - 1 for A, B , and C
    dplyr::mutate(P6_LINE_12 = ifelse(P6_LINE_12A == 1 & P6_LINE_12B == 1 & P6_LINE_12C == 1, 1, 0)) %>%
    dplyr::select(-c(P6_LINE_12A, P6_LINE_12B, P6_LINE_12C)) %>%
    #P6_Line_12_13_14 - 1 for all
    dplyr::mutate(P6_LINE_12_13_14 = ifelse(P6_LINE_12 == 1 & P6_LINE_13 == 1 & P6_LINE_14 == 1, 1, 0)) %>%
    dplyr::select(-c(P6_LINE_12, P6_LINE_13, P6_LINE_14) )  %>%
    #P6_Line_18
    dplyr::mutate(P6_LINE_18 = dplyr::case_when(
      P6_LINE_18_own_web == "X" ~ "own_website",
      P6_LINE_18_other_web == "X" ~ "others_website",
      P6_LINE_18_req == "X" ~ "request",
      P6_LINE_18_other == "X" ~ "other"
    )) %>%
    dplyr::mutate(P6_LINE_18 = dplyr::case_when(
      P6_LINE_18 == "own_website" ~ 1 ,
      is.na(P6_LINE_18) ~ 0,
      TRUE ~ 0
    )) %>%
    dplyr::select(-c(P6_LINE_18_other, P6_LINE_18_other_web, P6_LINE_18_own_web, P6_LINE_18_req)) %>%
    #order columns
    dplyr::select(sort(colnames(.))) %>%
    dplyr::relocate(ORG_EIN)


  ### Part XII Wrangling ----------------------------------------------------
  dat_12 <- dat[, keep_cols_part12 ]


  # Accounting method (Part XII, line 1) is a single choice: cash / accrual /
  # other. The "other" case is signalled by a free-text description. That field
  # is blank ("") when unused if the data were read with data.table::fread, but
  # NA if read another way -- so detect "other" as a non-blank, non-NA value,
  # NOT via is.na() (which treats "" as present and mislabels everyone "other").
  # P12_LINE_1 = 1 when the method is accrual, 0 for cash/other, NA when none is
  # reported.
  dat_12 <-
    dat_12 %>%
    dplyr::mutate(.method_other =
                    !is.na(F9_12_FINSTAT_METHOD_ACC_OTH) &
                    F9_12_FINSTAT_METHOD_ACC_OTH != "") %>%
    dplyr::mutate(P12_LINE_1 = dplyr::case_when(
      F9_12_FINSTAT_METHOD_ACC_ACCRU_X == "X" ~ 1,
      F9_12_FINSTAT_METHOD_ACC_CASH_X  == "X" ~ 0,
      .method_other                           ~ 0,
      TRUE ~ NA_real_
    )) %>%
    dplyr::select(ORG_EIN, P12_LINE_1)



  ### Bind the parts together ---------------------------------------------

  dat_append <-
    dat_12 %>%
    cbind(dat_4[, -1]) %>%
    cbind(dat_6[, -1])


  ### Final Formatting
  dat_append <-
    dat_append %>%
    dplyr::mutate(dplyr::across(!ORG_EIN,
                                as.numeric))


  dat_return <- dat_orig %>%
    cbind(dat_append[, -1])

  # Normalize the identifier on the returned data so downstream joins get a
  # consistent 9-digit EIN regardless of how it arrived (integer with dropped
  # leading zeros, or a formatted "EIN-.." string).
  dat_return$ORG_EIN <- .pad_ein(dat_return$ORG_EIN)

  ### Return  ---------------------------------------------
  return(dat_return)


}

