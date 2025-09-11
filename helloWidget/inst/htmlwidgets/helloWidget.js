HTMLWidgets.widget({

  name: "helloWidget",
  type: "output",

  factory: function(el, width, height) {

    return {

      renderValue: function(x) {
        // Clear the container
        el.innerHTML = "";

        // Scale width by container size
        var w = width / x.values.length;

        // Append SVG
        var svg = d3.select(el).append("svg")
          .attr("width", width)
          .attr("height", height);

        // Draw bars
        svg.selectAll("rect")
          .data(x.values)
          .enter()
          .append("rect")
          .attr("x", function(d, i) { return i * w; })
          .attr("y", function(d) { return height - d * 10; })
          .attr("width", w - 2)
          .attr("height", function(d) { return d * 10; })
          .attr("fill", "steelblue");
      },

      resize: function(width, height) {
        // handle resizing if needed
      }

    };
  }
});
