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
library(tmap)
library(ggplot2)
library(jsonlite)
library(stringr)



convert_json_to_sf <- function(json_str) {
  json_str <- gsub('""', '"', json_str)
  geometry_list <- fromJSON(json_str, simplifyVector = FALSE)
  coordinates <- geometry_list$coordinates[[1]]
  if (!identical(coordinates[[1]], coordinates[[length(coordinates)]])) {
    coordinates <- append(coordinates, list(coordinates[[1]])) 
  }
  polygon <- st_polygon(list(matrix(unlist(coordinates), ncol = 2, byrow = TRUE)))
  return(st_sfc(polygon, crs = 4326))
}

## Origin of data
# https://datos.cdmx.gob.mx/dataset/atlas-de-riesgo-sismico
# https://datos.cdmx.gob.mx/dataset/atlas-de-riesgo-inundaciones

setwd('C:/Users/fernando.dorantes/local/Git_repositories/')

Seismicdata <- fread('Repo30DayMapChallenge2024/Data/atlas-de-riesgo-sismico.csv')
Floodsdata <- fread('Repo30DayMapChallenge2024/Data/atlas-de-riesgo-inundaciones.csv')

colonias <- st_read('Repo30DayMapChallenge2024/Data/catlogo-de-colonias.json')


# geometrySeismicTest <- Seismicdata$geo_shape[1]
# valid_json <- validate(geometrySeismicTest)
# if (!valid_json) {
#   stop("Invalid JSONs")
# }

# geometrySeismicTest <- gsub('""', '"', geometrySeismicTest)
# geometry_list <- fromJSON(geometrySeismicTest, simplifyVector = FALSE)
# coordinates <- geometry_list$coordinates[[1]]
# st_polygon(list(matrix(unlist(coordinates), ncol = 2, byrow = TRUE)))



Seismicdata<- Seismicdata %>% 
  .[, c("lat", "lon") := tstrsplit(geo_point_2d, ",", fixed=TRUE)] %>% 
  .[, geometry := lapply(geo_shape, convert_json_to_sf)] %>% 
  .[, geometry := st_sfc(sapply(geometry, `[`))]


# Seismicdata$test <- Seismicdata$geometry <-  sf::st_sfc( sapply( Seismicdata$geometry, `[`) )

selectedColsSeismic <- c('id', 'lat', 'lon', 'fenomeno', 'taxonomia', 'r_p_v_e', 
                     'intensidad', 'descripcio', 'fuente', 'cvegeo', 'alcaldia', 
                     'entidad', 'area_m2', 'perime_m', 'int2')

selectedColsFlood <- c('id',  'fenomeno', 'taxonomia', 
                     'intensidad','descripcio' , 'intens_uni', 'intens_num',  'int2')


selectedColsmap <- c('id', 'geometry')

Seismicdata <- unique(Seismicdata, by='id')
Floodsdata <- unique(Floodsdata, by='id')


SeismicdataGeneral <- Seismicdata[, selectedColsSeismic, with=FALSE]
FloodsdataGeneral <- Floodsdata[, selectedColsFlood, with=FALSE]

names(SeismicdataGeneral) <- c('id', 'lat', 'lon', 'fenomeno_sismo', 'taxonomia_sismo', 
                               'r_p_v_e', 'intensidad_sismo', 'descripcion_sismo', 'fuente', 'cvegeo',
                               'alcaldia', 'entidad', 'area_m2', 'perimetro_m', 'intensidad_numerica_sismo')
names(FloodsdataGeneral) <- c('id', 'fenomeno_inundacion', 'taxonomia_inundacion', 'intensidad_inundacion', 'descripcion_inundacion',
                              'intensidad_descr_inundacion', 'intensidad_descr_inundacion_rango', 'intensidad_numerica_inundacion')

SeismicFloodDataGeneral <- merge(SeismicdataGeneral, FloodsdataGeneral, by='id')

SeismicdataMap <- Seismicdata[, selectedColsmap, with=FALSE] 

SeismicdataMap <- st_as_sf(SeismicdataMap, sf_column_name = "geometry")
st_crs(SeismicdataMap)<- st_crs(colonias)


SeismicFloodDataGeneral %>% 
  fwrite('Repo30DayMapChallenge2024/Data/atlas_de_riesgo_sismico_inundacion_edited.csv', row.names = F)

SeismicdataMap %>%
  st_write("Repo30DayMapChallenge2024/Data/atlas_de_riesgo_sismico_map.geojson", driver = "GeoJSON")



