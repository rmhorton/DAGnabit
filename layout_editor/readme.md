# Graph layout editor prototypes

This subtask is to develop a layout editor in client-side Javascript. This app should allow the user to rearrange the node locations, but it is not a general graph editor; for example, there is no need to be able to add nodes or edges, since these will all be specified in the BUGS code.
The editor should export the graph to publication-ready formats (PNG and SVG for now).

# To (maybe) do

* Better defaults for using auto layout. Currently it is on by default, but it should just be used for the initial layout, then turn off. The user may (?) want to turn it back on to relax and edited layout.
* Plates: the parser should figure out which sub-groups of nodes should be in a plate, and the layout engine should automatically draw plates and put the appropriate nodes within them. The layout editor should support editing these alyoutw with plates. Maybe it would be sufficient to let the user move the nodes, and the plates could be drawn around the nodes (so you can make the plates larger or smaller by dragging the nodes further apart or closer together).
* user-specified fonts (some journals are picky about fonts in figures).
* Alternative styles (black and white vs color; DoodleBUGS style, etc.)
* User-supplied graph (as parsed from BUGS code; edgelists? dataframe? maybe as an igraph object?)
* Wrap (in an htmlWidget?) for use in R.
* (?) user control of attributes like line and stroke thickness, since these depend on how big the figure will be (smaller figures may need relatively thicker lines). Or maybe this is just a matter of appropriate zooming before exporting?
* (?) Support for decision trees (including style, e.g, end nodes as left-pointing triangles).

