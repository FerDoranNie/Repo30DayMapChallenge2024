####################################
# Creado/Author por/by Fernando Dorantes Nieto <(°)
#                                               ( >)"
#                                                /|
#
#
####################################
import pandas as pd 

import pandas as pd
import numpy as np 
import geopandas as gpd

#https://www.inegi.org.mx/programas/ccpv/2020/#microdatos)



municipalityData = pd.read_csv('C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/Data/Day_21Data/ITER_NALCSV20.csv')


municipalityData= municipalityData[['ENTIDAD', 'NOM_ENT', 'MUN', 'NOM_MUN', 'LOC', 'LONGITUD', 'LATITUD', 'ALTITUD', 'POBTOT', 'POBFEM', 'POBMAS']]


municipalityData = municipalityData[~municipalityData['NOM_MUN'].str.contains('Total')]
municipalityData = municipalityData[~municipalityData['LATITUD'].isnull()]


municipalityData[['ALTITUD', 'POBTOT', 'POBFEM', 'POBMAS']] = municipalityData[['ALTITUD', 'POBTOT', 'POBFEM', 'POBMAS']].apply(pd.to_numeric, errors='coerce')


municipalityData =municipalityData.groupby(['ENTIDAD', 'NOM_ENT', 'MUN', 'NOM_MUN']).agg({'ALTITUD': 'mean', 'POBTOT':'sum', 'POBFEM':'sum', 'POBMAS':'sum' }).reset_index()


municipalityMap = gpd.read_file('C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/Data/mun23gw_c/mun23cw.shp')


municipalityMap.rename(columns={'NOM_ENT': 'NOM_ENT2'}, inplace=True)


municipalityData[['ENTIDAD', 'MUN']] = municipalityData[['ENTIDAD', 'MUN']].apply(pd.to_numeric)

municipalityMap[['CVE_ENT', 'CVE_MUN']]=municipalityMap[['CVE_ENT', 'CVE_MUN']].apply(pd.to_numeric)

municipalityData= pd.merge(municipalityData, municipalityMap, left_on=['ENTIDAD', 'MUN'], right_on=['CVE_ENT', 'CVE_MUN'])

municipalityData = municipalityData.drop_duplicates()


municipalityData['population_normalized'] = (municipalityData['POBTOT'] - municipalityData['POBTOT'].min()) / (municipalityData['POBTOT'].max() - municipalityData['POBTOT'].min())


municipalityData['region'] = np.where(municipalityData['NOM_ENT'].isin(['Baja California', 
                                                                        'Baja California Sur', 'Sonora', 'Chihuahua', 'Sinaloa', 'Durango']), 'Noroeste',
                                      np.where(municipalityData['NOM_ENT'].isin(['Coahuila de Zaragoza', 'Nuevo León', 'Tamaulipas']), 'Noreste', 
                                               np.where(municipalityData['NOM_ENT'].isin(['Zacatecas', 'Aguascalientes', 'San Luis Potosí', 'Querétaro', 'Guanajuato']), 'Centro Norte',
                                                np.where(municipalityData['NOM_ENT'].isin(['México', 'Ciudad de México', 'Morelos']), 'Centro Sur',
                                                         np.where(municipalityData['NOM_ENT'].isin(['Nayarit', 'Jalisco', 'Colima', 'Michoacán de Ocampo']), 'Occidente',
                                                                  np.where(municipalityData['NOM_ENT'].isin(['Hidalgo', 'Puebla', 'Tlaxcala', 'Veracruz de Ignacio de la Llave']), 'Oriente',
                                                                           np.where(municipalityData['NOM_ENT'].isin(['Guerrero', 'Oaxaca', 'Chiapas']), 'Suroeste', 'Sureste'))))))
                                      )



Regions = ['Noroeste', 'Noreste', 'Occidente', 'Oriente', 'Centro Norte', 'Centro Sur', 'Suroeste', 'Sureste']


fig, axes = plt.subplots(nrows=4, ncols=2, figsize=(15, 25))  # Ajusta las dimensiones según las categorías
axes = axes.flatten()

n_regions = min(len(Regions), len(axes))
for i, Region in enumerate(Regions[:n_regions]):
    #subseting = pd.DataFrame(municipalityData[municipalityData['region'] == Region]) 
    subseting = municipalityData.query("region == @Region")
    #subseting = gpd.GeoDataFrame(subseting)
    subseting.plot(column='POBTOT', cmap=viridis_original, legend=True, ax=axes[i],  edgecolor='black')
    #if Region in ['Noreste', 'Oriente', 'Centro Sur', 'Sureste']: 
    #    subseting.plot(column='POBTOT', cmap=viridis_original, legend=True, ax=axes[i],  edgecolor='black')
    #else:
    #    subseting.plot(column='POBTOT', cmap=viridis_original, legend=False, ax=axes[i],  edgecolor='black')
    if Region=='Sureste':
        Region = f'{Region} \n Fuente: Censo De población y vivienda, 2020' 
    axes[i].set_title(Region, fontsize=15)  # Título de la faceta
    axes[i].set_axis_off()  # Ocultar ejes

# Ocultar las facetas no utilizadas
#for j in range(len(axes)):
#    if j >= len(region):
#        axes[j].set_visible(False)
fig.suptitle(f"Población a nivel municipal dividida por regiones de México", fontsize=20)
#fig.supsubtitle("Fuente: Censo De población y vivienda, 2020", fontsize=15)
#plt.text(0.75, 0.75, 'Fuente: Censo de población y vivienda Inegi, 2020', 
#             fontsize=15, color='gray', ha='left', va='bottom')
plt.tight_layout(rect=[0, 0.03, 1, 0.95]) 
#plt.tight_layout()
plt.savefig("C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/images/Population_municipality_mexico_2020.png", dpi=300, bbox_inches='tight')
plt.show()