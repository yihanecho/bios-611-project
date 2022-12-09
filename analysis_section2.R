
#setwd("/Users/yihantang/Library/CloudStorage/OneDrive-UniversityofNorthCarolinaatChapelHill/bios-611-project/")
library(tidyverse)
library(dplyr)
library(randomForest)
library(caret)
library(gridExtra)
library(scales)
select <- dplyr::select
dat_fetal <- read.csv("./source_data/fetal_health.csv")


Df <- dat_fetal %>%
  mutate(fetal_cat = ifelse(fetal_health == 1, "Normal", 
                            ifelse(fetal_health == 2, "Suspect", "Pathological")))
colSums(is.na(Df))
Df$fetal_health=as.factor(Df$fetal_health)
levels(Df$fetal_health)<-list(Normal="1",Suspect="2",Pathological="3")   
str(Df)

set.seed(1234)
ind<-sample(2,nrow(Df),replace=TRUE,prob=c(0.7,0.3))
train<-Df[ind==1,]
test<-Df[ind==2,]

set.seed(223)
rf<-randomForest(fetal_health~. -fetal_cat,data=train)
print(rf)

p1<-predict(rf,train)
head(p1)
confusionMatrix(p1,train$fetal_health)

p2<-predict(rf,test)
head(p2)
confusionMatrix(p2,test$fetal_health)

png(filename = "./figures/figure23.png", width = 1000, height = 850, units = "px")
plot(rf)
dev.off()


#tuneRF(train[,-22],train[,22],stepFactor=0.5,plot=TRUE,ntreeTRY=300,trace=TRUE,improve=0.05)



set.seed(333)
rf1<-randomForest(fetal_health~. -fetal_cat ,data=train,ntree=300,mtry=8,importance=TRUE,proximity=TRUE)
print(rf)
#png(filename = "./figures/figure21.png", width = 1000, height = 850, units = "px")
#varImpPlot(rf1,sort=TRUE,n.var=10)
#dev.off()

importance(rf1)
varUsed(rf1)
# Partial Dependency Plot

png(filename = "./figures/figure22.png", width = 1000, height = 850, units = "px")
par(mfrow=c(1,3))
partialPlot(rf1,train,abnormal_short_term_variability,"Normal")
partialPlot(rf1,train,abnormal_short_term_variability,"Suspect")
partialPlot(rf1,train,abnormal_short_term_variability,"Pathological")
dev.off()


