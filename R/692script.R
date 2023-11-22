#European Social Survey Script##################################################
################################################################################
#Note that for these data the following values are generally coded:
#77 or 777 == Refusal to Answer
#88 or 888 == Don't Know
#99 or 999 == No Answer

#Load packages##################################################################
packs = c('dplyr','ggplot2','AppliedPredictiveModeling', 'caret','corrplot','doParallel',
          'glmnet','earth','kernlab','xgboost','ranger','rpart','pROC','e1071','generalhoslem',
          'MASS','arm')
lapply(packs,require,character.only=TRUE)
rm(packs)
################################################################################
setwd("C:/Users/rockc/OneDrive/Documents/A&M/2023/Summer 2023/STAT 692/ESS")
df <- read.csv("originalData.csv")
vars <- read.csv('variables.csv')
countries <- c(unique(df$cntry))
cntrySpecificVars <- vars$Name[which(vars$Country_specific=='yes')]
cntryNonspecificVars <- vars$Name[which(vars$Country_specific=='no')]
#Function to extract last n characters in a string##############################
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
#Creating separate country datasets#############################################
sweden <- df[which(df$cntry=='SE'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='se')],cntryNonspecificVars)]
austria <- df[which(df$cntry=='AT'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='at')],cntryNonspecificVars)]
belgium <- df[which(df$cntry=='BE'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='be')],cntryNonspecificVars)]
switzerland <- df[which(df$cntry=='CH'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='ch')],cntryNonspecificVars)]
czech <- df[which(df$cntry=='CZ'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='cz')],cntryNonspecificVars)]
germany <- df[which(df$cntry=='DE'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='de')],cntryNonspecificVars)]
estonia <- df[which(df$cntry=='EE'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='ee')],cntryNonspecificVars)]
spain <- df[which(df$cntry=='ES'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='es')],cntryNonspecificVars)]
finland <- df[which(df$cntry=='FI'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='FI')],cntryNonspecificVars)]
france <- df[which(df$cntry=='FR'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='fr')],cntryNonspecificVars)]
britain <- df[which(df$cntry=='GB'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='gb')],cntryNonspecificVars)]
hungary <- df[which(df$cntry=='HU'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='hu')],cntryNonspecificVars)]
ireland <- df[which(df$cntry=='IE'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='ie')],cntryNonspecificVars)]
israel <- df[which(df$cntry=='IL'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='il')],cntryNonspecificVars)]
iceland <- df[which(df$cntry=='IS'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='is')],cntryNonspecificVars)]
italy <- df[which(df$cntry=='IT'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='it')],cntryNonspecificVars)]
lithuania <- df[which(df$cntry=='LT'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='lt')],cntryNonspecificVars)]
netherlands <- df[which(df$cntry=='NL'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='nl')],cntryNonspecificVars)]
norway <- df[which(df$cntry=='NO'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='no')],cntryNonspecificVars)]
poland <- df[which(df$cntry=='PL'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='pl')],cntryNonspecificVars)]
portugal <- df[which(df$cntry=='PT'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='pt')],cntryNonspecificVars)]
russia <- df[which(df$cntry=='RU'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='ru')],cntryNonspecificVars)]
slovenia <- df[which(df$cntry=='SI'),c(vars$Name[which(substrRight(cntrySpecificVars,2)=='si')],cntryNonspecificVars)]
################################################################################
#check columns with excessive missing values####################################
results <- rep(0,ncol(sweden))
for(i in 1:ncol(sweden)){results[i] <- length(which(is.na(sweden[,i])))}
sweden <- sweden[,which(results==0)]
################################################################################
#remove columns with no information#############################################
results <- rep(0,ncol(sweden))
for(i in 1:ncol(sweden)){results[i] <- length(unique(sweden[,i]))}
colnames(sweden)[which(results==1)]
varlist <- which(results==1)[-2]
sweden <- sweden[,-c(varlist)]

#hand-picking features for inclusion###########################################
myVars <- c('nwspol','netustm','ppltrst','psppsgva','trstlgl','trstplc','trstplt',
           'trstprl','vote','lrscale','stfgov','stfedu','stfhlth','gincdif','imbgeco',
           'imueclt','imwbcnt','sclmeet','crmvct','aesfdrk','health','atchctr',
           'rlgblg','dscrgrp','ctzcntr','wrdpimp','wrdpfos','wrinspw','clmchng',
           'ccnthum','wrclmch','lknemny','agea','dvrcdeva','chldhm','domicil','eduyrs',
           'uempla','dsbld','rtrd','hswrk','emplrel','wkdcorga','wkhtot','hincfel',
           'ipcrtiv','imprich','impsafe','impdiff','ipfrule','ipudrst','ipmodst',
           'ipgdtim','impfree','iphlppl','ipstrgv','ipadvnt','ipbhprp','iprspot',
           'iplylfr','impenv','imptrad','impfun')
swedenX <- sweden[,names(sweden) %in% myVars]

