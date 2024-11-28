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
map <- tm_shape(aztecMap) +
  tm_polygons(
    'type', 
    border.alpha = 0.9,
    border.col='transparent'
  )+
  tm_add_legend(type = 'title', title='Fuente: https://hub.arcgis.com/datasets/vga::mesoamerican-civs/explore?layer=0  \n #30DayMapChallenge \n @FerDoranNie', 
  col = 'white', border.col = 'white', size=100)+
  tm_layout(
    main.title = 'Regiones de Tenochtitlán antes de la conquista',
    main.title.size =2,
    main.title.position = 'left',
    legend.outside=TRUE,
    legend.position = c("left", "bottom"),
    legend.text.size = 1,
    legend.title.size = 1.5,
    outer.margins = c(0.05, 0.05, 0.15, 0.05),
    panel.label.size = 1, 
    panel.label.bg.color = '#9d99bc',
    fontfamily = "serif"
  )


#map

tmap_save(map, filename = "Repo30DayMapChallenge2024/images/aztec_regions.png",height = 8.27, width = 11.69, dpi=600)



