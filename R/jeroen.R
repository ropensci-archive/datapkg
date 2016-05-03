# A poor man's oo system.

#' @export
print.jeroen <- function(x, title = paste0("<", is(x), ">"), indent = 0, ...){
  ns <- ls(x)
  if(length(title)) cat(title, "\n")
  lapply(ns, function(fn){
    if(is.function(x[[fn]])){
      cat(format_function(x[[fn]], fn, indent = indent), sep = "\n")
    } else {
      cat(" $", fn, ":\n", sep = "")
      print(x[[fn]], title = NULL, indent = indent + 2L)
    }
  })
  invisible(x)
}

#' @export
`$.jeroen` <- function(x, y){
  if(!exists(y, x, inherits = FALSE)){
    stop("Class '", is(x), "' has no field '", y, "'", call. = FALSE)
  }
  get(y, x, inherits = FALSE)
}

#' @export
`[[.jeroen` <- `$.jeroen`

#' @export
`[.jeroen` <- `$.jeroen`

# Pretty format function headers
format_function <- function(fun, name = deparse(substitute(fun)), indent = 0){
  #header <- sub("\\{$", "", capture.output(fun)[1])
  header <- head(deparse(args(fun)), -1)
  header <- sub("^[ ]*", "   ", header)
  header[1] <- sub("^[ ]*function ?", paste0(" $", name), header[1])
  paste(c(rep(" ", indent), header), collapse = "")
}

# Override default call argument.
stop <- function(..., call. = FALSE){
  base::stop(..., call. = call.)
}

# Override default call argument.
warning <- function(..., call. = FALSE){
  base::warning(..., call. = call.)
}
