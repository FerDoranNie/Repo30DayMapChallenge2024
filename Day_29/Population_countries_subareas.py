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
import requests
import re 


subAreasCountries = gpd.read_file('../Data/ne_10m_admin_1_states_provinces/ne_10m_admin_1_states_provinces.shp')

subAreasCountries.columns= [x.lower() for x in subAreasCountries.columns]


subAreasCountries= subAreasCountries[['featurecla', 'adm1_code', 'iso_3166_2', 'iso_a2', 'adm0_sr', 'sov_a3', 'name', 
                   'region', 'name_local', 'type', 'geonunit', 'latitude', 'longitude', 'postal', 'wikidataid', 'geometry']]


from wikidata.client import Client

client = Client()


def getWikiData(wiki_id):
    try:
        entity = client.get(wiki_id, load=True) 
        population_claims = entity.data['claims']['P1082']
        popvalue = str(population_claims[0]['mainsnak']['datavalue']['value']['amount'])
        popvalue = int(popvalue.replace('+', ''))
        valuesDict = dict({'wikidataid': [wiki_id], 'population': [popvalue]})
        #return valuesDict
        return pd.DataFrame.from_dict(valuesDict)
    except Exception as e: 
        print(f'Error al procesar {wiki_id}: {e}')
        return pd.DataFrame()
    
    
wikiDataids = subAreasCountries['wikidataid'].unique()
test = wikiDataids[0:5]



import time 
dfs = pd.DataFrame()

batch_size = 100
for i in range(0, len(wikiDataids), batch_size):
    batch = wikiDataids[i:i + batch_size]
    print(f"Procesando lote {i // batch_size + 1}: IDs {i} a {i + len(wikiDataids) - 1}")
    for wiki_id in batch:
        result = getWikiData(wiki_id)
        dfs = pd.concat([dfs, result], ignore_index=True)
    #mainDf = getWikiData(wikidata_id)
    #dfs.append(mainDf)
    if i + batch_size < len(test):
        print("Pausa de 1 minuto para evitar restricciones...")
        time.sleep(60)  

dfs.to_csv('../Data/Day_29Data/wikidataidsPopulation.csv')

subAreasCountriesMap = pd.merge(subAreasCountries, dfs, on='wikidataid', how='left')


bins = [0, 1e6, 5e6, 10e6, 20e6, 50e6, 100e6, float('inf')]
labels = ['0-1M', '0-5M', '5-10M', '10-20M', '20-50M', '50-100M', 
          '100M+']
subAreasCountriesMap['population_category'] = pd.cut(
    subAreasCountriesMap['population'], bins=bins, labels=labels, right=False
)
labels = ['No Information', '0-1M', '0-5M', '5-10M', '10-20M', '20-50M', '50-100M', 
          '100M+']
subAreasCountriesMap['population_category']  = np.where(subAreasCountriesMap['population'].isna(), 'No Information', subAreasCountriesMap['population_category'] )


continents = pd.read_csv('../Data/Day_29Data/continents2.csv')


continents.columns = ['country_name', 'iso_a2', 'iso_a3_n', 'country_code', 
                      'iso_3166_2', 'continent', 'subcontinent', 'intermediate_subcontinent',
                      'region_code_n', 'sub_region_code_n', 'intermediate_region_code_n']


continents['continent_desired'] = np.where( (continents['intermediate_subcontinent'].isin(['South America', 'Central America'])) & (continents['iso_a2']!='MX'), 
                                           'South America and Central America',
                                                np.where(continents['iso_a2'].isin(['MX', 'US', 'CA', 'BM', 'GL', 'PM']), 
                                                         'North America & Caribbean', 
                                                         np.where(continents['intermediate_subcontinent'].isin(['Caribbean']), 'North America & Caribbean',
                                                                  continents['continent'])))


subAreasCountriesMap= pd.merge(subAreasCountriesMap, continents, on='iso_a2', how='left')

subAreasCountriesMap= subAreasCountriesMap[~subAreasCountriesMap['name'].isin(['Antarctica', 'Clipperton Island', 'Guantanamo Bay USNB'])]


subAreasCountriesMap['continent_desired'] = np.where(subAreasCountriesMap['iso_a2'].isin(['NA']), 'Africa', np.where(subAreasCountriesMap['iso_a2'].isin(['XK']), 
                                                                                                                     'Europe', np.where(subAreasCountriesMap['name'].isin(['Somaliland']), 'Africa',
                                                                                                                                        subAreasCountriesMap['continent_desired'])))


