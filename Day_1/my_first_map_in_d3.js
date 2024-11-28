/*
projection = d3.geoEqualEarth()
projection = d3.geoEisenlohr()
world = FileAttachment("countries-50m.json").json()


path = d3.geoPath(projection)


outline = ({type: "Sphere"})


graticule = d3.geoGraticule10()


land = topojson.feature(world, world.objects.land)

borders = topojson.mesh(world, world.objects.countries, (a, b) => a !== b)


height = {
    const [[x0, y0], [x1, y1]] = d3.geoPath(projection.fitWidth(width, outline)).bounds(outline);
    const dy = Math.ceil(y1 - y0), l = Math.min(Math.ceil(x1 - x0), dy);
    projection.scale(projection.scale() * (l - 1) / l).precision(0.2);
    return dy;
  }


*/

// The svg
var svg = d3.select("svg"),
    width = +svg.attr("width"),
    height = +svg.attr("height");

// Map and projection. Try:  d3.geoAiry() / d3.geoAitoff() / d3.geoArmadillo() / d3.geoAugust() / d3.geoAzimuthalEqualArea() / d3.geoAzimuthalEquidistant() and more
//var projection = d3.geoAitoff()
var projection = d3.geoEisenlohr()
    .scale(width / 1.3 / Math.PI)
    .translate([width / 2, height / 2])

// Load external data and boot
d3.json("https://raw.githubusercontent.com/holtzy/D3-graph-gallery/master/DATA/world.geojson", function(data){

    // Draw the map
    svg.append("g")
        .selectAll("path")
        .data(data.features)
        .enter().append("path")
            .attr("fill", "#69b3a2")
            .attr("d", d3.geoPath()
                .projection(projection)
            )
            .style("stroke", "#fff")
})