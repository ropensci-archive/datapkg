read_data_package <- function(info){

}

is_package <- function(path){
  desc <- normalizePath(file.path(path, "DESCRIPTION"), mustWork = FALSE)
  if(!file.exists(desc))
    return(FALSE)
  info <- try(read.dcf(desc), silent = TRUE)
  if(!is.matrix(info))
    return(FALSE)
  identical(unname(info[,"Type"]), "Package")
}

init_data_package <- function(path, verbose){
  json_path <- normalizePath(file.path(path, "datapackage.json"), mustWork = FALSE)
  if(file.exists(json_path)){
    meta <- from_json(json_path)
    if(verbose)
      message("Opening existing datapackage: ", meta$name)
  } else {
    meta <- list(
      name = basename(normalizePath(path)),
      resources = list()
    )
    json <- to_json(meta)
    writeLines(json, json_path)
    if(is_package(path)){
      if(verbose)
        message("Initiating data-package inside an R package")
      build_ignore <- normalizePath(file.path(path, ".Rbuildignore"), mustWork = FALSE)
      write("^datapackage.json$", build_ignore, append = TRUE)
    }
  }
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
