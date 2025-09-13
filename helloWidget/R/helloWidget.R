#' Hello Widget: Simple bar chart
#'
#' @param x A numeric vector
#' @export
helloWidget <- function(x) {
	x <- as.list(x)

	htmlwidgets::createWidget(
		name = "helloWidget",
		x = list(values = x),
		width = NULL,
		height = NULL,
		package = "helloWidget"
	)
}
