check_vector_value_missing <- function(vector, value, column_name, substituted_data) {
  if (!length(value) || !length(vector))
    return(TRUE)
  missing <- any(is.na(value))
  value <- value[!is.na(value)]

  if (!missing && any(is.na(vector)))
    check_stop("column ", column_name, " in ", substituted_data, " cannot include missing values")

  if (!length(value)) {
    if (!all(is.na(vector)))
      check_stop("column ", column_name, " in ", substituted_data, " can only include missing values")
    return(TRUE)
  }
  value
}

check_vector_value <- function(vector, value, column_name, substituted_data)
  UseMethod("check_vector_value")

check_vector_value.default <- function(vector, value, column_name, substituted_data) {
  if (length(value) == 2) {
    range <- range(vector, na.rm = TRUE)
    value <- sort(value)
    if (range[1] < value[1] || range[2] > value[2])
      check_stop("the values in column ", column_name, " in ", substituted_data, " must lie between ", value[1], " and ", value[2])
    return(TRUE)
  }
  if (!all(vector %in% value))
    check_stop_set(value, column_name, substituted_data)
  TRUE
}

check_vector_value.logical <- function(vector, value, column_name, substituted_data) {
  value <- unique(value)
  if (length(value) == 2)
    return(TRUE)
  if (!all(vector == value))
    check_stop("column ", column_name, " in ", substituted_data, " can only include ",
              value, " values")
  TRUE
}

check_vector_value.character <- function(vector, value, column_name, substituted_data) {
  if (length(value) == 2) {
    if (!all(grepl(value[1], vector, perl = TRUE) & grepl(value[2], vector, perl = TRUE)))
      check_stop("column ", column_name, " in ", substituted_data, " contains strings that do not match both regular expressions ", punctuate(sort(value), qualifier = "and"))
    return(TRUE)
  }
  regexp <- paste0("(", paste(value, collapse = ")|(") , ")")
  if (!all(grepl(regexp, vector, perl = TRUE)))
    check_stop_set(value, column_name, substituted_data)
  TRUE
}

check_vector_value.factor <- function(vector, value, column_name, substituted_data) {
  if (length(value) == 2) {
    if (!all(as.character(value) %in% levels(vector)))
      check_stop("column ", column_name, " in ", substituted_data, " lacks factor levels ", punctuate(sort(as.character(value)), qualifier = "and"))
    return(TRUE)
  }
  if (!identical(levels(value), levels(vector)))
    check_stop_set(value, column_name, substituted_data)
  TRUE
}