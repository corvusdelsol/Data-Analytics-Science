####################Predictive Modeling of Flight Dataset#######################
require(data.table);require(caret);require(dplyr);require(e1071);require(astsa);
require(xts);require(aTSA);require(glmnet);require(nnet);require(VGAM);require(earth);
require(kernlab);require(klaR)

###############Creating .RData files for each year of data######################
#2019###########################################################################
setwd("C:/Users/rockc/OneDrive/Documents/A&M/2023/Spring 2023/STAT 656/Project/Data/2019")
paths        = dir(getwd(),pattern="2019_",full.names=TRUE)
names(paths) = basename(paths)
dfList       = lapply(paths,read.csv)
df19         = do.call(rbind,dfList)
save(df19, file="2019.Rdata")
rm(paths,dfList,df19)
#2020###########################################################################
setwd("C:/Users/rockc/OneDrive/Documents/A&M/2023/Spring 2023/STAT 656/Project/Data/2020")
paths        = dir(getwd(),pattern="2020_",full.names=TRUE)
names(paths) = basename(paths)
dfList       = lapply(paths,read.csv)
df20         = do.call(rbind,dfList)
save(df20, file="2020.Rdata")
rm(paths,dfList,df20)
#2021###########################################################################
setwd("C:/Users/rockc/OneDrive/Documents/A&M/2023/Spring 2023/STAT 656/Project/Data/2021")
paths        = dir(getwd(),pattern="2021_",full.names=TRUE)
names(paths) = basename(paths)
dfList       = lapply(paths,read.csv)
df21         = do.call(rbind,dfList)
save(df21, file="2021.Rdata")
rm(paths,dfList,df21)
#2022###########################################################################
setwd("C:/Users/rockc/OneDrive/Documents/A&M/2023/Spring 2023/STAT 656/Project/Data/2022")
paths        = dir(getwd(),pattern="2022_",full.names=TRUE)
names(paths) = basename(paths)
dfList       = lapply(paths,read.csv)
df22         = do.call(rbind,dfList)
save(df22, file="2022.Rdata")
rm(paths,dfList,df22)



########################formatting FL_DATE column###############################
df$FL_DATE <- format(as.Date(df$FL_DATE, format = "%m/%d/%Y %H:%M:%S %p"), "%Y/%m/%d")

###################taking random subset of dataframe############################
index <- createDataPartition(dfNC$FL_DATE, p = .05, list = FALSE) %>% as.vector(.)
mysamp <- dfNC[index,]

#creating month and year variables
df = df %>% mutate(MONTH=substr(df$FL_DATE,6,7),YEAR=substr(df$FL_DATE,1,4))

#computing daily mean departure delays##########################################
dailyMeanDepDelay = df %>% group_by(FL_DATE) %>% summarise(ave=mean(DEP_DELAY,na.rm=TRUE))
dailyMeanDepDelay$FL_DATE <- format(as.Date(dailyMeanDepDelay$FL_DATE, format = "%m/%d/%Y %H:%M:%S %p"), "%Y/%m/%d")
dailyMeanDepDelay <- setorder(dailyMeanDepDelay,"FL_DATE")
tsplot(dailyMeanDepDelay$ave,col='dodgerblue',lwd=1.3,main='Differenced Daily Mean Departure Delay',
       ylab='Departure Delay',xaxt="n")
#custom tick marks on plot######################################################
xtick<-c(1,152,366,518,705,856)
axis(side=1, at=xtick, labels = FALSE)
text(x=xtick,  par("usr")[3], 
     labels = c('Jan-19','June-19','Jan-20','June-20','Jan-21','June-21'), srt = 45, pos = 1, xpd = TRUE)

dailyMeanArrDelay = df %>% group_by(FL_DATE) %>% summarise(ave=mean(ARR_DELAY,na.rm=TRUE))
dailyMeanArrDelay$FL_DATE <- format(as.Date(dailyMeanArrDelay$FL_DATE, format = "%m/%d/%Y %H:%M:%S %p"), "%Y/%m/%d")
dailyMeanArrDelay <- setorder(dailyMeanArrDelay,"FL_DATE")
lines(dailyMeanArrDelay$ave,col='red')

