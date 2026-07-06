#' Summarize a guarded linear model
#'
#' This method keeps the familiar shape of [summary.lm()] but hides coefficient
#' p-values by default. If the model contains a categorical predictor with more
#' than two levels, printing the summary warns that its coefficient rows are
#' comparisons to a reference level, not tests of whether each category or the
#' overall predictor matters.
#'
#' @param object An `honest_lm` object.
#' @param ... Unused.
#' @param conf.level Confidence level used for stored confidence intervals.
#' @param p_values Optional p-value policy. See `honest_lm()`.
#'
#' @return A `summary_honest_lm` object.
#' @export
summary.honest_lm <- function(object,
                              ...,
                              conf.level = 0.95,
                              p_values = NULL) {
  p_values <- p_values %||% object$honest_lm_p_values %||% "hide"
  p_values <- match.arg(p_values, c("hide", "warn", "show"))

  lm_summary <- NextMethod("summary")
  coef_table <- stats::coef(lm_summary)

  ci <- stats::confint(object, level = conf.level)
  coef_out <- data.frame(
    term = rownames(coef_table),
    estimate = unname(coef_table[, "Estimate"]),
    std.error = unname(coef_table[, "Std. Error"]),
    conf.low = unname(ci[rownames(coef_table), 1]),
    conf.high = unname(ci[rownames(coef_table), 2]),
    stringsAsFactors = FALSE
  )

  if (identical(p_values, "show") || identical(p_values, "warn")) {
    coef_out$statistic <- unname(coef_table[, "t value"])
    coef_out$p.value <- unname(coef_table[, "Pr(>|t|)"])
  }

  factor_info <- honest_factor_info(object)
  notes <- character()
  warnings <- character()

  if (identical(p_values, "hide")) {
    notes <- c(
      notes,
      "Coefficient p-values are hidden by default. Use p_values = \"warn\" or \"show\" if you really want them."
    )
  }

  multilevel_factors <- factor_info[vapply(
    factor_info,
    function(x) x$n_levels > 2,
    logical(1)
  )]

  if (length(multilevel_factors) > 0) {
    notes <- c(
      notes,
      "For post-hoc comparisons among factor levels, consider estimated marginal means, e.g. emmeans::emmeans() and pairs(). See https://rvlenth.github.io/emmeans/."
    )

    warnings <- c(
      warnings,
      vapply(
        multilevel_factors,
        function(x) {
          paste0(
            "`", x$name, "` has ", x$n_levels, " levels. The coefficient rows ",
            "for `", x$name, "` are comparisons to the reference level `",
            x$reference, "`, not tests of whether each category or the overall ",
            "predictor matters."
          )
        },
        character(1)
      )
    )
  }

  aliased <- names(stats::coef(object))[is.na(stats::coef(object))]
  if (length(aliased) > 0) {
    warnings <- c(
      warnings,
      paste0(
        "Some coefficients were not estimable because of exact redundancy: ",
        paste(aliased, collapse = ", "),
        "."
      )
    )
  }

  out <- list(
    call = object$call,
    formula = stats::formula(object),
    nobs = stats::nobs(object),
    df = lm_summary$df,
    r.squared = lm_summary$r.squared,
    adj.r.squared = lm_summary$adj.r.squared,
    sigma = lm_summary$sigma,
    coefficients = coef_out,
    factor_info = factor_info,
    p_values = p_values,
    conf.level = conf.level,
    notes = unique(notes),
    warnings = unique(warnings),
    lm_summary = lm_summary
  )

  class(out) <- "summary_honest_lm"
  out
}

#' @export
print.summary_honest_lm <- function(x, digits = max(3, getOption("digits") - 3), ...) {
  lm_summary <- x$lm_summary

  cat("\nCall:\n")
  print(x$call)

  cat("\nResiduals:\n")
  residual_quantiles <- stats::quantile(
    lm_summary$residuals,
    probs = c(0, 0.25, 0.5, 0.75, 1),
    na.rm = TRUE
  )
  names(residual_quantiles) <- c("Min", "1Q", "Median", "3Q", "Max")
  print(residual_quantiles, digits = digits)

  cat("\nCoefficients:\n")
  coefs <- as.matrix(lm_summary$coefficients)
  if (identical(x$p_values, "hide")) {
    coefs <- coefs[, c("Estimate", "Std. Error", "t value"), drop = FALSE]
    stats::printCoefmat(coefs, digits = digits, signif.stars = FALSE)
  } else {
    stats::printCoefmat(coefs, digits = digits, signif.stars = TRUE)
  }

  if (length(x$factor_info) > 0) {
    cat("\nCategorical predictors:\n")
    for (info in x$factor_info) {
      cat(
        "  ", info$name, ": ",
        info$n_levels, " levels; reference level = ",
        info$reference, "\n",
        sep = ""
      )
    }
  }

  if (length(x$notes) > 0) {
    cat("\nNotes:\n")
    for (note in x$notes) {
      cat("  * ", note, "\n", sep = "")
    }
  }

  cat(
    "\nResidual standard error: ",
    format_number(x$sigma, digits),
    " on ",
    x$df[2],
    " degrees of freedom\n",
    sep = ""
  )

  if (!is.null(lm_summary$na.action)) {
    cat("  (", length(lm_summary$na.action), " observations deleted due to missingness)\n", sep = "")
  }

  cat(
    "Multiple R-squared:  ",
    format_number(x$r.squared, digits),
    ",\tAdjusted R-squared:  ",
    format_number(x$adj.r.squared, digits),
    "\n",
    sep = ""
  )

  if (!is.null(lm_summary$fstatistic)) {
    fstat <- lm_summary$fstatistic
    cat(
      "F-statistic: ",
      format_number(unname(fstat["value"]), digits),
      " on ",
      unname(fstat["numdf"]),
      " and ",
      unname(fstat["dendf"]),
      " DF",
      sep = ""
    )
    if (identical(x$p_values, "hide")) {
      cat("  (model-level p-value hidden)\n")
    } else {
      p_value <- stats::pf(fstat["value"], fstat["numdf"], fstat["dendf"], lower.tail = FALSE)
      cat(",  p-value: ", format.pval(p_value, digits = digits), "\n", sep = "")
    }
  }

  if (length(x$warnings) > 0) {
    utils::flush.console()
    warning(
      paste(x$warnings, collapse = "\n"),
      call. = FALSE
    )
  }

  invisible(x)
}
