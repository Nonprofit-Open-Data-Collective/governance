# Column names referenced with non-standard evaluation inside get_features() and
# the data objects loaded by get_scores(). Declared here so R CMD check does not
# raise "no visible binding for global variable" NOTEs.
utils::globalVariables(c(
  ".", "ORG_EIN",
  # Part IV
  "F9_12_FINSTAT_METHOD_ACC_OTH", "P12_LINE_1",
  "P4_LINE_12A", "P4_LINE_28A", "P4_LINE_28B", "P4_LINE_28C",
  "P4_LINE_29", "P4_LINE_30", "PM_LINE_31",
  # Part VI
  "P6_LINE_1A", "P6_LINE_1B", "divide.by.0",
  "P6_LINE_12", "P6_LINE_12A", "P6_LINE_12B", "P6_LINE_12C",
  "P6_LINE_13", "P6_LINE_14",
  "P6_LINE_18_other", "P6_LINE_18_other_web", "P6_LINE_18_own_web", "P6_LINE_18_req",
  # factor model objects loaded via data("factor-objects")
  "features2", "model6", "rho2"
))
