 /***********************************************************************************/
 /*Program Name: Index_&_Hash_Objects.sas*/
 /*Author: Casey Poulson*/
 /*Purpose: Creating and using indexes and hash objects in data manipulation*/
 
 
 /*(1) Assigning libref hwdata with read and write access*/
 /*Creating output fileref for pdf output, and opening the file destination*/
 
 LIBNAME HWDATA '~PATH\HWDATA';
 
 FILENAME output '~Path\CPoulson_HW13_output.pdf';
 
 ODS PDF FILE= output style=sapphire;
 
 /*Clearing titles, footnotes, and proc titles on ODS*/
 /*Setting system options ensuring index usage messages are printed in the log*/
 
 TITLE; FOOTNOTE; ODS NOPROCTITLE;
 
 OPTIONS nodate msglevel=i;
 
 
 /*(2) Creating 2 temporary datasets newfunds with dropped variables, and allfunds*/
 /*Setting lengths and initializing variables as missing*/
 /*First iteration of the data step, creating hash object invest*/
 /*Invest uses data from hwdata.investmentfunds with Symbol as the Key*/
 /*and Data variables defined on definedata method.*/
 /*Reading in hwdata.funds22apr2022 dataset*/
 /*If no match found in hash object, assign Type its value, & output to newfunds*/
 /*If match found, create new column as defined and output to allfunds*/
 /*Last output statement ensures allfunds get all rows and columns from*/
 /*hwdata.funds22apr2022.*/
 
 DATA newfunds(drop=_1_YR Max__Sales_Charge Expense_Ratio Yield_Comparison) allfunds;
    length Symbol $5 _1_YR 8 Max__Sales_Charge 8 Expense_Ratio 8 Type $24 Yield_Comparison 8;
    CALL MISSING(_1_YR, MAX__SALES_CHARGE, EXPENSE_RATIO);
    IF _n_ = 1 THEN DO;
        DECLARE hash invest(dataset: 'hwdata.investmentfunds');
        invest.definekey('Symbol');
        invest.definedata('_1_YR','MAX__SALES_CHARGE','EXPENSE_RATIO','Type');
        invest.definedone();
    END;
 SET hwdata.funds22apr2022;
    IF invest.find(key:Symbol) ne 0 THEN DO; 
        Type = 'Uncategorized New Fund';
        output newfunds;
    END;
    IF invest.find(key:Symbol) = 0 THEN DO;
        Yield_Comparison = YTD_Return - _1_YR;
        output allfunds;
    END;
 output allfunds;
 run;
 
 /*(3) Printing first 15 obs of work.newfunds dataset*/
 
 TITLE "Beginning of Newfunds Dataset";
 PROC PRINT DATA=newfunds (obs=15);
 run;
 
 /*(4) Printing descriptor portion of allfunds dataset*/
 
 TITLE "Allfunds Dataset Contents";
 PROC CONTENTS DATA=allfunds;
 run;
 
 /*Providing summary statistics for Yield_Comparison in allfunds dataset*/
 /*Class statement provides one row for each Type*/
 
 TITLE "Yield_Comparison Stats By Type";
 PROC MEANS DATA=allfunds min max mean maxdec=4;
    CLASS Type;
    VAR Yield_Comparison;
 run;
 
 /*(5) Creating composite index idterm from hwdata.course1*/
 /*PKEY and Term variables used for the index*/
 
 PROC SQL;
    CREATE INDEX idterm 
    ON hwdata.course1 (PKEY, Term);
 QUIT;
 
 /*(6) Printing descriptor portion of hwdata.course1 dataset*/
 
 TITLE "Hwdata.Course1 Dataset Contents";
 PROC CONTENTS DATA=hwdata.course1;
 run;
 
 /*(7) Creating course1_dup dataset. Term_Lag created with lag function*/
 /*First If condition only outputs rows that have duplicate PKEY values*/
 /*Second If condition sets Term_Lag to missing for the first instance*/
 /*of a duplicated PKEY observation.*/
 
 DATA course1_dup; 
    SET hwdata.course1;
    BY PKEY;
    Term_Lag = Term-lag1(Term);
    IF first.pkey=0 or last.pkey=0;
    IF first.pkey=1 and last.pkey=0 then Term_Lag = .;
 run;
 
 /*(8) Reporting the distribution of the Term_Lag variable created above*/
 
 TITLE "Distribution of Term_Lag for Students that Repeated Course1";
 PROC FREQ DATA=course1_dup;
    TABLES Term_Lag;
 run;
 
 /*(9) Controlling index usage with idxwhere and idxname options on where processing*/
 /*(a)*/
 
 title "9a. IDXWHERE on PKEY";
 PROC PRINT DATA=hwdata.course1(idxwhere=yes);
    WHERE PKEY > 1800000000;
 run;
 
 /*(b)*/
 
 title "9b. IDXWHERE Restricted";
 PROC PRINT DATA=hwdata.course1(idxwhere=no);
    WHERE PKEY > 1800000000;
 run;
 
 /*(c)*/
 
 title "9c. IDXWHERE on TERM";
 PROC PRINT DATA=hwdata.course1(idxwhere=yes);
    WHERE TERM = 201910;
 run;
 
 /*(d)*/
 
 title "9d. IDXNAME on TERM";
 PROC PRINT DATA=hwdata.course1(idxname=idterm);
    WHERE TERM = 201910;
 run;
 
 /*(e)*/
 
 title "9e. IDXWHERE on Major or Term";
 PROC PRINT DATA=hwdata.course1(idxwhere=yes);
    WHERE MAJOR = 'MISY' or TERM = 201910;
 run;
 
 /*(10) Deleting the idterm index by re-creating hwdata.course1*/
 
 DATA hwdata.course1;
    SET hwdata.course1;
 run;
 
 /*Printing descriptor portion of hwdata.course1 dataset*/
 
 TITLE "Hwdata.course1 Dataset Contents";
 PROC CONTENTS DATA=hwdata.course1;
 run;
 
 /*Closing the PDF ODS output file*/
 
 ODS PDF CLOSE;