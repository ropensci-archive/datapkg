read_data_package <- function(path, dialect = list(), hash = NULL) {
  stopifnot(file.exists(path))
  if(length(hash)){
    # Verify integrity here
  }
  do.call(read_data, c(file = path, dialect))
}

## Defaults from http://dataprotocols.org/csv-dialect/
read_data <- function(file, delimiter = ",", doubleQuote = TRUE, lineTerminator = "\r\n",
                      quoteChar = '"', escapeChar = "\\", skipInitialSpace = TRUE,
                      header = TRUE, caseSensitiveHeader = FALSE, ...){
  # unused: lineTerminator, skipInitialSpace, caseSensitiveHeader
  readr::read_delim(
    file = file,
    delim = delimiter,
    escape_double = doubleQuote,
    quote = quoteChar,
    escape_backslash = identical(escapeChar, "\\"),
    col_names = header
  )
}
