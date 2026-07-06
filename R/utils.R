honest_factor_info <- function(model) {
  mf <- stats::model.frame(model)
  if (ncol(mf) == 0) {
    return(list())
  }

  response <- as.character(stats::formula(model)[[2]])
  predictors <- setdiff(names(mf), response)

  factor_vars <- predictors[vapply(
    mf[predictors],
    function(x) is.factor(x) || is.character(x),
    logical(1)
  )]

  stats::setNames(
    lapply(factor_vars, function(var) {
      x <- mf[[var]]
      if (!is.factor(x)) {
        x <- factor(x)
      }

      list(
        name = var,
        n_levels = nlevels(x),
        levels = levels(x),
        reference = levels(x)[1]
      )
    }),
    factor_vars
  )
}

honest_contrast_notes <- function(model, terms) {
  factor_info <- honest_factor_info(model)
  notes <- rep(NA_character_, length(terms))

  if (length(factor_info) == 0) {
    return(notes)
  }

  for (info in factor_info) {
    term_matches <- startsWith(terms, info$name) & terms != info$name
    if (!any(term_matches)) {
      next
    }

    if (info$n_levels > 2) {
      notes[term_matches] <- paste0(
        "comparison to reference level `",
        info$reference,
        "`; not a test of whether `",
        info$name,
        "` matters overall"
      )
    } else {
      notes[term_matches] <- paste0(
        "comparison to reference level `",
        info$reference,
        "`"
      )
    }
  }

  notes
}

honest_plot_group_var <- function(data) {
  candidates <- intersect(
    c("colour", "color", "fill", "linetype", "shape"),
    names(data)
  )

  candidates <- candidates[vapply(
    data[candidates],
    function(x) length(unique(x[!is.na(x)])) > 1,
    logical(1)
  )]

  if (length(candidates) == 0) {
    return(NULL)
  }

  candidates[1]
}

format_number <- function(x, digits) {
  format(signif(x, digits), trim = TRUE)
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
