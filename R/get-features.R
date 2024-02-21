#' Function to calculate features matrix 
#'
#' This function takes input from raw 990 Part IV, VI, and XII, then output a wrangled data frame with columns as features needed to calculate goverannce score.
#' 
#' @param dat A data.frame with columns ORG_EIN and correct inputs from 990 Part IV, VI, and XII. See details below.
#'   ORG_EIN must be a character string of 9 digits.
#' 
#' @details
#' There are the variables from each Part/Schedule that is needed to run this function 
#' 
#' Variables from Part IV: "F9_04_AFS_IND_X", "F9_04_AFS_CONSOL_X", "F9_04_BIZ_TRANSAC_DTK_X", 
#' "F9_04_BIZ_TRANSAC_DTK_FAM_X", "F9_04_BIZ_TRANSAC_DTK_ENTITY_X", "F9_04_CONTR_NONCSH_MT_25K_X", 
#' "F9_04_CONTR_ART_HIST_X".
#' 
#' Variables from Part VI: "F9_06_GVRN_NUM_VOTING_MEMB", "F9_06_GVRN_NUM_VOTING_MEMB_IND", 
#' "F9_06_GVRN_DTK_FAMBIZ_RELATION_X", "F9_06_GVRN_DELEGATE_MGMT_DUTY_X", "F9_06_GVRN_DOC_GVRN_BODY_X", 
#' "F9_06_POLICY_FORM990_GVRN_BODY_X", "F9_06_POLICY_COI_X", "F9_06_POLICY_COI_DISCLOSURE_X", 
#' "F9_06_POLICY_COI_MONITOR_X", "F9_06_POLICY_WHSTLBLWR_X", "F9_06_POLICY_DOC_RETENTION_X", 
#' "F9_06_POLICY_COMP_PROCESS_CEO_X", "F9_06_DISCLOSURE_AVBL_OTH_X", "F9_06_DISCLOSURE_AVBL_OTH_WEB_X", 
#' "F9_06_DISCLOSURE_AVBL_REQUEST_X", "F9_06_DISCLOSURE_AVBL_OWN_WEB_X".
#' 
#' Variables from Part XII: "F9_12_FINSTAT_METHOD_ACC_OTH", "F9_12_FINSTAT_METHOD_ACC_ACCRU_X", 
#' "F9_12_FINSTAT_METHOD_ACC_CASH_X".
#' 
#' Variables from Schedule M: "SM_01_REVIEW_PROCESS_UNUSUAL_X".
#' 
#' @return
#' A data.frame appended with features needed to run the \code{\link{get_scores}} function.
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
    which_missing_4 <- cols_partM$old[!has_col_4 ]
    stop(paste("input data frame is missing column", which_missing_4, 
               ". See documentation for details."))
  }
  
  #Checking part 6
  has_col_6 <- cols_part6$old %in% colnames(dat)
  if(!all(has_col_6)){
    which_missing_6 <- cols_partM$old[!has_col_6 ]
    stop(paste("input data frame is missing column", which_missing_6, 
               ". See documentation for details."))
  }
  
  #Checking part 12
  has_col_12 <- keep_cols_part12 %in% colnames(dat)
  if(!all(has_col_12)){
    which_missing_12 <- cols_partM$old[!has_col_12 ]
    stop(paste("input data frame is missing column", which_missing_12, 
               ". See documentation for details."))
  }
  
  
  ### Schedule M wrangling ----------------------------------------------
  dat_M <- dat[ , cols_partM$old ]
  colnames(dat_M) <- cols_partM$new 
  
  dat_M <- 
    dat_M %>% 
    dplyr::mutate(PM_LINE_31 = case_when(
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
    dplyr::mutate(dplyr::across(dplyr::starts_with("P4"), 
                  ~ case_when(
                    . %in% c("true", "1") ~ "yes",
                    . %in% c("false", "0") ~ "no", 
                    TRUE ~ .
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
    dplyr::mutate(P4_LINE_29_30 = case_when(
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
    dplyr::mutate_at(dplyr::vars( paste0("P6_LINE_", c("2", "3", "8A","11A", "12A", "12B", "12C", "13", "14", "15A"))),
                     ~  ifelse(. == "true" | . == "1", "yes", "no")) %>% 
    #P6_LINE_2, 3, have no as good and yes as bad
    dplyr::mutate_at(dplyr::vars("P6_LINE_2", "P6_LINE_3" ) ,
              ~ ifelse(. == "no", 1, 0))%>%
    # P6_LINE_8A, 11A, 12A, 13, 14, yes is good, no is bad
    dplyr::mutate_at(dplyr::vars( paste0("P6_LINE_", c("8A","11A", "12A", "13", "14", "15A"))),
              ~  ifelse(. == "yes", 1, 0)) %>% 
    rowwise() %>%
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

  
  dat_12 <- 
    dat_12 %>% 
    dplyr::mutate(P12_LINE_1 = dplyr::case_when(
      !is.na(F9_12_FINSTAT_METHOD_ACC_OTH) ~ "other",
      F9_12_FINSTAT_METHOD_ACC_ACCRU_X == "X" ~ "accrual",
      F9_12_FINSTAT_METHOD_ACC_CASH_X == "X" ~ "cash"
    )) %>%
    # P12_LINE_1 
    dplyr::mutate(P12_LINE_1 = ifelse(P12_LINE_1 == "accrual", 1, 0))  %>% 
    dplyr::select(ORG_EIN, P12_LINE_1)
  
 
  
  ### Bind the parts together ---------------------------------------------
  
  dat_append <-
    dat_12 %>% 
    cbind(dat_4[, -1]) %>%
    cbind(dat_6[, -1])
  
  
  ### Final Formatting 
  dat_append <-
    dat_append %>%  
    dplyr::mutate(ORG_EIN = sprintf("%0*d", 9, as.numeric(ORG_EIN))) %>% 
    dplyr::mutate(dplyr::across(!ORG_EIN, 
                                as.numeric))
  
  
  dat_return <- dat %>% 
    cbind(dat_append[, -1])
  
  ### Return  ---------------------------------------------
  return(dat_append)
  
  
}


## Testings - using 01-make-govern-data
# dat1 <- as.data.frame(dat_all_M)
# dat2 <- as.data.frame(dat_all_4)
# dat3 <- as.data.frame(dat_all_6)
# dat4 <- as.data.frame(dat_all_12)
# 
# dat5 <- cbind(dat1, dat2, dat3, dat4)
# 
# dat6 <- get_features(dat5)
# dat6 <- na.omit(dat6)[1:200, ] #remove NA's and just pick a few to run the scores on
# 
# dat7 <- get_scores(dat6)