subAreasCountriesMap['continent_desired'] = np.where(subAreasCountriesMap['name'].isin(['Dhekelia', 'Northern Cyprus', 'Kashmir', 'Baykonur lease in Qyzylorda', 'Akrotiri']),
                                                     'Europe', np.where(subAreasCountriesMap['name'].isin(['Cocos (Keeling) Islands', 'Coral Sea Islands', 'Christmas Island']), 'Oceania',
                                                                                                          np.where(subAreasCountriesMap['name'].isin(['Spratly Islands']), 'Asia', 
                                                                                                                   subAreasCountriesMap['continent_desired'])))


subAreasCountriesMap=gpd.GeoDataFrame(subAreasCountriesMap)

subAreasCountriesMap.to_file('../Data/Day_29Data/population_countries_and_subareas.geojson', driver='GEOJSON')
colors2 = ['#FED976', '#FD8D3C', '#F03B20', 
          '#BD0026', '#800026', '#54278F', '#2B8CBE', '#08519C', '#023858', '#bfb2ad']

color_map = dict(zip(labels, colors2))



import matplotlib.pyplot as plt
fig, ax = plt.subplots(1, 1, figsize=(12, 8))

subAreasCountriesMap.plot(
    column='population', 
    cmap='viridis',  # Paleta de colores
    legend=False,    # Desactivamos la leyenda predeterminada para personalizarla
    edgecolor='black', 
    alpha=0.8, 
    ax=ax
)


import matplotlib.pyplot as plt
from matplotlib.colors import Normalize
import matplotlib.colorbar as cbar
import matplotlib as mpl


norm = Normalize(vmin=subAreasCountriesMap['population'].min(), 
                 vmax=subAreasCountriesMap['population'].max())



fig, ax = plt.subplots(1, 1, figsize=(12, 8))

subAreasCountriesMap.plot(
    column='population_category',
    cmap=mpl.colors.ListedColormap(colors2),  # Usar la paleta personalizada
    legend=True,  # Mostrar leyenda
    edgecolor=None,
    linewidth=0.5,
    ax=ax
)

# Personalizar título, subtítulo y leyenda
ax.set_title("Población por países y sus subregiones (Estados/Provincias etc)", fontsize=16, weight='bold')
#ax.set_su
#fig.suptitle("Clasificación de Migración en Rangos de 5 en 5", fontsize=12)
ax.set_axis_off()

# Personalizar leyenda
legend = ax.get_legend()
legend.set_title("Rangos  \n Población en millones de habitantes")
legend.set_bbox_to_anchor((1.2, 0.5))  # Mover la leyenda fuera del mapa
fig.text(0.1, 0.1, "Fuentes: Wikidata, 2024 \n Natural Earth Data, 2024  \n   \n #30DayMapChallenge \n @FerDoranNie", fontsize=10, ha='left')


output_path = "../images/world_population_per_countries_and_their_regions.png"
plt.savefig(output_path, dpi=300, bbox_inches='tight')
# Mostrar el mapa
plt.tight_layout()
plt.show()

continents = subAreasCountriesMap['continent_desired'].unique()

continents = [x for x in continents if str(x) != 'nan']

#continents = subAreasCountriesMap['continent_desired'].unique()

for continent in continents:
    print(continent)
    continentLabel = str(continent).replace(' ', '_')
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    continentData = subAreasCountriesMap[subAreasCountriesMap['continent_desired']==continent]
    continentData.plot(
        column='population_category',
        cmap=mpl.colors.ListedColormap(colors2),  # Usar la paleta personalizada
        legend=True,  # Mostrar leyenda
        edgecolor=None,
        linewidth=0.5,
        ax=ax
    )

    # Personalizar título, subtítulo y leyenda
    ax.set_title(f'{continent}: \n  Población por países y sus subregiones (Estados/Provincias etc)', fontsize=16, weight='bold')
    #ax.set_su
    #fig.suptitle("Clasificación de Migración en Rangos de 5 en 5", fontsize=12)
    ax.set_axis_off()

    # Personalizar leyenda
    legend = ax.get_legend()
    legend.set_title("Rangos  \n Población en millones de habitantes")
    legend.set_bbox_to_anchor((1.2, 0.5))  # Mover la leyenda fuera del mapa
    fig.text(0.1, 0.1, "Fuentes: Wikidata, 2024 \n Natural Earth Data, 2024  \n   \n #30DayMapChallenge \n @FerDoranNie", fontsize=10, ha='left')

    plotName = f'../images/{continentLabel}_population_per_countries_and_their_regions.png'
    output_path = plotName
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    # Mostrar el mapa
    plt.tight_layout()
    plt.show()    