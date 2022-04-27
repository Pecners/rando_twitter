library(tidyverse)
library(magick)
library(glue)

df <- tibble(
  x = 1,
  y = 1,
  lab = "%>%",
  lab_base = "|>"
)

pipe_one <- df %>%
  ggplot(aes(x, y, label = lab)) +
  geom_text(size = 10) +
  theme_void()

pipe_two <- df %>%
  ggplot(aes(x, y, label = lab)) +
  geom_text(size = 50) +
  theme_void()

base_one <- df %>%
  ggplot(aes(x, y, label = lab_base)) +
  geom_text(size = 10) +
  theme_void()

base_two <- df %>%
  ggplot(aes(x, y, label = lab_base)) +
  geom_text(size = 50) +
  theme_void()

ggsave(plot = pipe_one, "plots/pipes_tv_small.png", bg = "white")
ggsave(plot = pipe_two, "plots/pipes_tv_big.png", bg = "white")
ggsave(plot = base_one, "plots/pipes_base_small.png", bg = "white")
ggsave(plot = base_two, "plots/pipes_base_big.png", bg = "white")

files <- list.files("plots")
the_files <- files[which(str_detect(files, "^pipes"))]

imgs_order <- the_files[c(4, 3, 3, 2, 1, 1)]
img_list <- lapply(glue("plots/{imgs_order}"), image_read)

## join the images together
img_joined <- image_join(img_list)

## animate at 2 frames per second
img_animated <- image_resize(img_joined, '800') %>%
  image_animate(fps = 4)
## view animated image
img_animated

## save to disk
image_write(image = img_animated,
            path = "plots/pipes.gif")
