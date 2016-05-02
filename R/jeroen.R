#' @export
`$.jeroen` <- function(x, y){
  if(!exists(y, x, inherits = FALSE)){
    stop("object has no field '", y, "'")
  }
  get(y, x, inherits = FALSE)
}

#' @export
`[[.jeroen` <- `$.jeroen`

#' @export
`[.jeroen` <- `$.jeroen`

#' @export
names.jeroen <- function(x, ...){
  ls(x, ...)
}

#' @export
print.jeroen <- function(x, ...){
  str(as.list(x))
}
