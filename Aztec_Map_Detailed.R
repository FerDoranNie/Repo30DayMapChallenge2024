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


## Origin of data
# http://www.conabio.gob.mx/informacion/gis/?vns=gis_root/usv/inegi/usv250s7gw
# http://www.conabio.gob.mx/informacion/gis/?vns=gis_root/dipol/mupal/mun23gw

loadAndModifyMap <- function(path, colName,  colValue, crs){
  x <- st_read(path)
  x <- x %>%  
    mutate( !!colName :=colValue) %>% 
    st_set_crs(crs)
  return(x)
}



# Load Data ---------------------------------------------------------------
crsMap <- 'epsg:4326'
setwd('C:/Users/fernando.dorantes/local/Git_repositories/')

templesMap <- loadAndModifyMap('Repo30DayMapChallenge2024/Data/Aztec_maps/Aztec_temples.geojson', 
                 colName = 'type', colValue = 'temples', crs = crsMap)

villagesMap <- loadAndModifyMap('Repo30DayMapChallenge2024/Data/Aztec_maps/Aztec_villages.geojson', 
                 colName = 'type', colValue = 'villages', crs = crsMap)
roadsMap <- loadAndModifyMap('Repo30DayMapChallenge2024/Data/Aztec_maps/Caminos.geojson', 
                 colName = 'type', colValue = 'roads', crs = crsMap)
chinampasMap <- loadAndModifyMap('Repo30DayMapChallenge2024/Data/Aztec_maps/chinampas/MesoAmerican_civs.shp', 
                 colName = 'type', colValue = 'chinampas', crs = crsMap)
# chinampasMap2 <- loadAndModifyMap('Repo30DayMapChallenge2024/Data/Aztec_maps/Chinampas2.geojson', 
#                  colName = 'type', colValue = 'chinampas', crs = crsMap)
lakesMap <- loadAndModifyMap('Repo30DayMapChallenge2024/Data/Aztec_maps/GreatLakes.geojson', 
                 colName = 'type', colValue = 'lakes',crs = crsMap)
islandsMap <- loadAndModifyMap('Repo30DayMapChallenge2024/Data/Aztec_maps/Islas.geojson', 
                 colName = 'type', colValue = 'islands', crs = crsMap)
streetsMap <- loadAndModifyMap('Repo30DayMapChallenge2024/Data/Aztec_maps/Tenochtiltan_Streets.geojson', 
                 colName = 'type', colValue = 'streets',crs = crsMap)
municipalityMaps <- st_read('Repo30DayMapChallenge2024/Data/alcaldias_cdmx/poligonos_alcaldias_cdmx.shp')

municipalityMaps<- municipalityMaps %>%  
  st_set_crs(crsMap)

aztecMap <- bind_rows(
  list(
    templesMap,
    #villagesMap,
    roadsMap,
    chinampasMap,
    # chinampasMap2,
    lakesMap,
    islandsMap,
    streetsMap
  )
)

aztecMap <- aztecMap %>% 
   filter(!st_is_empty(.))

aztecMap <- aztecMap[aztecMap %>%  st_is_valid(), ]

aztecMap %>% 
  st_write('Repo30DayMapChallenge2024/Data/test.geojson', driver='GEOJSON')


# tmap_options(check.and.fix = TRUE)
tmap_options(check.and.fix = FALSE)
tm_shape(aztecMap) +
  tm_polygons(
    'type', 
    #palette = drought_colors, 
    title = 'Regiones de Tenochtitlan', 
    border.alpha = 0.9,
    border.col='transparent'
  )






