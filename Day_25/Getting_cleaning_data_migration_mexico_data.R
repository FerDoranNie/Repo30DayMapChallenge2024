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
# https://hub.worldpop.org/geodata/summary?id=1283

setwd('C:/Users/fernando.dorantes/local/Git_repositories/Repo30DayMapChallenge2024/')

statesMap <- st_read('./Data/dest23gw_c/dest23cw.shp')

centroidsData <- st_read('./Data/Day_25Data/Latin_America_and_Caribbean_1km_Internal_Migration_Flows/MEX_5yrs_InternalMigFlows_2010/MEX_AdminUnit_Centroids/MEX_AdminUnit_Centroids.shp')

pointsData <- fread('./Data/Day_25Data/Latin_America_and_Caribbean_1km_Internal_Migration_Flows/MEX_5yrs_InternalMigFlows_2010/MEX_5yrs_InternalMigFlows_2010.csv')

statesMap <- st_transform(statesMap, 4326)

names(statesMap) <- tolower(names(statesMap))
names(pointsData)<- tolower(names(pointsData))
names(centroidsData)<- tolower(names(centroidsData))

pointsData<- pointsData %>%
  .[, id := paste0(iso, '_', nodej, '_', nodei) ]


pointsDataSf <- st_as_sf(pointsData, coords= c('lonfr', 'latfr')) %>% 
  select('id')

pointsDataSf2 <- st_as_sf(pointsData, coords= c('lonto', 'latto')) %>% 
  select('id')

st_crs(pointsDataSf) <- st_crs(statesMap)
st_crs(pointsDataSf2) <- st_crs(statesMap)

intersectionsf <- st_intersection( pointsDataSf, statesMap)
intersectionsf2 <- st_intersection( pointsDataSf2, statesMap)

intersectionsf <- intersectionsf %>%  
  select(!any_of(c('geometry', 'cov_id', 'cov_', 'area', 'perimeter'))) %>% 
  st_drop_geometry()

intersectionsf2 <- intersectionsf %>%  
  select(!any_of(c('geometry', 'cov_id', 'cov_', 'area', 'perimeter'))) %>% 
  st_drop_geometry()

statesMap<- statesMap %>% 
  select(cvegeo)

migrationData <- merge(pointsData, intersectionsf, by='id') %>% 
  setnames(old = c('cvegeo', 'cve_ent', 'nomgeo', 'cve_cap', 'nom_cap'),
           new=c('cvegeo_from', 'cve_ent_from', 'nomgeo_from', 'cve_cap_from', 'nom_cap_from')) %>% 
  merge(intersectionsf2, by='id') %>% 
  setnames(old = c('cvegeo', 'cve_ent', 'nomgeo', 'cve_cap', 'nom_cap'),
           new=c('cvegeo_to', 'cve_ent_to', 'nomgeo_to', 'cve_cap_to', 'nom_cap_to')) 
  

migrationData <- migrationData %>% 
  data.table %>% 
  .[, region := fcase(
    nomgeo_from %in% c('Baja California', 'Baja California Sur', 'Sonora', 'Chihuahua', 'Sinaloa', 'Durango'), 'Noroeste',
    nomgeo_from %in% c('Coahuila de Zaragoza', 'Nuevo León', 'Tamaulipas'), 'Noreste',
    nomgeo_from %in% c('Zacatecas', 'Aguascalientes', 'San Luis Potosí', 'Querétaro', 'Guanajuato'), 'Centro Norte',
    nomgeo_from %in% c('México', 'Ciudad de México', 'Morelos'), 'Centro Sur',
    nomgeo_from %in% c('Nayarit', 'Jalisco', 'Colima', 'Michoacán de Ocampo'), 'Occidente',
    nomgeo_from %in% c('Hidalgo', 'Puebla', 'Tlaxcala', 'Veracruz de Ignacio de la Llave'), 'Oriente',
    nomgeo_from %in% c('Guerrero', 'Oaxaca', 'Chiapas'), 'Suroeste',
    default = 'Sureste'
  )] %>% 
  .[, nomgeo_from := fifelse(nomgeo_from=='México', 'Estado de México', 
                             nomgeo_from)]



regions <- migrationData$region %>%  unique

