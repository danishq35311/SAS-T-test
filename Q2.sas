/*
Question 2
*/

proc reg  data = work.main_with_indicators;
model col47 = col6 col8-col10 col12-col19 col23-col27 col30 col32-col34 col36-col37 col40-col41 col43-col46;
title 'Global Sales ~ Reviews';
run;

proc reg data = work.main_with_indicators;
model  col47 = col6 col8-col10 col12-col19 col23-col27 col30 col32-col34 col36-col37 col40-col41 col43-col46 / vif collinoint;
output out = work.regdata2 cookd = cookd student = sresiduals;
run;

/*Checking the number of observations outside the Cook's D threshold*/
proc print data = work.regdata2;
var _ALL_;
where cookd > 4/4413;
run;

proc contents data=work.regdata2;
run;

/*Running the model without influential points*/
proc reg data = work.regdata2;
model col47 = col6 col8-col10 col12-col19 col23-col27 col30 col32-col34 col36-col37 col40-col41 col43-col46;
where cookd < 4/4413;
run;

/*Robust regression*/
proc robustreg data = work.main_with_indicators fwls;
model col47 = col6 col8-col10 col12-col19 col23-col27 col30 col32-col34 col36-col37 col40-col41 col43-col46;
output out = robregmm2 weight = wgt outlier = ol;
run;

/*White test for heteroskedasticity*/
proc reg data = work.main_with_indicators;
model col47 = col6 col8-col10 col12-col19 col23-col27 col30 col32-col34 col36-col37 col40-col41 col43-col46/ hcc spec;
run;

/*Normality of error term*/
proc univariate data = work.regdata2 normal;
var sresiduals;
histogram sresiduals / normal kernel;
run;



