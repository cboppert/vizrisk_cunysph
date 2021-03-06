
/****************************************************************************/
/*																			*/
/* Data Management Project				  								    */
/* Last updated 4/5/2014 by Henry Wang										*/
/* 																			*/
/****************************************************************************/
/*Create Libname*/
libname epi752 "C:\Users\hwang1\Dropbox\School\Hunter\Spring 2014\EPI 752\Project\Data"; run; 
libname epi752 "e:\School\EPI 752 Project\Project\Data"; run;
/****************************************************************************/
/* Data Cleaning				  								  		    */
/****************************************************************************/
/*Look at data*/
proc print data=Y_mgx; run;
/*Look at physical activity questionaire data*/
proc print data=Y_paq; run;
/*Look at sample weights and demographics data*/
proc print data=Y_demo; run;
/*Look at sample weights and demographics data*/
proc print data=Y_bmx; run;
/*Merge datasets*/
data nnyfsmerged;
merge Y_demo Y_paq Y_mgx y_bmx;
by SEQN;
/*Save Dataset*/
Data epi752.demo_paq_mgx;/*this is where you will save it to*/
Set work.nnyfsmerged; /*this is the file you want to save*/
Run;

/*Rename varables*/
data epi752.demo_paq_mgx; set epi752.demo_paq_mgx;
rename 
bmicat=bmi_cat; 
run;
data epi752.demo_paq_mgx; set epi752.demo_paq_mgx;
rename MGDCGSZ=grip_combined; 
run;
data epi752.demo_paq_mgx; set epi752.demo_paq_mgx;
rename 
bmxbmi=bmi; 
run;

/*Create New Variables*/
data epi752.demo_paq_mgxA; /*Strated a new data file here*/ 
set epi752.demo_paq_mgx;
gripmean_h1= mean(MGXH1T1,MGXH1T2,MGXH1T3); /*Average grip strength hand 1*/
gripmean_h2= mean(MGXH2T1,MGXH2T2,MGXH2T3); /*Average grip strength hand 2*/
gripmax_h1= max(MGXH1T1,MGXH1T2,MGXH1T3); /* Peak grip strength hand 1*/
gripmax_h2= max(MGXH2T1,MGXH2T2,MGXH2T3); /* Peak grip strength hand 2*/
gripmax_both = max(MGXH1T1,MGXH1T2,MGXH1T3MGXH2T1,MGXH2T2,MGXH2T3);
/*Create Average Grip Strength Both Hands*/
/*Create Peak Grip Strength Both Hands*/
run;  

data epi752.demo_paq_mgxA1; /*Strated a new data file here*/ 
set epi752.demo_paq_mgxA;
gripmax_both = max(MGXH1T1,MGXH1T2,MGXH1T3MGXH2T1,MGXH2T2,MGXH2T3);run;

/*Create a Subset Males Only*/
DATA epi752.demo_paq_mgxA_Males;
  SET epi752.demo_paq_mgxA;
 IF RIAGENDR = 2 THEN DELETE ;
run;
proc freq data=epi752.demo_paq_mgxA_Males; tables RIAGENDR ; run;

/*Create a Subset Females Only*/
DATA epi752.demo_paq_mgxA_Females;
  SET epi752.demo_paq_mgxA;
 IF RIAGENDR = 1 THEN DELETE ;
run;
proc freq data=epi752.demo_paq_mgxA_females; tables RIAGENDR ; run;

/* Freqs*/
proc freq data=epi752.demo_paq_mgx; tables grip_combined ; run; 
proc freq data=epi752.demo_paq_mgx; tables bmi_cat ; run; 
proc freq data=epi752.demo_paq_mgx; tables height_cm ; run;
proc freq data=epi752.demo_paq_mgx; tables bmi ; run;
proc freq data=epi752.demo_paq_mgx; tables weight_kg ; run;
proc freq data=epi752.demo_paq_mgxA; tables gripmean_h1 ; run; 
proc freq data=epi752.demo_paq_mgxA; tables gripmean_h2 ; run;
proc freq data=epi752.demo_paq_mgxA; tables MGXH1T1 MGXH1T2 MGXH1T3 ; run;
proc freq data=epi752.demo_paq_mgxA; tables RIAGENDR ; run;
proc surveyfreq data=epi752.demo_paq_mgxA; tables riagendr; strata wtint ; weight WTMEC ; run; 

