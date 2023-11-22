/*****************************************/
/*Program Name: CPoulson_HW11_prog.sas*/
/*Date Created: 21 March 2021*/
/*Author: Casey Poulson*/
/*Purpose: Using conditional statements and creating and subsetting data sets.*/
/*Program Location: C:\Users\rockc\OneDrive\Documents\A&M\Spring 2021\STAT 604\Homework\11*/

/*Inputs: */
/*Outputs: */

/*(1) Clearing titles, footnotes, and proc titles on ods*/
TITLE;
FOOTNOTE;
ODS NOPROCTITLE;

/*(2) Creating mylib library containing covid_19_cases dataset, and fileref for pdf output file*/
LIBNAME mylib "C:\Users\rockc\OneDrive\Documents\A&M\Spring 2021\STAT 604\SAS Data files";
FILENAME output "C:\Users\rockc\OneDrive\Documents\A&M\Spring 2021\STAT 604\Homework\11\CPoulson_HW11_output.pdf";

/*(3) Creating 3 datasets named on following DATA line. Viewing PDV for first two iterations with note before the set statement.*/
/*Selecting input dataset and which variables to drop from output, only reading rows from "Texas".*/
/*Creating County_Size variable based on the specified population_count values.*/
/*Putting confirmed cases into texconfirmed dataset, deaths into texdeaths dataset, and all Texas data into texcovid dataset.*/
/*Specifying which variables to keep in output including the newly created County_Size variable.*/
/*Viewing PDV for first iteration with note before the run statement.*/
DATA mylib.texconfirmed mylib.texdeaths work.texcovid;
	if _N_ <= 2 then PUT "Note: PDV Before Set Statement " _ALL_;
	SET mylib.covid_19_cases(drop= people: iso: country_region data_source prep_flow_runtime lat long);
	WHERE Province_State="Texas";
	length County_Size $ 10;
	if population_count<20000 then County_Size="small";
	else if population_count<50000 then County_Size="medium";
	else if population_count<400000 then County_Size="large";
	else County_Size="very large";
	if Case_Type="Confirmed" then output mylib.texconfirmed;
	if Case_Type="Deaths" then output mylib.texdeaths;
	output work.texcovid;
	KEEP Case_Type Cases Difference Date Combined_Key Province_State Admin2 FIPS Population_Count County_Size;
	if _N_ <= 1 then PUT "Note: PDV Before Run Statement " _ALL_;
run;

/*(4) Opening PDF ODS for output*/
ODS PDF FILE= output;

/*(5) Reporting list of datasets in Mylib library*/
title1 "Datasets in Mylib library";
PROC CONTENTS data=mylib._ALL_ NODS;
run;

/*(6) Reporting Descriptor portion of texcovid dataset*/
title1 "Texcovid dataset Descriptor Portion";
PROC CONTENTS data=texcovid;
run;

/*(7) Setting 2 values for the macro variable Day, and viewing Data of very large counties on each macro variable value*/
%let Day=04May2020;
%let Day=04Jun2020;
title1 "Very Large County Data as of &Day";
PROC PRINT data=mylib.texconfirmed;
	WHERE County_Size="very large" and Date="&Day"d;
run;

/*(8) Closing PDF Destination*/
ODS PDF CLOSE;

/*(9)*/
/*(a)The first PDV written to the log shows the columns and are initialized as missing, it shows 0 errors and _N_=1 as the first iteration.*/
/*The second PDV written to the log shows the columns supplied with values for the first observation, 0 errors, and still _N_=1 since it is*/
/*still on the first iteration. This PDV is before the run statement is executed.*/
/*The third PDV written to the log shows the columns still supplied with values from the first observation.*/
/*It shows 0 errors and _N_=2 since it is about to begin the second iteration of the DATA step before the set statement.*/

/*(b)There were 69,120 observations read from the covid_19_cases dataset.*/

/*(c)There were 69,120 observations written to the temporary dataset work.texcovid.*/

/*(d)Dallas county had the highest difference value on May 4th. Harris county had the highest difference value on June 4th.*/

/*(e)The value of Cases for Dallas county increased by 6,873 from May 4th to June 4th (11,243-4,370).*/
