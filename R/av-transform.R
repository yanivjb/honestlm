#' Residualize variables for an added-variable plot
#'
#' `av_transform()` creates the two residualized variables used in an
#' added-variable, or partial-regression, plot. It returns the original data with
#' two new columns named from the focal predictor and response, such as
#' `.adjusted_asd_mm` and `.adjusted_prop_hybrid`. These are the focal predictor
#' and response after adjusting for the same variables. The result can be plotted
#' with ordinary ggplot2 layers.
#'
#' @param data A data frame.
#' @param y Response variable. Use an unquoted column name or a single string.
#' @param x Focal numeric predictor. Use an unquoted column name or a single
#'   string.
#' @param adjust Adjustment variables. Use `c(var1, var2)` with unquoted column
#'   names, a single unquoted column name, a character vector, or `NULL`.
#' @param names Optional names of the residualized columns to add. The first name
#'   is used for the residualized focal predictor and the second for the
#'   residualized response. If `NULL`, names are created automatically as
#'   `.adjusted_<x>` and `.adjusted_<y>`.
#'
#' @return A tibble with added residualized columns. Attributes record the
#'   original response, focal predictor, adjustment variables, and residual
#'   formulas used for plot labels.
#' @export
#'
#' @examples
#' av_data <- av_transform(mtcars, y = mpg, x = wt, adjust = c(hp, factor(cyl)))
#'
#' ggplot2::ggplot(av_data, ggplot2::aes(.adjusted_wt, .adjusted_mpg)) +
#'   ggplot2::geom_point() +
#'   ggplot2::geom_smooth(method = "lm") +
#'   av_labs(av_data)
av_transform <- function(data, y, x, adjust = NULL, names = NULL) {
  data <- as.data.frame(data)

  y_name <- av_variable_name(substitute(y), data, "y")
  x_name <- av_variable_name(substitute(x), data, "x")
  adjust_names <- av_adjust_names(substitute(adjust), data)

  if (is.null(names)) {
    names <- paste0(".adjusted_", c(x_name, y_name))
  }
  if (length(names) != 2 || any(is.na(names)) || any(names == "")) {
    stop("`names` must be NULL or a character vector of two non-empty column names.", call. = FALSE)
  }
  if (any(names %in% names(data))) {
    stop("`names` would overwrite existing columns in `data`.", call. = FALSE)
  }
  if (!is.numeric(data[[x_name]])) {
    stop("`x` must be numeric for an added-variable transformation.", call. = FALSE)
  }

  adjust_vars <- if (length(adjust_names) == 0) {
    character(0)
  } else {
    all.vars(stats::reformulate(adjust_names))
  }
  model_vars <- unique(c(y_name, x_name, adjust_vars))
  missing_vars <- setdiff(model_vars, names(data))
  if (length(missing_vars) > 0) {
    stop(
      "These variables are not in `data`: ",
      paste(missing_vars, collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  keep <- stats::complete.cases(data[, model_vars, drop = FALSE])
  out <- tibble::as_tibble(data)
  out[[names[1]]] <- NA_real_
  out[[names[2]]] <- NA_real_

  if (!any(keep)) {
    warning("No complete cases were available for the added-variable transformation.", call. = FALSE)
    return(av_add_attributes(out, y_name, x_name, adjust_names, names))
  }

  model_data <- data[keep, , drop = FALSE]
  adjust_formula <- if (length(adjust_names) == 0) {
    "1"
  } else {
    paste(adjust_names, collapse = " + ")
  }

  y_formula <- stats::as.formula(paste(y_name, "~", adjust_formula))
  x_formula <- stats::as.formula(paste(x_name, "~", adjust_formula))

  out[[names[2]]][keep] <- stats::residuals(stats::lm(y_formula, data = model_data))
  out[[names[1]]][keep] <- stats::residuals(stats::lm(x_formula, data = model_data))

  av_add_attributes(out, y_name, x_name, adjust_names, names)
}

av_variable_name <- function(expr, data, arg) {
  if (is.character(expr) && length(expr) == 1) {
    return(expr)
  }

  value <- try(eval(expr, envir = data, enclos = parent.frame()), silent = TRUE)
  if (is.character(value) && length(value) == 1 && value %in% names(data)) {
    return(value)
  }

  if (is.symbol(expr)) {
    return(as.character(expr))
  }

  stop("`", arg, "` must be an unquoted column name or a single string.", call. = FALSE)
}

av_adjust_names <- function(expr, data) {
  if (identical(expr, NULL)) {
    return(character(0))
  }

  if (is.character(expr)) {
    return(expr)
  }

  if (is.call(expr) && identical(expr[[1]], as.name("c"))) {
    pieces <- as.list(expr)[-1]
    return(vapply(pieces, av_adjust_piece_name, character(1)))
  }

  if (is.symbol(expr)) {
    name <- as.character(expr)
    if (!name %in% names(data)) {
      value <- try(eval(expr, envir = parent.frame()), silent = TRUE)
      if (is.character(value)) {
        return(value)
      }
    }
    return(name)
  }

  if (is.call(expr)) {
    return(deparse(expr, width.cutoff = 500L))
  }

  value <- try(eval(expr, envir = parent.frame()), silent = TRUE)
  if (is.character(value)) {
    return(value)
  }

  stop("`adjust` must be NULL, a column name, `c(...)`, or a character vector.", call. = FALSE)
}

av_adjust_piece_name <- function(piece) {
  if (is.symbol(piece)) {
    as.character(piece)
  } else if (is.character(piece) && length(piece) == 1) {
    piece
  } else if (is.call(piece)) {
    deparse(piece, width.cutoff = 500L)
  } else {
    stop("`adjust` must contain unquoted column names, strings, or model terms.", call. = FALSE)
  }
}

#' Labels for an added-variable plot
#'
#' `av_labs()` returns ggplot2 axis labels that describe the residual models used
#' by [av_transform()].
#'
#' @param data A data frame returned by [av_transform()].
#'
#' @return A ggplot2 labels object.
#' @export
#'
#' @examples
#' av_data <- av_transform(mtcars, y = mpg, x = wt, adjust = c(hp, factor(cyl)))
#'
#' ggplot2::ggplot(av_data, ggplot2::aes(.adjusted_wt, .adjusted_mpg)) +
#'   ggplot2::geom_point() +
#'   av_labs(av_data)
av_labs <- function(data) {
  x_label <- attr(data, "av_x_label", exact = TRUE)
  y_label <- attr(data, "av_y_label", exact = TRUE)

  if (is.null(x_label) || is.null(y_label)) {
    stop("`data` must be returned by `av_transform()`.", call. = FALSE)
  }

  ggplot2::labs(x = x_label, y = y_label)
}

av_add_attributes <- function(data, y, x, adjust, names) {
  adjust_formula <- if (length(adjust) == 0) "1" else paste(adjust, collapse = " + ")
  x_label <- paste0("resid(", x, " ~ ", adjust_formula, ")")
  y_label <- paste0("resid(", y, " ~ ", adjust_formula, ")")

  attr(data, "av_y") <- y
  attr(data, "av_x") <- x
  attr(data, "av_adjust") <- adjust
  attr(data, "av_names") <- names
  attr(data, "av_x_label") <- x_label
  attr(data, "av_y_label") <- y_label
  data
}
