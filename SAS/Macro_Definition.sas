/***********************************************************************************/
/*Program Name: Macro_Definition.sas*/
/*Author: Casey Poulson*/
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

LIBNAME HWDATA '~PATH\HWDATA' access=readonly;
LIBNAME MYLIB '~PATH\MYLIB';
FILENAME output '~PATH\Macro_Definition_output.pdf';
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
