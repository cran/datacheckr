check_class_matches <- function(data, parent, join, data_name, parent_name) {
  if (!equal(lapply(data[if_names(join)], class),
                 lapply(parent[join], class)))
     error("join columns in ", data_name, " and ", parent_name, " must have identical classes")
  invisible(data)
}

is_anti_join <- function(x, y, by) {
  by.x <- by
  by.y <- by
  if (!is.null(names(by))) by.x <- names(by)

  x <- x[,by.x,drop = FALSE]
  y <- y[,by.y,drop = FALSE]
  y$..ID <- 1
  x <- merge(x, y, by.x = by.x, by.y = by.y, all.x = TRUE)
  any(is.na(x$..ID))
}

check_referential_integrity <- function(data, parent, join, ignore_nas, data_name, parent_name) {
  data2 <- data[if_names(join)]
  if (ignore_nas)
    data2 <- data2[apply(!is.na(data2),1,any),,drop = FALSE]

  if (is_anti_join(data2, parent, by = join))
    error("many-to-one join between ", data_name, " and ", parent_name, " violates referential integrity")
  invisible(data)
}

#' Check Join
#'
#' Checks that the columns in a data frame form a many-to-one
#' join with correponding columns in parent.
#'
#' By default (\code{join = NULL}) all the columns in parent represent the join key.
#'
#' @inheritParams check_data_frame
#' @param parent A data frame of the parent table.
#' @param join A character vector of the join columns. Use a named character vector
#' if the names of the columns differ.
#' @param referential A flag indicating whether to check for referential integrity.
#' @param extra A flag indicating whether to allow additional matching columns or
#' a character vector of the names to allow.
#' @param ignore_nas A flag indicating whether to ignore missing values or
#' treat them as values.
#' @param parent_name A string of the name of parent.
#'
#' @return Throws an informative error or returns an invisible copy of
#' data.
#' @export
check_join <- function(data, parent, join = NULL, referential = TRUE,
                       extra = "Comments", ignore_nas = FALSE,
                       data_name = substitute(data),
                       parent_name = substitute(parent)) {
  if (!is.character(data_name)) data_name <- deparse(data_name)
  if (!is.character(parent_name)) parent_name <- deparse(parent_name)

  check_flag_internal(referential)
  if (!is_flag(extra) && !is.character(extra)) error("extra must be a flag or character vector")
  check_flag_internal(ignore_nas)
  check_string_internal(data_name)
  check_string_internal(parent_name)

  data <- check_data_frame(data, data_name)
  parent <- check_data_frame(parent, parent_name)

  matches <- intersect(colnames(data), colnames(parent))
  if (is.null(join)) {
    if (!length(matches))
      error(data_name, " and ", parent_name, " must have matching columns")
    join <- matches
  }
  data <- check_cols(data, colnames = if_names(join),
                     exclusive = FALSE, ordered = FALSE, data_name = data_name)
  parent <- check_key(parent, key = join, data_name = parent_name)

  if (is_flag(extra)) {
    if (!extra && length(setdiff(matches, join)))
      error(data_name, " and ", parent_name, " must not have additional matching columns")
  } else { # is.character(extra)
    extra <- intersect(extra, matches)
    if (length(setdiff(matches, join)) && (!length(extra) || length(setdiff(extra, setdiff(matches, join)))))
      error(data_name, " and ", parent_name, " must not have additional matching columns")
  }

  data <- check_class_matches(data, parent, join, data_name, parent_name)
  if (referential)
    data <- check_referential_integrity(data, parent, join, ignore_nas, data_name, parent_name)
  invisible(data)
}
