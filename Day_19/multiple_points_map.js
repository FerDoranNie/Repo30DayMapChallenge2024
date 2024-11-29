const svg = d3.select("svg"),
    width = +svg.attr("width"),
    height = +svg.attr("height");

// Map and projection
const projection = d3.geoAzimuthalEquidistant() 
    .scale(250)
    .translate([width/2, height/2*1.3])



let mexicoLonLat = [-99.14175584955996, 19.435994162858115]; 
let bogotaLonLat = [-74.09134263504326, 4.651015977841597];
 
let quitoLonLat = [-78.48861302822677, 0.18091961783285773];
 
let santiagoLonLat = [-70.64502057230652,-33.46896083574115];
let brasiliaLonLat = [-47.900625854053025, -15.820322589538224];
let pekinLonLat = [116.37767986557783, 39.922376734957375];
let aucklandLonLat = [174.75138233424502, -36.90054901581893];
 
let ankaraLonLat = [32.861563639347715, 39.954034548720266];
 
let seulLonLat = [126.99884617047354, 37.576734765365565];

// Create data: coordinates of start and end
const link = [
  //Mexico a Bogota
  {type: "LineString", coordinates: [mexicoLonLat, bogotaLonLat]},
  //Bogota a Quito
  {type: "LineString", coordinates: [bogotaLonLat, quitoLonLat]},
  //Quito a Santiago
  {type: "LineString", coordinates: [quitoLonLat, santiagoLonLat]},

  //Santiago a Brasilia
  {type: "LineString", coordinates: [santiagoLonLat,brasiliaLonLat]},

  //Brasilia a Ankara
  {type: "LineString", coordinates: [brasiliaLonLat, ankaraLonLat]},
  // Ankara a Pekin  
  {type: "LineString", coordinates: [ankaraLonLat, pekinLonLat]},
  // Pekin a Seul 
  {type: "LineString", coordinates: [pekinLonLat, seulLonLat]}

  
]






const path = d3.geoPath()
    .projection(projection)

d3.json("https://raw.githubusercontent.com/holtzy/D3-graph-gallery/master/DATA/world.geojson").then( function(data){


    svg.append("g")
        .selectAll("path")
        .data(data.features)
        .join("path")
            .attr("fill", "#e3cecf")
            .attr("d", path)
            .style("stroke", "#ffffff")
            .style("stroke-width", 1)

    svg.selectAll("myPath")
      .data(link)
      .join("path")
        .attr("d", function(d){ return path(d)})
        .style("fill", "none")
        .style("stroke", "#ae00ff")
        .style("stroke-width", 7)

})
