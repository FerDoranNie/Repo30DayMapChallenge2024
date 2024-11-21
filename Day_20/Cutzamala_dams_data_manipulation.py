####################################
# Creado/Author por/by Fernando Dorantes Nieto <(°)
#                                               ( >)"
#                                                /|
#
#
####################################
import pandas as pd 
import numpy as np 
import os 
import re 
import unidecode


folderPath = 'C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/Data/Mexico_dams_status_historical'
listFiles = os.scandir(folderPath)

maindf =[]
for file in listFiles:
    dateStr = file.path.split('_')[-1].split('.')[0]
    df = pd.read_csv(file.path, sep=',')
    df['date'] = dateStr
    maindf.append(df)
    
dataCutzamala = pd.concat(maindf) 

dataCutzamala.columns = [str(x).lower().replace(',', '').replace('(', '').replace(')', '').replace('³', '3') for x in  dataCutzamala.columns]
dataCutzamala.columns = dataCutzamala.columns.str.replace(' ', '_')

dataCutzamala.columns = [unidecode.unidecode(str(x)) for x in dataCutzamala.columns]

dataCutzamala.rename(columns={'#': 'original_index', '%_de_llenado_actual': 'porcentaje_de_llenado_actual'}, inplace=True)
dataCutzamala.head()

damsData  = pd.read_csv("C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/Data/Principales Presas de México.csv")


selectedCols = ['idmonitoreodiario', 'fechamonitoreo',	'clavesih',	'nombreoficial',	'nombrecomun',	'estado',
                'nommunicipio',	'regioncna',	'latitud',	'longitud',	'uso',	'corriente',	'tipovertedor',	'inicioop']

damsData = damsData[selectedCols]

selectedStr = ['El Bosque, Mich.', 'Valle de Bravo, Méx.', 'Villa Victoria, Méx.']

dataCutzamala = dataCutzamala[dataCutzamala['nombre_de_presa'].isin(selectedStr)] 


selectedDams = ['DBOMC', 'VVCMX', 'VBRMX']
damsData = damsData[damsData['clavesih'].isin(selectedDams)]

dataCutzamala['clavesih'] = np.where(dataCutzamala['nombre_de_presa']=='El Bosque, Mich.', 'DBOMC',
                                     np.where(dataCutzamala['nombre_de_presa']=='Valle de Bravo, Méx.', 'VBRMX', 'VVCMX'))

mainDataCutzamala = pd.merge(dataCutzamala, damsData, on='clavesih')

mainDataCutzamala['date']= pd.to_datetime(mainDataCutzamala['date'])

mainDataCutzamala.to_csv('C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/Data/Mexico_dams_status_historical/Cutzamala_historical_data.csv',
                         index=False)