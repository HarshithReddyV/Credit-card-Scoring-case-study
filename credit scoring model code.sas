
Proc import datafile="/home/harshithreddyv0/Logistic regression/Credit.csv" 
dbms=csv 
out= Graded.Credit replace;
run;

proc contents data=Graded.credit;
run;

data Graded.credit_new(drop=Var12);
set Graded.credit;
Rename RevolvingUtilizationOfUnsecuredL=RevUtiUnsec;
Rename MonthlyIncome=Income;
Rename Rented_OwnHouse=House_Ownership;
Rename NumberOfTime30_59DaysPastDueNotW=DuenW3059;
Rename NumberOfOpenCreditLinesAndLoans=Creditline_loan;
Rename NumberOfTimes90DaysLate=Dayslate_90;
Rename NumberRealEstateLoansOrLines=Realestate_loan;
Rename NumberOfTime60_89DaysPastDueNotW=DuenW6089;
Rename NumberOfDependents=Dependents;
run;

proc contents data=Graded.credit;
run;

data Graded.credit_new;
set Graded.Credit_new;
Income_new=input(Income,15.);
Dependents_new=input(Dependents,15.);
run;

proc freq data=Graded.Credit_new;
tables NPA_Status RevUtiUnsec age gender region House_ownership occupation education DuenW3059 Creditline_loan Dayslate_90 Realestate_loan DuenW6089 Dependents_new;
run;

proc means data=Graded.Credit_new
n NMISS min max mean;
Variables RevUtiUnsec Age Income_new DuenW3059 DebtRatio Creditline_loan Dayslate_90 Realestate_loan DuenW6089 Dependents_new;
run;

Data Graded.Credit_final;
Set Graded.credit_new;
if Income_new ge 0 and age>0;
run;

proc means data=Graded.Credit_final
n NMISS min max mean;
variables RevUtiUnsec Age Income_new DuenW3059 DebtRatio Creditline_loan Dayslate_90 Realestate_loan DuenW6089 Dependents_new;
run;

Proc freq data=Graded.Credit_final;
tables NPA_Status age gender region House_ownership occupation education DuenW3059 Creditline_loan Dayslate_90 Realestate_loan DuenW6089 Dependents_new;
run;

proc univariate data=Graded.Credit_final;
var Income_new;
run;

proc means data=Graded.Credit_final;
class NPA_Status;
var RevUtiUnsec age Income_new DuenW3059 DebtRatio Creditline_loan Dayslate_90 Realestate_loan DuenW6089 Dependents_new;
run;

data Graded.Credit_final replace;
set Graded.credit_final;
if (0 <= RevUtiUnsec <0.2) then Ruti_1=1; else Ruti_1=0;
if (0.2 <= RevUtiUnsec <0.4) then Ruti_2=1; else Ruti_2=0;
if (0.4 <= RevUtiUnsec <0.6) then Ruti_3=1; else Ruti_3=0;
if (0.6 <= RevUtiUnsec <0.8) then Ruti_4=1; else Ruti_4=0;
if (0.8 <= RevUtiUnsec <1) then Ruti_5=1; else Ruti_5=0;
if (RevUtiUnsec >=1) then Ruti_6=1; else Ruti_6=0;
if Gender="Female" then Gender_F=1; else Gender_F=0;
if Region="Centr" then Region_C=1; else Region_C=0;
if Region="North" then Region_N=1; else Region_N=0;
if Region="South" then Region_S=1; else Region_S=0;
if Region="East" then Region_E=1; else Region_E=0;
if Region="West" then Region_W=1; else Region_W=0;
if House_Ownership="Ownhouse" then House_own=1; else House_own=0;
if Occupation="Self_Emp" then Occ1=1; else Occ1=0;
if Occupation="Non-offi" then Occ2=1; else Occ2=0;
if Occupation="Officer1" then Occ3=1; else Occ3=0;
if Occupation="Officer2" then Occ4=1; else Occ4=0;
if Occupation="Officer3" then Occ5=1; else Occ5=0;
if Education="Graduate" then Edu1=1; else Edu1=0;
if Education="Matric" then Edu2=1; else Edu2=0;
if Education="PhD" then Edu3=1; else Edu3=0;
if Education="Post-Grad" then Edu4=1; else Edu4=0;
if Education="Professional" then Edu5=1; else Edu5=0;
run;