#Creating Delay Indicator Factor Variable#######################################
dfNC$DELAY_IND <- ifelse(dfNC$DEP_DELAY<=0 & dfNC$ARR_DELAY_IMP<=0,0,
                         ifelse(dfNC$DEP_DELAY>0 & dfNC$ARR_DELAY_IMP<=0,1,
                                ifelse(dfNC$DEP_DELAY<=0 & dfNC$ARR_DELAY_IMP>0,2,
                                       ifelse(dfNC$DEP_DELAY>0 & dfNC$ARR_DELAY_IMP>0,3,NA))))
dfNC$DELAY_IND <- as.factor(dfNC$DELAY_IND)

#Data Splitting#################################################################
#first take subset of full data################################################
index <- createDataPartition(dfNC19$FL_DATE, p = .025, list = FALSE) %>% as.vector(.)
mysamp <- dfNC19[index,]
mysamp <- mysamp[order(as.Date(mysamp$FL_DATE, format="%Y/%m/%d")),]
rm(index,dfNC19)
#now form training/validation/test splits#######################################
n <- nrow(mysamp)
trainIndex = createDataPartition(mysamp$FL_DATE, p = .5, list = FALSE) %>% as.vector(.)
validSplit = createDataPartition(mysamp$FL_DATE[-trainIndex], p = .5, list = FALSE) %>% as.vector(.)
validIndex = (1:n)[-trainIndex][validSplit]
testIndex  = (1:n)[-trainIndex][-validSplit]
role       = rep('train',n)
role[testIndex]  = 'test'
role[validIndex] = 'validation'
rm(validSplit)
Xtrain      = data.frame(X = mysamp[role == 'train',])
Ytrain      = mysamp$DEP_DELAY[role == 'train']
Xvalid      = data.frame(X = mysamp[role == 'validation',])
Yvalid      = mysamp$DEP_DELAY[role == 'validation']
Xtest      = data.frame(X = mysamp[role == 'test',])
Ytest      = mysamp$DEP_DELAY[role == 'test']
rm(n,role,testIndex,trainIndex,validIndex)
#Yeo Johnson transformation#####################################################
YtrainYeo = as.data.frame(Ytrain) %>% preProcess(method="YeoJohnson") %>% 
                                          predict(newdata=as.data.frame(Ytrain))
YtrainYeo <- YtrainYeo$Ytrain
YtestYeo = as.data.frame(Ytest) %>% preProcess(method="YeoJohnson") %>% 
                                          predict(newdata=as.data.frame(Ytest))
YtestYeo <- YtestYeo$Ytest
##Creating Dummy Variables for Factor Columns###################################
XtrainFact = Xtrain[,c(1,3,4,7,14)]
XvalidFact = Xvalid[,c(1,3,4,7,14)]
XtestFact  = Xtest[,c(1,3,4,7,14)]

Xtrain$X.DISTANCE  <- scale(Xtrain$X.DISTANCE,center=TRUE,scale=TRUE)
Xtest$X.DISTANCE  <- scale(Xtest$X.DISTANCE,center=TRUE,scale=TRUE)

dummyModel  = dummyVars(~ ., data = XtrainFact, fullRank = TRUE)
XtrainDummy = predict(dummyModel, XtrainFact)
dummyModel  = dummyVars(~ ., data = XvalidFact, fullRank = TRUE)
XvalidDummy = predict(dummyModel, XvalidFact)
dummyModel  = dummyVars(~ ., data = XtestFact, fullRank = TRUE)
XtestDummy  = predict(dummyModel, XtestFact)

XtrainFull  <- cbind(XtrainDummy,Xtrain$X.DISTANCE)
XvalidFull  <- cbind(XvalidDummy,Xvalid$X.DISTANCE)
XtestFull   <- cbind(XtestDummy,Xtest$X.DISTANCE)

#Basic Linear Model#############################################################
linMod <- lm(YtrainYeo~.,data=Xtrain[,c(1,3,4,7,13,14)])

#Refitted Lasso, Elastic Net, and Ridge Models##################################
lassoOut          = cv.glmnet(as.matrix(XtrainFull), YtrainYeo, alpha=1, standardize = FALSE)
betaHatLasso      = coef(lassoOut,s=lassoOut$lambda.min)
Slasso            = which(abs(betaHatLasso) > 1e-16)
YhatTestLasso     = predict(lassoOut,XtestFull,s='lambda.min')
testErrorLasso    = mean((YtestYeo-YhatTestLasso)**2)

