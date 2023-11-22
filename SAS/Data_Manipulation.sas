/***********************************************************************************/
/*Program Name: Data_Manipulation.sas*/
/*Author: Casey Poulson*/
/*Purpose: Data manipulation with arrays,*/
/*applying user-created functions and subroutines*/


/*(3) Libname statements to assign librefs to libraries, protecting hwdata*/
/*Creating output fileref for pdf output, and opening the file destination*/

LIBNAME HWDATA '~PATH\HWDATA' access=readonly;

LIBNAME MYLIB '~PATH\MYLIB';

FILENAME output '~PATH\Data_Manipulation_output.pdf';

ODS PDF FILE= output style=sapphire;

/*(4) Setting options to tell SAS where to look for stored functions*/

OPTIONS CMPLIB=mylib.functions nodate;

/*(5) Clearing titles, footnotes, and proc titles on ODS*/

TITLE;
FOOTNOTE;
ODS NOPROCTITLE;

/*(6) Creating temporary format dmy_date using date directives*/

TITLE "Creating dmy_date temporary format";
PROC FORMAT fmtlib;
	PICTURE dmy_date (default=20)
		'01JAN1950'd-'26APR2022'd = '%A: %0d%b%Y' (datatype=date);
run;

/*(7) Creating temporary dataset course1 from hwdata.course1*/
/*Initializing Season as character variable, Year, and Season_Code variables.*/
/*Calling the term_parse subroutine created in CPoulson_HW12_function.sas*/

DATA course1;
	SET hwdata.course1;
	Season=put(TERM,6.);
	CALL missing(Year, Term_Code);
	CALL term_parse(TERM, Year, Season, Term_Code);
run;

/*(8) Creating mylib.course1_gpa dataset with unique season, year, and*/
/*term_code combinations. GPA is calculated by using the gradePt function*/
/*created in CPoulson_HW12_function.sas, averaged across the distinct combinations.*/

PROC SQL;
CREATE TABLE mylib.course1_gpa as
	SELECT distinct Season 'Season', 
		   Year 'Year', 
		   Term_Code 'Term Code', 
	       mean(gradePt(GRADE)) as GPA 'GPA' format=5.3 
	FROM course1
	GROUP BY Season, Year, Term_Code
	ORDER BY Year, Term_Code;
QUIT;

/*(9) Transposing myilb.course1_gpa to create mylib.c1_gpa_tran*/
/*By year indicates row indexes, Var GPA indicates transposed variables*/
/*ID Term_Code names columns with Term as the indicated Prefix*/

PROC TRANSPOSE DATA=mylib.course1_gpa OUT=mylib.c1_gpa_tran(drop=_name_ _label_)
	PREFIX=Term;
	BY Year;
	VAR GPA;
	ID Term_Code;
run;

/*(10) Printing transposed dataset with title using custom format from above*/
/*to display the current date.*/

TITLE1 "Mylib.C1_GPA_TRAN Transposed Dataset";
TITLE2 "Based on Grades as of %sysfunc(today(),dmy_date.)";
PROC PRINT DATA=mylib.c1_gpa_tran noobs;
run;

/*(11) Creating mylib.course1_major dataset with unique major, season, year, and*/
/*term_code combinations. GPA is calculated by using the gradePt function*/
/*created in CPoulson_HW12_function.sas, averaged across the distinct combinations.*/

PROC SQL;
CREATE TABLE mylib.course1_major as
	SELECT distinct MAJOR 'Major',
		   Season 'Season', 
		   Year 'Year', 
		   Term_Code 'Term Code', 
	       mean(gradePt(GRADE)) as GPA 'GPA' format=5.3 
	FROM course1
	GROUP BY MAJOR, Season, Year, Term_Code
	ORDER BY Year, Term_Code, MAJOR;
QUIT;

/*(12) Creating dataset course1_major*/
/*Array Tran has row values 2017-2020, column values 1-3, */
/*with GPA average values supplied.*/
/*Array Tran populates the Term_Average variable, formatted for 3 decimals.*/
/*Variable Performance has length set and values determined conditional*/
/*on the values of the GPA column.*/

DATA course1_major;
	ARRAY Tran{2017:2020,3} _temporary_
	(3.167,3.327,3.058,2.571,2.854,3.235,
	2.821,3.510,3.325,3.239,3.528,3.377); 
	SET mylib.course1_major;
	Term_Average = Tran{Year,Term_Code/10};
	format Term_Average 5.3;
	length Performance $16;
	label Term_Average = "Term Average";
	IF GPA = . THEN Performance = "No Credit";
	ELSE IF GPA < Term_Average THEN Performance = "Below Average";
	ELSE Performance = "Average or Above";
run;

/*(13) */

TITLE1 "Course1_Major Temporary Dataset";
TITLE2 "Based on Grades as of %sysfunc(today(),dmy_date.)";
PROC PRINT DATA=course1_major noobs label;
VAR MAJOR Season Year GPA Term_Average Performance;
run;

/*Closing the PDF ODS output file*/

ODS PDF CLOSE;