data Graded.Train Graded.validate;
set Graded.credit_final;
if ranuni(100)<0.7 then output Graded.train;
else output Graded.validate;
run;

proc freq data=Graded.train;
table npa_status;
run;

proc logistic data=Graded.Train descending;
model NPA_Status=RevUtiUnsec age Gender_F Region_C Region_N Region_S Region_W Region_E Income_new 
House_own Occ1 Occ2 Occ3 Occ4 occ5 Edu1 Edu2 Edu3 Edu4 Edu5 DuenW3059 DebtRatio Creditline_loan 
Dayslate_90 Realestate_loan DuenW6089 Dependents_new / ctable lackfit;
run;

proc logistic data=Graded.Train descending;
model NPA_Status=age Gender_F Region_C Region_N Region_S Region_W Income_new 
House_own Occ2 Occ4 Edu2 Edu3 Edu4 DuenW3059 Dayslate_90 Realestate_loan DuenW6089 Dependents_new / ctable lackfit;
run;

proc logistic data=Graded.Train descending;
model NPA_Status=Ruti_1 Ruti_2 Ruti_3 Ruti_4 Ruti_5 
age Gender_F Region_C Region_N Region_S Region_W
Income_new House_own Occ2 Occ4 Edu1 Edu2 Edu3 Edu4 DuenW3059 Dayslate_90 
Realestate_loan DuenW6089 Dependents_new;
run;

proc logistic data=Graded.Train descending;
model NPA_Status=Ruti_1 Ruti_2 Ruti_3 Ruti_4 Ruti_5 
age Gender_F Region_C Region_N Region_S Region_W
Income_new House_own Occ2 Occ4 Edu2 Edu3 Edu4 DuenW3059 Dayslate_90 debtratio 
Realestate_loan DuenW6089 Dependents_new;
run;

proc logistic data=Graded.Train;
model  NPA_Status=Ruti_1 Ruti_2 Ruti_3 Ruti_4 Ruti_5  
age Gender_F Region_C Region_N Region_S Region_W
Income_new House_own Occ2 Occ4 Edu2 Edu3 Edu4 DuenW3059 Dayslate_90 
Realestate_loan DuenW6089 Dependents_new / selection=forward ctable lackfit;
run;

proc logistic data=Graded.Train;
model  NPA_Status=Ruti_1 Ruti_2 Ruti_3 Ruti_4 Ruti_5
age Gender_F Region_C Region_N Region_S Region_W
Income_new House_own Occ2 Occ4 Edu2 Edu3 Edu4 DuenW3059 Dayslate_90 
Realestate_loan DuenW6089 Dependents_new / selection=backward ctable lackfit;
run;

proc logistic data=Graded.train descending outmodel = Graded.dmm;
model NPA_Status=Ruti_1 Ruti_2 Ruti_3 Ruti_4 Ruti_5 
age Gender_F Region_C Region_N Region_S Region_W
Income_new House_own Occ2 Occ4 Edu2 Edu3 Edu4 DuenW3059 Dayslate_90 
Realestate_loan DuenW6089 Dependents_new / ctable lackfit;
score out=Graded.dmp;
run;

Proc rank data=Graded.dmp out=Graded.Decile_new groups=10 ties=mean;
var p_1;
ranks decile;
run;

proc sort data=Graded.Decile_new;
by descending p_1;
run;

proc export
data=Graded.Decile_new
DBMS=xls
outfile="/home/harshithreddyv0/Logistic regression/dms.xls";
run;

proc logistic data=Graded.Validate descending outmodel=Graded.dmm;
model NPA_Status=Ruti_1 Ruti_2 Ruti_3 Ruti_4 Ruti_5 
age Gender_F Region_C Region_N Region_S Region_W
Income_new House_own Occ2 Occ4 Edu2 Edu3 Edu4 DuenW3059 Dayslate_90 
Realestate_loan DuenW6089 Dependents_new / ctable lackfit;
score out=Graded.dmp;
run;
Proc rank data=Graded.dmp out=Graded.Decile groups=10 ties=mean;
var p_1;
ranks decile;
run;
proc sort data=Graded.Decile;
by descending p_1;
run;
Proc export
data=Graded.Decile
DBMS=xls
outfile='/home/harshithreddyv0/Logistic regression/ValidDecile_new.Xlsx';
run;

