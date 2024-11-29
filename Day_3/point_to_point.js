let geojson = {}

let context = d3.select('#content canvas')
	.node()
	.getContext('2d');

let projection = d3.geoOrthographic()
	.scale(200)
	//.rotate([30, -45]);
	.rotate([60, 0]);    


let geoGenerator = d3.geoPath()
	.projection(projection)
	.pointRadius(4)
	.context(context);

let mexicoLonLat = [-99.14175584955996, 19.435994162858115]; 
let bogotaLonLat = [-74.09134263504326, 4.651015977841597];
 
let quitoLonLat = [-78.48861302822677, 0.18091961783285773];
 
let santiagoLonLat = [-70.64502057230652,-33.46896083574115];
let brasiliaLonLat = [-47.900625854053025, -15.820322589538224];
let pekinLonLat = [116.37767986557783, 39.922376734957375];
//let geoInterpolator = d3.geoInterpolate(mexicoLonLat, bogotaLonLat, quitoLonLat, santiagoLonLat, brasiliaLonLat);
let geoInterpolator = d3.geoInterpolate(mexicoLonLat, brasiliaLonLat);

let u = 0;

function update() {
	context.clearRect(0, 0, 800, 600);

	context.lineWidth = 0.5;
	context.strokeStyle = '#333';

	context.beginPath();
	geoGenerator({type: 'FeatureCollection', features: geojson.features})
	context.stroke();

	let graticule = d3.geoGraticule();
	context.beginPath();
	context.strokeStyle = '#ccc';
	geoGenerator(graticule());
	context.stroke();


	context.beginPath();
	context.strokeStyle = 'red';
	//geoGenerator({type: 'Feature', geometry: {type: 'LineString', coordinates: [mexicoLonLat, bogotaLonLat, quitoLonLat, santiagoLonLat, brasiliaLonLat]}});
	geoGenerator({type: 'Feature', geometry: {type: 'LineString', coordinates: [mexicoLonLat, brasiliaLonLat]}});    
	context.stroke();

	context.beginPath();
	context.fillStyle = 'blue';
	geoGenerator({type: 'Feature', geometry: {type: 'Point', coordinates: geoInterpolator(u)}});
	context.fill();

	u += 0.01
	if(u > 1) u = 0
}


d3.json('https://gist.githubusercontent.com/d3indepth/f28e1c3a99ea6d84986f35ac8646fac7/raw/c58cede8dab4673c91a3db702d50f7447b373d98/ne_110m_land.json')
	.then(function(json) {
		geojson = json;
		window.setInterval(update, 50);
	});
