### Download Raw Data for Governance Factor Analysis
# This file downloads the raw data needed to do factor analysis on the 2013 990 data
# This data is used as as an example for how to use the package

library(data.table)
library(dplyr)

#our training set all 990 filers from the year 2018
years = 2013


### Part IV ----------------------------------------------------------

#initialize data
dat_4 <-  vector(mode = "list", length = length(years))
#get columns I want
keep_cols_part4 <- c("OBJECTID", "URL", "RETURN_VERSION", "ORG_EIN","RETURN_TYPE",
                     "F9_04_AFS_IND_X", "F9_04_AFS_CONSOL_X",
                     "F9_04_BIZ_TRANSAC_DTK_X", "F9_04_BIZ_TRANSAC_DTK_FAM_X", "F9_04_BIZ_TRANSAC_DTK_ENTITY_X",
                     "F9_04_CONTR_NONCSH_MT_25K_X",
                     "F9_04_CONTR_ART_HIST_X")

#read in the data
for(i in 1:length(years)){
  link <-  paste0("https://nccs-efile.s3.us-east-1.amazonaws.com/parsed/F9-P04-T00-REQUIRED-SCHEDULES-", years[i], ".csv")
  temp <- fread(link, select = keep_cols_part4)
  dat_4[[i]] <- temp
}

#clean up data
dat_all_4 <-
  rbindlist(dat_4) %>%
  mutate( year = as.numeric(substr(RETURN_VERSION, 1, 4)))%>%
  filter(year <= max(years))


### Part VI Data  ----------------------------------------------------------

#initialize data
dat_6 <-  vector(mode = "list", length = length(years))
#get columns I want
keep_cols_part6 <- c("OBJECTID", "URL", "RETURN_VERSION", "ORG_EIN", "RETURN_TYPE",
                     "F9_06_GVRN_NUM_VOTING_MEMB",
                     "F9_06_GVRN_NUM_VOTING_MEMB_IND",
                     "F9_06_GVRN_DTK_FAMBIZ_RELATION_X",
                     "F9_06_GVRN_DELEGATE_MGMT_DUTY_X",
                     "F9_06_GVRN_DOC_GVRN_BODY_X",
                     "F9_06_POLICY_FORM990_GVRN_BODY_X",
                     "F9_06_POLICY_COI_X",
                     "F9_06_POLICY_COI_DISCLOSURE_X",
                     "F9_06_POLICY_COI_MONITOR_X",
                     "F9_06_POLICY_WHSTLBLWR_X",
                     "F9_06_POLICY_DOC_RETENTION_X",
                     "F9_06_POLICY_COMP_PROCESS_CEO_X",
                     "F9_06_DISCLOSURE_AVBL_OTH_X",
                     "F9_06_DISCLOSURE_AVBL_OTH_WEB_X",
                     "F9_06_DISCLOSURE_AVBL_REQUEST_X",
                     "F9_06_DISCLOSURE_AVBL_OWN_WEB_X"
)

#read in data
for(i in 1:length(years)){
  link <-  paste0("https://nccs-efile.s3.us-east-1.amazonaws.com/parsed/F9-P06-T00-GOVERNANCE-", years[i], ".csv")
  temp <- fread(link, select = keep_cols_part6)
  dat_6[[i]] <- temp
}

#clean up data
dat_all_6 <-
  rbindlist(dat_6) %>%
  mutate( year = as.numeric(substr(RETURN_VERSION, 1, 4))) %>%
  filter(year <= max(years))



### Part XII Data ---------------------------------

#initialize data
dat_12 <-  vector(mode = "list", length = length(years))
#Keep all columns for part XII


#keep the columns we want
keep_cols_part12 <- c("OBJECTID", "URL", "RETURN_VERSION", "ORG_EIN","RETURN_TYPE",
                      "F9_12_FINSTAT_METHOD_ACC_OTH",
                      "F9_12_FINSTAT_METHOD_ACC_ACCRU_X",
                      "F9_12_FINSTAT_METHOD_ACC_CASH_X")


#download the data
for(i in 1:length(years)){
  link <-  paste0("https://nccs-efile.s3.us-east-1.amazonaws.com/parsed/F9-P12-T00-FINANCIAL-REPORTING-", years[i], ".csv")
  temp <- fread(link, select = keep_cols_part12)
  dat_12[[i]] <- temp
}


#clean up data
dat_all_12 <-
  rbindlist(dat_12) %>%
  mutate( year = as.numeric(substr(RETURN_VERSION, 1, 4)))%>%
  filter(year <= max(years))


### Schedule M Data -------------------------------------

#initialize data
dat_M <-  vector(mode = "list", length = length(years))
#get columns I want
keep_cols_partM <- c("OBJECTID", "URL", "RETURN_VERSION", "ORG_EIN","RETURN_TYPE",
                     "SM_01_REVIEW_PROCESS_UNUSUAL_X")

for(i in 1:length(years)){
  link <-  paste0("https://nccs-efile.s3.us-east-1.amazonaws.com/parsed/SM-P01-T00-NONCASH-CONTRIBUTIONS-", years[i], ".csv")
  temp <- fread(link, select = keep_cols_partM)
  dat_M[[i]] <- temp
}


#clean up data
dat_all_M <-
  rbindlist(dat_M) %>%
  mutate( year = as.numeric(substr(RETURN_VERSION, 1, 4)))%>%
  filter(year <= max(years))



### Merge all parts
vars.bind <- c("OBJECTID", "URL", "RETURN_VERSION", "ORG_EIN", "year", "RETURN_TYPE")

dat_example <-
  dat_all_4 %>%
  merge(dat_all_6, by = vars.bind) %>%
  merge(dat_all_12, by = vars.bind) %>%
  merge(dat_all_M, by = vars.bind) %>%
  filter(RETURN_TYPE != "990EZ")

### Save this as the training data
save(dat_example, file = "data/dat_example.rda")

