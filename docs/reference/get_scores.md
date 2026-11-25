# Calculate Governance Scores

Scores organizations on the nonprofit governance index. By default
(`model = "2023"`) the function returns the 2023 governance index, an
item response score on a scale with mean 100 and standard deviation 15
among all 501(c)(3) full Form 990 filers in tax year 2023, together with
the scores from the 2023 bifactor measurement model and a simple count
of practices. The original 2018 six-factor model remains available as
`model = "legacy-2018"`.

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

  The governance index: mean 100 and SD 15 among 2023 501(c)(3) full-990
  filers, so 115 is one standard deviation above the average 2023 filer.
  It ranges from about 67 (none of the 16 practices) to about 128 (all
  16), and adding a practice never lowers it.

- gov_score_se:

  Standard error of `gov_score`, in index points (about 4 in the middle
  of the distribution, about 10 at the extremes).

- gov_score_bf:

  General factor of the 2023 bifactor model (latent scale, 2023 mean 0).
  This was `gov_score` in version 0.1.0. It correlates .99 with the
  index but can fall when a practice is added, so it is not recommended
  as a published score.

- gov_s_finance, gov_s_minutes, gov_s_policy, gov_s_comp:

  Specific-factor scores of the bifactor model for financial assurance,
  meeting minutes, written policies, and compensation process. These are
  *residual* dimensions, orthogonal to `gov_score_bf`: a positive value
  means the organization does more in that area than its general level
  predicts. They are not standalone subscales, and they are much less
  reliable than the index (empirical reliability among 2023 filers:
  finance .57, compensation .48, minutes .41, policy .29). Only
  `gov_s_finance` carries substantial variance of its own. **Do not use
  `gov_s_policy`**: the written-policy items are the core of the general
  factor, and the policy factor has almost no variance of its own
  (omega-hierarchical \< .01); it only contrasts the
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

**The index (`gov_score`).** The index is the expected a posteriori
(EAP) estimate from a unidimensional graded response model
([`gov_index_2023`](https://nonprofit-open-data-collective.github.io/governance/reference/gov_index_2023.md)).
Nested practices are scored as ordinal items:

- financial assurance: compiled or reviewed, audited, audited with an
  audit committee (0–3);

- conflict-of-interest policy: policy, annual disclosure, monitoring
  (0–3);

- minutes: board and committee minutes (0–2);

- pay-setting process: CEO and other officers (0–2);

and accrual accounting, a majority-independent board, Form 990 review by
the board, whistleblower and document retention policies, and posting
the 990 online are binary items. Because the model has one dimension and
positive slopes, an organization's index can only rise when it reports
another practice. Its value is `100 + 15 * (theta - mu) / sd`, where
`mu` and `sd` are the mean and standard deviation of the 2023 estimates.
Item parameters and both constants are fixed at their 2023 values, so
the index for other tax years is on the 2023 scale; the items show no
meaningful differential functioning across tax years 2021–2024. Missing
items are handled by the model (scores use the answered items).

How much a practice adds depends on which practice it is and where an
organization starts: in 2023 the written policies added 7 to 12 points
on average and most other practices 1 to 4. See
[`vignette("making-gov-scores", package = "governance")`](https://nonprofit-open-data-collective.github.io/governance/articles/making-gov-scores.md)
for the points per practice, interpretation, and limitations, including
the ceiling at about 128.

**Bifactor scores.** `gov_score_bf` and the `gov_s_*` columns come from
the 2023 bifactor model
([`gov_model_2023`](https://nonprofit-open-data-collective.github.io/governance/reference/gov_model_2023.md)),
a general factor plus four testlets (financial assurance; minutes;
written policies; compensation). It describes how the items covary
better than the index model does and supports a single score, but its
EAP estimates are not monotone in the items (Hooker, Finkelman and
Schwartzman 2009): in 2023 data, adding committee minutes lowered
`gov_score_bf` for most organizations that lacked them.

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

## References

Hooker, G., Finkelman, M., and Schwartzman, A. (2009). Paradoxical
results in multidimensional item response theory. *Psychometrika*,
74(3), 419–442.

## See also

[`get_features`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md),
[`gov_index_2023`](https://nonprofit-open-data-collective.github.io/governance/reference/gov_index_2023.md),
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
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>   67.33   87.76   99.56  100.05  111.34  128.29 

# legacy 2018 model
legacy <- get_scores(features_example, model = "legacy-2018")
```
