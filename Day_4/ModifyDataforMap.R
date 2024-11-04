####################################
# Creado/Author por/by Fernando Dorantes Nieto <(°)
#                                               ( >)"
#                                                /|
#
#
####################################
library(magrittr)
library(data.table)
library(geohashTools)
library(sp)
library(sf)
library(ggplot2)
library(purrr)
library(stringi)

setwd('C:/Users/fernando.dorantes/local/Git_repositories/')

dataMetro <- fread('Repo30DayMapChallenge2024/Data/afluenciastc_simple_02_2024.csv')
mapaMetro <- st_read('Repo30DayMapChallenge2024/Data/stcmetro_shp/STC_Metro_estaciones_utm14n.shp')
alcaldias <- st_read('Repo30DayMapChallenge2024/Data/alcaldias_cdmx/poligonos_alcaldias_cdmx.shp')

names(dataMetro) <- tolower(names(dataMetro))
names(mapaMetro) <- tolower(names(mapaMetro))

dataMetro <- dataMetro %>% 
  data.table %>% 
  .[, station_name := stri_replace_all_fixed(stri_trans_general(str = tolower(estacion), 
                                                           id = 'Latin-ASCII'), ' ', '_')] %>% 
  .[, subway_line := gsub('linea|línea|[[:space:]]', '', tolower(linea)) ] %>% 
  .[, station_code := paste0(subway_line, '-', station_name)]

dataMetro %>%  head


mapaMetro <- mapaMetro %>% 
  data.table %>% 
  .[, long := unlist(map(mapaMetro$geometry, 1))] %>% 
  .[, lat := unlist(map(mapaMetro$geometry, 2))] %>% 
  .[, station_name := stri_replace_all_fixed(stri_trans_general(str = tolower(nombre), 
                                                                id = 'Latin-ASCII'), ' ', '_')] %>% 
  .[, subway_line := gsub('^0', '', tolower(linea)) ] %>% 
  .[, station_code := paste0(subway_line, '-', station_name)] %>% 
  .[, station_code := fcase(station_code =='9-mixhiuca', '9-mixiuhca',
                            station_code =='3-ninos_heroes/poder_judicial_cdmx', '3-ninos_heroes',
                            station_code =='6-uam_azcapotzalco', '6-uam-azcapotzalco',
                            rep(TRUE, .N), station_code
                            )] %>% 
  setnames(old = 'año', 'creation_year')


# test <- mapaMetro$station_code %>%  unique
# test2 <- dataMetro$station_code %>%  unique
# test[!test %in% test2]
# test2[!test2 %in% test]

metroCdmxData  <- merge(dataMetro, mapaMetro, by='station_code', allow.cartesian=TRUE)
selectedCols <- c('station_code', 'fecha', 'anio', 'mes', 'linea.x', 'estacion', 'afluencia', 
                  'tipo', 'alcaldias', 'creation_year', 'long', 'lat', 'est')
metroCdmxData<- metroCdmxData[,selectedCols, with = FALSE]
newNames <- c('station_code', 'date', 'year', 'month', 'line_name', 'station', 'passengers', 
                  'station_type', 'municipalities', 'creation_year', 'lon', 'lat', 'est_order')
names(metroCdmxData)<- newNames
metroCdmxData <- metroCdmxData[order(line_name, station)]

metroCdmxData<- metroCdmxData %>% 
  .[, est_order := as.numeric(est_order)] %>% 
  # .[, order := frank(station), by = list(line_name)]
  .[, order := seq_len(.N), by = (line_name)] %>% 
  .[, line_name := gsub('Linea|Línea', 'Línea', line_name)]


metroCdmxData %>% 
  fwrite('Repo30DayMapChallenge2024/Data/SubwayCDMXData.csv', row.names = FALSE)
