# governance [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10781067.svg)](https://doi.org/10.5281/zenodo.10781067)

R package for creating a nonprofit governance index score using 990 efile data. 

## Installation

```r
devtools::install_github( 'nonprofit-open-data-collective/governance' )
```

## Usage 

### Step 1: Get Input data 

We assume the user already has the relevant 990 Efile data downloaded. See [Downlaoding Data Vignette](https://nonprofit-open-data-collective.github.io/governance/articles/download-data.html) for instructions on downloading the need 990 efile data.

We will use a subset of a test set that was already created. See `data-raw/01-get-example-data.R`[here](https://github.com/Nonprofit-Open-Data-Collective/governance/blob/main/data-raw/01-get-example-data.R) for details on how this data set was created. 

```r
data("dat_example", package = "governance")

set.seed(57)
keep_rows <- sample(1:nrow(dat_example), 200)
dat_example <- dat_example[keep_rows, ]

```

## Step 2: Get Features Matrix 

Use the `get_features()` function to clean the data and transform it into a features matrix. 

```r
features_example <- get_features(dat_example)
```


## Step 3: Calculate the Scores 

Use the `get_scores()` function to get the governance scores. 

```r
scores_example <- get_scores(features_example)
```

## Citing the Package:  

- Beck, O., & Lecy, J. (2024). Nonprofit governance Package for R. *Zenodo*. https://doi.org/10.5281/zenodo.10781066




