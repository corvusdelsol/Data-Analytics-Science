/***********************************************************************************/
/*Program Name:SQL_Joins.sas*/
/*Author: Casey Poulson*/
/*Purpose: Outer Joins, Set Operators, and Sub-Queries in PROC SQL*/


/*(1) Clearing titles, footnotes, and proc titles on ODS*/

TITLE;
FOOTNOTE;
ODS NOPROCTITLE;

/*Creating librefs hwdata and mylib, and fileref output for pdf output*/

LIBNAME hwdata "~PATH\HWDATA" access=readonly;
LIBNAME mylib "~PATH\MYLIB" access=readonly;
FILENAME output "~PATH\SQL_Joins_output.pdf";

/*(2) Opening the PDF output file destination*/

ODS PDF FILE= output;

/*(3) 1st step creates a temporary table for Course 1 students with eligible grades*/
/*for taking course 2.*/

PROC SQL;
CREATE TABLE course1_eligible as
	SELECT *
	FROM hwdata.course1
	WHERE GRADE in ("A", "B", "C", "S");

/*Creating a table with selected columns, supplying aliases, labels, and formats*/
/*Using coalesce function to return the first non-missing value for PKEY*/
/*Creating Term_Length variable as stated*/
/*FROM clause selects data sources and specifies a full join is to be made*/
/*ON clause specifies the join conditions*/
/*ORDER BY clause specifies the sorting order of observations*/

CREATE TABLE fulljoin as
	SELECT COALESCE(one.PKEY, two.PKEY) as PKEY format=10., 
	   	   one.MAJOR as Major_C1 "Major_C1", 
 	       one.TERM as Term_C1 "Term_C1",
	       one.GRADE as Grade_C1 "Grade_C1", 
	       two.MAJOR as Major_C2 "Major_C2",
	       two.TERM as Term_C2 "Term_C2", 
		   two.GRADE as Grade_C2 "Grade_C2", 
		   Term_C2-Term_C1 as Term_Length
	FROM course1_eligible as one FULL JOIN hwdata.course2 as two
	ON (one.PKEY=two.PKEY)
	ORDER BY Term_C1, PKEY;

/*Reporting students whom only took course 2 with selected variables*/
/*FROM clause specifies to use the table previously created as the source*/
/*WHERE clause only selects students who received course 2 grades*/
/*ORDER BY clause sorts results by course 2 grades*/

TITLE "Students Recorded Completing Only Course 2";
PROC SQL;
SELECT PKEY format=10., Major_C2, Term_C2, Grade_C2
	FROM fulljoin
	WHERE Grade_C2 and not Grade_C1
	ORDER BY Grade_C2;
QUIT;

/*(4) number option prints row numbers on output*/
/*Selecting pkey and major columns from hwdata.course1 dataset*/
/*Grouping by and only including mulitple instances of pkey*/
/*Intersecting this selection with the following selection:*/
/*Selecting pkey and major columns from hwdata.course1 dataset*/
/*Where the term is fall 2017 (201730)*/

TITLE "Students Taking Course 1 Multiple Terms Including Fall 2017";
PROC SQL number;
	SELECT PKEY format=10., MAJOR
	FROM hwdata.course1
	GROUP BY PKEY
	HAVING count(*) > 1
INTERSECT 
	SELECT PKEY, MAJOR
	FROM hwdata.course1
	WHERE TERM = 201730;
QUIT;

/*(5) Selecting course, grade, and count column for variables from course 1*/
/*From hwdata.course 1 as first source*/
/*Grouping By grade to affect the count column "Students"*/
/*Union as the set operator to select unique rows from both tables*/
/*Selecting course, grade, and count column for variables from course 2*/
/*From hwdata.course2 as second source*/
/*Grouping By grade to affect the count column "Students"*/

TITLE "Grade Distribution of Students in Courses 1 and 2";
PROC SQL;
	SELECT COURSE "Course", GRADE "Grade", count(*) as Students "Students"
	FROM hwdata.course1
	GROUP BY GRADE
UNION
	SELECT COURSE, GRADE, count(*) as Students "Students"
	FROM hwdata.course2
	GROUP BY GRADE;
QUIT;

/*(6) Creating temporary table course1_only with the following selection:*/
/*Selecting pkey, term, major, and grade columns from course 1*/
/*FROM the fulljoin table created in step 3 as it already contains only*/
/*those students from course 1 who were eligible to take course 2*/
/*WHERE the student's PKEY is not in the following sub-query:*/
/*Selecting the PKEY column from fulljoin table*/
/*WHERE the course 2 Term variable has a non-missing value*/

TITLE "Students Eligible for Course 2 That Only Took Course 1";
PROC SQL;
CREATE TABLE course1_only as
	SELECT PKEY format=10., Term_C1, Major_C1, Grade_C1
	FROM fulljoin
	WHERE PKEY not in
		(SELECT PKEY
		 FROM fulljoin
		 WHERE Term_C2 is not missing);
QUIT;

/*(7) Reporting the contents of the temporary Work library*/

TITLE "Work Library Contents";
PROC CONTENTS DATA=work._ALL_;
run;

/*(8) Closing the PDF ODS output file*/

ODS PDF CLOSE;
