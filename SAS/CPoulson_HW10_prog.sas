/***********************************************************************************/
/*Program Name: CPoulson_HW10_prog.sas*/
/*Program Location: C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\Homework Assignments\10*/
/*Author: Casey Poulson*/
/*Creation Date: 02 April 2022*/
/*Last Run Date: 11 April 2022*/
/*Purpose: Defining and calling macros with iterative and data dependent processing*/


/*Clearing titles, footnotes, and proc titles on ODS, setting options*/

TITLE;
FOOTNOTE;
ODS NOPROCTITLE;

/*Setting system options to view macro resolution, code, and execution in the log*/
/*Setting mylib.myfmts to use the custom format created in the previous assignment*/

OPTIONS SYMBOLGEN MPRINT MLOGIC FMTSEARCH=(mylib.myfmts) nodate;

/*Libname statements to assign librefs to libraries, protecting hwdata*/
/*Creating output fileref for pdf output, and opening the file destination*/

LIBNAME HWDATA 'C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\Homework Assignments\HWDATA' access=readonly;
LIBNAME MYLIB 'C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\Homework Assignments\MYLIB';
FILENAME output 'C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\Homework Assignments\10\CPoulson_HW10_output.pdf';
ODS PDF FILE= output style=sapphire;

/*(1) */
/*Defining macro term_report with positional parameter term, keyword parameter limit*/
/*with default value 1. Verifying &limit is numeric and greater than 1. If not, let*/
/*it be equal to 1.*/

/*PROC SQL reports selected columns from hwdata.course1, counting major-grade*/
/*combinations, with term and count equal to parameter values supplied.*/

/*Proc means gives listed stats for term_length where term = &term value.*/

/*Proc print reports students who took both courses with course 1 from &term*/
/*and waited over a year (100) to take course 2.*/

%MACRO term_report(term, limit=1);
%IF (%datatyp(&limit)=NUMERIC and &limit ge 1) %THEN %LET limit=&limit;
%ELSE %LET limit=1;

TITLE1 "Course1 Grade Distribution by Major for %sysfunc(putn(&term, term.))";
TITLE2 "Rows with only &limit Student(s) Have Been Excluded";
PROC SQL;
	SELECT MAJOR 'Major', GRADE 'Grade', COUNT(*) AS Number
	FROM hwdata.course1
	WHERE TERM = &term
	GROUP BY MAJOR, GRADE
	HAVING Number > &limit;
QUIT; 

TITLE1 "Analysis of Time between Course1 in %sysfunc(putn(&term, term.)) and Course 2";
PROC MEANS DATA=mylib.both_courses n min mean max maxdec=0;
VAR Term_Length;
WHERE Term_c1 = &term;
run; 

TITLE1"%sysfunc(putn(&term, term.)) Students with over 1 Year between Course1 and Course2";
PROC PRINT DATA=mylib.both_courses noobs;
WHERE Term_c1=&term and Term_Length > 100;
run;
TITLE; FOOTNOTE; 

%MEND term_report;

/*(2) Calling the term_report macro with supplied parameter values*/

%term_report(201830, limit=a)

/*(3) Defining macro term_list with 2 parameters libref and data_out*/
/*Proc sql creates output dataset with distinct terms from &libref*/
/*2nd sql query creates macro variable num_terms by counting Terms*/
/*All Terms (12 here) saved to macro variables term1-term12 using &sqlobs*/

/*Creating local macro variable i as the index variable for the do loop*/
/*For i=1 to &num_terms (12), call macro term_report using the ith value*/
/*of the termn macro variables*/

%MACRO term_list(libref,data_out);

PROC SQL noprint;
CREATE TABLE &data_out AS
SELECT distinct TERM as Terms
FROM &libref;

SELECT COUNT(*), Terms 
	INTO :Num_Terms, :term1-:term&sqlobs
FROM &data_out;
QUIT;

%local i;
%DO i=1 %TO &Num_Terms;
%term_report(&&term&i)
%END;

%MEND term_list;

/*(4) Calling macro term_list with two parameters supplied*/
/*libref is hwdata.course1, data_out writes data to work.course1_terms*/

%term_list(hwdata.course1, course1_terms)

/*(5) Using a DATA step with DOSUBL function to use the list of Terms created in*/
/*step 3 as the first parameter in the term_report macro. Setting the limit=2.*/
/*Cats function concatenates the list of terms together.*/

DATA _null_;
	SET work.course1_terms;
	rc = dosubl(cats('%term_report(',Terms,',limit=2)'));
run;

/*Closing the PDF ODS output file*/

ODS PDF CLOSE;

/*(6) */
/*(a) The maximum amount of time between Course1 and Course2 for Students in*/
/*Fall 2018 is 280.*/

/*(b) ECON and MISY majors were also in the grade distribution in Fall 2018.*/
/*7 of these non-STAT majors made a B. Including STAT majors, 34 students made*/
/*a B in Fall 2018 Course1.*/

/*(c) 3 students in Spring 2017 took over a year between course1 and course2.*/

/*(d) The MLOGIC system option generated the message. The number after the word*/
/*now in the log is 13.*/
