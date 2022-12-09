

#install.packages("h2o")
library(MASS)
library(tidyverse)
library(tidyr)
library(ggplot2)
library(h2o)


#setwd("/Users/yihantang/Library/CloudStorage/OneDrive-UniversityofNorthCarolinaatChapelHill/bios-611-project/")
dat_fetal <- read.csv("./source_data/fetal_health.csv")
features <- setdiff(colnames(dat_fetal),'fetal_health')
target <- 'fetal_health'

Df <- dat_fetal %>%
  mutate(fetal_health = ifelse(fetal_health == 1, 0, 1))

ind<-sample(2,nrow(Df),replace=TRUE,prob=c(0.7,0.3))
train<-Df[ind==1,]
test<-Df[ind==2,]

fit= glm( fetal_health ~. , data = train)%>%
  stepAIC(trace = FALSE)
summary(fit)


# Make predictions
probabilities <- fit%>% predict(test, type = "response")
predicted.classes <- ifelse(probabilities > 0.5, 1, 0)
# Prediction accuracy
observed.classes <- test$fetal_health
mean(predicted.classes == observed.classes)
