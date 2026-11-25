# 2023 Governance Index Model

Item parameters of the 2023 anchor model used by
`get_scores(model = "2023")`: a bifactor two-parameter logistic item
response model
([`mirt::bfactor`](https://philchalmers.github.io/mirt/reference/bfactor.html))
fit to the 16 `GI_*` practice items for every 501(c)(3) organization
that e-filed a full Form 990 for tax year 2023. Fitting code:
`data-raw/fit-model-2023.R` in the package source.

## Usage

``` r
gov_model_2023
```

## Format

A list with elements:

- values:

  parameter table from
  [`mirt::mod2values()`](https://philchalmers.github.io/mirt/reference/mod2values.html),
  used to rebuild the model with fixed parameters when scoring

- spec:

  testlet assignment of each item (1 financial assurance, 2 minutes, 3
  written policies, 4 compensation, `NA` general only)

- items:

  item names, in model order

- factors:

  names of the score columns, in factor order

- year, n:

  anchor tax year and number of organizations

- logLik, BIC:

  fit statistics

- loadings:

  standardized loadings on the general and specific factors

- item_means:

  share of 2023 filers reporting each practice

- mirt_version, fitted:

  mirt version used and date fitted
