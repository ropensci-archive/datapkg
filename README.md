# datapackage

[![Build Status](https://travis-ci.org/ropenscilabs/datapackage.svg?branch=master)](https://travis-ci.org/ropenscilabs/datapackage)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ropenscilabs/datapackage?branch=master&svg=true)](https://ci.appveyor.com/project/jeroenooms/datapackage)
[![Coverage Status](https://codecov.io/github/ropenscilabs/datapackage/coverage.svg?branch=master)](https://codecov.io/github/ropenscilabs/datapackage?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/datapackage)](http://cran.r-project.org/package=datapackage)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/datapackage)](http://cran.r-project.org/web/packages/datapackage/index.html)
[![Github Stars](https://img.shields.io/github/stars/ropenscilabs/datapackage.svg?style=social&label=Github)](https://github.com/ropenscilabs/datapackage)

> Convenience functions for readingdatasets following the 'data packagist' format.

## Example

Data-packages is a [standard format](http://frictionlessdata.io/data-packages/) for describing meta-data for a collection of datasets. The package `datapkg` provides convenience functions for retrieving and parsing data packages in R. To install in R:

```r
library(devtools)
install_github("ropenscilabs/datapackage")
```

The `datapkg_read` function retrieves and parses data packages from a local or remote sources. A few example packages are available from the [datasets](https://github.com/datasets) and [testsuite-py](https://github.com/frictionlessdata/testsuite-py) repositories. The path needs to point to a directory on disk or URL containing the root of the data package directory.

```r
library(datapkg)
cities <- datapkg_read("https://raw.githubusercontent.com/datasets/world-cities/master")
```

The output object will contain data and metadata from the data-package. The actual datasets are inside the `$data` field of the list.

```r
# Show package metadat
print(cities)

# Open data in RStudio Viewer
View(cities$data[[1]])
```

In the case of multiple datasets, each one is either referenced by index or by name (if available):

```r
euribor <- datapkg_read("https://raw.githubusercontent.com/datasets/euribor/master")
names(euribor$data)
View(euribor$data[[1]])
```

## Status

Outstanding problems:

 - Make `readr` parse `0`/`1` values for booleans: [PR#406](https://github.com/hadley/readr/pull/406)
 - Support "year only" dates (`%Y`). Not sure if this constituates a valid date actually: [PR#407](https://github.com/hadley/readr/pull/407)
 - R and `readr` require to specify which strings are interepreted as missing values. Default are empty string `""` and `NA`. A similar property needs to be defined in the datapackage spec.
 - It is unclear what to do if the number of records in the csv does not match the fields. Examples: [s-and-p-500](https://github.com/datasets/s-and-p-500) and [currency-codes](https://raw.githubusercontent.com/frictionlessdata/testsuite-py/master/datasets/currency-codes)

Features:

 - Writing data packages from data frames. 

[![](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
