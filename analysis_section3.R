library(dplyr)
library(forcats)
library(ggplot2)
library(ggrepel)
library(sf)
library(tmap)
library(readr)
library(stringr)
select <- dplyr::select

# Spatial map ========================================================================

# Read in boundary data
state.remove <- c("HI", "AK")
zip.boundary <- st_read("./source_data/US_State/cb_2018_us_state_500k.shp",
                        quiet = TRUE) %>%
  select(STUSPS, NAME, geometry) %>%
  filter(!(STUSPS %in% state.remove))


# Make summary data
state.d <- read_csv("./derived_data/Salary_State.csv") %>%
  group_by(PRIM_STATE) %>%
  summarise(TOT_EMP = sum(TOT_EMP), Mean_Wage = mean(H_MEAN)) %>%
  filter(!(PRIM_STATE %in% state.remove))

# Meta data
sp.d <- zip.boundary %>% right_join(state.d, by = c("STUSPS" = "PRIM_STATE"))
sp.d <- st_make_valid(sp.d)

# Set mode
tmap_mode("view")

# Map Mean_Wage and TOT_EMP
p <- tm_shape(sp.d) +
  tm_polygons(col = c("Mean_Wage", "TOT_EMP"),
              style = "jenks",
              palette = "YlGn") +
  tm_layout(
            main.title.position = "center",
            main.title.size = 1,
            legend.position = c("left", "bottom")) +
  tm_facets(ncol = 2, sync = TRUE)

tmap_save(p, filename = "./figures/figure31.png")


# Employment vs Hourly Wage across States==========================================================

d.state <- read_csv("./derived_data/Salary_State.csv")

d.state.all <- d.state %>% filter(OCC_TITLE == "All")
plot.d <- d.state.all %>% select(PRIM_STATE, TOT_EMP, H_MEAN, A_MEAN) %>%
  arrange(H_MEAN)

png(p, filename = "./figures/figure32.png", width = 900, height = 700, units = "px")

ggplot(data = plot.d) +
  aes(x=TOT_EMP, y=H_MEAN, size=TOT_EMP*1000) + geom_point(alpha=0.5, col='blue') +
  geom_label_repel(aes(label = PRIM_STATE),
                   box.padding   = 0.1,
                   point.padding = 0.05,
                   segment.color = 'grey50',
                   label.size = 0.7,
                   max.overlaps = 60) +
  xlab("Total Employment") +
  ylab("Mean Hourly Wage") +
  theme_classic(base_size = 20)

dev.off()

