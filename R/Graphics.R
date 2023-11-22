#Graphics
#Created by Casey Poulson 
#Purpose:Using graphics such as histogram and boxplot to display selective data, and adding features to existing graphics.
Sys.time()
setwd("~PATH")

#(1)Housekeeping
#view contents of workspace
ls()
#clear workspace
#rm(list=ls())

#(2)load HW06 workspace
load("~PATH.RData")
#view contents of workspace
ls()

#(3)see all colors available in R
colors()

#(4)direct graphics output to pdf file
pdf("~PATH/graphics.pdf",width=11,height=8.5)

#(5)see maximum of percent positive cases count column
max(LATEST_USATEX$PCT_POSITIVE_CASES_COUNT)

#(6)create histogram of this column with each cell of width=1
hist(LATEST_USATEX$PCT_POSITIVE_CASES_COUNT,freq=FALSE,breaks=seq(0,18,1),xlab="Percent",main="Percentage of Positive Cases")

#(7)adding normal density line: creating x value vector
Xd <- seq(1,18,.1)
#creating density vector
Yd <- dnorm(Xd,mean=mean(LATEST_USATEX$PCT_POSITIVE_CASES_COUNT,na.rm=TRUE)
,sd=sd(LATEST_USATEX$PCT_POSITIVE_CASES_COUNT,na.rm=TRUE))
#plotting the line to our histogram
lines(Xd,Yd,type="l",col="violetred")

#(8)adding vertical maroon line to graph to represent mean
abline(v=mean(LATEST_USATEX$PCT_POSITIVE_CASES_COUNT),col="maroon",lwd=2)
#adding vertical yellow line to represent median
abline(v=median(LATEST_USATEX$PCT_POSITIVE_CASES_COUNT),lwd=2,col=7)

#(9)create new dataframe of Population greater than 100,000
POP100 <- USATEX[USATEX$Population>100000,]
#view summary of this new object
summary(POP100)

#(10)see the number of times each county is listed
table(POP100$COUNTY_NAME)

#(11)create boxplot of new case percentages grouped by weekday
boxplot(POP100$PCT_POSITIVE_NEW_CASES_COUNT~POP100$WEEKDAY,range=0,xlab="Weekday",
ylab="New Case Percentages",main="Percent New Covid Cases in Texas cities with Population greater than 100,000")

#(12)imbed date and time as text in upper left corner of graph
text(x=1,y=1.1,labels=Sys.time(),adj=0)

#(13)terminate output to graphics pdf file
graphics.off()

#(14)view contents of workspace
ls()
#remove vectors used for graphing
rm(Xd,Yd)
#view contents of workspace
ls()

#(15)save the workspace RData file
save.image("~PATH/Graphics.RData")
