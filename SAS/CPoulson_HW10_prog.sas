/****************************/
/*Program Name: CPoulson_HW10_prog.sas*/
/*Date Created: 14 March 2021*/
/*Author: Casey Poulson*/
/*Purpose: Accessing and creating different kinds of data with SAS*/
/*Program Location:C:\Users\rockc\OneDrive\Documents\A&M\Spring 2021\STAT 604\Homework\10*/

/*Inputs: COVID-19 Cases.csv file*/
/*Outputs: CPoulson_HW10_output.xlsx, program file, log file*/

/*(1) Clearing titles, footnotes, and proc titles on ods*/
TITLE;
FOOTNOTE;
ODS NOPROCTITLE;

/*(2) Creating mylib library, and filerefs for COVID-19 and output files*/
LIBNAME mylib "C:\Users\rockc\OneDrive\Documents\A&M\Spring 2021\STAT 604\SAS Data files";
FILENAME covid "C:\Users\rockc\OneDrive\Documents\A&M\Spring 2021\STAT 604\SAS Data files\COVID-19 Cases.csv";
FILENAME output "C:\Users\rockc\OneDrive\Documents\A&M\Spring 2021\STAT 604\Homework\10\CPoulson_HW10_output.xlsx";

/*(3) Importing covid_19_cases dataset from the covid fileref*/
PROC IMPORT DATAFILE= covid
	DBMS=CSV
	OUT=mylib.covid_19_cases
	REPLACE;
	GUESSINGROWS=70000;
run;

/*(4) Closing active ODS destinations and opening EXCEL ODS*/
ODS _all_ CLOSE;
ODS EXCEL FILE=output
	OPTIONS(EMBEDDED_TITLES="on"
			SHEET_INTERVAL="PROC");

/*(5) Reporting descriptor portion of covid_19_cases dataset in mylib library*/
ODS EXCEL OPTIONS(SHEET_NAME="Covid Descriptor");
title1 "COVID Dataset Descriptor Portion";
PROC CONTENTS data=mylib.covid_19_cases;
run;

/*(6) Creating temporary dataset of confirmed cases in Texas with population requirements*/
DATA work.COVID_TEX;
	SET mylib.covid_19_cases;
	WHERE Case_Type="Confirmed" and Province_State="Texas" and Population_Count>100000;
run;

/*(7) Viewing first 10 observations in COVID_TEX dataset*/
ODS EXCEL OPTIONS(SHEET_NAME="Texas County Sample");
title1 "COVID Dataset Data Portion (First 10 Obs.)";
PROC PRINT DATA=work.COVID_TEX(obs=10);
run;

/*(8) Closing EXCEL ODS and re-opening HTML ODS*/
ODS EXCEL CLOSE;
ODS html path="%qsysfunc(pathname(work))";

/*(9) */
/*After following the steps in question 9, I observe that under the mylib library, the covid_19_cases dataset
I created is indeed there. However, the COVID_TEX dataset I created was temporary and stored in the work 
library, and thus no longer appears in the current session.*/

/*(10) */
/*(a) There are 950,670 observations in the permanent dataset.*/
/*(b) The column name is People_Hospitalized_Cumulative_Count, and because of its length was truncated to
People_Hospitalized_Cumulative_C.*/
/*(c) The Prep_Flow_Runtime variable is numeric, its format is DATETIME, with a length of 8.*/
/*(d) There are 5,400 observations and 18 variables.*/
/*(e) The FIPS value on observation 3 in the temporary dataset is 48041.*/



