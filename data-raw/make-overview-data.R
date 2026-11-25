# make-overview-data.R -- population summaries for vignette("overview").
#
# Scores every 501(c)(3) full Form 990 filer for tax years 2021-2024 with the
# package (get_features() + get_scores(), 2023 model) and saves small summary
# tables to vignettes/data/gov-overview.rds. The vignette reads only that file,
# so it builds offline.
#
# Input: one raw file per year with the governance fields, header fields, Part I
# expenses and BMF traits (NTEE subsector, state), as written by panel990:
#
#   panel <- panelize(
#     sfw     = create_sfw("governance", form_type = "990"),
#     tables  = c("F9-P00-T00-HEADER", "F9-P01-T00-SUMMARY", governance:::.gov_tables),
#     years   = yr,
#     bmf     = TRUE,
#     columns = c(governance:::.gov_keys, governance:::.all_gov_fields(),
#                 "F9_00_EXEMPT_STAT_501C3_X", "F9_00_YEAR_FORMATION",
#                 "F9_01_EXP_TOT_CY")
#   )
#   saveRDS(as.data.frame(panel_deduplicate(panel)), sprintf("raw-%d.rds", yr))
#
# Set GOV_RAW_DIR to the folder holding raw-2021.rds ... raw-2024.rds.
# Runtime: about 5-10 minutes per year, mostly mirt::fscores().

pkgload::load_all(".")
suppressPackageStartupMessages(library(data.table))

raw_dir <- Sys.getenv("GOV_RAW_DIR", "paper/data")
years   <- 2021:2024
out     <- "vignettes/data/gov-overview.rds"

size_breaks <- c(-Inf, 1e5, 5e5, 2e6, 1e7, 4e7, Inf)
size_labels <- c("<$100k", "$100k-500k", "$500k-2m", "$2m-10m", "$10m-40m", "$40m+")

subsector_labels <- c(
  ART = "Arts, culture & humanities", EDU = "Education (excl. universities)",
  UNI = "Universities", ENV = "Environment & animals", HEL = "Health (excl. hospitals)",
  HOS = "Hospitals", HMS = "Human services", IFA = "International",
  PSB = "Public & societal benefit", REL = "Religion-related",
  MMB = "Mutual & membership benefit", UNU = "Unclassified"
)

num <- function(x) suppressWarnings(as.numeric(x))

score_year <- function(yr) {
  t0 <- Sys.time()
  d  <- readRDS(file.path(raw_dir, sprintf("raw-%d.rds", yr)))

  # 501(c)(3) full-990 filers with non-negative expenses: the anchor population
  c3  <- toupper(trimws(d$F9_00_EXEMPT_STAT_501C3_X)) %in% "X"
  exp <- num(d$F9_01_EXP_TOT_CY)
  d   <- d[c3 & !is.na(exp) & exp >= 0, ]

  s <- suppressMessages(get_scores(get_features(d)))

  ruling <- num(d$ruling_year)
  formed <- num(d$F9_00_YEAR_FORMATION)
  born   <- ifelse(!is.na(ruling) & ruling > 1800, ruling,
                   ifelse(!is.na(formed) & formed > 1800, formed, NA))
  state  <- ifelse(is.na(d$geo_state_abbr) | d$geo_state_abbr == "",
                   d$F9_00_ORG_ADDR_STATE, d$geo_state_abbr)

  keep <- c(.gi_items, .gi_risks, "gov_score", "gov_score_se", "gov_s_finance",
            "gov_s_minutes", "gov_s_policy", "gov_s_comp", "gov_count")
  r <- data.table(
    EIN2      = d$EIN2,
    year      = yr,
    expenses  = num(d$F9_01_EXP_TOT_CY),
    size      = cut(num(d$F9_01_EXP_TOT_CY), size_breaks, size_labels, right = FALSE),
    subsector = subsector_labels[ substr(d$nteev2_subsector, 1, 3) ],
    state     = state,
    age       = yr - born,
    s[ , keep ]
  )
  r[ is.na(subsector), subsector := "Unclassified" ]
  message(yr, ": ", format(nrow(r), big.mark = ","), " filers scored in ",
          round(difftime(Sys.time(), t0, units = "mins"), 1), " min")
  r
}

panel <- rbindlist(lapply(years, score_year))
p23   <- panel[ year == 2023 ]

# size-adjusted score: residual from the size-band mean, so group means compare
# organizations of the same size
p23[ , gov_adj := gov_score - mean(gov_score, na.rm = TRUE), by = size ]

