# --- BUILD layoutWidget 0.5.6 LOCALLY (no placeholders) ---

pkg <- "layoutWidget_0.5.6"
unlink(pkg, recursive = TRUE)
dir.create(pkg, recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(pkg, "R"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(pkg, "inst/htmlwidgets"), recursive = TRUE, showWarnings = FALSE)

# DESCRIPTION ----
writeLines(c(
	"Package: layoutWidget",
	"Type: Package",
	"Title: D3 Layout Editor for BUGS/JAGS Dependency Graphs",
	"Version: 0.5.6",
	"Authors@R: c(person('Robert','Horton', role=c('aut','cre'), email='rmhorton@example.com'))",
	"Description: Parse BUGS/JAGS model code into nodes and edges and edit the layout interactively in a D3-based htmlwidget.",
	"License: MIT + file LICENSE",
	"Encoding: UTF-8",
	"LazyData: true",
	"Imports: htmlwidgets, htmltools, jsonlite",
	"Suggests: igraph"
), file.path(pkg, "DESCRIPTION"))

# NAMESPACE ----
writeLines(c(
	"export(layoutWidget)",
	"export(parse_dependencies)",
	"export(example_jags_model)",
	"export(demo_layoutWidget)",
	"import(htmlwidgets)",
	"importFrom(htmltools, htmlDependency)"
), file.path(pkg, "NAMESPACE"))

# R/parse.R ---- (full code, no placeholders)
parse_code <- '
# ---------- Helpers ----------
.strip_comments <- function(model_lines) {
  model_lines <- gsub("#.*$", "", model_lines)
  trimws(model_lines)
}

.extract_model_block <- function(model_lines) {
  txt <- paste(model_lines, collapse = "\\n")
  mstart <- regexpr("\\\\bmodel\\\\s*\\\\{", txt, perl = TRUE)
  if (mstart[1] == -1) stop("No \'model { ... }\' block found.")
  start <- as.integer(mstart) + attr(mstart, "match.length")
  depth <- 1L; i <- start; end_pos <- NA_integer_
  while (i <= nchar(txt)) {
    ch <- substr(txt, i, i)
    if (ch == "{") depth <- depth + 1L
    if (ch == "}") { depth <- depth - 1L; if (depth == 0L) { end_pos <- i; break } }
    i <- i + 1L
  }
  if (is.na(end_pos)) stop("Could not find closing \'}\' for model block.")
  block <- substr(txt, start, end_pos - 1L)
  blines <- unlist(strsplit(block, "\\n", fixed = TRUE))
  blines <- blines[nzchar(trimws(blines))]
  blines
}

.normalize_index <- function(name) gsub("\\\\[[^\\\\]]*\\\\]", "[]", name, perl = TRUE)

.tokenize_symbols <- function(expr) {
  m <- gregexpr("\\\\b[A-Za-z_][A-Za-z0-9_.]*\\\\b(?:\\\\[[^\\\\]]+\\\\])?", expr, perl = TRUE)
  if (length(m) == 0L || m[[1]][1] == -1) return(character(0))
  unique(regmatches(expr, m)[[1]])
}

.is_numeric_like <- function(tok) {
  grepl("^([0-9]+(\\\\.[0-9]*)?|\\\\.[0-9]+)([eE][+-]?[0-9]+)?$", tok)
}

.ignore_set <- c(
  "model","for","in","if","else","T","F","NA","TRUE","FALSE",
  "I","log","log10","exp","sqrt","pow","abs","step","ceil","floor","round","phi",
  "cos","sin","tan","acos","asin","atan","max","min","mean","sd","sum","prod","length",
  # distributions
  "dbern","dbin","dcat","ddirch","ddexp","dgamma","dlnorm","dlogis","dnorm",
  "dpar","dpois","dunif","dweib","dmulti","dmnorm","dmvnorm","dwish","dinvgamma",
  "dhyper","dnbinom","dt","dchisqr","dexp","dbeta",
  # link helpers
  "cloglog","logit","probit","ilogit","equals","inprod"
)

# Combine soft-wrapped lines using a last-character heuristic
.coalesce_lines <- function(model_lines) {
  out <- character(0); buf <- ""
  for (ln in model_lines) {
    s <- trimws(ln); if (!nzchar(s)) next
    buf <- paste0(buf, " ", s)
    last_char <- if (nzchar(s)) substr(s, nchar(s), nchar(s)) else ""
    if (last_char %in% c(",", "+", "-", "*", "/", "^", "=")) next
    out <- c(out, trimws(buf)); buf <- ""
  }
  if (nzchar(trimws(buf))) out <- c(out, trimws(buf))
  out
}

# ---------- Main ----------
#\' Parse BUGS/JAGS code into nodes and edges
#\' @param model_text Character string containing BUGS/JAGS code
#\' @return A list with elements `nodes` (data.frame) and `edges` (data.frame)
#\' @export
parse_dependencies <- function(model_text) {
  raw <- unlist(strsplit(model_text, "\\n", fixed = TRUE))
  raw <- .strip_comments(raw)
  model_lines <- .extract_model_block(raw)
  model_lines <- .coalesce_lines(model_lines)

  from_vec <- character(); to_vec <- character()
  for (line in model_lines) {
    LHS <- RHS <- NULL
    if (grepl("~", line, fixed = TRUE)) {
      parts <- strsplit(line, "~", fixed = TRUE)[[1]]
      if (length(parts) >= 2) { LHS <- trimws(parts[1]); RHS <- paste(parts[-1], collapse = "~") }
    }
    if (is.null(LHS) && grepl("<-", line, fixed = TRUE)) {
      parts <- strsplit(line, "<-", fixed = TRUE)[[1]]
      if (length(parts) >= 2) { LHS <- trimws(parts[1]); RHS <- paste(parts[-1], collapse = "<-") }
    }
    if (is.null(LHS) || is.null(RHS)) next

    LHS <- sub("\\\\s+.*$", "", LHS)
    LHSn <- .normalize_index(LHS)

    toks <- .tokenize_symbols(RHS)
    parents <- toks[!toks %in% .ignore_set & !.is_numeric_like(toks)]
    parents <- parents[parents != LHS]
    parents <- unique(.normalize_index(parents))

    if (length(parents)) {
      from_vec <- c(from_vec, parents)
      to_vec   <- c(to_vec, rep(LHSn, length(parents)))
    }
  }

  edges <- unique(data.frame(from = from_vec, to = to_vec, stringsAsFactors = FALSE))
  nodes <- data.frame(name = sort(unique(c(edges$from, edges$to))), stringsAsFactors = FALSE)
  list(nodes = nodes, edges = edges)
}

#\' Example JAGS model string
#\' @return Character scalar
#\' @export
example_jags_model <- function() {
  paste(c(
    "# Model",
    "model{",
    "  # Data analysis",
    "  for (tmt in 1:2){                                      # Treatments tmt=1 (Seretide), tmt=2 (Fluticasone)",
    "    for (i in 1:4){                                      # There are 4 non-absorbing health states",
    "      r[tmt,i,1:5] ~ dmulti(pi[tmt,i,1:5], n[tmt,i])    # Multinomial DATA",
    "      pi[tmt,i,1:5] ~ ddirch(prior[tmt,i,1:5])          # Dirichlet prior for probs.",
    "    }",
    "  }",
    "  # Calculating summaries from a decision model",
    "  for (tmt in 1:2){",
    "    for (i in 1:5){ s[tmt,i,1] <- equals(i,1) }         # Initialise starting state",
    "    for (i in 1:4){",
    "      for (t in 2:13){",
    "        s[tmt,i,t] <- inprod(s[tmt,1:4,t-1], pi[tmt,1:4,i])  # 12 cycles",
    "      }",
    "      E[tmt,i] <- sum(s[tmt,i,2:13])",
    "    }",
    "    E[tmt,5] <- 12 - sum(E[tmt,1:4])",
    "  }",
    "  for (i in 1:5){",
    "    D[i] <- E[1,i] - E[2,i]",
    "    prob[i] <- step(D[i])",
    "  }",
    "}"
  ), collapse = "\\n")
}

#\' Demo: parse example JAGS and open the layout widget
#\' @export
demo_layoutWidget <- function(width = NULL, height = NULL) {
  pe <- parse_dependencies(example_jags_model())
  layoutWidget(pe$nodes, pe$edges, width = width, height = height)
}
'
writeLines(parse_code, file.path(pkg, "R/parse.R"))

# R/layoutWidget.R ---- (R side passes JSON strings; JS can handle strings or objects)
widget_r <- '
#\' D3 Layout widget (uses {nodes, edges}) with fixed grid spacing = 5
#\' @param nodes data.frame with column `name`
#\' @param edges data.frame with columns `from`,`to`
#\' @export
layoutWidget <- function(nodes, edges, width = NULL, height = NULL, elementId = NULL) {
  stopifnot(is.data.frame(nodes), is.data.frame(edges))
  if (!"name" %in% names(nodes)) stop("`nodes` must have a `name` column")
  if (!all(c("from","to") %in% names(edges))) stop("`edges` must have `from` and `to` columns")

  nodes$name <- as.character(nodes$name)
  edges$from <- as.character(edges$from)
  edges$to   <- as.character(edges$to)

  x <- list(
    nodes_json = jsonlite::toJSON(nodes, dataframe = "rows", auto_unbox = TRUE),
    edges_json = jsonlite::toJSON(edges, dataframe = "rows", auto_unbox = TRUE)
  )

  deps <- list(
    htmltools::htmlDependency(
      name = "d3",
      version = "7",
      src = c(href = "https://d3js.org"),
      script = "d3.v7.min.js"
    )
  )

  htmlwidgets::createWidget(
    name = "layoutWidget",
    x = x,
    width = width,
    height = height,
    package = "layoutWidget",
    elementId = elementId,
    dependencies = deps
  )
}
'
writeLines(widget_r, file.path(pkg, "R/layoutWidget.R"))

# inst/htmlwidgets/layoutWidget.js ---- (JS with safeParse; no placeholders)
widget_js <- 'HTMLWidgets.widget({
  name: "layoutWidget",
  type: "output",
  factory: function(el, width, height) {
    el.innerHTML = "";
    const root = document.createElement("div");
    root.style.position = "relative";
    root.style.width = "100%";
    root.style.height = "100%";
    el.appendChild(root);

    const sidebar = document.createElement("div");
    sidebar.id = "sidebar";
    sidebar.style.position = "absolute";
    sidebar.style.left = "0"; sidebar.style.top = "0"; sidebar.style.bottom = "0";
    sidebar.style.width = "200px";
    sidebar.style.background = "#f4f4f4";
    sidebar.style.borderRight = "1px solid #ccc";
    sidebar.style.padding = "10px";
    sidebar.style.boxSizing = "border-box";
    sidebar.innerHTML = "<button id=\\"fit\\">Fit to view</button><br><br>" +
                        "<button id=\\"saveSVG\\">Export SVG</button><br>" +
                        "<button id=\\"savePNG\\">Export PNG</button>";
    root.appendChild(sidebar);

    const graph = document.createElement("div");
    graph.id = "graph";
    graph.style.position = "absolute";
    graph.style.left = "200px"; graph.style.top = "0"; graph.style.right = "0"; graph.style.bottom = "0";
    root.appendChild(graph);

    const svg = d3.select(graph).append("svg")
      .attr("width", graph.clientWidth)
      .attr("height", graph.clientHeight);

    svg.append("defs").append("marker")
      .attr("id", "arrow")
      .attr("viewBox", "0 -5 10 10")
      .attr("refX", 18)
      .attr("refY", 0)
      .attr("markerWidth", 6)
      .attr("markerHeight", 6)
      .attr("orient", "auto")
      .append("path")
      .attr("d", "M0,-5L10,0L0,5")
      .attr("fill", "#666");

    const g = svg.append("g");
    const gridSpacing = 5;

    function safeParse(v) {
      if (Array.isArray(v)) return v;
      if (typeof v === "object" && v !== null) return Object.values(v);
      if (typeof v === "string") {
        try { return JSON.parse(v); } catch(e) { return []; }
      }
      return [];
    }

    function build(x) {
      const nodes = safeParse(x.nodes_json);
      const edges = safeParse(x.edges_json).map(e => ({ source: e.from, target: e.to }));
      g.selectAll("*").remove();

      const link = g.selectAll(".link")
        .data(edges).enter().append("line")
        .attr("stroke", "#666").attr("stroke-width", 1.5)
        .attr("marker-end", "url(#arrow)");

      const node = g.selectAll(".node")
        .data(nodes, d => d.name).enter().append("g")
        .attr("class", "node")
        .call(d3.drag().on("drag", dragged));

      node.append("ellipse")
        .attr("rx", 45).attr("ry", 25)
        .attr("fill", "#6fa").attr("stroke", "#333").attr("stroke-width", 1.5);

      node.append("text")
        .attr("text-anchor", "middle").attr("dy", 4)
        .text(d => d.name);

      function dragged(event, d) {
        d.x = Math.round(event.x / gridSpacing) * gridSpacing;
        d.y = Math.round(event.y / gridSpacing) * gridSpacing;
        d3.select(this).attr("transform", `translate(${d.x},${d.y})`);
        updateLinks();
      }
      function updateLinks() {
        link.attr("x1", d => findNode(d.source).x)
            .attr("y1", d => findNode(d.source).y)
            .attr("x2", d => findNode(d.target).x)
            .attr("y2", d => findNode(d.target).y);
      }
      function findNode(name) { return nodes.find(n => n.name === name) || {x:0,y:0}; }

      // simple initial positions
      nodes.forEach((n,i)=>{ n.x=200+i*150; n.y=200+(i%2)*150; });
      node.attr("transform", d => `translate(${d.x},${d.y})`);
      updateLinks();

      // toolbar actions
      const fitBtn = root.querySelector("#fit");
      if (fitBtn) fitBtn.onclick = () => {
        const bounds = g.node().getBBox();
        const W = graph.clientWidth, H = graph.clientHeight;
        const dx = bounds.width || 1, dy = bounds.height || 1;
        const x = bounds.x + dx/2, y = bounds.y + dy/2;
        const scale = 0.9/Math.max(dx/W, dy/H);
        const translate = [W/2 - scale*x, H/2 - scale*y];
        g.transition().duration(750).attr("transform", `translate(${translate}) scale(${scale})`);
      };

      const saveSVG = root.querySelector("#saveSVG");
      if (saveSVG) saveSVG.onclick = () => {
        const serializer = new XMLSerializer();
        let source = serializer.serializeToString(svg.node());
        if(!source.match(/^<svg[^>]+xmlns=\\"http:\\/\\/www\\.w3\\.org\\/2000\\/svg\\"/)) {
          source = source.replace(/^<svg/, \'<svg xmlns="http://www.w3.org/2000/svg"\');
        }
        const url = "data:image/svg+xml;charset=utf-8," + encodeURIComponent(source);
        const a = document.createElement("a"); a.href = url; a.download = "layout.svg"; a.click();
      };

      const savePNG = root.querySelector("#savePNG");
      if (savePNG) savePNG.onclick = () => {
        const serializer = new XMLSerializer();
        const source = serializer.serializeToString(svg.node());
        const img = new Image();
        const canvas = document.createElement("canvas");
        const W = graph.clientWidth, H = graph.clientHeight;
        canvas.width = W; canvas.height = H;
        const ctx = canvas.getContext("2d");
        const svgBlob = new Blob([source], {type:"image/svg+xml;charset=utf-8"});
        const url = URL.createObjectURL(svgBlob);
        img.onload = function(){
          ctx.fillStyle = "#fff"; ctx.fillRect(0,0,W,H);
          ctx.drawImage(img,0,0);
          URL.revokeObjectURL(url);
          const png = canvas.toDataURL("image/png");
          const a = document.createElement("a"); a.href = png; a.download = "layout.png"; a.click();
        };
        img.src = url;
      };
    }

    return {
      renderValue: function(x){ build(x); },
      resize: function(w,h){
        d3.select(graph).select("svg").attr("width", graph.clientWidth).attr("height", graph.clientHeight);
      }
    };
  }
});'
writeLines(widget_js, file.path(pkg, "inst/htmlwidgets/layoutWidget.js"))

# ZIP PACKAGE ----
oldwd <- setwd(pkg)
zipname <- paste0("../", pkg, ".zip")
utils::zip(zipname, list.files(".", recursive = TRUE))
setwd(oldwd)
cat("\nCreated: ", normalizePath(file.path(getwd(), paste0(pkg, ".zip"))), "\n", sep = "")
