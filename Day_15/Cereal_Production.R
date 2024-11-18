####################################
# Creado/Author por/by Fernando Dorantes Nieto <(°)
#                                               ( >)"
#                                                /|
#
#
####################################
library(magrittr)
library(data.table)
library(sf)
library(dplyr)
library(ggplot2)
library(tmap)
library(ggspatial)


## Origin of data
# https://www.fao.org/faostat/en

setwd('C:/Users/fernando.dorantes/local/Git_repositories/')

countriesMap <- st_read('Repo30DayMapChallenge2024/Data/ne_50m_admin_0_countries/ne_50m_admin_0_countries.shp')

faoData <- fread('Repo30DayMapChallenge2024/Data/FAOSTAT_data_en_11-15-2024.csv',
                 header = TRUE)

names(countriesMap) <- tolower(names(countriesMap))
names(faoData) <- tolower(names(faoData))


countriesMap<- data.table(countriesMap)[, c('featurecla', 'scalerank', 'labelrank', 'sovereignt', 'sov_a3',
                                  'adm0_diff', 'level', 'type', 'tlc', 'admin', 'adm0_a3', 'geounit', 
                                  'name', 'name_long', 'postal', 'pop_est', 'pop_rank', 'pop_year', 
                                  'gdp_md', 'gdp_year', 'economy', 'income_grp', 'iso_a3', 'adm0_iso', 
                                  'wikidataid', 'name_en', 'name_es', 'continent','region_un',  'geometry')] %>% 
  st_as_sf()




faoData <- faoData %>% 
  mutate(area = case_when(
    area=='Bahamas'~'The Bahamas',
    area=='Bolivia (Plurinational State of)'~'Bolivia',
    area=='China, Hong Kong SAR'~'China',
    area=='China, mainland'~'China',
    area=='China, Taiwan Province of'~'Taiwan',
    area=='Congo'~'Republic of the Congo',
    area=="Côte d'Ivoire"~'Ivory Coast',
    area=="Democratic People's Republic of Korea"~'North Korea',
    area=='Iran (Islamic Republic of)'~'Iran',
    area=='Netherlands (Kingdom of the)'~'Netherlands',
    area=='Republic of Korea'~'South Korea',
    area=='Republic of Moldova'~'Moldova',
    area=='Russian Federation'~'Russia',
    area=='Serbia'~'The Bahamas',
    area=='Syrian Arab Republic'~'Syria',
    area=='Türkiye'~'Turkey',
    area=='United Kingdom of Great Britain and Northern Ireland'~'United Kingdom',
    area=='Venezuela (Bolivarian Republic of)'~'Venezuela',
    area=='Viet Nam'~'Vietnam',
    area=="Lao People's Democratic Republic"~'Laos',
    TRUE ~ area
  ))

names1 <- countriesMap$sovereignt %>% unique %>%  sort
names2 <- faoData$area %>%  unique %>%  sort

names1[!names1 %in% names2]
names2[!names2 %in% names1]

faoData <- merge(data.table(faoData),
      data.table(countriesMap),
      by.x = 'area', by.y='sovereignt', 
      allow.cartesian = T) %>% st_as_sf()

# faoProductionData <- faoData %>% 
#   filter(element=='Production')

# faoProductionData <- faoData %>% 
#   filter(element=='Production')
faoProductionData <- faoData

ggplot(data = faoProductionData)+
  geom_sf(aes(fill= value), color='transparent')+
  facet_wrap(~item)+
  labs(title = 'Producción de los principales cereales por país', 
       subtitle='2022',
       caption= 'Fuente: \n FAO 2024 \n Autor:  @FerDoranNie')+
  scale_fill_viridis_c(name= 'Producción en toneladas')+
  theme(panel.grid.major = element_line(color = gray(.5), 
                                        linetype = 'dashed', size = 0.5),
        panel.background = element_rect(fill = 'aliceblue'))+
  annotation_scale(location = "bl", width_hint = 0.5)+
  xlab('') + ylab('')



faoProductionData %>% 
  st_write('Repo30DayMapChallenge2024/Data/FAOSTAT_data_edited.geojson',
           driver = 'GEOJSON')
