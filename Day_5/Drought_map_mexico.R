####################################
# Creado/Author por/by Fernando Dorantes Nieto <(°)
#                                               ( >)"
#                                                /|
#
#
####################################
library(magrittr)
library(data.table)
library(readxl)
library(sf)
library(lubridate)
library(tmap)
library(ggplot2)

## Origin of data
# https://smn.conagua.gob.mx/es/climatologia/monitor-de-sequia/monitor-de-sequia-en-mexico
# http://www.conabio.gob.mx/informacion/gis/?vns=gis_root/dipol/mupal/mun23gw

setwd('C:/Users/fernando.dorantes/local/Git_repositories/')

# Load Data ---------------------------------------------------------------
dataDrought <- data.table(read_xlsx('Repo30DayMapChallenge2024/Data/MunicipiosSequia.xlsx', 
          sheet = 'MUNICIPIOS')) 

mapMunicipality <- st_read('Repo30DayMapChallenge2024/Data/mun23gw_c/mun23cw.shp')
newNames <- gsub('*', '', tolower(names(dataDrought)), fixed = T)

names(dataDrought) <- newNames

varNames <- names(dataDrought)[1:9]
measureNames <- names(dataDrought)[!(names(dataDrought) %in%  varNames)]

dataDroughtLong <- melt(dataDrought, id.vars = varNames, measure.vars = measureNames)

dataDroughtLong <- dataDroughtLong[, value := fifelse(is.na(value), 'DN', value)] %>% 
  .[, variable := as.numeric(as.character(variable))] %>% 
  setnames(old = c('variable', 'value'), new= c('date', 'drought_category')) %>% 
  .[, date := as.Date(date, origin = '1899-12-30')] %>%  # Origin of dates of excel system
  .[, drought_category_long := fcase(
    drought_category=='D0', 'Anormalmente seco',
    drought_category=='D1', 'Sequía moderada',
    drought_category=='D2', 'Sequía Severa',
    drought_category=='D3', 'Sequía Extrema',
    drought_category=='D4', 'Sequía Excepcional',
    drought_category=='DN', 'Sin Sequía'
    
  )] %>% 
  .[, year := year(date)] %>% 
  .[, month := month(date)]

dataDroughtSelected <- dataDroughtLong[year %in% (2019:2024) & month==10]

dataDroughtSelected <- merge(dataDroughtSelected, mapMunicipality, by.x ='cve_concatenada', by.y = 'CVEGEO' ) %>% 
  st_as_sf()


names(dataDroughtSelected)


# Making map --------------------------------------------------------------
drought_colors <- c(
  'Anormalmente seco' = '#FFFF00',
  'Sequía moderada' = '#ffd37f',
  'Sequía Severa' = '#e69800',
  'Sequía Extrema' = '#e60000',
  'Sequía Excepcional' = '#730000',
  'Sin Sequía' = '#C0C0C0'
)

droughtMap <- tm_shape(dataDroughtSelected) +
  tm_polygons(
    'drought_category_long', 
    palette = drought_colors, 
    title = 'Categoría de sequía', 
    border.alpha = 0.9,
    border.col='transparent'
  )+
  tm_facets(by='year')+
  # tm_credits(
  #   text = c('', '', '',
  #            paste0(('Fuente:'), '\nhttps://smn.conagua.gob.mx/es/climatologia/monitor-de-sequia/monitor-de-sequia-en-mexico'), '', ''),
  #   position = c('LEFT', 'BOTTOM'),
  #   #position= c(.87, .03),
  #   just = "left",
  #   fontface = "bold"
  # )+
  tm_add_legend(type = 'title', title='Fuente: \n https://smn.conagua.gob.mx/es/climatologia/monitor-de-sequia/monitor-de-sequia-en-mexico', col = 'white', border.col = 'white', size=20)+
  tm_layout(
    main.title = 'Sequía en México en Octubre\nComparativa\núltimos 6 años',
    main.title.size = 0.5,
    main.title.position = 'left',
    legend.outside=TRUE,
    legend.position = c("left", "bottom"),
    legend.text.size = 0.5,
    legend.title.size = 0.7,
    outer.margins = c(0.05, 0.05, 0.15, 0.05),
    panel.label.size = 1, 
    panel.label.bg.color = '#9d99bc',
    fontfamily = "serif"
  )
  

  
mapFilename <- 'Repo30DayMapChallenge2024/images/Drought_map_last_5_years_mexico.png'
tmap_save(droughtMap,
          mapFilename, width=1920, height=1080, asp=0)



