/*****************************************/
/*Program Name: Conditional_Statements.sas*/
/*Author: Casey Poulson*/
/*Purpose: Using conditional statements and creating and subsetting data sets.*/


/*(1) Clearing titles, footnotes, and proc titles on ods*/
TITLE;
FOOTNOTE;
ODS NOPROCTITLE;

/*(2) Creating mylib library containing covid_19_cases dataset, and fileref for pdf output file*/
LIBNAME mylib "~PATH";
FILENAME output "~PATH\output.pdf";

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
