# datapackage

[![Build Status](https://travis-ci.org/ropenscilabs/datapackage.svg?branch=master)](https://travis-ci.org/ropenscilabs/datapackage)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ropenscilabs/datapackage?branch=master&svg=true)](https://ci.appveyor.com/project/jeroenooms/datapackage)
[![Coverage Status](https://codecov.io/github/ropenscilabs/datapackage/coverage.svg?branch=master)](https://codecov.io/github/ropenscilabs/datapackage?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/datapackage)](http://cran.r-project.org/package=datapackage)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/datapackage)](http://cran.r-project.org/web/packages/datapackage/index.html)
[![Github Stars](https://img.shields.io/github/stars/ropenscilabs/datapackage.svg?style=social&label=Github)](https://github.com/ropenscilabs/datapackage)

> Convenience functions for reading and writing datasets following the 'data packagist' format.

## Introduction

Data-packages is a [standard format](http://dataprotocols.org/data-packages/) for describing meta-data for a collection of datasets. The R package `datapackage` provides convenience functions for reading and writing data and meta-data in this format. To install in R:

```r
library(devtools)
install_github("ropenscilabs/datapackage")
```

The default behavior is to store datasets in the `data` sub-directory, which also is the standard location for datasets in R packages. Thereby the R package can also be a data-package which formalizes the bundled datasets.

## Hello World

```r
# Create new package in dir
mypkg <- tempfile()
dir.create(mypkg)
test <- data_package(mypkg)

# Set some fields
test$name("My test")
test$license("Public domain")
test$homepage("www.jeroen.nl")
test$description("This is a test package")
test$resources$find()

# Add data
test$resources$add(iris)

# View current json 
test$json()

# Lookup current data
test$resources$find()
test$resources$info("iris")
test$resources$find(folder = "data")
test$resources$find(folder = "nothing")
test$resources$find("iris")
test$resources$find("bla")

# Add more data
test$resources$add(cars)
test$resources$add(mtcars)
test$resources$remove("iris")
test$json()

# Add contributors
test$contributors$find()
test$contributors$add("Jeroen", "jeroenooms@gmail.com", "www.jeroen.nl")
test$contributors$add("Karthik")
test$contributors$remove("Karthik")

# Add sources
test$sources$find()
test$sources$add("NASA", web = "www.nasa.gov")
test$sources$add("blabla", "bla@blabla.com")
test$sources$find("bla")
test$sources$find("bla", exact = TRUE)
test$sources$remove("blabla")

# End result
test$json()
list.files(mypkg, recursive = T)

```

## Introduction

Lorem Ipsum.

[![](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
