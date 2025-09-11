#' Hello Widget: Simple bar chart
#'
#' @param x A numeric vector of values
#' @export
helloWidget <- function(x) {
	# convert R vector into list (JSON serializable)
	x <- as.list(x)

	htmlwidgets::createWidget(
		name = "helloWidget",
		x = list(values = x),
		width = NULL,
		height = NULL,
		package = "helloWidget"
	)
}


#' Shiny bindings for helloWidget
#'
#' Output and render functions for using helloWidget within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a helloWidget
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name helloWidget-shiny
#'
#' @export
helloWidgetOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'helloWidget', width, height, package = 'helloWidget')
}

#' @rdname helloWidget-shiny
#' @export
renderHelloWidget <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, helloWidgetOutput, env, quoted = TRUE)
}
