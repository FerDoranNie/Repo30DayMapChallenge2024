####################################
# Creado/Author por/by Fernando Dorantes Nieto <(°)
#                                               ( >)"
#                                                /|
#
#
####################################


import pandas as pd
import geopandas as gpd
import numpy as np 
import matplotlib.pyplot as plt
import seaborn as sns 


migrationData = pd.read_csv('C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/Data/Day_26Data/migracion_00_xlsx/migracion_datos_inegi.csv', 
                            encoding='latin-1')


populationData = pd.read_csv('C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/Data/Day_21Data/ITER_NALCSV20.csv')

munMap = gpd.read_file('C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/Data/mun23gw_c/mun23cw.shp')

populationData = populationData[['ENTIDAD', 'NOM_ENT', 'MUN', 'NOM_MUN', 'LOC', 'NOM_LOC','LONGITUD','LATITUD',
                'ALTITUD',	'POBTOT', 'POBFEM', 'POBMAS', 'P_5YMAS',]]


populationData = populationData[~populationData['NOM_MUN'].str.contains('Total')]
populationData = populationData[~populationData['LATITUD'].isnull()]

populationData.columns = [str(x).lower() for x in populationData.columns]

munMap.columns = [str(x).lower() for x in munMap.columns]

populationData[['altitud', 'pobtot', 'pobfem', 'pobmas', 'p_5ymas']] = populationData[['altitud', 'pobtot', 'pobfem', 'pobmas', 'p_5ymas']].apply(pd.to_numeric, errors='coerce')

munMap[['cvegeo', 'cve_ent', 'cve_mun', 'cov_', 'cov_id', 'area', 'perimeter']] = munMap[['cvegeo', 'cve_ent', 'cve_mun', 'cov_', 'cov_id', 'area', 'perimeter']].apply(pd.to_numeric, errors='coerce')

migrationData[['cve_entidad', 'cve_municipio', '2020']] = migrationData[['cve_entidad', 'cve_municipio', '2020']].apply(pd.to_numeric, errors='coerce')

populationData = populationData.groupby(['entidad', 'nom_ent', 'mun', 'nom_mun']).agg({'altitud': 'mean', 'pobtot':'sum', 'pobfem':'sum', 'pobmas':'sum', 'p_5ymas':'sum' }).reset_index()

migrationData = migrationData[~migrationData['desc_municipio'].isin(['Estados Unidos Mexicanos', 'Estatal'])]
migrationData = migrationData[migrationData['indicador']=='Población de 5 años y más emigrante']

migrationData= migrationData[['cve_entidad', 'desc_entidad', 'cve_municipio', 'desc_municipio', 'id_indicador', 'indicador', '2020', 'unidad_medida']]
migrationData.rename(columns={'2020':'emigration_2020'},    inplace=True)


populationData['id'] = populationData['entidad'].astype(str) + '_' + populationData['mun'].astype(str)
migrationData['id'] = migrationData['cve_entidad'].astype(str) + '_' + migrationData['cve_municipio'].astype(str)
munMap['id'] = munMap['cve_ent'].astype(str) + '_' + munMap['cve_mun'].astype(str)

migrationDataGeneral  = pd.merge(migrationData, populationData, on='id')

migrationDataGeneral  = pd.merge(migrationDataGeneral, munMap, on='id')

migrationDataGeneral['percent_migration'] = migrationDataGeneral['emigration_2020']/migrationDataGeneral['p_5ymas']


bins = [0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.30, float('inf')]
labels = ['0-5%', '5-10%', '10-15%', '15-20%', '20-25%', '25-30%', 
          '30%+']
migrationDataGeneral['migration_category'] = pd.cut(
    migrationDataGeneral['percent_migration'], bins=bins, labels=labels, right=False
)


migrationDataGeneral = gpd.GeoDataFrame(migrationDataGeneral)


colors = ['#FFEDA0', '#FED976', '#FEB24C', '#FD8D3C', '#F03B20', 
          '#BD0026', '#800026', '#54278F', '#2B8CBE', '#08519C', '#023858']


colors = ['#FED976','#FD8D3C', '#F03B20', 
          '#BD0026', '#800026', '#54278F', '#2B8CBE', '#08519C']


colors2 = ['#FED976', '#FD8D3C', '#F03B20', 
          '#BD0026', '#800026', '#54278F', '#2B8CBE', '#08519C', '#023858']

color_map = dict(zip(labels, colors2))


viridis_original=plt.colormaps.get_cmap('cividis')
viridis_reverse = viridis_original.reversed() 


import matplotlib.pyplot as plt
from matplotlib.colors import Normalize
import matplotlib.colorbar as cbar
import matplotlib as mpl



fig, ax = plt.subplots(1, 1, figsize=(12, 8))

# Crear un rango personalizado para la leyenda de color
norm = Normalize(vmin=migrationDataGeneral['percent_migration'].min(), 
                 vmax=migrationDataGeneral['percent_migration'].max())

# Mapa principal
migrationDataGeneral.plot(
    column='percent_migration', 
    cmap='viridis',  # Paleta de colores
    legend=False,    # Desactivamos la leyenda predeterminada para personalizarla
    norm=norm,       # Normalización
    edgecolor='black', 
    alpha=0.8, 
    ax=ax
)

# Personalizar el título y subtítulo
ax.set_title("Porcentaje de Migración por Región", fontsize=16, weight='bold')
fig.suptitle("Análisis de Migración Global", fontsize=14, weight='regular', y=0.93)
ax.set_axis_off()  # Desactiva los ejes

# Crear una barra de colores personalizada
sm = plt.cm.ScalarMappable(cmap='viridis', norm=norm)
sm._A = []  # Necesario para ScalarMappable
cbar = fig.colorbar(sm, ax=ax, fraction=0.03, pad=0.04)

# Personalizar la barra de colores
cbar.set_label('Porcentaje de Migración (%)', fontsize=12)
cbar.ax.tick_params(labelsize=10)

# Añadir un pie de página
fig.text(0.1, 0.1, "Fuente: Datos simulados, 2024", fontsize=10, ha='left')

# Mostrar el mapa
plt.tight_layout()
plt.show()



fig, ax = plt.subplots(1, 1, figsize=(12, 8))

# Graficar usando las categorías y colores
migrationDataGeneral.plot(
    column='migration_category',
    cmap=mpl.colors.ListedColormap(colors2),  # Usar la paleta personalizada
    legend=True,  # Mostrar leyenda
    edgecolor=None,
    linewidth=0.5,
    ax=ax
)

# Personalizar título, subtítulo y leyenda
ax.set_title("Porcentaje de emigración por municipios de México en 2020", fontsize=16, weight='bold')
#ax.set_su
#fig.suptitle("Clasificación de Migración en Rangos de 5 en 5", fontsize=12)
ax.set_axis_off()

# Personalizar leyenda
legend = ax.get_legend()
legend.set_title("Rangos % \n (Pob migrante/Pob total)")
legend.set_bbox_to_anchor((1.2, 0.5))  # Mover la leyenda fuera del mapa
fig.text(0.1, 0.1, "Fuente: Inegi, 2020  \n #30DayMapChallenge \n @FerDoranNie", fontsize=10, ha='left')


output_path = "../images/migration_map_mexico_2020.png"
plt.savefig(output_path, dpi=300, bbox_inches='tight')
# Mostrar el mapa
plt.tight_layout()
plt.show()
