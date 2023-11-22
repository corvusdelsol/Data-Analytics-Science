/****************************/
/*Program Name: Accessing_Data.sas*/
/*Author: Casey Poulson*/
/*Purpose: Accessing and creating different kinds of data with SAS*/

/*Inputs: COVID-19 Cases.csv file*/
/*Outputs: output.xlsx, program file, log file*/

/*(1) Clearing titles, footnotes, and proc titles on ods*/
TITLE;
FOOTNOTE;
ODS NOPROCTITLE;

/*(2) Creating mylib library, and filerefs for COVID-19 and output files*/
LIBNAME mylib "~PATH";
FILENAME covid "C~PATH\COVID-19 Cases.csv";
FILENAME output "~PATH\output.xlsx";

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
