/*************************************************************************/
/*Program Name: CPoulson_HW03_prog.sas*/
/*Program Location: C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\
                    STAT 657\Homework Assignments\3*/
/*Author: Casey Poulson*/
/*Creation Date: 19 January 2022*/
/*Last Run Date: 24 January 2022*/
/*Purpose: Merging and manipulating data, creating formats, libraries, and displaying descriptive statistics*/


/*Clearing titles, footnotes, and proc titles on ODS*/
TITLE;
FOOTNOTE;
ODS NOPROCTITLE;

/*(1) Creating librefs hwdata and mylib, and fileref output for pdf output*/
LIBNAME hwdata "C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\Homework Assignments\HWDATA" access=readonly;
LIBNAME mylib "C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\Homework Assignments\MYLIB";
FILENAME output "C:\Users\rockc\OneDrive\Documents\A&M\2022\Spring 2022\STAT 657\Homework Assignments\3\CPoulson_HW03_output.pdf";

/*(2) Creating a permanent custom format term_length*/ 
PROC FORMAT lib=mylib.myfmts;
	VALUE term_length 
		80  = "1 Term"
		90  = "2 Terms"
		100 = "3 Terms"
		180 = "4 Terms"
		190 = "5 Terms"
		200 = "6 Terms"
		200<-high = "7+ Terms";
run;

/*(3) Sorting Course1 Dataset by PKEY and creating course1_sort dataset*/

PROC SORT DATA=hwdata.course1 OUT=course1_sort;
	BY PKEY;
run;
/*Sorting Course2 Dataset by PKEY and creating course2_sort dataset*/

PROC SORT DATA=hwdata.course2 OUT=course2_sort;
	BY PKEY;
run;
/*Creating the 3 datasets in the manner outlined as follows*/
/*Naming the output datasets and which variables to keep in each*/
/*Merging the 2 sorted datasets by PKEY, renaming variables to reflect course number*/
/*Dropping the Course variable from each dataset, and only including Grades of A, B, C, or S from Course 1*/
/*Also creating in variables as indicators for contributing to the current observation*/
/*Removing unnecessary labels*/
/*Creating Term_Length variable as outlined*/
/*Outputting observations only found in Course 1 to the corresponding dataset*/
/*Outputting observations only found in Course 2 to the corresponding dataset*/
/*Outputting observations found in both courses to the corresponding dataset*/
DATA mylib.course1_only(keep=Major_c1 Term_c1 Grade_c1 PKEY) course2_only(keep=Major_c2 Term_c2 Grade_c2 PKEY) mylib.both_courses(keep=Major_c1 Term_c1 Grade_c1 PKEY Major_c2 Term_c2 Grade_c2 Term_Length);
	MERGE course1_sort(in=in1 rename=(MAJOR=Major_c1 TERM=Term_c1 GRADE=Grade_c1) drop=COURSE where=(Grade_c1 in ("A", "B", "C", "S"))) course2_sort(in=in2 rename=(MAJOR=Major_c2 TERM=Term_c2 GRADE=Grade_c2) drop=COURSE);
	BY PKEY;
	ATTRIB _ALL_ LABEL="";
	Term_Length = abs(Term_c2 - Term_c1);
	IF in1=1 and in2=0 THEN OUTPUT mylib.course1_only;
	IF in1=0 and in2=1 THEN OUTPUT course2_only;
	IF in1=1 and in2=1 THEN OUTPUT mylib.both_courses;
run;

/*(4) Opening the PDF output file destination*/
ODS PDF FILE= output;

/*(5) Supplying the folder containing my previously created format with FMTSEARCH option*/
/*Creating a frequency table showing the various term lengths of students who took both courses*/
/*Selecting the Term_Length variable and suppressing cumulative statistics*/
/*Formatting this variable with the previously created custom format*/
OPTIONS FMTSEARCH=(mylib.myfmts);
TITLE1 "Term Length Between Courses for CU Students Who Took Both Courses";
PROC FREQ DATA=mylib.both_courses;
	TABLES Term_Length / NOCUM;
	FORMAT Term_Length term_length.;
run;

/*(6) Printing the 2 observations with abnormal values for Term Length*/
TITLE1 "Students with Abnormalities in Term Length Between Courses";
PROC PRINT DATA=mylib.both_courses;
	WHERE Term_Length = 20;
run;

/*(7) Descriptor Portion of course2_only dataset for students recorded only taking course 2*/
TITLE1 "CU Students Recorded Completing Course 2 and Not Course 1";
PROC CONTENTS DATA=course2_only;
run;

/*(8) Reporting the contents of the temporary Work library*/
TITLE1 "Work Library Contents";
PROC CONTENTS DATA=work._ALL_ NODS;
run;

/*(9) Reporting the contents of the permanent Mylib library with variables displayed in creation order*/
TITLE1 "Mylib Library Contents";
PROC CONTENTS DATA=mylib._ALL_ varnum;
run;

/*(10) Closing the PDF ODS output file*/
ODS PDF CLOSE;

/*(13) Questions*/
/*(a) 559 students who were eligible for Course 2 only took Course 1 */

/*(b) 92 students took both Course 1 and Course 2*/

/*(c) 20 students took Course 2 with no record of them having taken Course 1*/

/*(d) There were 2 students with abnormal term lengths, as seen in the output of step 6.*/
/*One of these students is recorded of having taken Course 1 in the Fall of 2019, and having taken*/
/*Course 2 in the Spring of 2019. So this student took the two courses in the wrong order.*/
/*The other student appears to have done the exact same thing in 2018.*/

/*(e) Only 2.17% of students (2 students) who took both courses waited 7 or more terms after having completed*/
/*Course 1, before taking Course 2.*/

		
		
		