/*http://www.ats.ucla.edu/stat/sas/webbooks/reg/chapter1/sasreg1.htm*/
/*Histogram - Checking to see if the Gripmax_Both Variable is normally distrubuted*/
proc univariate data=epi752.demo_paq_mgxA;
 histogram gripmax_both;
run;
proc univariate data=epi752.demo_paq_mgxA1;
var gripmax_both; histogram / cfill=Red normal midpoints=7.5 to 55.5 by 5; run; 
proc univariate data=epi752.demo_paq_mgxA1;
var gripmax_both; histogram /  cfill=gray normal midpoints=7.5 to 55.5 by 5 kernel; run; 

/*Q-Q Plot */
proc univariate data=epi752.demo_paq_mgxA1;
  var gripmax_both ;
  qqplot / normal;
run;  

proc capability data=epi752.demo_paq_mgxA1 noprint;
  ppplot gripmax_both ;
run;

/**************************************************************************************/
/*Log Transformation of GripMax_Both*/
data epi752.demo_paq_mgxA2;
  set epi752.demo_paq_mgxA1;
log_gripmax_both = log(gripmax_both);/*Log Transformation of Grip max Both*/
log_bmi = log(bmi); /*Log Transformation of BMI*/
if 0=<paq706<=6 then paq60_min=0;/*Physical Activity Recode*/
if paq706=7 then paq60_min=1; 
if paq706=99 then paq60_min=999;
run; 
/*Check Recodes*/
proc freq data=epi752.demo_paq_mgxA2; 
tables paq60_min log_bmi log_gripmax_both ; run; 

/*******************Histograms*****************/
proc univariate data=epi752.demo_paq_mgxA2 noprint;
  var log_gripmax_both ;/*Histogram for Log Gripmax*/
  histogram / cfill=grayd0  normal kernel (color = red);
run;
proc univariate data=epi752.demo_paq_mgxA;
 histogram gripmax_h1; /* is this as normall distrubuted as you would like? - May Consider transformation*/ 
run;
proc univariate data=epi752.demo_paq_mgxA2 noprint;
  var bmi ;/*Histogram for BMI*/
  histogram / cfill=grayd0  normal kernel (color = red);
run;
proc univariate data=epi752.demo_paq_mgxA2 noprint;
  var log_bmi ;/*Histogram for Log BMI*/
  histogram / cfill=grayd0  normal kernel (color = red);
run;

/*Boxplots*/
proc sort data=epi752.demo_paq_mgxA; by RIDAGEYR; run;
proc boxplot data=epi752.demo_paq_mgxA;
plot (gripmax_h1)*RIDAGEYR ; 
run; 
/*Scatter Plots*/
proc sgplot data=epi752.demo_paq_mgxA2;
  scatter x=RIDAGEYR y=gripmax_both ;
run;
proc sgplot data=epi752.demo_paq_mgxA2;
  scatter x=bmi y=gripmax_both ; /*Gripstrength as a predictor for BMI*/
run;

/*Linear Regression with sample weights.*/

proc surveyreg  data= epi752.demo_paq_mgxA2; 
strata SDMVSTRA;  /* Use the strata statement to specify the strata (SDMVSTRA) and account for design effects of stratification.*/
cluster SDMVPSU;  /*Use the cluster statement to specify PSU (sdmvpsu) to account for design effects of clustering.*/
weight WTMEC; /*Use the weight statement to account for the unequal probability of sampling and non-response.  In this example, the MEC weight (WTMEC) is used.*/
model log_gripmax_both= RIDAGEYR /solution clparm; /*Log Gripstrength and Age*/
run;

proc surveyreg  data= epi752.demo_paq_mgxA2; 
strata SDMVSTRA;  /* Use the strata statement to specify the strata (SDMVSTRA) and account for design effects of stratification.*/
cluster SDMVPSU;  /*Use the cluster statement to specify PSU (sdmvpsu) to account for design effects of clustering.*/
weight WTMEC; /*Use the weight statement to account for the unequal probability of sampling and non-response.  In this example, the MEC weight (WTMEC) is used.*/
model log_gripmax_both= BMI /solution clparm;/*Log Gripstrength and BMI*/
run;

proc surveyreg  data= epi752.demo_paq_mgxA2; 
strata SDMVSTRA;  /* Use the strata statement to specify the strata (SDMVSTRA) and account for design effects of stratification.*/
cluster SDMVPSU;  /*Use the cluster statement to specify PSU (sdmvpsu) to account for design effects of clustering.*/
weight WTMEC; /*Use the weight statement to account for the unequal probability of sampling and non-response.  In this example, the MEC weight (WTMEC) is used.*/
model log_gripmax_both= PAQ60_min /solution clparm;/*Log Gripstrength and PA*/
run;

