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

setwd('C:/Users/fernando.dorantes/local/Git_repositories/')


populatedPlaces <- st_read('./Repo30DayMapChallenge2024/Data/ne_110m_populated_places/ne_110m_populated_places.shp')

colstoSelect <- c('NAME', 'NAMEASCII', 'ADM0CAP', 'SOV0NAME', 'ISO_A2', 
                  'LATITUDE', 'LONGITUDE', 'NAME_ES', 'ADM0_A3', 'SOV_A3',
                  'POP1950', 'POP1955', 'POP1960', 'POP1965', 'POP1970', 
                  'POP1975', 'POP1980', 'POP1985', 'POP1990', 'POP1995',
                  'POP2000', 'POP2005', 'POP2010', 'POP2015', 'POP2020', 
                  'POP2025', 'POP2050', 'geometry')

populatedPlaces <-  populatedPlaces %>%  
  select(all_of(colstoSelect)) %>% 
  data.table()

populatedPlaces  <- melt(populatedPlaces, id.vars=c('NAME', 'NAMEASCII', 'ADM0CAP', 'SOV0NAME', 'ISO_A2', 
                                'LATITUDE', 'LONGITUDE', 'NAME_ES', 'ADM0_A3', 'SOV_A3', 
                                'geometry'), 
     measure.vars=c('POP1950', 'POP1955', 'POP1960', 'POP1965', 'POP1970', 
                    'POP1975', 'POP1980', 'POP1985', 'POP1990', 'POP1995',
                    'POP2000', 'POP2005', 'POP2010', 'POP2015', 'POP2020', 
                    'POP2025', 'POP2050'), variable.name='population_year', 
     value.name='population')

populatedPlaces<- populatedPlaces[, population:= as.numeric(population)*1000] %>% 
  .[, population_year  := as.character(gsub('POP', '', population_year)) ] 


# populatedPlaces <-  populatedPlaces[ADM0CAP==1 & population > 0]
populatedPlaces <-  populatedPlaces[population > 0]

names(populatedPlaces) <- tolower(names(populatedPlaces))
populatedPlaces <- populatedPlaces[, city_category := ifelse(adm0cap==1, 'Capital',
                                          'Other Cities')]


# populatedPlaces[sov0name=='Mexico' ]

populatedPlaces <- populatedPlaces[, population_year := as.integer(population_year)]

test <- populatedPlaces[population_year=='2050']



populatedPlaces <- populatedPlaces %>%
  group_by(name) %>%
  mutate(lat = first(latitude), lon = first(longitude))


test$population

mainMap <- ggplot(populatedPlaces, aes(x= lon, y= lat, size = population, color=city_category))+
  borders("world", colour = "#675a58", fill = "#c0d6e4")+
  geom_point(alpha = 0.7) +
  scale_color_manual(values=c('#008080', '#ff7da3'), name='City Category') +
  scale_size(
    range = c(2, 20),  # Tamaño mínimo y máximo de los puntos
    breaks = as.numeric(c(1e6, 5e6, 10e6, 15e6, 20e6)),
    labels = c("1M", "5M", "10M", "15M", "20M"),
    name='Population'
  )+
  labs(title = "Población de las principales ciudades del mundo: {frame_time}",
       subtitle = "Capitales y ciudades principales secundarias",
       caption= 'Fuente: \n Natural Earth Data \n Autor:  @FerDoranNie \n#30DayMapChallenge2024',
       x = "Longitud", y = "Latitud") +
  xlab('')+
  ylab('')+
  annotation_north_arrow(location = 'bl', 
                         which_north = 'true', 
                         pad_x = unit(0.75, 'in'),
                         pad_y = unit(0.5, 'in'), 
                         style = north_arrow_fancy_orienteering)+
  theme_minimal(base_size = 30) +
  transition_time(population_year) +
  shadow_mark(past = FALSE, future = FALSE)
  

length(populatedPlaces$population_year %>%  unique)
  
animate(mainMap, renderer = gifski_renderer("./Repo30DayMapChallenge2024/images/Cities_population_over_years.gif"), 
        width = 2400, height = 1600, nframes = 300,
         duration=15, transition_states = transition_states(population_year, transition_length = 0, state_length = 1))





set.seed(123)
years <- 2000:2020
cities <- data.frame(
  city = rep(c("Ciudad A", "Ciudad B", "Ciudad C", "Ciudad D", "Ciudad E"), each = length(years)),
  year = rep(years, 5),
  population = sample(50000:1000000, length(years) * 5, replace = TRUE),
  lat = rep(c(19.4, 19.5, 19.6, 19.7, 19.8), each = length(years)),
  lon = rep(c(-99.1, -99.2, -99.3, -99.4, -99.5), each = length(years))
)


map <- ggplot(cities, aes(x = lon, y = lat)) +
  borders("world", colour = "gray85", fill = "gray80") +  # Mapa base
  geom_point(aes(size = population, color = population), alpha = 0.7) +
  scale_color_viridis_c() +
  labs(title = "Población de las principales ciudades del mundo: {frame_time}",
       subtitle = "Capitales y ciudades principales secundarias",
       x = "Longitud", y = "Latitud") +
  xlab('')+
  ylab('')+
  theme_minimal() +
  transition_time(year) +
  shadow_mark()



bars <- cities %>%
  group_by(year) %>%
  top_n(10, population) %>%
  ungroup() %>%
  ggplot(aes(x = reorder(city, population), y = population, fill = population)) +
  geom_col() +
  coord_flip() +
  scale_fill_viridis_c() +
  labs(title = "Top 10 Ciudades más pobladas: {frame_time}",
       x = "Ciudad", y = "Población") +
  theme_minimal() +
  transition_time(year) +
  shadow_mark()


combined <- map / bars  

# combined <- map + bars + plot_layout(ncol = 1, heights = c(3, 2))
animate(combined, renderer = gifski_renderer("./ciudades_poblacion.gif"), nframes = 100)
animate(map, renderer = gifski_renderer("./ciudades_poblacion2.gif"), nframes = 100)
