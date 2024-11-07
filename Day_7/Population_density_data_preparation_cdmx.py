####################################
# Creado/Author por/by Fernando Dorantes Nieto <(°)
#                                               ( >)"
#                                                /|
#
#
####################################

import geopandas as gpd
import pandas as pd 

popDensity = gpd.read_file('C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/Data/densidad_poblacion_2010/densidad_poblacion_2010/densidadpoblacion2010.shp')

popDensity = popDensity.to_crs(4326)
popDensity['Center_centroid_point'] = popDensity['geometry'].centroid
popDensity['lon_centroid'] = popDensity.Center_centroid_point.map(lambda point: point.x )
popDensity['lat_centroid'] =  popDensity.Center_centroid_point.map(lambda point: point.y )
popDensity= popDensity.drop(columns=['Center_centroid_point'])

geojsonPath = 'C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/Data/densidadpoblacion2010.json'
popDensity.to_file(geojsonPath, driver="GeoJSON")