items <- c(.gi_items, .gi_risks)
q <- function(x, p) as.numeric(stats::quantile(x, p, na.rm = TRUE))

score_summary <- function(dt, by) {
  dt[ , .(
    n          = .N,
    gov_mean   = mean(gov_score, na.rm = TRUE),
    gov_p25    = q(gov_score, .25),
    gov_median = q(gov_score, .50),
    gov_p75    = q(gov_score, .75),
    gov_adj    = mean(gov_adj, na.rm = TRUE),
    count_mean = mean(gov_count, na.rm = TRUE),
    finance    = mean(gov_s_finance, na.rm = TRUE),
    minutes    = mean(gov_s_minutes, na.rm = TRUE),
    policy     = mean(gov_s_policy, na.rm = TRUE),
    comp       = mean(gov_s_comp, na.rm = TRUE)
  ), keyby = by ]
}

item_rates <- function(dt, by) {
  long <- melt(dt[ , c(by, items), with = FALSE], id.vars = by,
               variable.name = "item", value.name = "x")
  long[ , .(rate = mean(x, na.rm = TRUE)), keyby = c(by, "item") ]
}

age_breaks <- c(-Inf, 5, 10, 20, 40, Inf)
age_labels <- c("<5 years", "5-9", "10-19", "20-39", "40+")
p23[ , age_band := cut(age, age_breaks, age_labels, right = FALSE) ]

# within-organization change: organizations filing in both 2021 and 2024
w <- dcast(panel[ year %in% c(2021, 2024) ], EIN2 ~ year,
           value.var = c("gov_score", "gov_count"))
w <- w[ !is.na(gov_score_2021) & !is.na(gov_score_2024) ]
w <- merge(w, p23[ , .(EIN2, size) ], by = "EIN2")
w[ , `:=`(d_gov = gov_score_2024 - gov_score_2021,
          d_count = gov_count_2024 - gov_count_2021) ]

change_by_size <- w[ , .(
  n         = .N,
  gov_2021  = mean(gov_score_2021),
  gov_2024  = mean(gov_score_2024),
  d_gov     = mean(d_gov),
  share_up  = mean(d_count > 0),
  share_same = mean(d_count == 0),
  share_down = mean(d_count < 0)
), keyby = size ]

overview <- list(
  population     = panel[ , .(n = .N,
                              gov_mean = mean(gov_score, na.rm = TRUE),
                              gov_sd = stats::sd(gov_score, na.rm = TRUE),
                              count_mean = mean(gov_count, na.rm = TRUE)),
                          keyby = year ],
  items_overall  = p23[ , lapply(.SD, mean, na.rm = TRUE), .SDcols = items ],
  items_by_size  = item_rates(p23, "size"),
  items_by_year  = item_rates(panel, "year"),
  scores_by_size = score_summary(p23, "size"),
  scores_by_subsector = score_summary(p23, "subsector"),
  scores_by_state = score_summary(p23[ state %in% c(state.abb, "DC") ], "state"),
  scores_by_age  = score_summary(p23[ !is.na(age_band) ], "age_band"),
  count_dist     = p23[ !is.na(gov_count), .N, keyby = gov_count ],
  score_hist     = p23[ !is.na(gov_score),
                        .N, keyby = .(bin = floor(gov_score / 2.5) * 2.5) ],   # 2.5-point bins (index scale)
  se_by_decile   = p23[ !is.na(gov_score),
                        .(gov_mean = mean(gov_score), se_mean = mean(gov_score_se)),
                        keyby = .(decile = cut(rank(gov_score, ties.method = "first"),
                                               10, labels = FALSE)) ],
  cor_size       = p23[ , .(gov   = cor(gov_score, log10(pmax(expenses, 1)),
                                        method = "spearman", use = "pair"),
                            count = cor(gov_count, log10(pmax(expenses, 1)),
                                        method = "spearman", use = "pair"),
                            gov_count = cor(gov_score, gov_count, use = "pair")) ],
  change_by_size = change_by_size,
  change_overall = w[ , .(n = .N, d_gov = mean(d_gov), share_up = mean(d_count > 0),
                          share_same = mean(d_count == 0), share_down = mean(d_count < 0)) ],
  built          = Sys.Date()
)

overview <- lapply(overview, function(x) if (is.data.table(x)) as.data.frame(x) else x)
dir.create(dirname(out), showWarnings = FALSE, recursive = TRUE)
saveRDS(overview, out, compress = "xz")
message("Saved ", out, " (", round(file.size(out) / 1024), " KB)")
