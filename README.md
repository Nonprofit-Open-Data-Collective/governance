# governance
Package for creating a governance quality index for nonprofits using 990 efile data. 


## Instalation

```
devtools::install_github( 'nonprofit-open-data-collective/governance' )
```

## Usage 

### Step 1: Get Input data 

We assume the user already has the relevant 990 Efile data downloaded. See [Downlaoding Data Vignette](doc/articles/download-data.html) for instructions on downloading the need 990 efile data.

We will use a subset of a test set that was already created. See `data-raw/01-get-example-data.R`[here](https://github.com/Nonprofit-Open-Data-Collective/governance/blob/main/data-raw/01-get-example-data.R) for details on how this data set was created. 

```
data("dat_example", package = "governance")

set.seed(57)
keep_rows <- sample(1:nrow(dat_example), 200)
dat_example <- dat_example[keep_rows, ]

```

## Step 2: Get Features Matrix 

Use the `get_features()` function to clean the data and transform it into a features matrix. 

```
features_example <- get_features(dat_example)
```


## Step 3: Calculate the Scores 

Use the `get_scores()` function to get the governance scores. 

```
scores_example <- get_scores(features_example)
```