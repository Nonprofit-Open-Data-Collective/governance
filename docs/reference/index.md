# Package index

## Data import

Retrieve and assemble 990 efile data via the panel990 package.

- [`get_governance_data()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_data.md)
  : Import raw 990 governance fields via the panel990 package
- [`get_governance_scores()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_governance_scores.md)
  : Import 990 data and compute governance scores in one call

## Scoring functions

Turn raw 990 governance fields into a governance index.

- [`get_features()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_features.md)
  : Function to calculate features matrix
- [`get_scores()`](https://nonprofit-open-data-collective.github.io/governance/reference/get_scores.md)
  : Calculate Governance Scores

## Data

Bundled example data and the fitted models.

- [`dat_example`](https://nonprofit-open-data-collective.github.io/governance/reference/dat_example.md)
  : Example Data
- [`gov_index_2023`](https://nonprofit-open-data-collective.github.io/governance/reference/gov_index_2023.md)
  : 2023 Governance Index Model
- [`gov_model_2023`](https://nonprofit-open-data-collective.github.io/governance/reference/gov_model_2023.md)
  : 2023 Bifactor Measurement Model

## Legacy 2018 model

Objects behind get_scores(model = “legacy-2018”).

- [`dat.2018`](https://nonprofit-open-data-collective.github.io/governance/reference/dat.2018.md)
  : 2018 990 Data
- [`features2`](https://nonprofit-open-data-collective.github.io/governance/reference/features2.md)
  : Features for Training Data
- [`model6`](https://nonprofit-open-data-collective.github.io/governance/reference/model6.md)
  : Factor Model
- [`rho2`](https://nonprofit-open-data-collective.github.io/governance/reference/rho2.md)
  : Training Polychoric Correlations
- [`scores`](https://nonprofit-open-data-collective.github.io/governance/reference/scores.md)
  : Training Factor Scores

## Utilities

- [`` `%>%` ``](https://nonprofit-open-data-collective.github.io/governance/reference/pipe.md)
  : Pipe operator
