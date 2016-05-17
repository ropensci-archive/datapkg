## Data Package in R

Data-packages is a [standard format](http://frictionlessdata.io/data-packages/) for describing meta-data for a collection of datasets. The package `datapkg` provides convenience functions for retrieving and parsing data packages in R. To install in R:

```r
library(devtools)
install_github("ropenscilabs/datapkg")
```

The `datapkg_read` function retrieves and parses data packages from a local or remote sources. A few example packages are available from the [datasets](https://github.com/datasets) and [testsuite-py](https://github.com/frictionlessdata/testsuite-py) repositories. The path needs to point to a directory on disk or git remote or URL containing the root of the data package.

```r
library(datapkg)
cities <- datapkg_read("git://github.com/datasets/world-cities")

# same over http
cities <- datapkg_read("https://raw.githubusercontent.com/datasets/euribor/world-cities")
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
 - R and `readr` require to specify which strings are interepreted as missing values. Default are empty string `""` and `NA`. A similar property needs to be defined in the spec.
 - It is unclear what to do if the number of records in the csv does not match the fields. Examples: [s-and-p-500](https://github.com/datasets/s-and-p-500) and [currency-codes](https://raw.githubusercontent.com/frictionlessdata/testsuite-py/master/datasets/currency-codes)

Features:

 - Writing data packages from data frames. 

[![](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
