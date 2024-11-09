####################################
# Creado/Author por/by Fernando Dorantes Nieto <(°)
#                                               ( >)"
#                                                /|
#
#
####################################
import os 
import pandas as pd
import numpy as np 
import geopandas as gpd
import json

# Origen de los datos https://www.citylines.co/


## Functions
def jsontoColumn(json_string):
    try:
        values = pd.json_normalize(json.loads(json_string))
        return values 
    except (json.JSONDecodeError, TypeError):
        return pd.DataFrame([{"line": None, "line_url_name": None, "system": None}]) 
    
    
dirMonterrey1 = '../Data/citylines_data/monterrey_stations.geojson'
dirMonterrey2 = '../Data/citylines_data/monterrey_sections.geojson'
dirGuadalajara1 = '../Data/citylines_data/guadalajara_stations.geojson'
dirGuadalajara2 = '../Data/citylines_data/guadalajara_sections.geojson'
dirCdmx1 = '../Data/citylines_data/mexico-city_stations.geojson'
dirCdmx2 = '../Data/citylines_data/mexico-city_sections.geojson'
dirMunicipality  = '../Data/mun23gw_c/mun23cw.shp'


cdmxStations = gpd.read_file(dirCdmx1)
cdmxSections = gpd.read_file(dirCdmx2)
guadalajaraStations = gpd.read_file(dirGuadalajara1)
guadalajaraSections = gpd.read_file(dirGuadalajara2)
monterreyStations = gpd.read_file(dirMonterrey1)
monterreySections = gpd.read_file(dirMonterrey2)

cdmxStations['city_name'] = 'Mexico City'
cdmxSections['city_name'] = 'Mexico City'
guadalajaraStations['city_name'] = 'Guadalajara'
guadalajaraSections['city_name'] = 'Guadalajara'
monterreyStations['city_name'] = 'Monterrey'
monterreySections['city_name'] = 'Monterrey'

citiesStations = pd.concat([cdmxStations, guadalajaraStations, monterreyStations])

citiesSections = pd.concat([cdmxSections, guadalajaraSections, monterreySections])

linesStations = citiesStations['lines'].apply(jsontoColumn)

linesStations = pd.concat(linesStations.tolist(), ignore_index=True)

linesSections = citiesSections['lines'].apply(jsontoColumn)

linesSections = pd.concat(linesSections.tolist(), ignore_index=True)


citiesStations = pd.concat([citiesStations.reset_index(drop=True), linesStations.reset_index(drop=True)], axis=1).drop(columns=['lines'])
citiesSections = pd.concat([citiesSections.reset_index(drop=True), linesSections.reset_index(drop=True)], axis=1).drop(columns=['lines'])


citiesStations.columns = ['id_station', 'class_station', 'name_station', 'opening_station', 'buildstart_station', 'closure_station', 'geometry',
                          'city_name', 'osm_id_station', 'osm_tags_station', 'osm_metadata_station', 'line_name_station', 'line_url_name_station', 'system']


citiesSections.columns = ['id_section', 'class_section', 'length_section', 'opening_section', 'buildstart_section', 'closure_section', 'geometry', 'city_name',
                          'osm_id_section', 'osm_tags_section', 'osm_metadata_section', 'line_name_section', 'line_url_name_section', 'system', 'from_section']


geojsonPath1 = '../Data/mexico_metropolitan_transport_stations.geojson'
geojsonPath2 = '../Data/mexico_metropolitan_transport_sections.geojson'

citiesStations.to_file(geojsonPath1, driver="GeoJSON")
citiesSections.to_file(geojsonPath2, driver="GeoJSON")
