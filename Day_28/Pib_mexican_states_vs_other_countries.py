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
import re



countriesInfo = gpd.read_file('../Data/ne_50m_admin_0_countries/ne_50m_admin_0_countries.shp')


pibStates = pd.read_csv('../Data/Day_28Data/pib_estados.csv')

gdpData =  pd.read_csv('../Data/GDP_per_country_worldbank/API_NY.GDP.MKTP.CD_DS2_en_csv_v2_9865.csv', skiprows=4)


mapStates = gpd.read_file('../Data/dest23gw_c/dest23cw.shp', encoding='utf-8')



gdpData.columns = [x.lower().replace(' ', '_') for x in gdpData.columns]
mapStates.columns = [x.lower()for x in mapStates.columns]


pibStates = pibStates[['estado', '2021']].rename(columns={'2021': 'gdp_state', 'estado':'mexican_state'})


gdpData= gdpData[['country_name', 'country_code', '2021']].rename(columns={'2021': 'gdp_country'})


exchangeRate = pd.read_csv('../Data/Day_28Data/banxico_tipo_de_cambio_2021.csv')


avgExchangeRate = np.mean(exchangeRate['tipo_de_cambio'])
avgExchangeRate

pibStates['gdp_state'] = pibStates['gdp_state'].str.replace(',', '')

pibStates['gdp_state'] = pd.to_numeric(pibStates['gdp_state'])


pibStates['gdp_state_dollar'] = (pibStates['gdp_state']/avgExchangeRate)*1e6
countriesInfo = countriesInfo[['ISO_A2', 'SOV_A3', 'NAME_EN', 'ISO_A3']]
countriesInfo.columns = [x.lower().replace(' ', '_') for x in countriesInfo.columns]
from forex_python.converter import CurrencyRates
c = CurrencyRates()


def get_rates(x):
    rates = c.get_rate('MXN', 'USD', x)
    return rates 


def find_closest_country(pib, countries_df):
    differences = abs(countries_df['gdp_country'] - pib)
    closest_country = countries_df.loc[differences.idxmin()]
    return closest_country['country_name'], closest_country['country_code']

# Asignar país a cada estado
closest_matches = []
for _, row in pibStates.iterrows():
    closest_country, country_code = find_closest_country(row['gdp_state_dollar'], gdpData)
    closest_matches.append({'state': row['mexican_state'], 'country': closest_country, 'country_code': country_code})

# Convertir resultados en DataFrame
closest_matches_df = pd.DataFrame(closest_matches)


statesMatches = pd.merge(closest_matches_df, countriesInfo, left_on='country_code', right_on='iso_a3')


statesMatches = pd.merge(statesMatches, mapStates, left_on='state', right_on='nomgeo')

statesMatches['iso_a2'] = statesMatches['iso_a2'].str.lower()
statesMatches['iso_a3'] = statesMatches['iso_a3'].str.lower()

statesMatches = gpd.GeoDataFrame(statesMatches)


statesMatches.to_file('../Data/Day_28Data/pib_estados_mexico_vs_countries.geojson', driver="GeoJSON")