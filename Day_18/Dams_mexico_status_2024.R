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
# https://sinav30.conagua.gob.mx:8080/SINA/?opcion=base
# http://www.conabio.gob.mx/informacion/gis/

setwd('C:/Users/fernando.dorantes/local/Git_repositories/')

crsDesired <- 'EPSG:4326'

statesMap <- st_read('Repo30DayMapChallenge2024/Data/dest23gw_c/dest23cw.shp') %>% 
  st_transform(crsDesired)
damsMexico <- fread('Repo30DayMapChallenge2024/Data/Principales Presas de México.csv',
      header = T)

colors <- c('#ff4949', '#ffb01a', '#f3ff2c', '#d3ff84', '#1fe500')

# originalCRS <- st_crs(statesMap)
names(damsMexico)
damsMexico <- st_as_sf(damsMexico, coords = c('longitud', 'latitud'), 
                       crs= 'EPSG:4326' )

damsMexico<- damsMexico %>% 
  mutate(llenano = as.numeric(llenano)) %>% 
  filter(!is.na(llenano))


damsMexico <- damsMexico %>% 
  mutate(category_fill_dam = case_when(
    llenano>=0 & llenano<0.2 ~'0-20%',
    llenano>=0.2 & llenano<0.4 ~'20-40%',
    llenano>=0.4 & llenano<0.6 ~'40-60%',
    llenano>=0.6 & llenano<0.8 ~'60-80%',
    llenano>=0.8 ~ '80-100%')
  )


# damsMexico %>%  head

ggplot() +
  geom_sf(data= statesMap, fill='#f7edec', alpha=0.25) +
  geom_sf(
    data = damsMexico,
    pch = 21,
    aes(size = almacenaactual, fill = category_fill_dam),
    col = "grey20"
    )+
  scale_size_binned(name='Llenado actual hm3:', n.breaks = 5 )+
  scale_fill_manual(values= colors, name='Categorías, porcentaje de llenado:') +
  # guides(fill = guide_legend(title = "")) +
  labs(title = 'Estado de las presas de México 2024',
       subtitle  = 'Porcentaje de llenado y volumen actual',
       caption = 'Fuente: CONAGUA, 2024 \n @FerDoranNie',
       size = "") +
  theme_void() +
  theme(legend.text = element_text(angle = 45))+
  theme(legend.position = "bottom")+
  guides(fill = guide_legend(override.aes = list(size=5)))
 
