#' Read / write data packages
#'
#' Read and write data frames using the standard data packagist format.
#'
#' @param df a data frame
#' @param which format to use for storing data
#' @export
#' @rdname data_package
#' @aliases datapackage
#' @importFrom jsonlite toJSON
#' @importFrom readr write_csv
#' @examples # Write example data
#' pkgdir <- tempfile()
#' dir.create(pkgdir)
#' data(diamonds, package = "ggplot2")
#' pkg <- write_data_package(diamonds, pkgdir)
#'
#' # What it looks like
#' list.files(pkgdir)
#' cat(readLines(pkg), sep = "\n")
#'
#' # Read it back
#' #mydata <- read_data_package(pkgdir)
#' #all.equal(ggplot2::diamonds, mydata)
write_data_package <- function(df, path = ".", format = "csv"){
  stopifnot(is.data.frame(df))
  format <- match.arg(format)
  data_name <- deparse(substitute(df))
  file_name <- paste(data_name, format, sep = ".")
  field_names <- names(df)
  field_types <- vapply(df, get_type, character(1), USE.NAMES = FALSE)
  meta <- list(
    name = data_name,
    resources = list(
      path = file_name,
      schema = list(
        fields = data.frame(
          name = field_names,
          type = field_types,
          stringsAsFactors = FALSE
        )
      )
    )
  )

  # Write the data to disk
  switch(format,
    csv = readr::write_csv(df, file.path(path, file_name)),
    stop("Unknown format: ", format)
  )

  # Write the meta file
  json <- jsonlite::toJSON(meta, auto_unbox = TRUE, pretty = TRUE)
  pkg_file <- file.path(path, "datapackage.json")
  writeLines(json, pkg_file)
  return(pkg_file)
}

#' @rdname data_package
#' @importFrom jsonlite fromJSON
#' @export
read_data_package <- function(path = "."){
  file_path <- normalizePath(file.path(path, "datapackage.json"), mustWork = TRUE)
  meta <- jsonlite::fromJSON(readLines(file_path))


}

get_type <- function(x){
  if(inherits(x, "Date")){
    return("date")
  } else if(inherits(x, "POSIXt")){
    return("timestamp")
  } else if(is.integer(x)){
    return("integer")
  } else if(is.numeric(x)){
    return("numeirc")
  } else {
    return("string")
  }
}
