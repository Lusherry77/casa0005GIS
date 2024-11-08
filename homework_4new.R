library(here)
library(tidyverse)
library(sf)
library(janitor)
library(tmap)


# read .csv数据
Report_CompositeData <- read.csv(here::here("HDR23-24_Composite_indices_complete_time_series.csv"),
                                 header = TRUE, sep = ",",
                                 encoding = "latin1")
# na=" " read.csv和read_csv的区别

Shape_World_countries <- st_read(here::here("World_Countries_Generalized.geojson"))

# 处理.csv数据
Gii_only <- Report_CompositeData %>%
  janitor::clean_names(.) %>%
  dplyr::select(contains("iso3"),
                contains("country"),
                contains("gii_2010"),
                contains("gii_2019")) %>%
  mutate(gii_difference = gii_2019 - gii_2010) %>%
  dplyr::select(contains("iso3"),
                contains("country"),
                contains("gii_difference"),
                gii_2010:gii_2019)

# join .csv到spatial data
join_data <- Shape_World_countries %>%
  left_join(Gii_only, by = c("COUNTRY" = "country"))
head(join_data)
# 可以把三位变成两位再join

# 画图
tmap_mode("plot")
tm_shape(join_data) + 
  tm_polygons("gii_difference",palette = "RdYlGn", title = "GII Difference(2010-2019)")+ 
  tm_layout(main.title = "Global Gender Inequality Index Difference(2010-2019)")
