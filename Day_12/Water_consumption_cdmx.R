####################################
# Creado/Author por/by Fernando Dorantes Nieto <(°)
#                                               ( >)"
#                                                /|
#
#
####################################
library(magrittr)
library(data.table)
library(dplyr)
library(sf)
library(tmap)
library(ggplot2)
library(units)
library(ggspatial)
library(tmap)
library(gridExtra)

## Origin of data
# https://datos.cdmx.gob.mx/dataset/diferencia-consumo-total-sacmex


setwd('C:/Users/fernando.dorantes/local/Git_repositories/')


mapColonies <- st_read('Repo30DayMapChallenge2024/Data/diferencia-consumo-total-sacmex.json')

mapColonies<- mapColonies %>% 
  mutate(SUM_cons_t= as.numeric(SUM_cons_t))

waterMap <- ggplot(data = mapColonies) +
  geom_sf(aes(fill=SUM_cons_t))+
  ggtitle('Consumo de agua por colonia en la CDMX (2023)')+
  scale_fill_viridis_c(option = "plasma", trans = "sqrt", name=expression ('Consumo de agua en'~m^3))+
  theme(panel.grid.major = element_line(color = gray(.5), 
                                        linetype = 'dashed', size = 0.5),
        panel.background = element_rect(fill = 'aliceblue'))+
  annotation_north_arrow(location = 'bl', 
                         which_north = 'true', 
                         pad_x = unit(0.75, 'in'),
                         pad_y = unit(0.5, 'in'), 
                         style = north_arrow_fancy_orienteering)+
  annotation_scale(location = "bl", width_hint = 0.5)+
  annotate(geom='text', x=-99.01, y=19.12, label='Fuente: \n Datos abiertos de la CDMX \n (2023)',
           fontface = 'bold', color = 'black', size = 2.7)+
  annotate(geom='text', x=-99.05, y=19.57, label='@FerDoranNie',
           fontface = 'bold', color = 'black', size = 2.7)+
  xlab('') + ylab('')



populationMap <- ggplot(data = mapColonies) +
  geom_sf(aes(fill=pob_2010))+
  ggtitle('Población por colonia en CDMX (2010)')+
  scale_fill_viridis_c(option = "viridis", trans = "sqrt", name='Población')+
  theme(panel.grid.major = element_line(color = gray(.5), 
                                        linetype = 'dashed', size = 0.5),
        panel.background = element_rect(fill = 'aliceblue'))+
  annotation_north_arrow(location = 'bl', 
                         which_north = 'true', 
                         pad_x = unit(0.75, 'in'),
                         pad_y = unit(0.5, 'in'), 
                         style = north_arrow_fancy_orienteering)+
  annotation_scale(location = "bl", width_hint = 0.5)+
  annotate(geom='text', x=-99.01, y=19.12, label='Fuente: \n Datos abiertos de la CDMX \n (2023)',
           fontface = 'bold', color = 'black', size = 2.7)+
  xlab('') + ylab('')


library(ggpubr)


ggarrange(waterMap, populationMap, 
          ncol = 2, nrow = 1, align='h')+
  theme(plot.margin = margin(0.1,0.1,2,0.1, "cm"))

        