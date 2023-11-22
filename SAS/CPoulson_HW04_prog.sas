/***********************************************************************************/
/*Program Name: CPoulson_HW04_prog.sas*/
/*Program Location: C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\
Homework Assignments\4*/
/*Author: Casey Poulson*/
/*Creation Date: 28 January 2022*/
/*Last Run Date: 31 January 2022*/
/*Purpose: Basic SQL queries, creating and joining tables, displaying output*/


/*(1) Clearing titles, footnotes, and proc titles on ODS*/

TITLE;
FOOTNOTE;
ODS NOPROCTITLE;

/*Creating librefs hwdata and mylib, and fileref output for pdf output*/

LIBNAME hwdata "C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\Homework Assignments\HWDATA" access=readonly;

LIBNAME mylib "C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\Homework Assignments\MYLIB" access=readonly;

FILENAME output "C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\Homework Assignments\4\CPoulson_HW04_output.pdf";

/*(2) Opening the PDF output file destination*/

ODS PDF FILE= output;

/*(3) Printing all rows and columns from hwdata.course1 dataset*/
/*Writing to the log the sql long-hand code with feedback*/
/*Preventing the first statement from actually running with noexec*/

PROC SQL feedback noexec;
SELECT *
	FROM hwdata.course1;

/*Resetting the sql options to allow code execution once again*/

RESET exec;

/*Describing the hwdata.course2 dataset*/

PROC SQL;
DESCRIBE TABLE hwdata.course2;
QUIT;

/*(4) Creating a table from course1 and course2 datasets in hwdata library*/
/*Select clause selects included variables with applied aliases and labels*/
/*From clause specifies data sources*/
/*Where clause specifies join conditions of matching PKEY values*/
/*Additional clause to only select course1 students with passing grades*/

PROC SQL;
CREATE TABLE both_courses_sql AS
	SELECT one.MAJOR as Major_C1 "Major_C1", one.TERM as Term_C1 "Term_C1",
		   one.GRADE as Grade_C1 "Grade_C1", one.PKEY format=10., two.MAJOR as Major_C2 "Major_C2",
		   two.TERM as Term_C2 "Term_C2", two.GRADE as Grade_C2 "Grade_C2",
		   Term_C2-Term_C1 as Term_Length
		FROM hwdata.course1 one, hwdata.course2 two 
		WHERE one.PKEY=two.PKEY
		and one.GRADE in ("A", "B", "C", "S");
QUIT;

/*(5) Selecting Course 1 Term and creating Students variable with the count function*/
/*From clause specifies data source*/
/*Group By and count number of students in Course 1 Term */
/*Having clause limits output to terms with 4 or more students*/
/*Order By clause orders the output by descending order of students*/

PROC SQL;
TITLE "Number of Students per Term in Course 1 Who Took Course 2";
SELECT Term_C1, count(*) as Students "Number of Students"
	FROM both_courses_sql
	GROUP BY Term_C1
	HAVING Students ge 4
	ORDER BY Students desc;
QUIT;

/*(6) Highlighting the two students with abnormal term lengths between courses*/

PROC SQL;
TITLE "Students with Abnormalities in Term Length Between Courses";
SELECT *
	FROM both_courses_sql
	WHERE Term_Length = -20;
QUIT;

/*(7) Reporting descriptor portion of both_courses_sql dataset*/

TITLE "CU Students Recorded Taking Course 1 and 2";
PROC CONTENTS DATA=both_courses_sql varnum;
run;

/*(8) Reporting descriptor portion of mylib.both_courses dataset from previous hw*/

TITLE "Students in Both Courses (from previous assignment)";
PROC CONTENTS DATA=mylib.both_courses varnum;
run;

/*(9) Closing the PDF ODS output file*/

ODS PDF CLOSE;

/*(12)*/
/*(a) NOTE: Statement transforms to: */
/*select COURSE1.MAJOR, COURSE1.TERM, COURSE1.COURSE, COURSE1.GRADE, COURSE1.PKEY*/
/*from HWDATA.COURSE1;*/

/*(b) The format of the term column in hwdata.COURSE2 is BEST. and the label is TERM.*/

/*(c) The data type of the COURSE column in hwdata.COURSE 2 is character. The length is 7,*/
/*and the following syntax defined the column (step 3c of this program):*/
/*COURSE char(7) format=$7. informat=$7. label='COURSE'*/

/*(d) 201730 (Fall 2017) Course 1 term had the highest number of students in course 2 with 15 students.*/

/*(e) The order of the columns in the table I created with SQL is the same order that I listed in*/
/*the SELECT clause. The order of the columns in the table from the previous assignment happens to*/
/*be the same since I listed them similarly in the MERGE statement. The MERGE statement determines*/
/*the order of columns by taking the order from the first dataset, and then appending to it the*/
/*columns from subsequent datasets. PROC SQL determines column order simply by the order columns*/
/*are listed in the SELECT clause.*/


