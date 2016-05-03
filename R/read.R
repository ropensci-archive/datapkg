read_data_package <- function(path, format = "csv", dialect = list(), hash = NULL) {
  stopifnot(file.exists(path))
  if(length(hash)){
    if(grepl("^[a-z]+ ", hash)){
      # Oth
    } else {

    }
  }



}
