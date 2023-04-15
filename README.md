# shiny-rnaseq-power

[![gh-actions-build-status](https://github.com/royfrancis/shiny-rnaseq-power/workflows/build/badge.svg)](https://github.com/royfrancis/shiny-rnaseq-power/actions?workflow=build) [![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/royfrancis/shiny-rnaseq-power?label=dockerhub)](https://hub.docker.com/repository/docker/royfrancis/shiny-rnaseq-power)

This is an R shiny app to run power analysis for RNA-Seq experiments.

![](preview.png)

## Running the app

### Run online

Click [here](https://rnaseq-power.serve.scilifelab.se/) to access an online instance of this app. This link may not always be active.

### Run using docker

```
docker run --rm -p 3838:3838 royfrancis/shiny-rnaseq-power:v1.1.0
```

The app should be available through a web browser at `http://0.0.0.0:3838`.

### Run in R

Install the following R packages:

```
install.packages(c("BiocManager","shinyBS","pak"),repo="https://cloud.r-project.org/")
pak::pkg_install("rstudio/bslib")
BiocManager::install("RNASeqPower");
```

This repo is not an R package. Clone this repo and execute the R command `shiny::runApp("app.R")` in the root directory.

## Acknowledgements

The underlying calculations are performed by the [RNASeqPower R package](https://bioconductor.org/packages/release/bioc/html/RNASeqPower.html).

Therneau T, Hart S, Kocher J (2021). Calculating samplesSize estimates for RNA Seq studies. R package version 1.32.0. 

***

2023 • Roy Francis
