read_data_package <- function(path, dialect = list(), hash = NULL, schema = NULL) {
  stopifnot(file.exists(path))
  if(length(hash)){
    # Verify integrity here
  }
  data <- do.call(read_data, c(file = path, dialect))
  lapply(schema, function(x){
    name <- x$name
    type <- x$type
    if(length(name) && length(type)){
      if(is.null(data[[name]])){
        warning("Field not found in data: ", name)
      } else {
        data[[name]] <- coerse_type(data[[name]], type)
      }
    }
  })
  data
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
  if(is.numeric(x)) return("numeric")
  if(is.logical(x)) return("boolean")
  return("character")
}

parse_bool <- function(x){
  is_true <- (x %in% c("yes", "y", "true", "t", "1"))
  is_false <- (x %in% c("no", "n", "false", "f", "0"))
  is_none <- (!is_true & !is_false)
  if(any(is_none))
    stop("Failed to parse boolean values: ", paste(head(x[is_none], 5), collapse = ", "))
  out <- rep(FALSE, length(x))
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
