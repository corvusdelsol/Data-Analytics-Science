#Homework 08_STAT 604
#"C:/Users/rockc/OneDrive/Documents/A&M/Spring 2021/STAT 604/Homework/8"
#Created by Casey Poulson on 02-21-2021
#Purpose:Using iterative calculations to create functions and graphics.
#Last executed: 02-24-2021
Sys.time()
setwd("C:/Users/rockc/OneDrive/Documents/A&M/Spring 2021/STAT 604/Homework/8")

#Housekeeping
#view contents of workspace
ls()
#clear workspace
#rm(list=ls())

#(1)Load HW07 workspace
load("C:/Users/rockc/OneDrive/Documents/A&M/Spring 2021/STAT 604/Homework/7/HW07.RData")
#view contents of workspace
ls()

#(2)Plotting actual data and 7-day moving average for Brazos county
#(a)creating subset of USATEX dataframe with the following restrictions
USATEX_FUNC <- USATEX[USATEX$COUNTY_NAME=="Brazos"&USATEX$REPORT_DATE>="2020-03-15",c(2,3)]
#view structure of this new object
str(USATEX_FUNC)

#(b)reordering the dataframe by REPORT_DATE
USATEX_FUNC <- USATEX_FUNC[order(USATEX_FUNC$REPORT_DATE),]

#(c)assigning values for alpha and N to use in our formula
N <- 7 ; a <- 2/(1+N)

#(d)creating vector of zeroes for EMA values
EMA <- seq(from=0,to=0,length.out=318)

#(e)setting the 7th index of EMA to the 7-day average of our case count column
EMA[7] <- mean(USATEX_FUNC$POSITIVE_NEW_CASES_COUNT[1:7])

#(f)calculating estimated moving averages for our case counts and storing them appropriately
for(i in 8:318) {
	EMA[i] <- (USATEX_FUNC$POSITIVE_NEW_CASES_COUNT[i]*a)+(EMA[i-1]*(1-a))
	}

#(g)setting plot background color
par(bg="grey90")
#plotting line of new cases by days since 2020-03-15
plot(1:318,USATEX_FUNC$POSITIVE_NEW_CASES_COUNT,type="l",col="yellow3",main="Brazos County 7 Day EMA and Daily Cases"
,xlab="Days Since 2020-03-15",ylab="New Cases")

#(h)adding the 7-day moving average line to our graph
lines(EMA,col="purple")

#(i)adding formula expression as text to graph
text(x=1,y=(0.95*(max(USATEX_FUNC$POSITIVE_NEW_CASES_COUNT))),labels=expression(paste(EMA[i]==(P[i]*alpha)+(EMA[i-1]*(1-alpha)),
" where ",alpha==(2/(1+7)))),font=0.95,adj=0)

#(3)removing objects created in step 2
rm(a,EMA,i,N)

#(4)creating a function to return N-day moving average graphic for chosen county, start date, N-value, and dataframe
EMA7 <- function(county,N=7,data=USATEX,stdate="2020-03-15")
	{USATEX_FUNC <- data[data$COUNTY_NAME==county&data$REPORT_DATE>=stdate,c(2,3)]
	USATEX_FUNC <- USATEX_FUNC[order(USATEX_FUNC$REPORT_DATE),]
	a <- 2/(1+N);
	EMA <- seq(from=0,to=0,length.out=length(USATEX_FUNC[,1]));
	EMA[N] <- mean(USATEX_FUNC$POSITIVE_NEW_CASES_COUNT[1:N]);
	for(i in (N+1):length(USATEX_FUNC[,1])) {
	EMA[i] <- (USATEX_FUNC$POSITIVE_NEW_CASES_COUNT[i]*a)+(EMA[i-1]*(1-a))};
	par(bg="grey90");
	plot(1:length(USATEX_FUNC[,1]),USATEX_FUNC$POSITIVE_NEW_CASES_COUNT,type="l",col="yellow3",main=paste(county, "County", N, "Day EMA and Daily Cases",sep=" ")
	,xlab=paste("Days Since", stdate,sep=" "),ylab="New Cases");
	lines(EMA,col="purple");
	text(x=1,y=(0.95*(max(USATEX_FUNC$POSITIVE_NEW_CASES_COUNT))),labels=expression(paste(EMA[i]==(P[i]*alpha)+(EMA[i-1]*(1-alpha)),
	" where ",alpha==(2/(1+N)))),font=0.95,adj=0)}

#(5)opening pdf graphics file
pdf("C:/Users/rockc/OneDrive/Documents/A&M/Spring 2021/STAT 604/Homework/8/CPoulson_HW08_graphics.pdf",width=11,height=8.5)

#(6)setting graphics parameters
#2 columns per page
par(mfcol=c(1,2))
#overall page margins in inches
par(omi=c(0.5,0.5,1.5,0.5))
#graph margins in lines
par(mar=c(4,4,2,0))

#(7)calling the function
EMA7(county="Brazos")
EMA7(county="Brazos",N=14)

#(8)adding system time stamp in bottom left margin
mtext(Sys.time(),side=1,adj=0,outer=TRUE)

#(9)sampling 2 counties from LATEST_USATEX with seed set
set.seed(1234567000)
X <- sample(LATEST_USATEX$COUNTY_NAME,size=2,replace=FALSE)

#(10)
for(i in X) {EMA7(county=i,stdate="2020-04-01")}

#(11)De-bugging
graphics.off()

#(12)additional questions
#(a)There are 318 observations in the Brazos county dataframe.

#(b)Raising the N-value lowers the moving average(purple line)at this peak.

#(c)The moving average for Galveston county seems to be higher in the interval of 
#100 to 150 days since 2020-03-2015 than that of Williamson county.
#Also, in the interval of 250-300+ days since 2020-03-15: Williamson county appears to fluctuate
#more than Galveston county. Williamson county appears to reach 500 cases in a day before Galveston county does so.
#Looking at the second peak on the graph, Galveston county case numbers increases more gradually than does 
#Williamson county. This does make some logical sense, as Williamson county has nearly twice the population than Galveston.