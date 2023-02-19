/*
Question 1
*/
data game;
set '/home/u60735213/sasuser.v94/HW3/videogamesales_main.sas7bdat';
log_global_sales = log(global_sales);
log_critic_count = log(critic_count);
log_user_count = log(user_count);
log_critic_score = log(critic_score);
log_user_score = log(user_score);
proc print contents=game;

/*Getting the baseline model, along with vif, cookd & studentized residuals*/
proc reg  data = game;
model global_sales = critic_score critic_count user_score user_count / vif collinoint;
title 'Global Sales ~ Reviews';
run;

proc glmmod data = game outdesign = work.main_with_indicators noprint;
class genre rating year_of_release platform;
model global_sales = critic_score critic_count user_score user_count genre rating year_of_release platform log_critic_count log_user_count log_critic_score log_user_score log_global_sales / noint;
run;

proc contents data=work.main_with_indicators;
run;

proc reg data = work.main_with_indicators;
model global_sales = col1-col42 / vif collinoint;
output out = work.regdata cookd = cookd student = sresiduals;
run;
/*better than model with only critic_score, critic_count, user_score & user_count*/

/*Checking the observations that could be influential*/
proc print data = work.regdata;
var _ALL_;
where cookd > 4/4413;
run;
/*Around 74 observations that are greater than the threshold*/

proc reg data = work.regdata;
model global_sales = col1-col42;
where cookd < 4/4413;
run;
/*R-squared has increased to 37%, but the residuals are still not normally distributed. 
Logging the response variable to see if there's an improvement.*/

proc reg data = work.main_with_indicators;
model global_sales = col1-col42; /*linear-linear model*/
model col47 = col1-col42; /*log-linear model*/
model col47 = col5-col46; /*log-log model*/
run;

/*Performing robust regression*/
proc robustreg data = work.main_with_indicators fwls method = mm;
model global_sales = col1-col42;
output out = work.robregmm weight = wgt outlier = ol;
run;
/*Some of the variables have become significant, and vice versa which means there's heteroskedasticity present*/

/*Using forward selection to drop insignificant variables based on p_values - taking significance level to be 15%*/
proc glmselect data = game plots = all;
class genre(split) rating(split) year_of_release(split) platform(split);
model log_global_sales = log_critic_score log_critic_count log_user_score log_user_count genre rating year_of_release platform
/selection=forward(select=sl sle=0.15) stats=all showpvalues;




