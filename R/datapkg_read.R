#' Read/write data-package
#'
#' Read and write data frames to/from 'data-package' format. For reading
#' supported paths are disk, http or git. For writing only disk is supported.
#'
#' @import readr
#' @param path file path or URL to the data package directory
#' @rdname datapackage
#' @name datapackage
#' @aliases datapkg
#' @references \url{http://frictionlessdata.io/data-packages}, \url{https://github.com/datasets}
#' @export
#' @examples # Create new data package
#' pkgdir <- tempfile()
#' datapkg_write(mtcars, path = pkgdir)
#' datapkg_write(iris, path = pkgdir)
#'
#' # Read it back
#' mypkg <- datapkg_read(pkgdir)
#' print(mypkg$data$mtcars)
#'
#' # Clone package with git:
#' cities <- datapkg_read("git://github.com/datasets/world-cities")
#'
#' # Read over http
#' euribor <- datapkg_read("https://raw.githubusercontent.com/datasets/euribor/master")
datapkg_read <- function(path = getwd()){
  root <- sub("datapackage.json$", "", path)
  root <- sub("/$", "", root)
  if(is_git(root)){
    newroot <- tempfile()
    git2r::clone(root, newroot)
    root <- newroot
  }
  json_path <- file.path(root, "datapackage.json")
  json <- if(is_url(root)){
    con <- curl::curl(json_path, "r")
    on.exit(close(con))
    readLines(con, warn = FALSE)
  } else {
    readLines(normalizePath(json_path, mustWork = TRUE), warn = FALSE)
  }
  pkg_info <- jsonlite::fromJSON(json, simplifyVector = TRUE)
  if(is.data.frame(pkg_info$resources))
    class(pkg_info$resources) <- c("datapkg_resources", class(pkg_info$resources))
  if(is.data.frame(pkg_info$sources))
    class(pkg_info$sources) <- c("datapkg_sources", class(pkg_info$sources))
  pkg_info$data <- list(rep(NA, nrow(pkg_info$resources)))
  data_names <- pkg_info$resources$name
  for(i in seq_len(nrow(pkg_info$resources))){
    target <- as.list(pkg_info$resources[i, ])
    pkg_info$data[[i]] <- read_data_package(get_data_path(target, root),
      dialect = as.list(target$dialect), hash = target$hash, target$schema$fields[[1]])
  }
  class(pkg_info$data) <- c("datapkg_data")
  if(length(data_names))
    names(pkg_info$data) <- ifelse(is.na(data_names), "", data_names)
  pkg_info
}

get_data_path <- function(x, root){
  if(length(x$path)){
    data_path <- normalizePath(file.path(root, x$path), mustWork = FALSE)
    if(is_url(data_path) || file.exists(data_path)){
      return(data_path)
    } else {
      if(length(x$url)){
        message("File not found: ", data_path)
        return(x$url)
      } else {
        stop("File not found: ", data_path)
      }
    }
  }
}

is_git <- function(x){
  grepl("^git://", x)
}

is_url <- function(x){
  grepl("^[a-zA-Z]+://", x)
}

read_data_package <- function(path, dialect = list(), hash = NULL, fields = NULL) {
  if(!length(fields))
    return(data.frame())
  col_types <- list()
  for(i in seq_len(nrow(fields)))
    col_types[[i]] <- do.call(make_field, as.list(fields[i,]))
  do.call(parse_data_file, c(list(file = path, col_types = col_types), dialect))
}

make_field <- function(name = "", type = "string", description = "", format = NULL, ...){

  #datapkg prefixes strptime format with 'fmt:'
  if(length(format))
    format <- sub("^fmt:", "", format)
  switch(type,
    string = col_character(),
    number = col_number(),
    integer = col_integer(),
    boolean = col_logical(),
    object = col_character(),
    array = col_character(),
    date = col_date(format),
    datetime = col_datetime(format),
    time = col_time(format),
    col_character()
  )
}

## Defaults from http://dataprotocols.org/csv-dialect/
parse_data_file <- function(file, col_types = NULL, delimiter = ",", doubleQuote = TRUE,
    lineTerminator = "\r\n", quoteChar = '"', escapeChar = "", skipInitialSpace = TRUE,
    header = TRUE, caseSensitiveHeader = FALSE){
  # unused fields: lineTerminator, skipInitialSpace, caseSensitiveHeader
  message("Reading file ", file)
  readr::read_delim(
    col_types = col_types,
    file = file,
    delim = delimiter,
    escape_double = doubleQuote,
    quote = quoteChar,
    escape_backslash = identical(escapeChar, "\\"),
    col_names = header
  )
}

#' @export
print.datapkg_resources <- function(x, ...){
  print_names <- names(x) %in% c("name", "path", "format")
  print(as.data.frame(x)[print_names])
}

#' @export
print.datapkg_data <- function(x, ...){
  for(i in seq_along(x)){
    data_name <- names(x[i])
    if(length(data_name) && !is.na(data_name)){
      cat(" $", data_name, "\n", sep = "")
    } else {
      cat(" [[", i, "]]\n", sep = "")
    }
    mydata <- x[[i]]
    for(j in seq_along(mydata)){
      cat("  [", j, "] ", names(mydata)[j], " (", methods::is(mydata[[j]])[1], ")\n", sep = "")
    }
  }
}
