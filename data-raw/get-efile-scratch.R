
as_bullet_list <- function( items ) {
  paste0( "#  - ", items, collapse = "\n" )
}

irs990efile::get_table_names() |> as_bullet_list() |> cat()


#  - F9-P00-T00-HEADER
#  - F9-P01-T00-SUMMARY
#  - F9-P01-T00-SUMMARY-EZ
#  - F9-P02-T00-SIGNATURE
#  - F9-P03-T00-MISSION
#  - F9-P03-T00-PROGRAM-ONE
#  - F9-P03-T00-PROGRAMS
#  - F9-P03-T00-PROGRAM-THREE
#  - F9-P03-T00-PROGRAM-TWO
#  - F9-P03-T01-PROGRAMS-OTHER
#  - F9-P03-T02-PROGRAMS-EZ
#  - F9-P04-T00-REQUIRED-SCHEDULES
#  - F9-P04-T00-REQUIRED-SCHEDULES-EZ
#  - F9-P05-T00-OTHER-IRS-FILING
#  - F9-P06-T00-GOVERNANCE
#  - F9-P06-T00-GOVERNANCE-EZ
#  - F9-P07-T00-DIR-TRUST-KEY
#  - F9-P07-T01-COMPENSATION
#  - F9-P07-T01-COMPENSATION-HCE-EZ
#  - F9-P07-T02-CONTRACTORS
#  - F9-P08-T00-REVENUE
#  - F9-P08-T01-REVENUE-PROGRAMS
#  - F9-P08-T02-REVENUE-MISC
#  - F9-P09-T00-EXPENSES
#  - F9-P09-T01-EXPENSES-OTHER
#  - F9-P10-T00-BALANCE-SHEET
#  - F9-P11-T00-ASSETS
#  - F9-P12-T00-FINANCIAL-REPORTING
#  - SA-P00-T00-HEADER
#  - SA-P01-T00-PUBLIC-CHARITY-STATUS
#  - SA-P01-T01-PUBLIC-CHARITY-STATUS
#  - SA-P02-T00-SUPPORT_SCHEDULE_170
#  - SA-P03-T00-SUPPORT_SCHEDULE_509
#  - SA-P04-T00-SUPPORT-ORGS
#  - SA-P05-T00-SUPPORT-ORGS
#  - SB-P01-T01-CONTRIBUTORS
#  - SC-P01-T00-LOBBY
#  - SC-P01-T01-POLITICAL-ORGS-INFO
#  - SC-P02-T00-LOBBY
#  - SC-P03-T00-LOBBY
#  - SD-P01-T00-ORGS-DONOR-ADVISED-FUNDS-OTH
#  - SD-P02-T00-CONSERV-EASEMENTS
#  - SD-P03-T00-ORGS-COLLECT-ART-HIST-TREASURE-OTH
#  - SD-P04-T00-ESCROW-CUSTODIAL-ARRANGEMENTS
#  - SD-P05-T00-ENDOWMENT
#  - SD-P06-T00-LAND-BLDG-EQUIP
#  - SD-P07-T00-INVESTMENTS-SECURITIES
#  - SD-P07-T01-INVESTMENTS-OTH-DERIVATIVES
#  - SD-P07-T01-INVESTMENTS-OTH-EQUITY
#  - SD-P07-T01-INVESTMENTS-OTH-SECURITIES
#  - SD-P08-T00-INVESTMENTS-PROG-RLTD
#  - SD-P08-T01-INVESTMENTS-PROG-RLTD
#  - SD-P09-T00-OTH-ASSETS
#  - SD-P09-T01-OTH-ASSETS
#  - SD-P10-T00-OTH-LIABILITIES
#  - SD-P10-T01-OTH-LIABILITIES
#  - SD-P11-T00-RECONCILIATION-REVENUE
#  - SD-P12-T00-RECONCILIATION-EXPENSES
#  - SD-P99-T00-RECONCILIATION-NETASSETS
#  - SE-P01-T00-SCHOOLS
#  - SF-P01-T00-FRGN-ACTS
#  - SF-P01-T01-FRGN-ACTS-BY-REGION
#  - SF-P02-T00-FRGN-ORG-GRANTS
#  - SF-P02-T01-FRGN-ORG-GRANTS
#  - SF-P03-T01-FRGN-INDIV-GRANTS
#  - SF-P04-T00-FRGN-INTERESTS
#  - SF-P99-T00-FRGN-ORG-GRANTS
#  - SG-P01-T00-FUNDRAISING-ACTS
#  - SG-P01-T01-FUNDRAISERS-INFO
#  - SG-P02-T00-FUNDRAISING-EVENTS
#  - SG-P02-T01-FUNDRAISING-EVENTS
#  - SG-P03-T00-GAMING
#  - SH-P01-T00-FAP-COMMUNITY-BENEFIT-POLICY
#  - SH-P02-T00-FAP-COMMUNITY-BENEFIT-POLICY
#  - SH-P03-T00-FAP-COMMUNITY-BENEFIT-POLICY
#  - SH-P04-T01-COMPANY-JOINT-VENTURES
#  - SH-P05-T00-FAP-COMMUNITY-BENEFIT-POLICY
#  - SH-P05-T01-HOSPITAL-FACILITY
#  - SH-P05-T02-NON-HOSPITAL-FACILITY
#  - SH-P99-T00-FAP-COMMUNITY-BENEFIT-POLICY
#  - SI-P01-T00-GRANTS-INFO
#  - SI-P02-T00-GRANTS-US-ORGS-GOVTS
#  - SI-P02-T01-GRANTS-US-ORGS-GOVTS
#  - SI-P03-T01-GRANTS-US-INDIV
#  - SI-P99-T00-GRANTS-US-ORGS-GOVTS
#  - SJ-P01-T00-COMPENSATION
#  - SJ-P02-T01-COMPENSATION-DTK
#  - SK-P01-T01-BOND-ISSUES
#  - SK-P02-T01-BOND-PROCEEDS
#  - SK-P03-T01-BOND-PRIVATE-BIZ-USE
#  - SK-P04-T01-BOND-ARBITRAGE
#  - SK-P05-T01-PROCEDURE-CORRECTIVE-ACT
#  - SL-P01-T00-EXCESS-BENEFIT-TRANSAC
#  - SL-P01-T01-EXCESS-BENEFIT-TRANSAC
#  - SL-P02-T00-LOANS-INTERESTED-PERS
#  - SL-P02-T01-LOANS-INTERESTED-PERS
#  - SL-P03-T01-GRANTS-INTERESTED-PERS
#  - SL-P04-T01-BIZ-TRANSAC-INTERESTED-PERS
#  - SM-P01-T00-NONCASH-CONTRIBUTIONS
#  - SM-P01-T01-NONCASH-CONTRIBUTIONS
#  - SN-P01-T00-LIQUIDATION-TERMINATION-DISSOLUTION
#  - SN-P01-T01-LIQUIDATION-TERMINATION-DISSOLUTION
#  - SN-P02-T00-DISPOSITION-OF-ASSETS
#  - SN-P02-T01-DISPOSITION-OF-ASSETS
#  - SN-P99-T00-LIQUIDATION-TERMINATION-DISSOLUTION
#  - SR-P01-T01-ID-DISREGARDED-ENTITIES
#  - SR-P02-T01-ID-RLTD-TAX-EXEMPED-ORGS
#  - SR-P03-T01-ID-RLTD-ORGS-TAXABLE-PARTNERSHIP
#  - SR-P04-T01-ID-RLTD-ORGS-TAXABLE-CORPORATION
#  - SR-P05-T00-TRANSACTIONS-RLTD-ORGS
#  - SR-P05-T01-TRANSACTIONS-RLTD-ORGS
#  - SR-P06-T01-UNRLTD-ORGS-TAXABLE-PARTNERSHIP





