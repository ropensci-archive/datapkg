# datapackage

[![Build Status](https://travis-ci.org/ropensci/datapackage.svg?branch=master)](https://travis-ci.org/ropensci/datapackage)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ropensci/datapackage?branch=master&svg=true)](https://ci.appveyor.com/project/jeroenooms/datapackage)
[![Coverage Status](https://codecov.io/github/ropensci/datapackage/coverage.svg?branch=master)](https://codecov.io/github/ropensci/datapackage?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/datapackage)](http://cran.r-project.org/package=datapackage)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/datapackage)](http://cran.r-project.org/web/packages/datapackage/index.html)
[![Github Stars](https://img.shields.io/github/stars/ropensci/datapackage.svg?style=social&label=Github)](https://github.com/ropensci/datapackage)

> Convenience functions for reading and writing datasets following the 'data packagist' format.

## Introduction

Data-packages is a [standard format](http://dataprotocols.org/data-packages/) for describing meta-data for a collection of datasets. The R package `datapackage` provides convenience functions for reading and writing data and meta-data in this format. 

The default behavior is to store datasets in the `data` sub-directory, which also is the standard location for datasets in R packages. Thereby the R package can also be a data-package which formalizes the bundled datasets.

## Hello World

```r
# Write example data
pkgdir <- dir.create(tempfile())
write_data_package(ggplot2::diamonds, pkgdir)

# What it looks like
list.files(pkgdir)
cat(readLines(file.path(pkgdir, "datapackage.json")))

# Read it back
mydata <- read_data_package(pkgdir)
all.equal(ggplot2::diamonds, mydata)
```

## Introduction

Lorem Ipsum.

[![](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
