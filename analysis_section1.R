library(tidyverse)
library(dplyr)
library(tidyr)
library(ggplot2)
library(gridExtra)
library(scales)
select <- dplyr::select

# Data read in 
#setwd("/Users/yihantang/Library/CloudStorage/OneDrive-UniversityofNorthCarolinaatChapelHill/bios-611-project/")
dat_fetal <- read.csv("./derived_data/fetal_health_new.csv")


## Visualisations
Df_num  <- dat_fetal %>% 
  gather(variable, values, 1:dim(dat_fetal)[2])


Df_num %>% ggplot() +
  geom_boxplot(aes(x = variable, y = values)) +
  facet_wrap(~variable, ncol = 6, scales = "free")+
 theme(strip.text.x = element_blank(), text = element_text(size = 9))+
  theme_minimal()

png(filename = "./figures/figure1.png", width = 1000, height = 850, units = "px")
p <- grid.arrange(p1, ncol = 1)
dev.off()


## Selective Distribution by fetal Health
Df <- dat_fetal %>%
  mutate(fetal_cat = ifelse(fetal_health == 1, "Normal", 
                            ifelse(fetal_health == 2, "Suspect", "Pathological"))) %>%
  select(fetal_cat, baseline.value:mean_value_of_long_term_variability, histogram_median, 
         accelerations:percentage_of_time_with_abnormal_long_term_variability, 
         histogram_number_of_zeroes:histogram_variance)



p2 <- Df %>%
  pivot_longer(baseline.value:histogram_variance) %>%
  ggplot(aes(x = factor(fetal_cat), y = value, color = fetal_cat)) + 
  geom_boxplot(size = 1, outlier.shape = 1, outlier.color = "black", outlier.size = 3) +
  geom_jitter(alpha = 0.5, width =  0.2) +
  facet_wrap(~name, ncol = 2, scales = "free") +
  theme(strip.text.x = element_blank(), text = element_text(size = 9)) +
  scale_y_continuous(label = comma) +
  coord_flip()

png(filename = "./figures/figure2.png", width = 1000, height = 850, units = "px")
p <- grid.arrange(p2, ncol = 1)
dev.off()