get_dd <- function( vars ){

  cc.url <- "https://raw.githubusercontent.com/Nonprofit-Open-Data-Collective/irs-efile-master-concordance-file/refs/heads/master/concordance.csv"
  concordance <- data.table::fread( cc.url )

  dd <- concordance[
    variable_name %in% vars,
    .(variable_name, location_code, description)
  ]

  dd <- dd[ ! duplicated(dd$variable_name), ]


  df <- as.data.frame(
    lapply(dd, function(col) {
      if (is.character(col)) iconv(col, from = "", to = "UTF-8", sub = "byte") else col
    }),
    stringsAsFactors = FALSE
  )

  df$description <- stringr::str_wrap(df$description, width = 40)

  # Capture the pander output as text
  table_text <- 
    capture.output(  
      pander::pander(  df, 
                       split.tables=150, 
                       justify=c("lll") 
  ))

  # Prepend "# " to each line
  commented_table <- paste0( "##   ", table_text )

  # Print the result
  cat( commented_table, sep = "\n" )

}




https://nccs-efile.s3.us-east-1.amazonaws.com/public/efile_v2_0/F9-P02-T00-SIGNATURE-2021.CSV

https://nccsdata.s3.amazonaws.com/harmonized/bmf/unified/BMF_UNIFIED_V1.1.csv

https://nccsdata.s3.us-east-1.amazonaws.com/bmf/unified/v1.2/UNIFIED_BMF_V1.2.csv


get_table <- function( table.name, year ){
  options(timeout = max(600, getOption("timeout")))
  root <- "https://nccs-efile.s3.us-east-1.amazonaws.com/public/efile_v2_0/"
  url <- paste0( root, table.name, "-", year, ".CSV" )
  df <- data.table::fread( url )
  # df$EIN2 <- format_ein( df$ORG_EIN )
  return( df )
}


get_bmf <- function(){
  options(timeout = max(600, getOption("timeout")))
  url <- "https://nccsdata.s3.us-east-1.amazonaws.com/bmf/unified/v1.2/UNIFIED_BMF_V1.2.csv"
  bmf <- data.table::fread( url )
  return( bmf )
}


format_ein <- function( x, to="id" ) {

    if( to == "id" ){   
      x <- stringr::str_pad( x, 9, side="left", pad="0" )
      sub1 <- substr( x, 1, 2 )
      sub2 <- substr( x, 3, 9 )
      ein  <- paste0( "EIN-", sub1, "-", sub2 ) 
      return(ein) }
      
    if( to == "n" ){  
      x <- gsub( "[^0-9]", "", x )
      return( x ) }    
}

get_panel <- function( table.name, years=2009:2019 ){
  df.list <- list()
  for( i in years )
  {
    df.list[[ as.character(i) ]] <- get_table( "F9-P01-T00-SUMMARY", year=2009 ) 
  }
  df <- dplyr::bind_rows( df.list )
  return( df )
}