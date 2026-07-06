#' Tidy a guarded linear model
#'
#' This method calls broom's ordinary `lm` tidier, removes `p.value` by default,
#' and adds a `contrast_note` column for factor contrast rows.
#'
#' @param x An `honest_lm` object.
#' @param ... Passed to [broom::tidy()].
#' @param p_values Optional p-value policy. See `honest_lm()`.
#'
#' @return A tibble when broom is installed.
#' @importFrom generics tidy
#' @method tidy honest_lm
#' @export
tidy.honest_lm <- function(x, ..., p_values = NULL) {
  if (!requireNamespace("broom", quietly = TRUE)) {
    stop(
      "`tidy.honest_lm()` requires the broom package. ",
      "Install it with install.packages(\"broom\").",
      call. = FALSE
    )
  }

  p_values <- p_values %||% x$honest_lm_p_values %||% "hide"
  p_values <- match.arg(p_values, c("hide", "warn", "show"))

  lm_x <- x
  class(lm_x) <- setdiff(class(lm_x), "honest_lm")
  out <- broom::tidy(lm_x, ...)

  if (identical(p_values, "hide") && "p.value" %in% names(out)) {
    out$p.value <- NULL
  }

  out$contrast_note <- honest_contrast_notes(x, out$term)

  if (identical(p_values, "warn")) {
    notes <- unique(stats::na.omit(out$contrast_note))
    if (length(notes) > 0) {
      warning(
        paste(notes, collapse = "\n"),
        call. = FALSE
      )
    }
  }

  out
}

#' Glance at a guarded linear model
#'
#' This method calls broom's ordinary `lm` glance method and removes the
#' model-level `p.value` by default.
#'
#' @param x An `honest_lm` object.
#' @param ... Passed to [broom::glance()].
#' @param p_values Optional p-value policy. See `honest_lm()`.
#'
#' @return A tibble when broom is installed.
#' @importFrom generics glance
#' @method glance honest_lm
#' @export
glance.honest_lm <- function(x, ..., p_values = NULL) {
  if (!requireNamespace("broom", quietly = TRUE)) {
    stop(
      "`glance.honest_lm()` requires the broom package. ",
      "Install it with install.packages(\"broom\").",
      call. = FALSE
    )
  }

  p_values <- p_values %||% x$honest_lm_p_values %||% "hide"
  p_values <- match.arg(p_values, c("hide", "warn", "show"))

  lm_x <- x
  class(lm_x) <- setdiff(class(lm_x), "honest_lm")
  out <- broom::glance(lm_x, ...)

  if (identical(p_values, "hide")) {
    p_cols <- intersect("p.value", names(out))
    out[p_cols] <- NULL
  }

  out
}