proc surveyreg  data= epi752.demo_paq_mgxA2; 
strata SDMVSTRA;  /* Use the strata statement to specify the strata (SDMVSTRA) and account for design effects of stratification.*/
cluster SDMVPSU;  /*Use the cluster statement to specify PSU (sdmvpsu) to account for design effects of clustering.*/
weight WTMEC; /*Use the weight statement to account for the unequal probability of sampling and non-response.  In this example, the MEC weight (WTMEC) is used.*/
model log_gripmax_both= RIDAGEYR /solution clparm;/*Log Gripstrength and Age*/
run;


/**Means**/
PROC SURVEYMEANS 
data= epi752.demo_paq_mgxA_Males; 
strata SDMVSTRA; 
cluster SDMVPSU;  
weight WTMEC;
domain  RIDAGEYR ; 
var gripmean_h1 gripmean_h2 gripmax_h1 gripmax_h2; /*grip means*/
run;

PROC SURVEYMEANS 
data= epi752.demo_paq_mgxA_females; 
strata SDMVSTRA; 
cluster SDMVPSU;  
weight WTMEC;
domain  RIDAGEYR ; 
var gripmean_h1 gripmean_h2 gripmax_h1 gripmax_h2; /**Means - Females By Age*/
run;

/*Check Means without sample weights - Just to see the numbers you get*/
/*ANOVA*/
PROC ANOVA DATA = epi752.demo_paq_mgxA;
	class RIDAGEYR;
	model gripmax_h1 = RIDAGEYR;
	means RIDAGEYR / TUKEY; /*Requesting TUKEY Method*/ 
	where RIAGENDR = 1; 
RUN;
QUIT;

proc surveyreg
data= epi752.demo_paq_mgxA;
strata SDMVSTRA; 
cluster SDMVPSU;  
weight WTMEC;
model gripmax_h1 = RIDAGEYR /anova;
run;


/*Import Y_PAQ File*/
libname epi xport  "E:\EPI 752 Project\Project\Data\y_paq.xpt";   
data epi752.y_paq;  
   set epi.y_paq;  
run;
/*merge Y_PAQ file with demo_paq_mgxA */

data epi752.data_3_31;
merge epi752.Y_paq epi752.demo_paq_mgxA1;
by SEQN;
run; 


/*Import Y_BMX File*/
libname epi xport  "E:\School\EPI 752 Project\Project\Data\y_bmx.xpt";   
data epi752.y_bmx;  
   set epi.y_bmx;  
run;

/*3/31/2014*/
/*New merged dataset*/

proc sort data=epi752.Demo_paq_mgxa2; by SEQN; run;
proc sort data=epi752.Y_paq; by SEQN; run;
data epi752.datafinal;
merge epi752.Demo_paq_mgxa2 epi752.Y_paq;
by SEQN;
run; 

proc freq data=epi752.datafinal; tables PAQ706  ; run;

DATA epi752.datafinal1; SET epi752.datafinal; 
 physicallyactive = .; 
 IF (PAQ706=7) THEN physicallyactive = 1; 
 IF (PAQ706=6) THEN physicallyactive = 0; 
 IF (PAQ706=5) THEN physicallyactive = 0; 
 IF (PAQ706=4) THEN physicallyactive = 0; 
 IF (PAQ706=3) THEN physicallyactive = 0; 
 IF (PAQ706=2) THEN physicallyactive = 0; 
 IF (PAQ706=1) THEN physicallyactive = 0; 
 IF (PAQ706=0) THEN physicallyactive = 0; 
IF (PAQ706=99) THEN physicallyactive = .; 

PAQ706_nomiss=.;
 IF (PAQ706=0) THEN PAQ706_nomiss = 0; 
 IF (PAQ706=1) THEN PAQ706_nomiss = 1; 
 IF (PAQ706=2) THEN PAQ706_nomiss = 2; 
 IF (PAQ706=3) THEN PAQ706_nomiss = 3; 
 IF (PAQ706=4) THEN PAQ706_nomiss = 4; 
 IF (PAQ706=5) THEN PAQ706_nomiss = 5; 
 IF (PAQ706=6) THEN PAQ706_nomiss = 6; 
 IF (PAQ706=7) THEN PAQ706_nomiss = 7; 
 IF (PAQ706=99) THEN PAQ706_nomiss = .; 
Run;

