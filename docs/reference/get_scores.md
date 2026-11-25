# Calculate Governance Scores

Scores organizations on the nonprofit governance index. By default
(`model = "2023"`) the function applies the 2023 anchor model: a
bifactor item response model fit to all 501(c)(3) full Form 990 filers
in tax year 2023. It appends a general governance score, four
specific-factor scores, and a simple count of practices. The original
2018 six-factor model remains available as `model = "legacy-2018"`.

## Usage

``` r
get_scores(
  feature.matrix,
  model = c("2023", "legacy-2018"),
  missing = TRUE,
  impute = "median",
  scores.by.hand = FALSE
)
```

## Arguments

- feature.matrix:

  A data.frame of features, the output of
  [`get_features`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md).
  For `model = "2023"` it must contain the 16 `GI_*` item columns; for
  `model = "legacy-2018"` the 12 legacy features (`"P12_LINE_1"`,
  `"P4_LINE_12"`, ...).

- model:

  Which scoring model to apply: `"2023"` (default) or `"legacy-2018"`.

- missing, impute, scores.by.hand:

  Used only by `model = "legacy-2018"`; passed to
  [`psych::factor.scores`](https://rdrr.io/pkg/psych/man/factor.scores.html)
  as in earlier versions. With `missing = FALSE`, rows with `NA`
  features are dropped.

## Value

The input data frame with appended columns.

For `model = "2023"`:

- gov_score:

  General governance score (EAP estimate of the general factor). On the
  latent scale, 2023 501(c)(3) filers have mean 0 and SD 1. Higher means
  more of the recommended practices.

- gov_score_se:

  Standard error of `gov_score`.

- gov_s_finance, gov_s_minutes, gov_s_policy, gov_s_comp:

  Specific-factor scores for financial assurance, meeting minutes,
  written policies, and compensation process. These are *residual*
  dimensions, orthogonal to `gov_score`: a positive value means the
  organization does more in that area than its general score predicts.
  They are not standalone subscales, and they are much less reliable
  than `gov_score` (empirical reliability among 2023 filers: finance
  .57, compensation .48, minutes .41, policy .29, vs .83 for
  `gov_score`). Only `gov_s_finance` carries substantial variance of its
  own. **Do not use `gov_s_policy`**: the written-policy items are the
  core of `gov_score`, and the policy factor has almost no variance of
  its own (omega-hierarchical \< .01); it only contrasts the
  conflict-of-interest items with the whistleblower and retention
  policies. It is returned for completeness.

- gov_count:

  Number of the 16 practices present (0–16), a transparent alternative
  that correlates about .96 with `gov_score`.

- gov_n_items:

  Number of the 16 items answered. Rows with no answered items get `NA`
  scores.

For `model = "legacy-2018"`: six factor scores and `total.score`, as in
earlier versions of the package.

## Details

**2023 model.** The model has a general factor and four specific factors
(testlets) that absorb the strong dependence among nested items:

- financial assurance: review/audit, audit, audit committee, accrual;

- minutes: board and committee minutes;

- written policies: conflict-of-interest policy, disclosure, monitoring,
  whistleblower, retention;

- compensation: CEO and other-officer pay process.

Board independence, Form 990 review by the board, and posting the 990
online load on the general factor only. Item parameters are fixed at
their 2023 values
([`gov_model_2023`](https://nonprofit-open-data-collective.github.io/governance/reference/gov_model_2023.md)),
so scores for other tax years are on the 2023 scale and can be compared
over time; the items show no meaningful differential functioning across
tax years 2021–2024. Missing items are handled by the IRT model (scores
use the answered items). Scores are expected a posteriori (EAP)
estimates computed with
[`mirt::fscores`](https://philchalmers.github.io/mirt/reference/fscores.html).

Three financial-assurance items (audit, review or audit, accrual) show
moderate differential item functioning by organization size: at the same
general level, larger organizations are more likely to be audited, in
part because of legal and funder audit thresholds. Keep this in mind
when comparing organizations of very different size.

**Legacy model.** The 2018 model has known problems, including negative
implied weights on several good-practice features and a training sample
that excluded fully independent boards. It is kept for reproducing
earlier work. See "Known issues" in
[`vignette("legacy-2018-model", package = "governance")`](https://nonprofit-open-data-collective.github.io/governance/articles/legacy-2018-model.md).

## See also

[`get_features`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md),
[`gov_model_2023`](https://nonprofit-open-data-collective.github.io/governance/reference/gov_model_2023.md).

## Examples

``` r
data("dat_example", package = "governance")
set.seed(57)
dat_example <- dat_example[sample(seq_len(nrow(dat_example)), 200), ]
features_example <- get_features(dat_example)

# 2023 index (default)
scores_example <- get_scores(features_example)
summary(scores_example$gov_score)
#>      Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
#> -1.944843 -0.847470  0.006912  0.007729  0.754730  1.692339 

# legacy 2018 model
legacy <- get_scores(features_example, model = "legacy-2018")
```
