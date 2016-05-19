#' @rdname datapackage
#' @export
datapkg_write <- function(data, name, path = getwd()){
  if(missing(name))
    name <- deparse(substitute(data))
  stopifnot(is.data.frame(data))
  root <- sub("datapackage.json$", "", path)
  root <- sub("/$", "", root)
  dir.create(file.path(root, "data"), showWarnings = FALSE, recursive = TRUE)
  json_path <- file.path(root, "datapackage.json")
  csv_name <- file.path("data", paste0(name, ".csv"))
  csv_path <- file.path(root, csv_name)
  if(file.exists(csv_path))
    stop("File already exists: ", csv_path, call. = FALSE)
  pkg_info <- if(file.exists(json_path)){
    message("Opening existing ", json_path)
    jsonlite:::fromJSON(json_path, simplifyVector = FALSE)
  } else {
    message("Creating new ", json_path)
    list()
  }
  readr::write_csv(data, csv_path)
  pkg_info$resources <- c(pkg_info$resources,
    list(list(
      path = csv_name,
      name = name
    ))
  )
  json <- jsonlite::toJSON(pkg_info, pretty = TRUE, auto_unbox = TRUE)
  writeLines(json, json_path)
}