proc freq data=epi752.datafinal1; tables physicallyactive  ; run;
proc freq data=epi752.datafinal1; tables gripstrength  ; run;


proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
model gripmax_both = PAQ706 /solution clparm; 
run;

proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
model PAQ706= physicallyactive /solution clparm; 
run;

proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
model bmi= PAQ706/solution clparm; 
run;

/*Histrogram*/
proc univariate data=epi752.datafinal1;
 histogram paq706;
run;
/*Scatter plots*/
proc sgplot data=epi752.datafinal1;
  scatter x=PAQ706_nomiss y=bmi / group=RIAGENDR; 
run;

proc sgplot data=epi752.datafinal1;
  scatter x=PAQ706_nomiss y=gripmax_both / group=RIAGENDR; 
run;

proc sgplot data=epi752.datafinal1;
  scatter x=physicallyactive y=bmi / group=RIAGENDR; 
run;

/*Model BMI vs physically active yes no*/

proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
model bmi= physicallyactive/solution clparm; 
run;

proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
model bmi= gripmax_both/solution clparm; 
run;

/*Histrogram for BMI*/
proc univariate data=epi752.datafinal1;
var bmi; histogram /  cfill=gray normal midpoints=7.5 to 55.5 by 5 kernel; run; 



/*Histrogram for BMI*/
proc univariate data=epi752.bmidataset;
var bmi; histogram /  cfill=gray normal midpoints=12.5 to 37 by 1 kernel; run; 

proc univariate data=epi752.y_bmx;
var BMDBMIC; histogram /  cfill=gray normal midpoints=1 to 4 by 1 kernel; run;
proc univariate data=epi752.bmidataset;
var overweight; histogram /  cfill=gray normal midpoints=0 to 1 by 1 kernel; run;

/*QQ Plots*/
proc univariate data=epi752.bmidataset;
  var bmi ;
  qqplot / normal;
run;  
DATA epi752.bmidataset;
  SET epi752.datafinal1;
  log_bmi = log(bmi);
run;

proc univariate data=epi752.bmidataset noprint;
  var log_bmi ;
  histogram / cfill=grayd0  normal kernel (color = red);
run;

proc univariate data=epi752.bmidataset;
  var log_bmi ;
  qqplot / normal;
run; 

proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
model log_bmi= physicallyactive/solution clparm; 
run;

proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
class physicallyactive;
model bmi= physicallyactive/solution clparm; 
run;


proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
model log_gripmax_both= physicallyactive/solution clparm; 
run;

proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
model gripmax_both= physicallyactive/solution clparm; 
run;

proc freq data=epi752.datafinal1; tables PAQ706 physicallyactive; run; 


proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
class physicallyactive;
model gripmax_both= physicallyactive/solution clparm;
run;

/*Physically active vs. Overweight obese*/
/*4/4/2014*/
proc format;
value physicallyactiveF
0="Not Active"
1="Active";

value overweightF
1="Normal"
0="Overweight";

DATA epi752.bmidataset;
  SET epi752.datafinal1;
 IF (bmi=>40) THEN bmi =.;
 IF (bmi=<12) THEN bmi =.;
 if (bmi_cat =1) then overweight =0;
 if (bmi_cat=2)then overweight =0;
 if (bmi_cat =3)  then overweight =1;
 if(bmi_cat=4)then overweight =1;
 if (bmi_cat =.) then overweight=.;

format
physicallyactive physicallyactiveF.
overweight overweightf.;
run;
/*Analysis*/

PROC SURVEYFREQ data=epi752.bmidataset;
TABLES  bmi_CAT overweight ; 
STRATA SDMVSTRA; 
CLUSTER SDMVPSU; 
WEIGHT WTMEC ; 
RUN;

PROC SURVEYFREQ data=epi752.bmidataset;
TABLES  physicallyactive*overweight; 
STRATA SDMVSTRA; 
CLUSTER SDMVPSU; 
WEIGHT WTMEC ; 
RUN;

PROC SURVEYLOGISTIC data=epi752.bmidataset;
Class physicallyactive /param=ref; 
Model overweight = physicallyactive ; 
STRATA SDMVSTRA; 
CLUSTER SDMVPSU; 
WEIGHT WTMEC ; 
RUN;

PROC SURVEYLOGISTIC data=epi752.bmidataset1; 
Model overweight (descending) = physicallyactive ; 
STRATA SDMVSTRA; 
CLUSTER SDMVPSU; 
WEIGHT WTMEC ; 
RUN;