for(r in regions){
  print(r)
  p <- ggplot(migrationData[region==r]) +
    # geom_sf(data = statesMap)+
    borders("world", regions = 'mexico', colour = "black", fill = "gray80") +  
    geom_segment(aes(x = lonfr, y = latfr, 
                     xend = lonto, yend = latto,
                     size=prdmig),  color="steelblue") + 
    scale_size_continuous(
      range = c(0.2, 2),  # Tamaño mínimo y máximo de las líneas
      breaks = c(100, 500, 1000, 5000, 10000),  # Rango ajustado para prdmig
      labels = c("100", "500", "1K", "5K", "10K"),  # Etiquetas legibles
      name = "Migración\n(Num. Personas)"
    ) +  
    coord_equal()+
    facet_wrap(~nomgeo_from)+
    theme_void(base_size = 12) +  # Tema base sin elementos visuales innecesarios
    theme(
      strip.text = element_text(size = 10, face = "bold"),  
      panel.grid = element_blank(),  
      panel.border = element_blank(),  
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5),  
      plot.subtitle = element_text(size = 12, hjust = 0.5),  
      legend.position = "bottom",  
      legend.key.width = unit(2, "cm"),  
      legend.key.height = unit(0.4, "cm")  
    ) +
    # Títulos
    labs(
      title = paste0("Flujos Migratorios en el ",  r, ' de México'),
      subtitle = "Rutas de migración representadas por el número de personas",
      caption= 'Fuente: \n WorldPop, 2016 \n Autor:  @FerDoranNie \n #30DayMapChallenge'
    )  
  
  
  fileName = paste0(gsub('[[:space:]]', '_', r), '_migration_flux.png')
  ggsave(filename = paste0('./images/', fileName), plot = p,  
         width = 1200, height = 675, units = "px", bg = "white", scale=1.75)
  
}


                                           




# migrationData <- merge(pointsData, intersectionsf, by='id') %>% 
#   merge(statesMap, by='cvegeo') 

# names(migrationData)
# 
# totals <- migrationData %>% 
#   data.table %>% 
#   .[, .(sumaMigracion = sum(prdmig, na.rm = T)), by= list(nomgeo)] %>% 
#   setorder(-sumaMigracion) 
# 
# migrationData %>%  dim
# 
# migrationData2 <- merge(migrationData, totals, by='nomgeo') #%>% 
#   # data.table %>% 
#   .[, sumaMigracion:= as.numeric(sumaMigracion)] %>% 
#   # .[, rank := frankv(-sumaMigracion), by= list(nomgeo)] %>% 
#   # .[, rankState := paste0(as.character(rank), '-', nomgeo)] %>% 
#   # st_as_sf()
# 

# migrationData2 %>%  filter(rank==1)


# municipalityData['region'] = np.where(municipalityData['NOM_ENT'].isin(['Baja California', 
#                                                                         'Baja California Sur', 'Sonora', 'Chihuahua', 'Sinaloa', 'Durango']), 'Noroeste',
#                                       np.where(municipalityData['NOM_ENT'].isin(['Coahuila de Zaragoza', 'Nuevo León', 'Tamaulipas']), 'Noreste', 
#                                                np.where(municipalityData['NOM_ENT'].isin(['Zacatecas', 'Aguascalientes', 'San Luis Potosí', 'Querétaro', 'Guanajuato']), 'Centro Norte',
#                                                         np.where(municipalityData['NOM_ENT'].isin(['México', 'Ciudad de México', 'Morelos']), 'Centro Sur',
#                                                                  np.where(municipalityData['NOM_ENT'].isin(['Nayarit', 'Jalisco', 'Colima', 'Michoacán de Ocampo']), 'Occidente',
#                                                                           np.where(municipalityData['NOM_ENT'].isin(['Hidalgo', 'Puebla', 'Tlaxcala', 'Veracruz de Ignacio de la Llave']), 'Oriente',
#                                                                                    np.where(municipalityData['NOM_ENT'].isin(['Guerrero', 'Oaxaca', 'Chiapas']), 'Suroeste', 'Sureste'))))))
# )





# migrationData %>%
#   st_write("./Data/Day_25Data/Migration_data.shp") 


# plot(statesMap)
# plot(pointsDataSf)
# 
# data(World, rivers)
# tm_shape(World) +
#   tm_fill() +
#   tm_shape(rivers) +
#   tm_lines(col="black", lwd="scalerank", scale=2, legend.lwd.show = FALSE) +
#   tm_style("cobalt", title = "Rivers of the World") +
#   tm_format("World")
