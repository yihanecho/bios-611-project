
library(tidyverse)
library(dplyr)
library(randomForest)
library(caret)


set.seed(123)
ind<-sample(2,nrow(health),replace=TRUE,prob=c(0.7,0.3))
train<-health[ind==1,]
test<-health[ind==2,]

set.seed(223)
rf<-randomForest(fetal_health~.,data=train)
print(rf)


p1<-predict(rf,train)
head(p1)
confusionMatrix(p1,train$fetal_health)


p2<-predict(rf,test)
head(p2)
confusionMatrix(p2,test$fetal_health)


plot(rf)

tuneRF(train[,-22],train[,22],stepFactor=0.5,plot=TRUE,ntreeTRY=300,trace=TRUE,improve=0.05)


set.seed(333)
rf1<-randomForest(fetal_health~.,data=train,ntree=300,mtry=8,importance=TRUE,proximity=TRUE)
print(rf)

p1<-predict(rf1,train)
head(p1)
confusionMatrix(p1,train$fetal_health)


hist(treesize(rf1),col="blue")


varImpPlot(rf1,sort=TRUE,n.var=10)
importance(rf1)
varUsed(rf1)

# Partial Dependency Plot
partialPlot(rf1,train,abnormal_short_term_variability,"Normal")
partialPlot(rf1,train,abnormal_short_term_variability,"Suspect")
partialPlot(rf1,train,abnormal_short_term_variability,"Pathological")





