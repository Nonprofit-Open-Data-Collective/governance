# 2023 Governance Index Model

Parameters of the model behind the governance index returned as
`gov_score` by `get_scores(model = "2023")`: a unidimensional graded
response model
([`mirt::mirt`](https://philchalmers.github.io/mirt/reference/mirt.html))
fit to every 501(c)(3) organization that e-filed a full Form 990 for tax
year 2023. The 16 `GI_*` practices enter as ten items: nested practices
are summed into ordinal items (financial assurance 0–3,
conflict-of-interest policy 0–3, minutes 0–2, pay-setting process 0–2)
and the other six are binary. The estimates are placed on a scale with
mean 100 and SD 15 among 2023 filers. Fitting code:
`data-raw/fit-index-2023.R` in the package source.

## Usage

``` r
gov_index_2023
```

## Format

A list with elements:

- values:

  parameter table from
  [`mirt::mod2values()`](https://philchalmers.github.io/mirt/reference/mod2values.html),
  used to rebuild the model with fixed parameters when scoring

- items, itemtype:

  the ten index items, in model order, and their item types (`"graded"`
  or `"2PL"`)

- bundles:

  the `GI_*` practices summed into each item

- mu, sd:

  mean and standard deviation of the 2023 EAP estimates; the index is
  `100 + 15 * (theta - mu) / sd`

- year, n:

  anchor tax year and number of organizations

- fit:

  limited-information fit (RMSEA, SRMSR, CFI, TLI) and empirical
  reliability

- coef:

  item parameters in IRT form (slope `a`, thresholds)

- mirt_version, fitted:

  mirt version used and date fitted

## See also

[`get_scores`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md),
[`gov_model_2023`](https://nonprofit-open-data-collective.github.io/governance/reference/gov_model_2023.md).
