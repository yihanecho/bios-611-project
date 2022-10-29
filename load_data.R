library(tidyverse)
library(dplyr)
library(tidyr)
library(ggplot2)
library(gridExtra)
library(scales)
select <- dplyr::select

# Data clean
#setwd("/Users/yihantang/Library/CloudStorage/OneDrive-UniversityofNorthCarolinaatChapelHill/bios-611-project/")
dat_fetal <- read.csv("./source_data/fetal_health.csv")

colSums(is.na(dat_fetal))
dat_fetal$fetal_health=as.factor(dat_fetal$fetal_health)
levels(dat_fetal$fetal_health)<-list(Normal="1",Suspect="2",Pathological="3")   
str(dat_fetal)

d  <- dat_fetal  %>% na.omit() %>% mutate(fetal_health=as.factor(fetal_health), )

write.csv(d, "./derived_data/fetal_health_new.csv")
print(paste0("./derived_data/fetal_health_new.csv saved.", " #row: ", nrow(d.us)))




