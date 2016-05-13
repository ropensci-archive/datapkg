#' Data-package
#'
#' Load or initiate a \href{http://dataprotocols.org/data-packages}{data package} for
#' reading / writing data and metadata. A data package can be an R package at the same
#' time. The default format for storing data is
#' \href{http://dataprotocols.org/linear-tsv}{linear-tsv} which is the least
#' ambiguous format and natively supported by R via \code{\link{read.table}}
#' or \code{\link[readr:read_tsv]{readr::read_tsv}}.
#'
#' @aliases datapackage
#' @importFrom tools md5sum
#' @param path root directory of the data package
#' @param verbose emits some debugging messages
#' @examples # Create a data package in a dir
#' pkgdir <- tempfile()
#' dir.create(pkgdir)
#' pkg <- data_package(pkgdir)
#'
#' # Show methods
#' print(pkg)
#'
#' # Examples
#' pkg$author("Jerry", "jerry@gmail.com")
#' pkg$resources$add(iris)
#' pkg$sources$add("Fisher, R. A. (1936)")
#'
#' # View json file
#' pkg$json()
#'
#' # Parse data
#' pkg$resources$read("iris")
datapkg_new <- function(path = ".", verbose = TRUE){
  pkg_file <- function(x, exists = TRUE) {
    normalizePath(file.path(path, x), mustWork = exists && !is_url(x))
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
    structure(environment(), class=c("dpkg-contributors", "jeroen", "environment"))
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
    structure(environment(), class=c("datapkg-sources", "jeroen", "environment"))
  }

  # Resources object
  pkg_resources <- function(){
    find <- function(name = "", folder = NULL){
      data <- Filter(function(x){
        res_path <- paste0("", x$path)
        res_name <- paste0("", x$name)
        if(length(folder) && !(grepl(paste0("^", folder, "/"), res_path)))
          return(FALSE)
        grepl(name, res_name, fixed = TRUE)
      }, pkg_read()$resources)
      for(i in seq_along(data)){
        data[[i]]$read = function(){
          target <- data[[i]]
          read_data_package(pkg_file(target$path), dialect = target$dialect, hash = target$hash, target$schema)
        }
      }
      jsonlite:::simplifyDataFrame(data, c("name", "path", "format", "read"), flatten = FALSE, simplifyMatrix = FALSE)
    }
    info <- function(name){
      data <- Filter(function(x){
        (x$name == name)
      }, pkg_read()$resources)
      if(!length(data))
        stop("Resource not found: ", name)
      data[[1]]
    }
    add <- function(data, name, folder = "data", format = "csv"){
      stopifnot(is.data.frame(data))
      if(missing(name))
        name <- deparse(substitute(data))
      format <- match.arg(format)
      if(nrow(find(name)))
        stop("Resource with name '", name, "' already exists.")
      file_name <- paste(name, format, sep = ".")
      file_path <- file.path(folder, file_name)
      abs_path <- pkg_file(file_path, exists = FALSE)
      dir.create(pkg_file(folder, exists = FALSE), showWarnings = FALSE)
      write_data <- prepare_data(data)
      readr::write_delim(write_data, abs_path, delim = ";", col_names = TRUE)
      hash <- tools::md5sum(abs_path)
      rec <- base::list(
        name = name,
        path = file_path,
        format = "tsv",
        hash = unname(hash),
        schema = make_schema(data),
        dialect = base::list(
          header = TRUE,
          delimiter = ";"
        )
      )
      pkg_update(resources = c(pkg_read()$resources, base::list(rec)))
      find()
    }
    remove <- function(name, folder = "data"){
      stopifnot(is_string(name))
      target <- info(name)
      unlink(pkg_file(target$path))
      pkg_update(resources = Filter(function(x){
        (x$name != name)
      }, pkg_read()$resources))
      find()
    }
    read <- function(name){
      target <- info(name)
      data_path <- pkg_file(target$path)
      read_data_package(data_path, dialect = target$dialect, hash = target$hash, target$schema)
    }
    lockEnvironment(environment(), TRUE)
    structure(environment(), class=c("datapkg-resources", "jeroen", "environment"))
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

prepare_data <- function(data){
  for(i in seq_along(data)){
    if(is.logical(data[[i]])){
      out <- ifelse(data[[i]], "true", "false")
      out[is.na(data[[i]])] <- ""
      data[[i]] <- out
    }
  }
  data
}

make_schema <- function(data){
  out <- as.list(rep(NA, length(data)))
  for(i in seq_along(data)){
    out[[i]] <- list(
      name = names(data)[i],
      type = get_type(data[[i]])
    )
  }
  list(fields = out)
}

from_json <- function(path){
  path <- normalizePath(path, mustWork = TRUE)
  jsonlite::fromJSON(readLines(path, warn = FALSE), simplifyVector = FALSE)
}

to_json <- function(x){
  jsonlite::toJSON(x, auto_unbox = TRUE, pretty = TRUE)
}

is_string <- function(x){
  is.character(x) && identical(length(x), 1L)
}

is_url <- function(x){
  grepl("^[a-zA-Z]+://", x)
}


# Implements: http://dataprotocols.org/json-table-schema/#schema
coerse_type <- function(x, type){
  switch(type,
         string = as.character(x),
         number = as.numeric(x),
         integer = as.integer(x),
         boolean = parse_bool(x),
         object = lapply(x, from_json),
         array = lapply(x, from_json),
         date = parse_date(x),
         datetime = parse_datetime(x),
         time = paste_time(x),
         as.character(x)
  )
}

get_type <- function(x){
  if(inherits(x, "Date")) return("date")
  if(inherits(x, "POSIXt")) return("datetime")
  if(is.character(x)) return("string")
  if(is.integer(x)) return("integer")
  if(is.numeric(x)) return("number")
  if(is.logical(x)) return("boolean")
  return("string")
}

parse_bool <- function(x){
  is_true <- (x %in% c("yes", "y", "true", "t", "1"))
  is_false <- (x %in% c("no", "n", "false", "f", "0"))
  is_na <- is.na(x) | (x %in% c("NA", "na", ""))
  is_none <- (!is_true & !is_false & !is_na)
  if(any(is_none))
    stop("Failed to parse boolean values: ", paste(head(x[is_none], 5), collapse = ", "))
  out <- rep(FALSE, length(x))
  out[is_na] <- NA
  out[is_true] <- TRUE
  out
}

parse_date <- function(x){
  as.Date(x)
}

parse_datetime <- function(x){
  as.POSIXct(x)
}

paste_time <- function(x){
  as.POSIXct(x)
}

