# DAGnabit

## Student Project: Develop an R package for generating Directed Acyclic Graph diagrams from BUGS code.

The ability to visualize graphs is widely useful:

* Applications of [graphical models](https://en.wikipedia.org/wiki/Graphical_model)
	- [Gene regulatory networks](https://en.wikipedia.org/wiki/Gene_regulatory_network)
	- [Causal models](https://en.wikipedia.org/wiki/Causal_model)
	- [Bayesian Belief Networks](https://en.wikipedia.org/wiki/Bayesian_network)
	- [Decision analysis](https://en.wikipedia.org/wiki/Decision_analysis)
  - Probabilistic Bayesian modeling (e.g., with BUGS).
	
The BUGS programming language was developed to develop MCMC models that can be solved with Gibbs sampling.
Any BUGS program can be represented as a [Directed Acyclic Graph](https://en.wikipedia.org/wiki/Directed_acyclic_graph) (DAG), which can be visualized with a diagram.
An important early implementation was WinBUGS for Windows.
[JAGS](https://mcmc-jags.sourceforge.io/) is a newer implementation of the BUGS language, which also runs on Mac and Linux. It is usually called from R.
		
### Ideas and comments

* I have developed several versions of a [proof-of-concept prototype](https://github.com/rmhorton/DAGnabit) using ChatGPT. It shows the idea of parsing BUGS code and drawing a graph, but it has issues:
	- They make some mistakes (e.g., it included some things that are not really nodes, like the word "for")
	- They do not fully implement the [diagram conventions](https://www.multibugs.org/documentation/latest/ModelSpecification.html) (plates, for example)

* Existing DAG packages for R seem to be focused on [causal modeling](https://cran.r-project.org/web/packages/ggdag/vignettes/intro-to-dags.html):
	- [ggdag](https://cran.r-project.org/web/packages/ggdag/vignettes/intro-to-ggdag.html)
	- [shinydag](https://www.gerkelab.com/project/shinydag/)

* There are lots of JAGS and WinBUGS programs available, some of which have published DAG diagrams while others do not. Here are some interesting biomedical examples:
	- Health Technology Assessment
		+ [R for Health Technology Assessment](https://gianluca.statistica.it/books/online/r-hta/) includes an introduction to the field.
		+ [ARCESDMH](https://github.com/rmhorton/ARCESDMH) JAGS code
	- Many other examples from the [WinBUGS documentation](https://github.com/rmhorton/DAGnabit/blob/main/examples/WinBUGS_help_examples.pdf)
	
* semi-automatic layout
	- Use automatic layout for a first pass. Let the user edit it interactively by dragging nodes around (maybe in [dagitty](https://www.dagitty.net/dags.html), or something like it), then capture coordinates for the final figure.
	
* BUGS is not a general purpose programming language. It is very specialized, and all the syntax can be demonstrated in a short example. To build a parser, the AI will also need a table of reserved words, including built-in functions and statistical distributions. I have started collecting some of these in the proof-of-concept RMarkdown document.

* You may have heard of [Stan](https://mc-stan.org/), which is an even newer, more sophisticated language and system for programming MCMC models. It can do things besides implementing models described as DAGs.


### Goals

* Gain experience using large language models like GPT to generate computer code.
* Help build an R package.
* Learn how to visualize graphs in R, including with Javascript libraries.
* Become familiar with applications of graphs in biology, statistics and data science.
* Secondary goals: Learn a bit about 
	+ Health Technology Assessment
	+ Probabilistic Bayesian modeling
		- BUGS

### Project Aspects

Chat GPT can help with (or do) all of these things.

1. BUGS parser [Shayla](https://github.com/sdcaoile21/DAGnabit_BUGS_Parser-)
	- Pull variables and dependencies from code.
	- Exclude keywords, functions, distribution names, etc.

2. Graph Layout Editor [Liam](https://github.com/lskgrad/DAGnabit-Graph-Layout-Editor)
	- Interactive graph layout editing with Javascript-powered widget
	- Export layout for use in other graph layouts
	- Produce publication-quality graph visualization (SVG & PNG)

3. Building the R package [Tamara](https://github.com/tbabic55/DAGnabit-R-Package)
	- [Read the chat](https://chatgpt.com/share/68c303e3-6834-800a-8388-9dd6511d4e25) where I developed my [helloWidget package]()
	- Install the "helloWidget" package from github. Also, look through the files and directories for the helloWidget repo on the [Dagnabit repo](https://github.com/rmhorton/DAGnabit).
	- Wrap the graph layout editor in an htmlwidget for use in R.
	- Build the package.
	- Deploy the package to yor github repo.

4. Testing and Documentation [Naz](https://github.com/nyucel1234/DAGnabit-Documentation)
	- Help function developers complete and maintain the documentation for each function using [Roxygen](https://roxygen2.r-lib.org/).
	- Collect examples of BUGS programs with "official" DAG diagrams, to compare to DAGnabit-generated diagrams.
	- Write vignettes (RMarkdown documents) showing how to run the examples (maybe show graphs before and after interactive editing?)


### Git and GitHub
	- [Two decades of Git: A conversation with creator Linus Torvalds](https://www.youtube.com/watch?v=sCr_gb8rdEI&t=15s)
		+ What else is the developer famous for?
		+ Look at the comments.
	- git for local use
	- git vs github
	
	
### Deliverables

This project is to build an R package to draw DAG diagrams from a given BUGS/JAGS model. The package will include:

* implementation of a BUGS/JAGS parser to extract variables and parameters and their dependency relationships from a BUGS program.
* implementation of an HTML/Javascript graphical layout editor to let a user arrange the nodes the way they want to present them
* an 'htmlwidgets' wrapper to enable use of this layout editor in R
* examples (in this case, your data is BUGS code; you will want a set of examples that demonstrate the capabilities and limitations of your system)
* Vignettes (detailed guides or tutorials on how to use the R package)
	
Your job is to get the code working (using vibe coding, and a little help from me), together with demo data and documentation. I'll help you assemble it into a package that is installable from github (or maybe CRAN if it works really well).
