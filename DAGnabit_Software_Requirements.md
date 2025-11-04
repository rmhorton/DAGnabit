# DAGnabit Package — Software Requirements Specification (SRS)

## 1. Introduction

The **DAGnabit** package is an R package designed to help WinBUGS and JAGS users produce clean, publication-quality DAG (Directed Acyclic Graph) diagrams from their model code. The package wraps an existing D3-based HTML/JavaScript app that allows manual positioning of graph nodes. DAGnabit integrates with a WinBUGS dependency parser written in R that provides tables of nodes and edges representing the model structure.

The HTML app provides an interactive DAG layout editor where users can drag nodes and arrange the graph as desired. Once satisfied, the user can export the layout as coordinates (either to a file or copied to the clipboard), a PNG image, or an SVG file for documentation. When coordinates are supplied, the same widget can display the graph in a static, non-editable form—eliminating the need for a separate static-rendering function.

The package runs in standalone mode and does not require Shiny. Shiny integration may be added as a future enhancement.

---

## 2. Functional Overview

### 2.1 Package Goals

* Provide an R htmlwidget wrapper for the existing D3 DAG layout editor.
* Support both interactive and static display modes.
* Enable exporting and reusing layout coordinates for documentation.
* Integrate seamlessly with WinBUGS model parsing output.

### 2.2 Non-Goals

* No topology editing (no adding/removing nodes or edges).
* No modification of plate contents (plate membership is fixed by the WinBUGS parser).
* No heavy GUI features beyond node and plate dragging, zooming, and export.

---

## 3. Core Components

### 3.1 Data Structures

* **Nodes Table:** `data.frame(id, label, type, plate)`
  Each node has an optional `plate` value indicating its membership in a plate.
* **Edges Table:** `data.frame(from, to)`
* **Coordinates:** a separate data structure containing node and plate coordinates, typically stored and exchanged as JSON (same format used by `readLayout()` and `writeLayout()`).

### 3.2 Main Functions

#### `dagLayoutEditor()`

Creates the D3-based htmlwidget for interactive DAG editing or static display.

**Usage:**

```r
structure <- parseBugsModel("model.txt")
dagLayoutEditor(
  structure$nodes,
  structure$edges,
  coords = NULL,
  editable = TRUE
)
```

**Arguments:**

* `nodes`, `edges`: graph elements.
* `coords`: optional coordinate data (JSON-like list or file) specifying node and plate positions.
* `editable`: if `FALSE`, disables dragging (static display mode). If `TRUE`, allows node and plate repositioning.
* `width`, `height`: widget dimensions.

**Behavior:**

* If `editable = TRUE`, an **Export ▾** control is always shown.
* If `editable = FALSE`, coordinates must be supplied to fix node and plate positions.

#### `readLayout()` / `writeLayout()`

Simplify loading and saving coordinate JSON files. These functions define the canonical JSON structure used for coordinate import and export by the widget.

---

## 4. User Workflows

### 4.1 Standalone Workflow

1. Parse WinBUGS model:

   ```r
   structure <- parseBugsModel("model.txt")
   ```
2. Launch editor:

   ```r
   dagLayoutEditor(structure$nodes, structure$edges, editable = TRUE)
   ```
3. Adjust node and plate positions with mouse.
4. Use **Export ▾** to download PNG, SVG, or coordinates (JSON file) or to copy coordinates to the clipboard.
5. Reuse layout later:

   ```r
   coords <- readLayout("layout.json")
   dagLayoutEditor(structure$nodes, structure$edges, coords = coords, editable = FALSE)
   ```

---

## 5. Widget Design

### 5.1 Modes

| Mode         | Editable | Export Control                                            | Communication                   | Use Case                   |
| ------------ | -------- | --------------------------------------------------------- | ------------------------------- | -------------------------- |
| Standalone   | ✅        | Always shown (PNG/SVG/Coords to File/Coords to Clipboard) | File download or clipboard copy | Offline layout editing     |
| Display-only | ❌        | None                                                      | None                            | Embedding or documentation |

### 5.2 Export Control

* Single **Export ▾** dropdown offering:

  * **PNG** — downloads a raster image of the current layout.
  * **SVG** — downloads a vector graphic of the layout.
  * **Coordinates to File** — downloads a `.json` file with node and plate coordinates (same structure as `writeLayout()`).
  * **Coordinates to Clipboard** — copies the same JSON structure directly to the clipboard.
* Always visible when `editable = TRUE`.
* Triggers client-side D3-based rendering/export.

### 5.3 Visual Conventions

* **Node shapes/colors:** indicate type (stochastic, deterministic, data).
* **Edges:** directional arrows drawn with D3 lines.
* **Plates:** drawn as translucent rounded rectangles automatically sized to fit their component nodes.
* Plates cannot be edited directly, but their bounding boxes adjust automatically as contained nodes are moved.
* **Zoom/pan:** mouse and touch support.
* **Snap-to-grid:** already implemented in the HTML app and always available.

---

## 6. Static Display

Static graphs are displayed by calling `dagLayoutEditor()` with `editable = FALSE` and providing saved coordinates. No separate `dagRenderStatic()` function is required.

---

## 7. Dependencies

* **htmlwidgets** for R–JavaScript interface.
* **D3.js** for graph drawing and interactivity.
* **jsonlite** for coordinate import/export.

---

## 8. Nonfunctional Requirements

* Must operate offline in RStudio Viewer or any modern browser.
* Layout exports must be deterministic and reproducible.
* Must support R ≥ 4.1.
* License: MIT.

---

## 9. Future Enhancements (post v1.0)

* **Shiny Integration:** Add a `launchDagEditor()` function enabling a minimal Shiny app that embeds the D3 widget. The app would support real-time coordinate updates through `Shiny.setInputValue()` and a Save Layout button for direct export to R or JSON.
* Theme customization options.

---

## Appendix — Development Plan for Codex

Each minor version below is intended to be completed in a **single Codex session**.

### Version 0.1 — D3 HTMLWidget Wrapper

**Goal:** Wrap the existing D3 layout editor in an R htmlwidget.

**Codex prompt:**

```
You are implementing version 0.1 of the DAGnabit R package. Wrap the existing D3-based HTML app in an htmlwidget named dagLayoutEditor. The widget must accept nodes and edges from R, allow interactive dragging when editable=TRUE, and include a single Export ▾ menu offering PNG, SVG, Coordinates to File (JSON), and Coordinates to Clipboard. If editable=FALSE, coordinates must be supplied to fix node and plate positions. Do not add Shiny code yet.
```

### Version 0.2 — File I/O Helpers

**Goal:** Implement `readLayout()` and `writeLayout()` helpers for coordinate files.

**Codex prompt:**

```
You are implementing version 0.2 of the DAGnabit package. Add functions readLayout() and writeLayout() to handle JSON coordinate files. These should load or save node and plate coordinate data without merging it into the nodes table. The JSON structure must match that used for export by the dagLayoutEditor widget.
```

### Version 0.3 — Documentation and Examples

**Goal:** Provide full documentation, vignettes, and example WinBUGS models.

**Codex prompt:**

```
You are implementing version 0.3 of DAGnabit. Write Roxygen2 documentation for all functions, add vignettes showing standalone workflows, and include example model data parsed from WinBUGS. Ensure that the documentation reflects that all graphs are rendered using D3, plate membership is fixed, plates auto-resize to contain their nodes, snap-to-grid is already included, and static display is achieved with editable=FALSE.
```

---

**End of Updated SRS Document**
