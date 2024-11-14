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


## Origin of data
# http://www.conabio.gob.mx/informacion/gis/?vns=gis_root/usv/inegi/usv250s7gw
# http://www.conabio.gob.mx/informacion/gis/?vns=gis_root/dipol/mupal/mun23gw


# Load Data ---------------------------------------------------------------
setwd('C:/Users/fernando.dorantes/local/Git_repositories/')


useSoilData <- st_read('Repo30DayMapChallenge2024/Data/usv250s7gw_c/usv250s7cw.shp') 
originalCRS <- st_crs(useSoilData)

useSoilData <- useSoilData %>%  data.table
municipalityData <- st_read('Repo30DayMapChallenge2024/Data/mun23gw_c/mun23cw.shp') 

useSoilData <- useSoilData %>% 
  .[, description_summary := fcase(
    grepl('AGRICULTURA', DESCRIPCIO), 'AGRICULTURA',
    grepl('ASENTAMIENTOS HUMANOS', DESCRIPCIO), 'ASENTAMIENTOS HUMANOS',
    grepl('DESPROVISTO DE VEGETACIÓN', DESCRIPCIO), 'ZONA URBANA',
    grepl('SELVA ALTA', DESCRIPCIO), 'SELVA ALTA',
    grepl('SELVA MEDIANA', DESCRIPCIO), 'SELVA MEDIANA',
    grepl('SELVA BAJA', DESCRIPCIO), 'SELVA BAJA',
    grepl('BOSQUE', DESCRIPCIO), 'BOSQUE',
    grepl('MATORRAL', DESCRIPCIO), 'MATORRAL',
    grepl('PALMAR', DESCRIPCIO), 'PALMAR',
    grepl('PASTIZAL', DESCRIPCIO), 'PASTIZAL',
    grepl('MANGLAR', DESCRIPCIO), 'MANGLAR',
    grepl('DESIERTOS|DUNAS', DESCRIPCIO), 'DESERTICA',
    grepl('SABANA|SABANOIDE', DESCRIPCIO), 'SABANA',
    grepl('GALERÍA', DESCRIPCIO), 'SELVA BAJA',
    grepl('TULAR', DESCRIPCIO), 'TULAR',
    grepl('SECUNDARIA|PETÉN', DESCRIPCIO), 'OTRA VEGETACIÓN',
    grepl('HALÓFILA|GIPSÓFILA|', DESCRIPCIO), 'SALINAS',
        # default = 'OTRA VEGETACIÓN'
    rep(TRUE, .N), DESCRIPCIO
  
  )] 

useSoilData <- useSoilData %>%  st_as_sf()

test <- useSoilData %>% 
  filter(description_summary=='BOSQUE')



newSoilData <-  st_intersection(useSoilData, municipalityData )

names(newSoilData) <- tolower(names(newSoilData))

names(newSoilData) <- c('description', 'cov', 'cov_id', 'codigo',
                        'description_summary', 'cve_geo', 'cve_ent',
                        'cve_mun', 'nom_geo', 'nom_ent', 'cov_1', 'cov_id1',
                        'area', 'perimeter', 'geometry')

newSoilData <- newSoilData[, c('description', 'cov', 'cov_id', 'codigo',
                'description_summary', 'cve_geo', 'cve_ent',
                'cve_mun', 'nom_geo', 'nom_ent',
                'area', 'perimeter', 'geometry')]


newSoilData %>%  head

newSoilData %>% 
  st_write("Repo30DayMapChallenge2024/Data/uso_de_suelo_conabio/soil_use_and_municipality.shp")


# newSoilData %>% 
#   ggplot()+
#   geom_sf(aes(fill=description_summary))

# newSoilData <- merge(useSoilData, municipalityData, by = 'COV_ID')
# 
# newSoilData<- newSoilData[, c('COV_ID', 'DESCRIPCIO', 'codigo', 'geometry.x', 
#                 'description_summary', 'CVEGEO', 'CVE_ENT', 'CVE_MUN', 
#                 'NOMGEO', 'NOM_ENT', 'AREA')]
# 
# names(newSoilData) <- c('cov_id', 'description', 'codigo',
#                         'geometry', 'description_summary', 
#                         'cvegeo', 'cve_ent', 'cve_mun', 'nom_geo', 
#                         'nom_ent', 'area')
# 
# newSoilData<- newSoilData %>% 
#   st_as_sf() 
# 
# head(newSoilData)
# 
# newSoilData %>%  
#   filter(nom_geo=='Tecamachalco') 

# newSoilData %>% 
#   st_as_sf() %>%
#   # st_set_crs(originalCRS) %>% 
#   st_write("Repo30DayMapChallenge2024/Data/uso_de_suelo_conabio/soil_use_and_municipality.geojson", 
#            driver = "GeoJSON")

# useSoilData$DESCRIPCIO %>%  unique %>%  sort
# 
# useSoilData %>%  head
# municipalityData %>%  head
# 
# 
# municipalityData[NOMGEO=='Miguel Hidalgo' & NOM_ENT=='Ciudad de México']
# 
# useSoilData[COV_ID==277]


