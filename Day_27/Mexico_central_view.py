####################################
# Creado/Author por/by Fernando Dorantes Nieto <(°)
#                                               ( >)"
#                                                /|
#
#
####################################
import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt

worldMap = gpd.read_file('C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/Data/ne_50m_admin_0_countries/ne_50m_admin_0_countries.shp')


central_longitude = -102
central_latitude = 23
worldMap = worldMap.to_crs(f"+proj=laea  +lat_0={central_latitude} +lon_0={central_longitude} +datum=WGS84")


dictCountries = {'Country':['México', 'Brasil', 'Australia', 'China'], 
                 'latitud_central':[20.623113197862992, -11.111135928587728, -26.26271293140888, 36.30293593566699], 
                 'longitud_central': [-100.69214370671304, -53.9485513717341, 134.60647441447554, 96.48488877692749]}


centralPoints = pd.DataFrame(dictCountries)


for index, row in centralPoints.iterrows():
    central_longitude = row['longitud_central']
    central_latitude = row['latitud_central']
    worldMap = worldMap.to_crs(f"+proj=laea  +lat_0={central_latitude} +lon_0={central_longitude} +datum=WGS84")
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    worldMap.plot(ax=ax, edgecolor='#353f46', color='#5d76d7')

    ax.set_xlim(-15000000, 15000000)  
    ax.set_ylim(-15000000, 15000000)

    ax.set_title(f"¿Cómo se vería el mundo si {row['Country']} estuviera en el centro del mundo? \n Proyección acimutal de Lambert", 
                 fontsize=16, weight='bold')
    ax.set_axis_off()
    fig.text(0.1, 0.1, "Fuente: Natural Earth Data, 2024  \n #30DayMapChallenge \n @FerDoranNie", fontsize=10, ha='left')
    output_path = f"../images/country_{row['Country']}_center_map.png"
    #print(output_path)
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.tight_layout()
    plt.show()
