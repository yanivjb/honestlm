#' Model-predicted means for categorical displays
#'
#' `stat_lm_means()` is a model-aware alternative to using
#' [ggplot2::stat_summary()] for means and intervals. It draws fitted means from
#' a linear model implied by the plot aesthetics instead of raw grouped means.
#' With two categorical predictors, `interaction = FALSE` fits an additive model
#' and `interaction = TRUE` fits the interaction model.
#'
#' @inheritParams ggplot2::layer
#' @param interaction Should the fitted means come from an interaction model? The
#'   default `FALSE` uses an additive model.
#' @param se Should confidence intervals be drawn?
#' @param level Confidence level for intervals.
#' @param na.rm If `FALSE`, missing values are removed with a warning. If
#'   `TRUE`, missing values are silently removed.
#' @param ... Additional arguments passed to the ggplot2 layer.
#'
#' @return A ggplot2 layer.
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' ggplot(mtcars, aes(factor(cyl), mpg, colour = factor(am))) +
#'   geom_point() +
#'   stat_lm_means()
stat_lm_means <- function(mapping = NULL,
                          data = NULL,
                          geom = "pointrange",
                          position = "identity",
                          ...,
                          interaction = FALSE,
                          se = TRUE,
                          level = 0.95,
                          na.rm = FALSE,
                          show.legend = NA,
                          inherit.aes = TRUE) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = StatLmMeans,
    geom = geom,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      interaction = interaction,
      se = se,
      level = level,
      na.rm = na.rm,
      ...
    )
  )
}

StatLmMeans <- ggplot2::ggproto(
  "StatLmMeans",
  ggplot2::Stat,

  required_aes = c("x", "y"),
  extra_params = c("na.rm", "interaction", "se", "level"),

  compute_layer = function(self, data, params, layout) {
    interaction <- params$interaction %||% FALSE
    se <- params$se %||% TRUE
    level <- params$level %||% 0.95

    group_var <- honest_plot_group_var(data)
    needed <- c("x", "y", "PANEL", group_var)
    keep <- stats::complete.cases(data[, needed, drop = FALSE])
    data <- data[keep, , drop = FALSE]

    if (nrow(data) == 0) {
      return(data[0, , drop = FALSE])
    }

    same_partition <- function(a, b) {
      a <- factor(a)
      b <- factor(b)
      nlevels(base::interaction(a, b, drop = TRUE)) == max(nlevels(a), nlevels(b))
    }

    x_levels <- sort(unique(data$x))
    data$.lm_x <- factor(data$x, levels = x_levels)
    x_has_multiple_levels <- length(x_levels) > 1

    panel_levels <- unique(data$PANEL)
    data$.lm_panel <- factor(data$PANEL, levels = panel_levels)
    panel_has_multiple_levels <- nlevels(data$.lm_panel) > 1

    group_has_multiple_levels <- FALSE
    include_group <- FALSE
    if (!is.null(group_var)) {
      data$.lm_group <- factor(data[[group_var]], levels = unique(data[[group_var]]))
      group_has_multiple_levels <- nlevels(data$.lm_group) > 1
      include_group <- group_has_multiple_levels &&
        !same_partition(data$.lm_group, data$.lm_x) &&
        !(panel_has_multiple_levels && same_partition(data$.lm_group, data$.lm_panel))
    }

    include_panel <- panel_has_multiple_levels &&
      !same_partition(data$.lm_panel, data$.lm_x) &&
      !(include_group && same_partition(data$.lm_panel, data$.lm_group))

    terms <- character(0)
    if (x_has_multiple_levels) {
      terms <- c(terms, ".lm_x")
    }
    if (include_group) {
      terms <- c(terms, ".lm_group")
    }
    if (include_panel) {
      terms <- c(terms, ".lm_panel")
    }

    formula <- if (length(terms) == 0) {
      y ~ 1
    } else if (isTRUE(interaction) && include_group && x_has_multiple_levels) {
      stats::as.formula(paste("y ~", paste(c(".lm_x * .lm_group", setdiff(terms, c(".lm_x", ".lm_group"))), collapse = " + ")))
    } else {
      stats::as.formula(paste("y ~", paste(terms, collapse = " + ")))
    }
    fit <- stats::lm(formula, data = data)

    combo_cols <- c("PANEL", "x", group_var)
    combos <- unique(data[, combo_cols, drop = FALSE])
    combos <- combos[order(combos$PANEL, combos$x), , drop = FALSE]

    pred_data <- combos
    pred_data$.lm_x <- factor(pred_data$x, levels = levels(data$.lm_x))
    pred_data$.lm_panel <- factor(pred_data$PANEL, levels = levels(data$.lm_panel))
    if (!is.null(group_var)) {
      pred_data$.lm_group <- factor(pred_data[[group_var]], levels = levels(data$.lm_group))
    }

    group_inputs <- pred_data[, combo_cols, drop = FALSE]
    pred_data$group <- as.integer(do.call(base::interaction, c(group_inputs, drop = TRUE)))

    pred <- stats::predict(fit, newdata = pred_data, se.fit = TRUE)
    pred_data$y <- as.numeric(pred$fit)

    if (isTRUE(se)) {
      crit <- stats::qt((1 + level) / 2, df = stats::df.residual(fit))
      pred_data$se <- as.numeric(pred$se.fit)
      pred_data$ymin <- pred_data$y - crit * pred_data$se
      pred_data$ymax <- pred_data$y + crit * pred_data$se
    }

    aesthetic_cols <- intersect(
      c("colour", "color", "fill", "alpha", "linetype", "linewidth", "size", "shape"),
      names(data)
    )

    for (aesthetic in aesthetic_cols) {
      if (!is.null(group_var) && identical(aesthetic, group_var)) {
        next
      }

      pred_data[[aesthetic]] <- vapply(
        seq_len(nrow(pred_data)),
        function(i) {
          rows <- data$PANEL == pred_data$PANEL[i] & data$x == pred_data$x[i]
          if (!is.null(group_var)) {
            rows <- rows & data[[group_var]] == pred_data[[group_var]][i]
          }
          data[[aesthetic]][which(rows)[1]]
        },
        data[[aesthetic]][1]
      )
    }

    pred_data
  }
)
