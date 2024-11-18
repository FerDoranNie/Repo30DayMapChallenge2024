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
# https://www.inegi.org.mx/programas/ccpv/2020/#microdatos

setwd('C:/Users/fernando.dorantes/local/Git_repositories/')

agebCDMX <- st_read('Repo30DayMapChallenge2024/Data/lmites-de-ageb-urbanas-en-la-ciudad-de-mxico.json')
censusData <-fread('Repo30DayMapChallenge2024/Data/RESAGEBURB_09CSV20.csv',
                   header = T)


censusData <- censusData[, c('ENTIDAD', 'NOM_ENT', 'NOM_MUN',  'MUN', 'AGEB',
              'MZA',  'POBTOT', 'PDER_SS')]

censusData <- censusData <- censusData %>% 
  .[, PDER_SS:= as.numeric(PDER_SS)] %>% 
  .[, POBTOT:= as.numeric(POBTOT)] %>% 
  .[, MUN := as.numeric(MUN)] %>% 
  .[, ENTIDAD := as.numeric(ENTIDAD)] 


agebCDMX <-agebCDMX %>% 
  mutate(CVE_ENT = as.numeric(CVE_ENT)) %>% 
  mutate(CVE_MUN = as.numeric(CVE_MUN)) 


head(censusData)
head(agebCDMX)


# censusData[, .(PDER_SS = sum(PDER_SS, na.rm = T),
#                POBTOT = sum(POBTOT, na.rm = T) ) 
#            by= list(ENTIDAD, NOM_ENT, MUN, AGEB) ]

censusData<-censusData[, lapply(.SD, sum, na.rm=TRUE), 
                       by=list(ENTIDAD, NOM_ENT,NOM_MUN, MUN, AGEB), 
           .SDcols=c('POBTOT', 'PDER_SS') ] %>% 
  .[, percentPopulationHealth := PDER_SS/POBTOT]


censusData <- merge(censusData, agebCDMX, by.x=c('AGEB', 'ENTIDAD', 'MUN'),
                    by.y=c('CVE_AGEB', 'CVE_ENT', 'CVE_MUN'))

censusData <- censusData %>%  st_as_sf()




ggplot(data = censusData) +
  geom_sf(aes(fill= percentPopulationHealth), color='black')+
  scale_fill_viridis_c(option = 'cividis', name='% de Población afiliada a servicios de salud', direction = -1)+
  labs(title = 'Sistemas de transporte por manzana', 
        subtitle='Área metropolitana de la ciudad de México',
        caption= 'Fuente: \n Censo de población y vivienda 2020, INEGI \n Autor:  @FerDoranNie \n#30DayMapChallenge2024')+
  # theme(panel.grid.major = element_line(color = gray(.5), 
  #                                        linetype = 'dashed', size = 0.1),
    theme(panel.background = element_rect(fill = 'gray90'))+
  annotation_north_arrow(location = 'bl', 
                         which_north = 'true', 
                         pad_x = unit(0.75, 'in'),
                         pad_y = unit(0.5, 'in'), 
                         style = north_arrow_fancy_orienteering)+
  annotation_scale(location = "bl", width_hint = 0.5)+
  xlab('') + ylab('')
