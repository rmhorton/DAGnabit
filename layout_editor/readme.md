# Graph layout editor prototypes

This subtask is to develop a layout editor in client-side Javascript. This app should allow the user to rearrange the node locations, but it is not a general graph editor; for example, there is no need to be able to add nodes or edges, since these will all be specified in the BUGS code.
The editor should export the graph to publication-ready formats (PNG and SVG for now).

# To do

* user-specified fonts (some journals are picky about fonts in figures).
* (?) user control of attributes like line and stroke thickness, since these depend on how big the figure will be (smaller figures may need relatively thicker lines). Or Maybe this is a matter of zooming before exporting.
* (?) Support for decision trees
* Alternative styles (black and white vs color; DoodleBUGS style, etc.)