/*This one may be it!*/

data epi752.bmidataset1; /*Strated a new data file here*/ 
set epi752.bmidataset;
total_SKF= sum (BMXSUB,BMXTRI,BMXCALFF); 
drop total_SKF; 
run; 




/*Means*/
proc sort data=epi752.bmidataset1; by RIAGENDR; run;
Proc Surveymeans data=epi752.bmidataset1
 mean STDERR median min max;
VAR bmi RIDAGEYR RIDEXAGY BMXARMC BMXWAIST BMXCALF BMXCALFF BMXTRI BMXSUB;
by RIAGENDR;
STRATA SDMVSTRA; 
CLUSTER SDMVPSU; 
RUN;

Proc Surveymeans data=epi752.bmidataset1
 mean STDERR median min max;
VAR BMXWAIST;
STRATA SDMVSTRA; 
CLUSTER SDMVPSU; 
RUN;

/*Freqs*/
PROC SURVEYFREQ data=epi752.bmidataset;
TABLES  physicallyactive PAQ706 overweight bmi_cat RIDRETH1; 
STRATA SDMVSTRA; 
CLUSTER SDMVPSU; 
WEIGHT WTMEC ; 
RUN;

PROC SURVEYFREQ data=epi752.bmidataset;
TABLES  BMXWAIST; 
STRATA SDMVSTRA; 
CLUSTER SDMVPSU; 
WEIGHT WTMEC ; 
RUN;

/*Chi Square*/
PROC SURVEYFREQ data=epi752.bmidataset;
TABLES physicallyactive*overweight/row CHISQ;
STRATA SDMVSTRA; 
CLUSTER SDMVPSU; 
WEIGHT WTMEC ; 
RUN;


PROC SURVEYLOGISTIC data=epi752.bmidataset1; 
CLASS physicallyactive (ref="Active") /param=ref ; /* */
MODEL overweight (event='overweight') = physicallyactive ; 
domain RIAGENDR;
STRATA SDMVSTRA; 
CLUSTER SDMVPSU; 
WEIGHT WTMEC ; 
RUN;


/**/
PROC SURVEYLOGISTIC data=epi752.bmidataset1;  
CLASS PAQ706(param=ref ref='7') ; 
MODEL overweight (descending) = PAQ706 RIDAGEYR ; 
domain RIAGENDR;
STRATA SDMVSTRA; 
CLUSTER SDMVPSU; 
WEIGHT WTMEC ; 
RUN;


PROC SURVEYLOGISTIC data=epi752.bmidataset1; 
CLASS physicallyactive/ param=ref ; 
MODEL overweight (descending) = physicallyactive RIDAGEYR; 
domain RIAGENDR;
STRATA SDMVSTRA; 
CLUSTER SDMVPSU; 
WEIGHT WTMEC ; 
RUN;

PROC SURVEYLOGISTIC data=epi752.bmidataset1; 
CLASS physicallyactive (ref="Active") /param=ref ; 
MODEL overweight (event='overweight') = physicallyactive ; 
domain RIAGENDR;
STRATA SDMVSTRA; 
CLUSTER SDMVPSU; 
WEIGHT WTMEC ; 
RUN;
/*Histrogram for WC*/
proc univariate data=epi752.datafinal1;
var BMXWAIST; histogram /  cfill=gray normal midpoints=7.5 to 55.5 by 5 kernel; run; 

/*Linear Regression*/

/*Waist Circumference*/
proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
CLASS physicallyactive (ref="Active") /param=ref ; 
model BMXWAIST= physicallyactive RIDAGEYR/solution clparm;
run;

/*Arm Circumference*/
proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
CLASS BMXARMC (ref="Active") /param=ref ; 
model BMXARMC= physicallyactive RIDAGEYR/solution clparm;
run;


/*Subscapular*/
proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
CLASS physicallyactive (ref="Active") /param=ref ; 
model BMXSUB= physicallyactive RIDAGEYR/solution clparm;
run;

/*Tricep*/
proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
CLASS physicallyactive (ref="Active") /param=ref ; 
model BMXTRI= physicallyactive RIDAGEYR/solution clparm;
run;
/*Calf*/
proc surveyreg  data= epi752.datafinal1;
strata SDMVSTRA;  
cluster SDMVPSU;  
weight WTMEC; 
CLASS physicallyactive (ref="Active") /param=ref ; 
model BMXCALFF= physicallyactive RIDAGEYR/solution clparm;
run;




