#' Launch the standalone helloWidget JavaScript demo
#'
#' Opens the included HTML page in your browser. This page requires the
#' \code{helloWidget.js} file from the package.
#'
#' @export
example_js <- function() {
	index <- system.file("examples", "helloWidget-js", "index.html", package = "helloWidget")
	if (index == "") stop("Example not found. Was it installed?")
	utils::browseURL(index)
}