betaHatTemp       = coef(lassoOut,s='lambda.1se')[-1]
Srefitted         = which(abs(betaHatTemp) > 0.001)
Xdf               = as.data.frame(XtrainFull[,Srefitted])
refittedOut       = lm(YtrainYeo ~ ., data = Xdf)
betaHatRefitted   = coef(refittedOut)
YhatRefLasso      = predict(refittedOut,Xtest[,c(5,6)])
MSE_RefLasso      = mean((YhatRefLasso-Ytest)**2)

ridgeOut          = cv.glmnet(as.matrix(XtrainFull),Ytrain,alpha=0,standardize=FALSE)
YhatTestRidge     = predict(ridgeOut, XtestFull, s = 'lambda.min')
testErrorRidge    = mean((YhatTestRidge-Ytest)**2)

#multinomial model fitting######################################################
XtrainMulti <- Xtrain[,c(1,3,4,7,13,14)]
YtrainMulti <- Xtrain$X.DELAY_IND
YtrainMulti <- relevel(YtrainMulti, ref="0")
XtestMulti <- Xtest[,c(1,3,4,7,13,14)]
YtestMulti <- Xtest$X.DELAY_IND
YtestMulti <- relevel(YtestMulti, ref="0")
multinomialModel <- multinom(YtrainMulti~., data=XtrainMulti,MaxNWts=3169)
model <- vglm(YtrainMulti ~., multinomial, data = XtrainMulti)
YhatMulti <- predict(multinomialModel,XtestMulti)
multinomialModel_misclassRate <- length(which(YhatMulti != YtestMulti))/length(YhatMulti)
multinomialModel_misclassRate

#Logistic Elastic Net model fitting#############################################
K           = 10
trainControl = trainControl(method = "cv", number = K)
tuneGrid     = expand.grid('alpha'=c(0,.25,.5,.75,1),'lambda' = seq(00, .001, length.out = 15))
elasticOut = train(x = XtrainDummy, y = YtrainNet,
                   method = "glmnet", 
                   trControl = trainControl, tuneGrid = tuneGrid)
glmnetOut = glmnet(x = XtrainFull, y = YtrainYeo, alpha = elasticOut$bestTune$alpha,
                   standardize = FALSE)
YhatLasso <- predict(glmnetOut,XtestFull,s=elasticOut$bestTune$lambda)
mean((YtestYeo-YhatLasso)**2)

#MARS models####################################################################
marsOut <- earth(x=XtrainMars,y=YtrainYeo)
tuneGrid = expand.grid(degree = 1:3, nprune = c(10,15,20,25,30,40,50))
marsOut <- train(x=XtrainMars,y=YtrainYeo,method="earth",trControl=trainControl(method="cv",number=10),tuneGrid=tuneGrid)
summary(marsOut) %>% .$coefficients
#SVM############################################################################
svmModel <- train(XtrainSVM,YtrainYeo,method="svmRadial",tuneLength=5,trControl=trainControl(method="cv"))

#random forest##################################################################
fit.rf <- train(Xtrain$X.DELAY_IND~., data=XtrainSVM, method="rf", metric="Accuracy", 
             trControl=trainControl(method="cv", number=10))
require(randomForest)
outRF <- randomForest(Xtrain[,c(1,3,13,14)],YtrainYeo,importance=TRUE,mtry=2)
#boosting#######################################################################
boostOut = train(x = XtrainFull, y = YtrainYeo,
                 method = "xgbTree",
                 tuneGrid = tuneGrid,trControl=trainControl(method="cv",number=5))
#CART###########################################################################
tuneGrid = data.frame('cp'=c(0,.001,.01,.1,.5,1))
trainControl = trainControl(method = 'cv', number = 10)
rpartOut = train(x = Xtrain[,c(1,3,4,7,13,14)], y = Ytrain,
                 method = "rpart",
                 tuneGrid = tuneGrid,
                 trControl = trainControl)
Yhat <- predict(rpartOut,Xtest[,c(1,3,4,7,13,14)])
mean((Ytest-Yhat)**2)
