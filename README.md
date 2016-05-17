## Data Package in R

Data-packages is a [standard format](http://frictionlessdata.io/data-packages/) for describing meta-data for a collection of datasets. The package `datapkg` provides convenience functions for retrieving and parsing data packages in R. To install in R:

```r
library(devtools)
install_github("ropenscilabs/datapkg")
```

The `datapkg_read` function retrieves and parses data packages from a local or remote sources. A few example packages are available from the [datasets](https://github.com/datasets) and [testsuite-py](https://github.com/frictionlessdata/testsuite-py) repositories. The path needs to point to a directory on disk or git remote or URL containing the root of the data package.

```r
# Load client
library(datapkg)

# Clone via git
cities <- datapkg_read("git://github.com/datasets/world-cities")

# Same data but download over http
cities <- datapkg_read("https://raw.githubusercontent.com/datasets/world-cities/master")
```

The output object contains data and metadata from the data-package, with actual datasets inside the `$data` field.

```r
# Package info
print(cities)

# Open actual data in RStudio Viewer
View(cities$data[[1]])
```

In the case of multiple datasets, each one is either referenced by index or, if available, by name (names are optional in data packages).

```r
# Package with many datasets
euribor <- datapkg_read("https://raw.githubusercontent.com/datasets/euribor/master")

# List datasets in this package
names(euribor$data)
View(euribor$data[[1]])
```

## Status

This package is work in progress. Current open issues:

 - Make `readr` parse `0`/`1` values for booleans: [PR#406](https://github.com/hadley/readr/pull/406)
 - Support "year only" dates (`%Y`). Not sure if this constituates a valid date actually: [PR#407](https://github.com/hadley/readr/pull/407)
 - R and `readr` require to specify which strings are interepreted as missing values. Default are empty string `""` and `NA`. A similar property needs to be defined in the spec.
 - It is unclear what to do with parsing errors, or if the fields in `datapackage.json` does not match the csv data. Examples: [s-and-p-500](https://github.com/datasets/s-and-p-500) and [currency-codes](https://raw.githubusercontent.com/frictionlessdata/testsuite-py/master/datasets/currency-codes)

Features:

 - Writing data packages from data frames. 

[![](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
