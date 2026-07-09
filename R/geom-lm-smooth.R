#' Linear-model smooths with additive slopes by default
#'
#' `geom_lm_smooth()` is a linear-model smoother. For ungrouped plots it draws
#' the ordinary `y ~ x` linear fit. For grouped plots, the default
#' `interaction = FALSE` fits one slope with group offsets (`y ~ x + group`)
#' across the layer, then draws the relevant additive fit in each panel. With
#' `interaction = TRUE`, it delegates to [ggplot2::geom_smooth()] with
#' `method = "lm"` for ordinary separate grouped slopes.
#' @inheritParams ggplot2::geom_smooth
#' @param interaction Should the grouped smooth use separate slopes? The default
#'   `FALSE` draws additive/parallel linear-model smooths.
#'
#' @return A ggplot2 layer.
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) +
#'   geom_point() +
#'   geom_lm_smooth()
geom_lm_smooth <- function(mapping = NULL,
                           data = NULL,
                           ...,
                           interaction = FALSE,
                           se = TRUE,
                           level = 0.95,
                           n = 100,
                           fullrange = FALSE,
                           na.rm = FALSE,
                           show.legend = NA,
                           inherit.aes = TRUE) {
  if (isTRUE(interaction)) {
    return(ggplot2::geom_smooth(
      mapping = mapping,
      data = data,
      method = "lm",
      formula = y ~ x,
      se = se,
      level = level,
      n = n,
      fullrange = fullrange,
      na.rm = na.rm,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      ...
    ))
  }

  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = StatLmSmooth,
    geom = "smooth",
    position = "identity",
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      se = se,
      level = level,
      n = n,
      fullrange = fullrange,
      na.rm = na.rm,
      ...
    )
  )
}

StatLmSmooth <- ggplot2::ggproto(
  "StatLmSmooth",
  ggplot2::Stat,

  required_aes = c("x", "y"),
  extra_params = c("na.rm", "se", "level", "n", "fullrange"),

  compute_layer = function(self, data, params, layout) {
    se <- params$se %||% TRUE
    level <- params$level %||% 0.95
    n <- params$n %||% 100
    fullrange <- params$fullrange %||% FALSE

    keep <- stats::complete.cases(data[, c("x", "y", "group")])
    data <- data[keep, , drop = FALSE]

    if (nrow(data) == 0) {
      return(data[0, , drop = FALSE])
    }

    has_groups <- "group" %in% names(data) && length(unique(data$group)) >= 2

    if (!has_groups) {
      fit <- stats::lm(y ~ x, data = data)

      aesthetic_cols <- intersect(
        c("colour", "color", "fill", "alpha", "linetype", "linewidth", "size"),
        names(data)
      )
      x_global <- range(data$x, na.rm = TRUE)
      panels <- unique(data$PANEL)

      grid <- lapply(panels, function(this_panel) {
        this_data <- data[data$PANEL == this_panel, , drop = FALSE]
        x_range <- if (isTRUE(fullrange)) x_global else range(this_data$x, na.rm = TRUE)

        pred_data <- data.frame(
          x = seq(x_range[1], x_range[2], length.out = n),
          PANEL = this_panel,
          group = -1
        )

        for (aesthetic in aesthetic_cols) {
          pred_data[[aesthetic]] <- this_data[[aesthetic]][1]
        }

        pred_data
      })

      pred_data <- do.call(rbind, grid)
      pred <- stats::predict(fit, newdata = pred_data, se.fit = TRUE)
      pred_data$y <- as.numeric(pred$fit)

      if (isTRUE(se)) {
        crit <- stats::qt((1 + level) / 2, df = stats::df.residual(fit))
        pred_data$se <- as.numeric(pred$se.fit)
        pred_data$ymin <- pred_data$y - crit * pred_data$se
        pred_data$ymax <- pred_data$y + crit * pred_data$se
      }

      return(pred_data)
    }

    data$.lm_group <- factor(data$group)
    fit <- stats::lm(y ~ x + .lm_group, data = data)

    aesthetic_cols <- intersect(
      c("colour", "color", "fill", "alpha", "linetype", "linewidth", "size"),
      names(data)
    )
    x_global <- range(data$x, na.rm = TRUE)
    panel_group_combos <- unique(data[, c("PANEL", "group"), drop = FALSE])

    grid <- lapply(seq_len(nrow(panel_group_combos)), function(i) {
      this_panel <- panel_group_combos$PANEL[i]
      this_group <- panel_group_combos$group[i]
      this_data <- data[data$PANEL == this_panel & data$group == this_group, , drop = FALSE]
      x_range <- if (isTRUE(fullrange)) x_global else range(this_data$x, na.rm = TRUE)

      pred_data <- data.frame(
        x = seq(x_range[1], x_range[2], length.out = n),
        PANEL = this_panel,
        group = this_group
      )
      pred_data$.lm_group <- factor(this_group, levels = levels(data$.lm_group))

      for (aesthetic in aesthetic_cols) {
        pred_data[[aesthetic]] <- this_data[[aesthetic]][1]
      }

      pred_data
    })

    pred_data <- do.call(rbind, grid)
    pred <- stats::predict(fit, newdata = pred_data, se.fit = TRUE)
    pred_data$y <- as.numeric(pred$fit)

    if (isTRUE(se)) {
      crit <- stats::qt((1 + level) / 2, df = stats::df.residual(fit))
      pred_data$se <- as.numeric(pred$se.fit)
      pred_data$ymin <- pred_data$y - crit * pred_data$se
      pred_data$ymax <- pred_data$y + crit * pred_data$se
    }

    pred_data
  }
)
