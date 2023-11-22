/***********************************************************************************/
/*Program Name: SQL_Queries.sas*/
/*Author: Casey Poulson*/
/*Purpose: Proc sql queries, in-line views, dictionary tables*/


/*(1) Clearing titles, footnotes, and proc titles on ODS*/

TITLE;
FOOTNOTE;
ODS NOPROCTITLE;

/*Creating librefs hwdata and mylib, and fileref output for pdf output*/
/*Opening the PDF output file destination*/

LIBNAME HWDATA '~PATH\HWDATA' access=readonly;
LIBNAME MYLIB '~PATH\MYLIB';
FILENAME output '~PATH\SQL_Queries_output.pdf';
ODS PDF FILE= output;

/*(2) Selecting pkey, major, term, and grade columns from first in-line view dfw*/
/*Selecting term, grade, and term Interval columns from second in-line view pass*/
/*From first in-line view dfw only including non-passing grades*/
/*Second in-line view pass only including passing grades*/
/*Where the pkey columns match between the two in-line views*/
/*Ordering the report by descending Interval values*/

TITLE "Students Receiving a DFW Grade Prior to a Passing Grade in Course 1";
FOOTNOTE "Output from PROC SQL query";
PROC SQL;
SELECT dfw.PKEY format=10., 
	   dfw.major "Major" as Major,
	   dfw.term "DFW Term" as DFW_Term,
	   dfw.grade "DFW Grade" as DFW_Grade,
	   pass.term "Pass Term" as Pass_Term, 
	   pass.grade "Pass Grade" as Pass_Grade,
	   pass.term-dfw.term "Interval" as Interval
	FROM (SELECT major, term, grade, pkey
			FROM hwdata.course1
			WHERE grade not in ("A","B","C","S")) as dfw,
		 (SELECT major, term, grade, pkey
			FROM hwdata.course1
			WHERE grade in ("A","B","C","S")) as pass
	WHERE dfw.pkey = pass.pkey
	ORDER BY Interval desc;
QUIT;

/*(3) Creating empty table mylib.grades with the following 8 columns as specified*/

PROC SQL;
CREATE TABLE mylib.grades
	(PKEY num format=10.,
	 Major char format=$4.,
	 DFW_Term num "DFW Term" format=6.,
	 DFW_Grade char "DFW Grade" format=$1.,
	 Pass_Term num "Pass Term" format=6.,
	 Pass_Grade char "Pass Grade" format=$1.,
	 Interval num format=3.,
	 Load_Date date "Load Date" format=date9.);
QUIT;

/*(4) Reporting the descriptor portion of mylib.grades table from previous steps*/

TITLE "Mylib.Grades Table Created in Step 3";
FOOTNOTE;
PROC CONTENTS data=mylib.grades varnum;
run;

/*(5) Viewing sashelp.vcolumn dictionary table for the mylib.grades table*/

TITLE "Mylib.Grades Table Viewed From Sashelp.vcolumn";
PROC SQL;
SELECT *
FROM sashelp.vcolumn
WHERE memname = "GRADES"
ORDER BY npos;
QUIT;

/*(6) Inserting the query from step 2 into the empty mylib.grades table*/
/*Computing the Load_Date column with the today() function*/
/*Omitting the previous ORDER BY clause from step 2*/

PROC SQL;
INSERT INTO mylib.grades
	SELECT dfw.PKEY format=10., 
	   dfw.major "Major" as Major,
	   dfw.term "DFW Term" as DFW_Term,
	   dfw.grade "DFW Grade" as DFW_Grade,
	   pass.term "Pass Term" as Pass_Term, 
	   pass.grade "Pass Grade" as Pass_Grade,
	   pass.term-dfw.term "Interval" as Interval,
	   today() as Load_Date "Load Date" format=date9.  
	FROM (SELECT major, term, grade, pkey
			FROM hwdata.course1
			WHERE grade not in ("A","B","C","S")) as dfw,
		 (SELECT major, term, grade, pkey
			FROM hwdata.course1
			WHERE grade in ("A","B","C","S")) as pass
	WHERE dfw.pkey = pass.pkey;
QUIT;

/*(7) Viewing the number of observations in mylib.grades from sashelp.vtable*/

TITLE "Number of Observations in Mylib.Grades Table";
PROC SQL;
SELECT nobs
FROM sashelp.vtable
WHERE memname = "GRADES";
QUIT;

/*(8) Printing the data portion of mylib.grades dataset without observation numbers*/

TITLE "Mylib.Grades Dataset Observations";
FOOTNOTE "Output from PROC PRINT";
PROC PRINT data=mylib.grades noobs label;
run;

/*(9) Closing the PDF ODS output file*/

ODS PDF CLOSE;