numericVars <- c('nwspol','netustm','agea','eduyrs','wkhtot')
factorVars  <- subset(colnames(swedenX), !(colnames(swedenX) %in% numericVars))
#possible response variables####################################################
swedenY <- sweden[,names(sweden) %in% c('stflife','happy')]

#cleaning factor variables with "no answer", "refusal", or "don't know" responses
fullData$ppltrst[which(fullData$ppltrst=='77')] <- NA #refusal
fullData$ppltrst[which(fullData$ppltrst=='88')] <- NA #don't know
fullData$ppltrst[which(fullData$ppltrst=='99')] <- NA #no answer
fullData$ppltrst <- droplevels(fullData$ppltrst)
fullData$ppltrst <- as.numeric(fullData$ppltrst)

#For loop for running median imputation on numeric columns########################
for(j in 1:ncol(numericData)) {
  for(i in 1:nrow(numericData)){if(is.na(numericData[i,j])==TRUE)numericData[i,j] <- median(numericData[,j],na.rm=TRUE)}
}

#training/test splits###########################################################
X <- fullDataImpute[,-24]
Y <- fullDataImpute$happy
n <- nrow(X)
trainIndex = createDataPartition(X$cntry, p = .5, list = FALSE) %>% as.vector(.)
validSplit = createDataPartition(X$cntry[-trainIndex], p = .5, list = FALSE) %>% as.vector(.)
validIndex = (1:n)[-trainIndex][validSplit]
testIndex  = (1:n)[-trainIndex][-validSplit]
role       = rep('train',n)
role[testIndex]  = 'test'
role[validIndex] = 'validation'
rm(validSplit)
Xtrain      = data.frame(X = X[role == 'train',])
Ytrain      = Y[role == 'train']
Xvalid      = data.frame(X = X[role == 'validation',])
Yvalid      = Y[role == 'validation']
Xtest      = data.frame(X = X[role == 'test',])
Ytest      = Y[role == 'test']
rm(n,role,testIndex,trainIndex,validIndex)

#Create Dummy Variables for Factor Variables####################################
XtrainFact <- Xtrain[,1:14]
XvalidFact <- Xvalid[,1:14]
XtestFact <- Xtest[,1:14]
dummyModel  = dummyVars(~ ., data = XtrainFact, fullRank = TRUE)
XtrainDummy = predict(dummyModel, XtrainFact)
dummyModel  = dummyVars(~ ., data = XvalidFact, fullRank = TRUE)
XvalidDummy = predict(dummyModel, XvalidFact)
dummyModel  = dummyVars(~ ., data = XtestFact, fullRank = TRUE)
XtestDummy  = predict(dummyModel, XtestFact)
XtrainFull <- cbind(XtrainDummy,Xtrain[,15:57])
XvalidFull <- cbind(XvalidDummy,Xvalid[,15:57])
XtestFull <- cbind(XtestDummy,Xtest[,15:57])
rm(XtrainFact,XvalidFact,XtestFact,dummyModel,XtrainDummy,XvalidDummy,XtestDummy)




#Logistic Models################################################################
#Here, happy<7 is 'unhappy' and happy>=7 is 'happy'#############################
YtrainBinary    <- Ytrain
YtrainBinary    <- ifelse(Ytrain < 7, 0, 1)
YtrainBinary    <- as.factor(YtrainBinary)
YtestBinary    <- Ytest
YtestBinary    <- ifelse(Ytest < 7, 0, 1)
YtestBinary    <- as.factor(YtestBinary)

set.seed(12345)
trControl       <- trainControl(method = 'cv', number = 10)
outLogisticFull <- train(x = Xtrain, y = YtrainBinary,
                    method = 'glm', trControl = trControl)
summary(outLogisticFull)
#remove some variables from model based on p-values
#re-categorize atchctr variable and remove original atchctr variable
rmList <- c(42,9,29,51,30,52,46,55,3,49,18,28,44,11,40,32,14,41,54,48,31,12,13,53,47,57,38,56,6,25)
XtrainrmList <- Xtrain[,-rmList]
XtrainrmList$X.atchctrRECAT <- ifelse(Xtrain$X.atchctr < 7, 0, 1)
XtrainrmList$X.atchctrRECAT <- as.factor(XtrainrmList$X.atchctrRECAT)
XtrainrmList <- XtrainrmList[,-18]

XtestrmList <- Xtest[,-rmList]
XtestrmList$X.atchctrRECAT <- ifelse(Xtest$X.atchctr < 7, 0, 1)
XtestrmList$X.atchctrRECAT <- as.factor(XtestrmList$X.atchctrRECAT)
XtestrmList <- XtestrmList[,-18]
########

outLogistic2    <- train(x = XtrainrmList, y = YtrainBinary,
                         method = 'glm', trControl = trControl)
summary(outLogistic2)
YhatLogisticProb <- predict(outLogistic2$finalModel, XtestrmList,
                       type = 'response')
