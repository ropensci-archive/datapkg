# datapackage

[![Build Status](https://travis-ci.org/ropensci/datapackage.svg?branch=master)](https://travis-ci.org/ropensci/datapackage)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ropensci/datapackage?branch=master&svg=true)](https://ci.appveyor.com/project/jeroenooms/datapackage)
[![Coverage Status](https://codecov.io/github/ropensci/datapackage/coverage.svg?branch=master)](https://codecov.io/github/ropensci/datapackage?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/datapackage)](http://cran.r-project.org/package=datapackage)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/datapackage)](http://cran.r-project.org/web/packages/datapackage/index.html)
[![Github Stars](https://img.shields.io/github/stars/ropensci/datapackage.svg?style=social&label=Github)](https://github.com/ropensci/datapackage)

> Convenience functions for reading and writing datasets following the 'data packagist' format.

Additional resources:

 - http://dataprotocols.org/data-packages/

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
