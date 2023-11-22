#Homework 05_STAT 604
#"C:/Users/rockc/OneDrive/Documents/A&M/Spring 2021/STAT 604/Homework/5"
#Created by Casey Poulson on 02-06-2021
#Purpose:working with data frame specifications, adjusting values and names, working with strings,
#merging data frames, adding new columns, etc.
#Last executed: 02-06-2021
Sys.time()
setwd("C:/Users/rockc/OneDrive/Documents/A&M/Spring 2021/STAT 604/Homework/5")

#(1)Housekeeping
#view contents of workspace
ls()
#clear workspace
#rm(list=ls())

#(2)load COVID workspace
load("C:/Users/rockc/OneDrive/Documents/A&M/Spring 2021/STAT 604/R Data files/Covid.RData")
#view contents pf COVID workspace
ls()
str(USA_Daily)

#(3)read in the COVID-19 Cases dataset
COVID <- read.csv("COVID-19 Cases.csv",header=TRUE,sep=",",dec=".",fill=TRUE)
#view structure of this data frame
str(COVID)
#column name vector
colnames(COVID)
#rename first column
colnames(COVID)[1] <- "Type"

#(4)Create new data frame for confirmed cases in Texas on June 4, 2020
COVID_TEX <- COVID[COVID$Province_State=="Texas"&COVID$Type=="Confirmed"&COVID$Date==max(COVID$Date),c(6,12,15)]
#(a)see structure of newly created data frame
str(COVID_TEX)
#(b)see first 10 rows across all columns of this data frame
COVID_TEX[1:10,]
#(c)remove ", Texas, US" string from our data frame
COVID_TEX$Combined_Key <- gsub(", Texas, US","",COVID_TEX$Combined_Key)
#(d)change Combined_Key column name to COUNTY_NAME
colnames(COVID_TEX)[1] <- "COUNTY_NAME"
#change Population_Count column name to Population
colnames(COVID_TEX)[3] <- "Population"

#(5)see counties in the data frame that have a "v" in the name, regardless of case
grep("v",COVID_TEX$COUNTY_NAME,ignore.case=TRUE,value=TRUE)

#(6)view data frame excluding FIPS column ordered by decreasing Population values
COVID_TEX[order(COVID_TEX[3],decreasing=TRUE),-2]

#(7)using cat and paste functions to output Texas csv file
cat(paste(COVID_TEX$FIPS,COVID_TEX$COUNTY_NAME,COVID_TEX$Population,"\n"),
file="C:/Users/rockc/OneDrive/Documents/A&M/Spring 2021/STAT 604/Homework/5/COVID_TEX.csv",sep=" ")

#(8)Create new data frame by merging USA_Daily and COVID_TEX data frames with specifications
USATEX <- merge(USA_Daily[USA_Daily$PROVINCE_STATE_NAME=="Texas",c(2,4,12,1,7,13)],COVID_TEX,all=FALSE)
#summary of USATEX data frame
summary(USATEX)

#(9)attach column names to USATEX
attach(USATEX)
#(a)create new weekday column
USATEX[,9] <- weekdays(as.Date(REPORT_DATE))

#(b)I decided to give this column a name
colnames(USATEX)[9] <- "WEEKDAY"
#create new percent positive new cases count column
USATEX[,10] <- (POSITIVE_NEW_CASES_COUNT/Population)*100
#renaming this column
colnames(USATEX)[10] <- "PCT_POSITIVE_NEW_CASES_COUNT"
#create new percent positive cases count column
USATEX[,11] <- (POSITIVE_CASES_COUNT/Population)*100
#renaming this column
colnames(USATEX)[11] <- "PCT_POSITIVE_CASES_COUNT"
#creating new percent death new count column
USATEX[,12] <- (DEATH_NEW_COUNT/Population)*100
#renaming this column
colnames(USATEX)[12] <- "PCT_DEATH_NEW_COUNT"
#creating new percent death count column
USATEX[,13] <- (DEATH_COUNT/Population)*100
#renaming this column
colnames(USATEX)[13] <- "PCT_DEATH_COUNT"

#(9)(c)view structure of this data frame and the first 20 rows
str(USATEX)
USATEX[1:20,]

#(9)(d)remove column names from the R search path
detach(USATEX)

#(10)display contents of new workspace
ls()

#(11)remove the following objects from workspace and view updated workspace
rm(USA_Daily,COVID_TEX)
ls()

#(12)save this workspace as follows
save.image("C:\\Users\\rockc\\OneDrive\\Documents\\A&M\\Spring 2021\\STAT 604\\Homework\\5\\TX_Covid.RData")

#(13)
#(a)There were 950,670 observations of 18 variables loaded in this csv file
#(b)There were 256 observations created in the Texas Population subset
#(c)Travis county has population 1,273,954 people.
#(d)The most populous county is Harris with population 4,713,325 people. 
#(d)The least populous county is Loving with population 169 people.
#(e)There were 18 new cases reported on Thursday,10-15-2020 in Anderson county.
