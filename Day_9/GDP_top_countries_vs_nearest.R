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
library(tmap)

## Origin of data
# https://data.worldbank.org/indicator/NY.GDP.MKTP.CD
# https://www.naturalearthdata.com/downloads/50m-cultural-vectors/


# Load Data ---------------------------------------------------------------


setwd('C:/Users/fernando.dorantes/local/Git_repositories/')


gdpData <- fread('Repo30DayMapChallenge2024/Data/GDP_per_country_worldbank/API_NY.GDP.MKTP.CD_DS2_en_csv_v2_9865.csv', 
      skip= 4, header=TRUE)


countriesData <- st_read('Repo30DayMapChallenge2024/Data/ne_50m_admin_0_countries/ne_50m_admin_0_countries.shp') %>% 
  data.table()


# Data Manipulation ---------------------------------------------------------------

names(gdpData) <- gsub('[[:space:]]', '_',  tolower(names(gdpData)))
names(countriesData) <- tolower(names(countriesData))


gdpDataSelected <- gdpData[, c('country_name', 'country_code', 'indicator_name', 'indicator_code',
            '2022', '2023')]

countriesData<- countriesData[, c('featurecla', 'scalerank', 'labelrank', 'sovereignt', 'sov_a3',
                  'adm0_diff', 'level', 'type', 'tlc', 'admin', 'adm0_a3', 'geounit', 
                  'name', 'name_long', 'postal', 'pop_est', 'pop_rank', 'pop_year', 
                  'gdp_md', 'gdp_year', 'economy', 'income_grp', 'iso_a3', 'adm0_iso', 
                  'wikidataid', 'name_en', 'name_es', 'continent','region_un',  'geometry')]


gdpDataSelected <- gdpDataSelected %>%  setnames(old=c('2022', '2023'), new=c('gdp_2022', 'gdp_2023'))

gdpDataSelected <- gdpDataSelected[, gdp_2022 := as.numeric(gdp_2022)] %>% 
  .[, gdp_2023 := as.numeric(gdp_2023)] %>% 
  .[, gdp_last := ifelse(is.na(gdp_2023), gdp_2022, gdp_2023)]


gdpDataMap <- merge(gdpDataSelected, countriesData, by.x='country_code', by.y='adm0_a3')

gdpDataMap <- gdpDataMap[order(-gdp_last)]


gdpDataMap <- gdpDataMap[, ranking_gdp := frank(-gdp_last)] 
gdpDataMap <- gdpDataMap %>%  st_as_sf %>%  
  mutate(centroid := st_centroid(geometry))

top10Gdp <- gdpDataMap %>%  data.table %>%  .[ranking_gdp<= 10] %>% 
  st_as_sf

limit_distance <- set_units(10000, "km")

topCountries <- top10Gdp$country_code %>%  unique

continents <- gdpDataMap$region_un %>%  unique

# topCountries <- c(topCountries, 'MEX')

gdpComparisonList <- lapply(topCountries, function(x){
  selectedCountry <- x
  print(selectedCountry)
  countrytoTest <- gdpDataMap %>% 
    filter(country_code== selectedCountry)
  
  selectedCountryName <- countrytoTest$country_name
  otherCountries <- gdpDataMap %>% 
    filter(country_code!= selectedCountry)
  
  target_gdp <- countrytoTest$gdp_last %>%  as.numeric
  superior_gdp <- gdpDataMap %>%  filter(gdp_last> target_gdp)
  countries_superior <- superior_gdp$country_code %>%  unique 

  if(selectedCountry %in% c('CHN', 'USA')){
    continentFilter <- c('Americas', 'Europe', 'Asia')
  }else{
    continentFilter <- countrytoTest$region_un
  }
  print(continentFilter)
  
  otherCountries <- otherCountries %>% 
    filter(!country_code %in% countries_superior) %>% 
    filter(region_un %in% continentFilter)
  

  distances <- st_distance(countrytoTest$centroid, otherCountries$centroid)
  distances <- set_units(distances, "km")
  distances <- as.numeric(distances)
  
  otherCountries <- otherCountries %>% 
    mutate(distance_to_top = distances) %>% 
    arrange(distance_to_top) %>% 
    filter(!is.na(gdp_last)) 
 
  otherCountries <- otherCountries %>% 
    mutate(cumulative_gdp = cumsum(gdp_last))
  
  # print(unique(otherCountries$country_code))
  otherCountries <- otherCountries %>% 
    filter(cumulative_gdp <= target_gdp * 1.05) 
  
  
  countrytoTest <- countrytoTest %>% 
    mutate(country_to_compare = selectedCountry) %>% 
    mutate(country_name_to_compare = selectedCountryName) %>% 
    mutate(category = 'Country to compare')
  
  otherCountries <- otherCountries %>% 
    mutate(country_to_compare = selectedCountry) %>% 
    mutate(country_name_to_compare = selectedCountryName) %>% 
    mutate(category = 'All nearest countries that match its gdp')
  print(unique(otherCountries$country_code))
  mainDf <- bind_rows(countrytoTest, otherCountries)
  return(mainDf)
})

gdpComparison <- bind_rows(gdpComparisonList)

gdpComparison %>% 
  st_as_sf() %>% 
  ggplot()+
  geom_sf(aes(fill = category)) +
  facet_wrap(~country_name_to_compare)


tm_shape(gdpComparison) +
  tm_polygons(
    'category', 
    title = 'Countries', 
    border.alpha = 0.9,
    border.col='transparent'
  )+
  tm_facets(by='country_name_to_compare')



gdpComparison %>% 
  select(-c('centroid')) %>% 
  st_as_sf() %>% 
  st_write("Repo30DayMapChallenge2024/Data/countries_gdp_comparison.geojson", driver = "GeoJSON")

# selectedCountry <- 'USA'
# 
# testCountry <- gdpDataMap %>%  filter(country_code==selectedCountry)
# target_gdp_test <- testCountry$gdp_last
# continent <- testCountry$region_un
# target_gdp_test
# 
# testCountries <- gdpDataMap %>%  filter(country_code!= selectedCountry) %>% 
#   data.frame()
# 
# distancesTest <- st_distance(testCountry$centroid, testCountries$centroid)
# distancesTest <- set_units(distancesTest, "km")
# distancesTest <- as.numeric(distancesTest)
# 
# dim(testCountries)
# 
# testCountries <- testCountries %>% 
#   mutate(distance_to_top = distancesTest) %>% 
#   arrange(distance_to_top) %>% 
#   filter(!is.na(gdp_last))
# 
# 
# testCountries <- testCountries %>% 
#   mutate(cumulative_gdp = cumsum(gdp_last))
# 
# testCountries <- testCountries %>% 
#   filter(cumulative_gdp <= target_gdp_test * 1.05) 
# 
# 
# testCountry <- testCountry %>% 
#   mutate(country_to_compare = selectedCountry) %>% 
#   mutate(category = 'County to compare')
# 
# testCountries <- testCountries %>% 
#   mutate(country_to_compare = selectedCountry) %>% 
#   mutate(category = 'All nearest countries that match its gdp')
# 
# mainDf <- bind_rows(testCountry, testCountries)
# 
# 
# mainDf %>% 
#   st_as_sf() %>% 
#   ggplot()+
#   geom_sf(aes(fill = category)) 
# 
# 

