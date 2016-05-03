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
#' x$author("Jerry", "jerry@gmail.com")
#' x$resources$add(iris)
#' x$json()
data_package <- function(path = ".", verbose = TRUE){
  pkg_file <- function(x, exists = TRUE) {
    normalizePath(file.path(path, x), mustWork = exists)
  }

  pkg_json <- function(){
    pkg_file("datapackage.json")
  }

  pkg_read <- function(){
    from_json(pkg_json())
  }

  pkg_update <- function(...){
    meta <- pkg_read()
    args <- list(...)
    for(i in seq_along(args)){
      key <- names(args[i])
      meta[[key]] = args[[i]]
    }
    writeLines(to_json(meta), pkg_json())
    return(meta)
  }

  pkg_init <- function(){
    if(file.exists(pkg_file("datapackage.json", FALSE))){
      meta <- pkg_read()
      if(verbose)
        message("Opening existing datapackage: ", meta$name)
    } else {
      writeLines("{}", pkg_file("datapackage.json", FALSE))
      pkg_update(
        name = basename(normalizePath(path)),
        resources = list()
      )
    }
  }

  # Sources object
  pkg_contributors <- function(){
    find <- function(name = "", exact = FALSE){
      data <- Filter(function(x){
        if(isTRUE(exact)){
          return(x$name == name)
        } else {
          grepl(name, x$name, fixed = TRUE)
        }
      }, pkg_read()$contributors)
      jsonlite:::simplifyDataFrame(data, c("name", "email", "web"), flatten = FALSE, simplifyMatrix = FALSE)
    }
    add <- function(name, email, web){
      out <- list(name = name)
      if(!missing(email))
        out$email = email
      if(!missing(web))
        out$web = web
      pkg_update(contributors = c(pkg_read()$contributors, list(out)))
      find()
    }
    remove <- function(name){
      stopifnot(is_string(name))
      all <- find(name, exact = TRUE)
      if(!nrow(all))
        stop("No source found for: ", name)
      pkg_update(contributors = Filter(function(x){
        (x$name != name)
      }, pkg_read()$contributors))
      find()
    }
    lockEnvironment(environment(), TRUE)
    structure(environment(), class=c("jeroen", "environment"))
  }

  # Sources object
  pkg_sources <- function(){
    find <- function(name = "", exact = FALSE){
      data <- Filter(function(x){
        if(isTRUE(exact)){
          return(x$name == name)
        } else {
          grepl(name, x$name, fixed = TRUE)
        }
      }, pkg_read()$sources)
      jsonlite:::simplifyDataFrame(data, c("name", "email", "web"), flatten = FALSE, simplifyMatrix = FALSE)
    }
    add <- function(name, email, web){
      out <- list(name = name)
      if(!missing(email))
        out$email = email
      if(!missing(web))
        out$web = web
      pkg_update(sources = c(pkg_read()$sources, list(out)))
      find()
    }
    remove <- function(name){
      stopifnot(is_string(name))
      all <- find(name, exact = TRUE)
      if(!nrow(all))
        stop("No source found for: ", name)
      pkg_update(sources = Filter(function(x){
        (x$name != name)
      }, pkg_read()$sources))
      find()
    }
    lockEnvironment(environment(), TRUE)
    structure(environment(), class=c("jeroen", "environment"))
  }

  # Resources object
  pkg_resources <- function(){
    find <- function(title = "", folder = NULL){
      data <- Filter(function(x){
        if(length(folder) && !(grepl(paste0("^", folder, "/"), x$path))){
          return(FALSE)
        }
        grepl(title, x$title, fixed = TRUE)
      }, pkg_read()$resources)
      jsonlite:::simplifyDataFrame(data, c("title", "path", "format"), flatten = FALSE, simplifyMatrix = FALSE)
    }
    info <- function(title){
      data <- Filter(function(x){
        (x$title == title)
      }, pkg_read()$resources)
      if(!length(data))
        stop("Resource not found: ", title)
      data[[1]]
    }
    add <- function(data, title, folder = "data", format = "tab"){
      stopifnot(is.data.frame(data))
      if(missing(title))
        title <- deparse(substitute(data))
      format <- match.arg(format)
      if(nrow(find(title)))
        stop("Resource with title '", title, "' already exists.")
      file_name <- paste(title, format, sep = ".")
      file_path <- file.path(folder, file_name)
      abs_path <- pkg_file(file_path, exists = FALSE)
      dir.create(pkg_file(folder, exists = FALSE), showWarnings = FALSE)
      readr::write_tsv(data, abs_path)
      hash <- tools::md5sum(abs_path)
      rec <- base::list(
        title = title,
        path = file_path,
        format = "tsv",
        hash = unname(hash),
        dialect = base::list(
          header = TRUE,
          delimiter = "\t"
        )
      )
      pkg_update(resources = c(pkg_read()$resources, base::list(rec)))
      find()
    }
    remove <- function(title, folder = "data"){
      stopifnot(is_string(title))
      target <- info(title)
      unlink(pkg_file(target$path))
      pkg_update(resources = Filter(function(x){
        (x$title != title)
      }, pkg_read()$resources))
      find()
    }
    read <- function(title, folder = "data"){
      target <- info(title)
      read_data_package(target)
    }
    lockEnvironment(environment(), TRUE)
    structure(environment(), class=c("jeroen", "environment"))
  }

  # Exported methods
  pkg_init()
  self <- local({
    sources <- pkg_sources()
    resources <- pkg_resources()
    contributors <- pkg_contributors()
    name <- function(x){
      if(!missing(x))
        pkg_update(name = x)
      pkg_read()$name
    }
    license <- function(type, url){
      if(!missing(type)){
        if(!missing(url)){
          pkg_update(license = list(
            type = type,
            url = url
          ))
        } else {
          pkg_update(license = type)
        }
      }
      pkg_read()$license
    }
    author <- function(name, email, web){
      if(!missing(name)){
        out <- list(name = name)
        if(!missing(email))
          out$email = email
        if(!missing(web))
          out$web = web
        pkg_update(author = out)
      }
      pkg_read()$author
    }
    description <- function(x){
      if(!missing(x))
        pkg_update(description = x)
      pkg_read()$description
    }
    homepage <- function(x){
      if(!missing(x))
        pkg_update(homepage = x)
      pkg_read()$homepage
    }
    version <- function(x){
      if(!missing(x))
        pkg_update(version = x)
      pkg_read()$version
    }
    json <- function(){
      str <- paste(readLines(pkg_json()), collapse = "\n")
      structure(str, class = "json")
    }
    lockEnvironment(environment(), TRUE)
    structure(environment(), class=c("dpkg", "jeroen", "environment"))
  })
}
