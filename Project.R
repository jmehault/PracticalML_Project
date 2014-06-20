trainDat <- read.csv("pml-training.csv")

## replace "#DIV/0!" by NA's
trainDat <- replace(trainDat,(trainDat=="#DIV/0!"),"NA")
## remove every variables with NA => 160 -> 60 variables remain
trainDat <- subset(trainDat,select=colSums(is.na(trainDat))<1)

library(ggplot2)
library(caret)
library(FactoMineR)

n <- 10 # number of loops
Acc <- matrix(rep(-1, n*3), ncol=3) # results matrix
ComputeTree <- function(trainDat)
{
  # split training set into train and test set
  inTrain <- createDataPartition(trainDat$classe, p=0.2, list=F)

  testing <- trainDat[-inTrain,]
  train <- trainDat[inTrain,]
  
  # remove non numeric variables but 'classe' variable
  ntrain <- data.frame(train[,-c(1,2,3,4,5,6)])
  ntesting <- data.frame(testing[,-c(1,2,3,4,5,6)])
  
  ######### Selection of variables
  # remove classe variable if in data set
  if ("classe" %in% names(ntrain)) {
    nacptrain <- subset(ntrain, select=-c(classe))
  }

  # PCA to find important variables in the two first principal axis
  acp <- PCA(nacptrain,scale=T, ncp=10, graph=F)
  # compute contributions on 1st main plan
  contribPP1 <- sqrt(acp$var$coord[,1]**2+acp$var$coord[,2]**2)
  lst <- which( contribPP1 > 0.6 ) # 19 variables keept with 60% on contribution in 1st plan
  lst <- as.data.frame(t(lst))
  keepVar <- names(lst)
  
  # I keep only the variables from PCA
  mtrain <- nacptrain[,c(keepVar)]
  acpm <- PCA(mtrain,scale=T, ncp=10, graph=F) # on voit tres bonne separation de 5 groupes
  
  # normalize data (mean and scale)
  preObj <- preProcess(mtrain, method=c("center","scale"))
  mtrain <- predict(preObj, mtrain)
  
  # add variable to predict
  mtrain$classe <- ntrain$classe
  
  ##### training with one of the three methods
  ## Boosting
  #trControl <- trainControl(method="cv", number=2, allowParallel=T) # control de puissance de calcul
  #modFit <- train(classe~., method="gbm", data=mtrain, verbose=F, trControl=trControl)
  
  ## RandomForest 
  trControl <- trainControl(method="cv",number=2,allowParallel=T) # control de puissance de calcul
  modFit <- train(classe~.,method="rf",data=mtrain,prox=T, trControl=trControl)
  
  ### Bagging
  #BagContrl <- bagControl(fit=ctreeBag$fit, predict=ctreeBag$pred, aggregate=ctreeBag$aggregate) # param de fit
  #modFit <- bag(mtrain[,-dim(mtrain)[2]], mtrain$classe, B=10, bagControl=BagContrl)
  
  
  ########## Cross validation
  ntesting <- subset(ntesting, select=keepVar) # keep variables from PCA
  testingS <- predict(preObj, ntesting) # normalize
  
  pred <- predict(modFit, newdata=testingS)
  conf <- confusionMatrix(testing$classe,pred)
  conf
}

### loop for multiplesampling
for (i in 1:n){
        print(i)
        Conf <- ComputeTree(trainDat)
        Acc[i,] <- Conf$overall[c(1,3,4)] # save accuracy and 95% errors
}

print(c(apply(Acc,2,mean)[1], apply(Acc,2,sd)[1])) # compute mean and 68% error
