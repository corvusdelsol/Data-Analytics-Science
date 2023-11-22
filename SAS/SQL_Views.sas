/***********************************************************************************/
/*Program Name: SQL_Views.sas*/
/*Author: Casey Poulson*/
/*Purpose: Creating and reporting sql views, using proc fedsql*/


/*(1) Clearing titles, footnotes, and proc titles on ODS*/

TITLE;
FOOTNOTE;
ODS NOPROCTITLE;

/*Creating libref mylib, and fileref output for pdf output*/
/*Opening the PDF output file destination*/

LIBNAME MYLIB '~PATH\MYLIB';
FILENAME output '~PATH\SQL_Views_output.pdf';
ODS PDF FILE= output;

/*(2) Creating view mylib.dfw as defined*/
/*From clause defines two in-line views, the first selecting term, and acount column*/
/*where the student received a DFW grade, counting number of dfw students per term*/
/*via GROUP BY clause. The second in-line view counts all students grouped by term*/
/*Outer Select statement selects these columns, and creates dfw_percent column as defined*/
/*Using clause identifies the location of hwdata.course1 with Libname clause.*/

PROC SQL;
CREATE VIEW mylib.dfw as
	SELECT a.TERM, 
		   DFW_Count, 
		   Students, 
		   DFW_Count/Students as DFW_Percent
	FROM (SELECT TERM, count(*) as DFW_Count
		  FROM hwdata.course1 
		  WHERE GRADE not in ("A", "B", "C", "S")
		  GROUP BY TERM) as a,
		 (SELECT TERM, count(*) as Students
		  FROM hwdata.course1 
		  GROUP BY TERM) as b 
		  WHERE a.TERM=b.TERM
	USING LIBNAME hwdata 'C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\Homework Assignments\HWDATA';
QUIT;

/*(3) Writing the definition of the new view to the log*/

PROC SQL;
DESCRIBE VIEW mylib.dfw;
QUIT;

/*(4) Displaying contents of Mylib library, suppressing the descriptor portion*/

TITLE "Mylib Library Contents";
PROC CONTENTS data=mylib._ALL_ NODS;
run;

/*(5) Reporting the descriptor portion of mylib.dfw view*/

TITLE "Mylib.DFW View Description";
PROC CONTENTS data=mylib.dfw;
run;

/*(6) Displaying the data outputted from mylib.dfw view*/

TITLE "Data Retrieved from Mylib.DFW View";
PROC SQL;
SELECT *
FROM mylib.dfw;
QUIT;

/*(7) Outputting min, max, and mean dfw_percent values from mylib.dfw view*/
/*Using PROC SQL, formatting values and supplying labels*/

TITLE "Min, Max, & Mean Percent of Students with DFW Grade Per Term";
FOOTNOTE "PROC SQL Output";
PROC SQL;
SELECT min(dfw_percent) "Min DFW_Percent" format=5.3,
	   max(dfw_percent) "Max DFW_Percent" format=5.3,
	   avg(dfw_percent) "Mean DFW_Percent" format=5.3
FROM mylib.dfw;
QUIT;

/*(8) Outputting min, max, and mean dfw_percent values from mylib.dfw view*/
/*Using PROC MEANS*/

TITLE "Min, Max, & Mean Percent of Students with DFW Grade Per Term";
FOOTNOTE "PROC MEANS Output";
PROC MEANS data=mylib.dfw min max mean;
	VAR dfw_percent;
run;

/*(9) Creating temporary dataset dfw with the data retrieved from mylib.dfw view*/

DATA work.dfw;
SET mylib.dfw;
run;

/*(10) Reporting top 5 dfw_percent values with proc fedsql*/
/*Selecting Term, Students, and formatting dfw_percent as defined from work.dfw*/
/*Ordering by descending dfw_percent, and limiting to 5 observations output*/

TITLE "5 Highest Percentages of Students with DFW Grades Per Term";
FOOTNOTE;
PROC FEDSQL;
SELECT TERM, Students, put(DFW_Percent, percent7.1) as DFW_Percent
FROM dfw
ORDER BY dfw_percent desc
LIMIT 5;
QUIT;

/*Closing the PDF ODS output file*/

ODS PDF CLOSE;
