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
# https://datos.cdmx.gob.mx/dataset/numero-de-sistemas-de-transporte-disponibles-por-manzana

setwd('C:/Users/fernando.dorantes/local/Git_repositories/')

transportMap <- st_read('Repo30DayMapChallenge2024/Data/Numero_de_sistemas_de_transporte_disponibles_por_manzana/manzanas_zmvm.shp')
municipalityMaps <- st_read('Repo30DayMapChallenge2024/Data/alcaldias_cdmx/poligonos_alcaldias_cdmx.shp')


names(transportMap) <- tolower(names(transportMap))
transportMap <- data.table(transportMap)

coberturaMap <- transportMap[, c('cvegeo', 'cobertura', 'geometry')]

transportMap <- transportMap %>%
  data.table %>% 
  .[, ! c('pob1', 'oid_1', 'cobertura')]


allTransports <- coberturaMap[cobertura==0] %>% 
  .[, transport_name :='sin sistema de transporte'] %>% 
  .[, presence_absence:=1] %>% 
  .[, !c('cobertura')]


transportNames <- names(transportMap)[! names(transportMap) %in% c('cvegeo', 'geometry')]

transportMap <- transportMap %>%  
  melt(id.vars = c('cvegeo', 'geometry'), measure.vars = transportNames) %>% 
  setnames(old = c('variable', 'value'), new=c('transport_name', 'presence_absence'))  

transportMap$transport_name %>%  unique

transportMap<- rbindlist(list(transportMap, allTransports))


transportMap <- transportMap %>% 
  # data.table %>% 
  mutate(transport_name = case_when (
    transport_name=='tren_liger'~'tren ligero',
    transport_name=='trole_elev'~'trolebus',
    transport_name=='t_concesio'~'transporte concesionado',
    TRUE ~ transport_name
  ))
  # .[, transport_name_edited:= fcase(
  #   transport_name=='tren_liger', 'tren ligero',
  #   transport_name=='trole_elev', 'trolebus',
  #   transport_name=='t_concesio', 'transporte concesionado',
  #   #rep(TRUE, .N), transport_name
  #   )]

transportMap <- transportMap %>% 
  mutate(presence_absence = as.integer(presence_absence)) %>% 
  mutate(presence_absence_char = ifelse(presence_absence==1, 'Presente', 'Ausente'))

transportMap %>% 
  data.table %>% 
  .[, .(suma = sum(presence_absence) ), by=list(transport_name) ] %>% 
    setorder(suma) %>% 
  data.frame

transportMap <- transportMap %>% st_as_sf()




ggplot(data = transportMap %>%  
         filter(transport_name %in% c('metro', 'metrobus', 
                                      'rtp', 'transporte concesionado',
                                      'ecobici', 'sin sistema de transporte')) 
       ) +
  geom_sf(aes(fill= presence_absence_char), color='transparent')+
  facet_wrap(~transport_name)+
  labs(title = 'Sistemas de transporte por manzana', 
       subtitle='Área metropolitana de la ciudad de México',
       caption= 'Fuente: \n INEGI y SEMOVI 2021 \n Autor:  @FerDoranNie')+
  scale_fill_manual(values = c('#98ff98', '#f4c3d8'),
                    name= 'Presencia ausencia de transporte')+
  theme(panel.grid.major = element_line(color = gray(.5), 
                                         linetype = 'dashed', size = 0.5),
         panel.background = element_rect(fill = 'aliceblue'))+
   annotation_scale(location = "bl", width_hint = 0.5)+
   xlab('') + ylab('')
  


  
  