/***********************************************************************************/
/*Program Name: CPoulson_HW08_prog.sas*/
/*Program Location: C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\Homework Assignments\8*/
/*Author: Casey Poulson*/
/*Creation Date: 17 March 2022*/
/*Last Run Date: 20 March 2022*/
/*Purpose: Practice using macro-variables and macro-programs*/


/*Clearing titles, footnotes, and proc titles on ODS*/

TITLE;
FOOTNOTE;
ODS NOPROCTITLE;

/*(1) Setting system options to write resolved macro-variable values to the log*/
/*Write to the log text generated by macro execution, suppressing date header on output*/

OPTIONS SYMBOLGEN MPRINT NODATE;

/*(2) Creating global macro variable assn and assigning it 08*/
/*Creating fileref output for pdf output, referencing assn macro-variable at the end of the path*/
/*Using %nrstr() macro function to mask the & in A&M*/
/*Assigning librefs MYLIB and HWDATA with readonly access on HWDATA*/
/*Opening the PDF output file destination*/

%let assn = 08;
FILENAME output "C:\Users\rockc\OneDrive\Documents\A%nrstr(&)M\2022\Spring 2022\STAT 657\Homework Assignments\8\CPoulson_HW&assn._output.pdf";
LIBNAME MYLIB 'C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\Homework Assignments\MYLIB';
LIBNAME HWDATA 'C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\Homework Assignments\HWDATA' access=readonly;
ODS PDF FILE = output;

/*(3) Creating a copy of hwdata.course1 dataset into the temporary work library*/

PROC SQL;
CREATE TABLE work.course1 AS
	SELECT *
	FROM hwdata.course1;
QUIT;

/*(4) Reporting the term, major, grade, and number of students per each combination from hwdata.course1*/
/*Grouping by all 3 columns to affect the count column*/
/*Having clause selects combinations of either greater than 2 or those without a C, D, F, or U*/

TITLE "Grades by Term and Major for Course1";
FOOTNOTE "Majors with 2 or fewer low grades are excluded.";
PROC SQL;
SELECT TERM, MAJOR, GRADE, count(*) as Students
FROM hwdata.course1
GROUP BY GRADE, MAJOR, TERM
HAVING Students > 2 or GRADE not in ('C','D','F','U');
QUIT;

/*(5) Defining macro grades using previous query*/
/*Using macro-variable references &lib and &table on From statement*/
/*Using %substr() function with &table to select the course number of dataset*/

%MACRO grades;
TITLE "Grades by Term and Major for Course%substr(&table,7)";
FOOTNOTE "Majors with 2 or fewer low grades are excluded.";
PROC SQL;
SELECT TERM, MAJOR, GRADE, count(*) as Students
FROM &lib..&table
GROUP BY GRADE, MAJOR, TERM
HAVING Students > 2 or GRADE not in ('C','D','F','U');
QUIT;
TITLE;
FOOTNOTE;
%MEND grades;

/*(6) Creating global macro variables lib and table with defined values*/
/*Calling the previously defined macro grades*/

%let lib = hwdata;
%let table = course2;
%grades

/*(7) Editing the macro to include positional and keyword parameters*/
/*%scan() function selects the 2nd word from &libref with . as the delimiter*/
/*%substr() function selects the 7th character which is the proper course number*/
/*From statement amended to reference the first positional parameter libref*/
/*Having and Footnote statements edited to reference &filter parameter*/

%MACRO grades_parm(libref,filter=1);
TITLE "Grades by Term and Major for Course%substr(%scan(&libref,2,.),7)";
FOOTNOTE "Majors with &filter or fewer low grades are excluded.";
PROC SQL;
SELECT TERM, MAJOR, GRADE, count(*) as Students
FROM &libref
GROUP BY GRADE, MAJOR, TERM
HAVING Students > &filter or GRADE not in ('C','D','F','U');
QUIT;
TITLE;
FOOTNOTE;
%MEND grades_parm;

/*(8) Calling the newly-defined macro grades_parm*/
/*hwdata.course1 acts as the first positional parameter libref*/

%grades_parm(hwdata.course1)

/*(9) Calling the newly-defined macro grades_parm*/
/*work.course1 acts as the first positional parameter libref*/
/*setting the keyword parameter filter equal to 4*/

%grades_parm(work.course1,filter=4)

/*(10) Defining grades_parmc macro stored in mylib*/
/*Adding a title to report creation time and date with %sysfunc function*/

OPTIONS MSTORED SASMSTORE=mylib;
%MACRO grades_parmc(libref,filter=1) / STORE;
TITLE "Grades by Term and Major for Course%substr(%scan(&libref,2,.),7)";
TITLE2 "Created at %sysfunc(time(),timeampm8.) on %sysfunc(today(),mmddyy10.) by a Stored Compiled Macro";
FOOTNOTE "Majors with &filter or fewer low grades are excluded.";
PROC SQL;
SELECT TERM, MAJOR, GRADE, count(*) as Students
FROM &libref
GROUP BY GRADE, MAJOR, TERM
HAVING Students > &filter or GRADE not in ('C','D','F','U');
QUIT;
TITLE;
FOOTNOTE;
%MEND grades_parmc;

/*(11) Calling grades_parmc macro, hwdata.course2 as 1st positional parameter*/

%grades_parmc(hwdata.course2)

/*(12) Reporting permanent macros in Mylib library*/

PROC CATALOG cat=mylib.sasmacr;
CONTENTS;
TITLE "Stored Compiled Macros in Mylib Library";
QUIT;

/*Closing the PDF ODS output file*/

ODS PDF CLOSE;

/*(13) */
/*(a) 12 STAT majors made an A in Course1 in 201720.*/

/*(b) 15 STAT majors made an A in Course2 in 201810.*/

/*(c) The following majors made at least one A in Course2 in 201810: ECON, MATH, PETE*/

/*(d) 3 STAT majors withdrew from Course1 in 201930.*/
