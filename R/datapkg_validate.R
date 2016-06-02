#' @export
#' @rdname datapackage
datapkg_validate <- function(path = getwd()){
  root <- sub("datapackage.json$", "", path)
  root <- sub("/$", "", root)
  json_path <- file.path(root, "datapackage.json")
  schema_path <- system.file("tabular-data-package.json", package = "datapkg")
  json <- paste(readLines(json_path), collapse = "\n")
  schema <- paste(readLines(schema_path), collapse = "\n")
  jsonvalidate::json_validate(json, schema, verbose =TRUE, greedy = TRUE)
}
