library(tidyverse)
library(osmdata)
library(tigris)
library(rnaturalearth)
library(sf)
library(ggtext)
library(glue)
library(MetBrewer)

hort <- opq("Hortonia, Wisconsin") %>%
  add_osm_feature(key = "boundary") %>%
  osmdata_sf()

hort_polys <- hort$osm_multipolygons %>%
  filter(str_detect(name, "Horton"))

s <- states() 


l <- ne_download(type = "lakes", category = "physical", scale = "large")  %>%
  st_as_sf(., crs = st_crs(4326))

gl <- l %>% 
  filter(name %in% c("Lake Michigan", "Lake Superior")) %>%
  st_union()

wi <- s %>%
  filter(NAME == "Wisconsin") %>%
  st_transform(., crs = st_crs(gl))

wi_trim <- st_difference(wi, gl)


hort_polys %>%
  ggplot() +
  geom_sf() +
  theme_void()

wi_trim %>%
  ggplot() +
  geom_sf(size = .01, fill = "grey70") +
  geom_sf(data = hort_polys, fill = "red", size = .05) +
  coord_sf(expand = c(0,0)) +
  theme_void() +
  theme(plot.title = element_textbox(margin = margin(t = 5, b = 10),
                                     size = 20, hjust = .5),
        plot.caption = element_textbox(hjust = .5,
                                       margin = margin(t = 10, b = 10),
                                       color = "grey70")) +
  labs(title = glue("<span style='color:red'>Hortonville</span> and ",
                    "<span style='color:red'>Hortonia</span> locations within Wisconsin"),
       caption = "Graphic by Spencer Schien (@MrPecners)")

ggsave(filename = "plots/wi_map.png", bg = "grey95")

c <- met.brewer("Egypt")

hort_polys[1,] %>%
  ggplot() +
  geom_sf(fill = alpha(c[1], .5), color = "white", size = .1) +
  geom_sf_text(aes(label = name), color = c[1], size = 5, fontface = "bold") +
  geom_sf(data = hort_polys[2,], fill = alpha(c[3], .5), color = "white", size = .1) +
  geom_sf_text(data = hort_polys[2,], aes(label = name), color = c[3],
               size = 5, fontface = "bold") +
  coord_sf(expand = c(.001, 0)) +
  theme_void() +
  theme(plot.title = element_textbox(margin = margin(t = 5, b = 10),
                                     size = 20, hjust = .5),
        plot.caption = element_textbox(hjust = .5,
                                       margin = margin(t = 5, b = 0),
                                       color = "grey70")) +
  labs(title = glue("A <span style='color:{c[3]}'>**Hor**</span>",
                    "<span style='color:{c[1]}'>**ton**</span> divided against itself"),
       caption = "Graphic by Spencer Schien (@MrPecners)")

ggsave(filename = "plots/hortons_map.png", bg = "grey95")