YhatLogistic0.53 <- ifelse(YhatLogisticProb > .53, '1', '0')%>%
  as.factor
confusionMatrix(data = YhatLogistic0.53,
                reference = YtestBinary, positive = '1')
ROC <- roc(YtestBinary,YhatLogisticProb)
plot(ROC)
ROC$auc
#best results with threshold 0.53
#accuracy 0.8083
#sensitivity 0.9318
#specificity 0.4116
#AIC 18763
#AUC 0.8136

#Check if numeric features are linear in log odds of YtrainBinary
YtrainBinaryNum <- as.numeric(YtrainBinary)
YtrainBinaryNum <- YtrainBinaryNum - 1

x <- XtrainrmList$X.ppltrst
q <- quantile(x,probs=seq(0,1,0.25))
p1 <- mean(YtrainBinaryNum[x<q[2]])
p2 <- mean(YtrainBinaryNum[x>=q[2] & x<q[3]])
p3 <- mean(YtrainBinaryNum[x>=q[3] & x<q[4]])
p4 <- mean(YtrainBinaryNum[x>=q[4]])
probs <- c(p1,p2,p3,p4)
logits <- log(probs/(1-probs))
meds <- c(median(x[x<q[2]]),median(x[x>=q[2] & x<q[3]]),median(x[x>=q[3] & x<q[4]]),median(x[x>=q[4]]))
plot(meds,logits,)
#check outLogistic2 model goodness of fit for binomial
#null is no lack of fit, alternative is that there is a lack of fit
logitgof(YtrainBinary,fitted(outLogistic2$finalModel))
#X-squared Test Statistic = 15.369
#df = 8
#p-value = 0.05236

#create binned residual plot for residual analysis
binnedplot(fitted(outLogistic2$finalModel), 
           residuals(outLogistic2$finalModel, type = "response"), 
           nclass = NULL, 
           xlab = "Expected Values", 
           ylab = "Average residual", 
           main = "Binned residual plot", 
           cex.pts = 0.8, 
           col.pts = 1, 
           col.int = "gray")


#SVM Classification modeling####################################################
#Here, happy 0-3 is 'unhappy' or '1', happy 4-6 is 'somewhat happy' or '2',#####
#and happy 7-10 is 'happy' or '3'###############################################
Ytrain3cat <- Ytrain
for(i in 1:length(Ytrain3cat)){
  Ytrain3cat[i] <- if(Ytrain[i] < 4) 1 
  else if(Ytrain[i] < 7) 2
  else 3
  }
Ytrain3cat <- as.factor(Ytrain3cat)

svmGrid = expand.grid(C = c(.001,.01,.1,1,10,50),
                      degree = c(1,2,3),
                      scale = c(.1,1,10,50,100))
svmPolyOut = train(x = Xtrain, y = YtrainBinary,
                   method = "svmPoly",
                   tuneGrid = svmGrid,
                   trControl = trainControl(method = 'cv'))
#This model fitting is taking TOO LONG




################################################################################
#KNN model fitting##############################################################
trControl <- trainControl(method = 'cv', number = 10, verboseIter=TRUE)
tuneGrid  <- expand.grid(k = c(1,2,11,51,101,180))
knnOut = train(x = XtrainFull, y = Ytrain3cat,
               method = "knn",
               tuneGrid = tuneGrid,
               trControl = trControl)
#create 3 category version of Ytest set#########################################
Ytest3cat <- Ytest
for(i in 1:length(Ytest3cat)){
  Ytest3cat[i] <- if(Ytest[i] < 4) 1 
  else if(Ytest[i] < 7) 2
  else 3
}
Ytest3cat <- as.factor(Ytest3cat)
#create binary version of Ytest set#############################################
YtestBinary    <- Ytest
YtestBinary    <- ifelse(Ytest < 7, 0, 1)
YtestBinary    <- as.factor(YtestBinary)

YhatKNNProb  <- predict(knnOut$finalModel,XtestFull)
YhatKNN <- rep(0,nrow(YhatKNNProb))
for(i in 1:length(YhatKNN)){YhatKNN[i] <- which.max(YhatKNNProb[i,])}
knnAccuracy <- 1- (length(which(YhatKNN != Ytest3cat))/length(Ytest3cat))
knnAccuracy 
#76.81% accuracy with 3 category response
#77.15% accuracy with binary response





################################################################################
#Boosting Trees#################################################################
tuneGrid = data.frame('nrounds'=10000,
                       'max_depth' = 1,
                       'eta' = .01,
                       'gamma' = 0,
                       'colsample_bytree' = 1,
                       'min_child_weight' = 0,
                       'subsample' = 0.5)
boostOut = train(x = XtrainFull, y = Ytrain,
                 method = "xgbTree",
                 tuneGrid = tuneGrid,
                 trControl = trainControl(method = 'cv', number = 10, verboseIter=TRUE))
boostPred <- predict(boostOut$finalModel,as.matrix(XtestFull))
boostMSE <- mean((Ytest-boostPred)**2) #2.308907


