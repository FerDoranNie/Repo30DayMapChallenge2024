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
library(gganimate)
library(patchwork)


## Origin of data
# https://www.naturalearthdata.com/downloads/110m-cultural-vectors/

setwd('C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/')


timeZoneData <- st_read('./Data/Day_24Data/ne_10m_time_zones/ne_10m_time_zones.shp')
timeZoneData %>%  head

timeZoneData$name[!timeZoneData$name %in% timeZoneData$zone]

timeZoneData$name %>%  unique
timeZoneData$zone %>%  unique


timeZoneData<- timeZoneData %>% 
  mutate(zone = as.numeric(zone)) %>% 
  # mutate(time_zone_mexico_view = ifelse(zone>0, zone+7, zone-7 )) 
  mutate(time_zone_mexico_view = zone+7) 


ggplot(timeZoneData)+
  borders("world", colour = "#675a58", fill = "#f0f0f0")+
  geom_sf(aes(fill=time_zone_mexico_view), alpha=0.6)+
  scale_fill_viridis_c(option = 'turbo', 
                       name='Diferencia horaria \n desde el centro de México',
                       direction = -1,
                       breaks= seq(-12, 24, 2),
                       labels= scales::label_number(accuracy = 1, suffix = " h"),
                       guide = guide_colorbar(
                         barwidth = 1, 
                         barheight = 10,
                         label.theme = element_text(size = 10)  
                       )
                       )+
  coord_sf(xlim = c(-150, 150), ylim = c(-60, 90), expand = FALSE) +
  theme_minimal(base_size = 12)+
  xlab('') + ylab('')+
  theme(
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12, face = "italic"),
    plot.caption = element_text(size = 9, hjust = 0)
  ) +  
  labs(title = '¿Cuál es la diferencia en horas de las diferentes \n zonas horarias desde el punto de vista del centro de México? ', 
     subtitle=expression(italic("#30DayMapChallenge")),
     caption= 'Fuente: \n Natural Earth Data, 2024 \n Autor:  @FerDoranNie')
  
                       