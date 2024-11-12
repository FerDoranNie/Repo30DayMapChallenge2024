####################################
# Creado/Author por/by Fernando Dorantes Nieto <(°)
#                                               ( >)"
#                                                /|
#
#
####################################
import pandas as pd
import numpy as np 
import geopandas as gpd
import json
import matplotlib.pyplot as plt
from cartopy import crs as ccrs
import re 
import matplotlib.pyplot as plt
import seaborn as sns 
import imageio
import os

#Origen de los datos https://www.naturalearthdata.com/

worldData = gpd.read_file('../Data/ne_50m_admin_0_countries/ne_50m_admin_0_countries.shp')
worldData.columns =  [x.lower() for x in  worldData.columns]


worldData= worldData[['featurecla', 'scalerank', 'labelrank', 'sovereignt', 'sov_a3','adm0_diff', 'level', 'type', 'tlc', 'admin', 'adm0_a3', 'geounit',
              'name', 'name_long', 'postal', 'economy', 'iso_a3', 'adm0_iso', 'wikidataid', 'name_en', 'name_es', 'continent','region_un',  'geometry']]



projections = {
    "EPSG:4326": "WGS 84 (Lat-Long)",           # Proyección geográfica básica
    #"EPSG:3857": "Web Mercator",                # Proyección común de mapas web
    "ESRI:54030": "Mollweide",                  # Proyección de Mollweide
    "ESRI:54034": "Mercator",                   # Proyección de Mercator
    "ESRI:54009": "Robinson",                   # Proyección de Robinson
    "ESRI:54008": "Sinusoidal",                 # Proyección Sinusoidal
    "ESRI:54012": "Equal Earth",                # Proyección Equal Earth
}


images_list=[]


worldData['region_un'].unique()

from matplotlib.colors import LinearSegmentedColormap


hexCols = ['#CCCCFF', '#6495ED', '#DE3163', '#FF7F50', '#40E0D0', '#FFBF00']

cmapHex = LinearSegmentedColormap.from_list("custom_cmap", hexCols, N=6)



for epsg_code, proj_name in projections.items():
    # Transformar el GeoDataFrame a la proyección actual
    world_projected = worldData.to_crs(epsg_code)
    xlim = worldData.total_bounds[[0, 2]]
    ylim = worldData.total_bounds[[1, 3]]
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    ax.set_title(f"World Map Projection: - {proj_name}", fontsize=15)
    
    # Graficar el mapa con la proyección actual
    world_projected.plot(column = 'region_un', ax=ax, cmap= cmapHex, edgecolor="black", 
                         legend_kwds={'title': "Continent", 'loc': 'lower left'}, legend=True)
    
    #ax.set_xlim(xlim)
    #ax.set_ylim(ylim) 
    
    ax.set_axis_off()

    plt.text(1, -0.1, "Fuente: Natural Earth 2024 Autor: @FerDoranNie", 
             fontsize=10, color='gray', ha='right', transform=ax.transAxes, weight='bold')

    plt.text(1, -2, "@FerDoranNie", 
             fontsize=10, color='gray', ha='right', transform=ax.transAxes, weight='bold')

    #ax.set_facecolor('#aac7cf')
    #plt.figure(facecolor='#aac7cf')
    filename = f"map_{proj_name}.png"
    plt.savefig(filename, format="png", dpi=100)
    #plt.savefig(filename, format="png", dpi=100, bbox_inches="tight")
    images_list.append(imageio.imread(filename))
    plt.close()



imageio.mimsave("../images/projection_map_animation.gif", images_list, duration=2000)


for filename in [f"map_{proj_name}.png" for proj_name in projections.values()]:
    os.remove(filename)

#print("Animación guardada como 'projection_map_animation.gif'")