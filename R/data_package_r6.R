#' Data-package
#'
#' Load or initiate a \href{http://dataprotocols.org/data-packages}{data package} for
#' reading / writing data and metadata. A data package can be an R package at the same
#' time. The default format for storing data is
#' \href{http://dataprotocols.org/linear-tsv}{linear-tsv} which is the least
#' ambiguous format and natively supported by R via \code{\link{read.table}}
#' or \code{\link[readr:read_tsv]{readr::read_tsv}}.
#'
#' @export
#' @aliases datapackage
#' @importFrom readr write_csv write_tsv
#' @importFrom tools md5sum
#' @param path root directory of the data package
#' @param verbose emits some debugging messages
#' @examples x <- data_package(tempdir())
#' x$list_resources()
#' x$add_resource(mtcars)
#' x$add_resource(iris)
#' x$json()
#' x$remove_resource("mtcars")
data_package <- function(path = ".", verbose = TRUE){
  DataPackage$new(path, verbose)
}

#' @importFrom R6 R6Class
DataPackage <- R6Class("DataPackage",
  private = list(
    path = NULL,
    verbose = NULL,
    file = function(x, exists = TRUE){
      normalizePath(file.path(private$path, x), mustWork = exists)
    }
  ),
  public = list(
    initialize = function(path, verbose) {
      private$path <- normalizePath(path, mustWork = TRUE)
      private$verbose <- verbose
      init_data_package(private$path, private$verbose)
    },
    json = function(){
      str <- paste(readLines(private$file("datapackage.json")), collapse = "\n")
      cat(str)
    },
    info = function(...){
      pkg_json <- private$file("datapackage.json")
      meta <- from_json(pkg_json)
      args <- list(...)
      for(i in seq_along(args)){
        key <- names(args[i])
        meta[[key]] = args[[i]]
      }
      writeLines(to_json(meta), pkg_json)
      return(meta)
    },
    list_resources = function(folder = "data"){
      data <- Filter(function(x){
        grepl(paste0("^", folder, "/"), x$path)
      }, self$info()$resources)
      jsonlite:::simplifyDataFrame(data, c("title", "path", "format"), flatten = FALSE, simplifyMatrix = FALSE)
    },
    find_resources = function(title){
      Filter(function(x){
        x$title == title
      }, self$info()$resources)
    },
    get_resource = function(title){
      target <- self$find_resources(title)
      if(!length(target))
        stop("Resource not found: ", title)
      target[[1]]
    },
    add_resource = function(data, title, folder = "data", format = "tab"){
      stopifnot(is.data.frame(data))
      if(missing(title))
        title <- deparse(substitute(data))
      format <- match.arg(format)
      if(length(self$find_resources(title)))
        stop("Resource with title '", title, "' already exists.")
      file_name <- paste(title, format, sep = ".")
      file_path <- file.path(folder, file_name)
      abs_path <- private$file(file_path, exists = FALSE)
      dir.create(private$file(folder, exists = FALSE), showWarnings = FALSE)
      readr::write_tsv(data, abs_path)
      hash <- tools::md5sum(abs_path)
      rec <- list(
        title = title,
        path = file_path,
        format = "tsv",
        hash = unname(hash),
        dialect = list(
          header = TRUE,
          delimiter = "\t"
        )
      )
      self$info(resources = c(self$info()$resources, list(rec)))
      self$list_resources()
    },
    remove_resource = function(title, folder = "data"){
      stopifnot(is_string(title))
      target <- self$get_resource(title)
      unlink(private$file(target$path))
      self$info(resources = Filter(function(x){
        (x$title != title)
      }, self$info()$resources))
      self$list_resources()
    },
    read_resource = function(title, folder = "data"){
      target <- self$get_resource(title)
      read_data_package(target)
    }
  )
)
