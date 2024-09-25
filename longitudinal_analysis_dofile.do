*======================================================================================
*
//This file deals with correlation analysis, mixed effects modelling and longitudinal modelling.
//Please refer to Python file first for exploratory analysis before reading through this file.
*
*======================================================================================



use "C:\Users\medasud\Downloads\DSDP Project 2 Loneliness\covidpanel_us_stata_jan_17_2023.dta", clear

describe cr058
list cr058 in 1/10
tabulate cr058

//view and drop missing values in the loneliness variable (cr058)
misstable summarize cr058
drop if missing(cr058)
count
*
*
*
					*Chi-Square Test and Cramer's V
					*==============================

//all the variables are categorical. To check the correlation, we cannot use Pearson's
//correlation for this as the data is not numeric data. instead, we use chi square tests
//to test the presence of association and then test the strength of the association with
//Cramer's V


//define a list of variables to test against cr058
local varlist hhincome maritalstatus education retired race disabled gender hhmembernumber coping_socmedia coping_drinking coping_cigarette coping_drugs working cr056a cr056b cr056c cr056d cr056e cr056f cr056g cr056h cr056i cr054s1 cr054s2 cr054s3 cr054s4 cr054s5 cr054s6 cr054s7 cr054s8 cr054s9 cr054s10 ei002 ei005c ei008 ei014 healthinsurance lr026 lr026a lr031 cr068s6

//define number of variables
local numvars : word count `varlist'
//create a matrix to store results 
matrix results = J(`numvars', 3, .)
local i = 1

//loop through each variable in the list and perform the Chi square test, and calculate Cramer's V
foreach var of local varlist {
    di "Calculating Cramer's V between cr058 and `var'"
    quietly tabulate cr058 `var', chi2 expected
    
    //calculate Cramér's V
    local chi2 = r(chi2)  //get chi2 value
    local pvalue = r(p)  //extract p-value
    local N = r(N)
    local min_dim = min(r(r), r(c)) - 1
    local cramer_v = sqrt(`chi2' / (`N' * `min_dim'))
    
    //store the results
    matrix results[`i', 1] = `chi2'
    matrix results[`i', 2] = `pvalue'
    matrix results[`i', 3] = `cramer_v'
    
    local i = `i' + 1
}

//add row and column names to the matrix
matrix rownames results = hhincome maritalstatus education retired race disabled gender hhmembernumber coping_socmedia coping_drinking coping_cigarette coping_drugs working cr056a cr056b cr056c cr056d cr056e cr056f cr056g cr056h cr056i cr054s1 cr054s2 cr054s3 cr054s4 cr054s5 cr054s6 cr054s7 cr054s8 cr054s9 cr054s10 ei002 ei005c ei008 ei014 healthinsurance lr026 lr026a lr031 cr068s6
matrix colnames results = chi2 p_value cramer_v
//display
matrix list results


//Most of the variables show statistically significant results (p value = 0 or close to
//0), meaning that there is evidence of some relationship between cr058 and most of the
//variables, but the strength of the association varies.

//The variable cr054s9 (presence of a mental health condition) has the strongest
//association with loneliness (cr058) (Cramer's V = 0.2339). In large datasets, a cramer
//v of 0.25 suggest strong correlation. The high chi square value also indicates a
//highly significant relationship.

//Similarly, lr026a (married or with partner) (Cramer V = 0.2243) is another variable
//with a very strong association. Similarly for cr056e (depression) (Cramer's V =
//0.2107). 'maritalstatus' has a significant relationship (Chi2 = 8667.1682) and a
//moderate association (Cramer's V = 0.1351). ei002 (food insecurity) has a moderately
//strong association  with cr058.

//There are some variables like lr026 (interaction with another person within 6 feet
//distance)(Cramer's V = 0.0319) where the association is weak but still statistically
//significant (p < 0.05). ei008 (owe money on student loans)(Cramer's V = 0.0795) and
//'working' (Cramer V = 0.0680) both show moderate relationships with cr058.

//gender and hhincome also show some moderate associations, indicating that these
//variables have a meaningful but not very strong relationship with cr058.

//Overall, most of the associations between loneliness and the other variables are weak.
//We might be able to observe better associations by using regression modelling.
//However, as the data is panel data with multiple entries per respondent, we will
//perform longitudinal analysis.

*
*
*
				*Longitudinal Analysis with Mixed Effects Modelling
				*==================================================

//set up panel. Unique identifier for each participant is uasid and the wave number is
//the time variable here
//encode uasid to a numeric identifier as it is currently string
encode uasid, generate(uasid_num)
xtset uasid_num wave

//summary of cr058 by wave
tabstat cr058, by(wave) stats(mean sd min max n)

//check for duplicates
duplicates report uasid_num wave
//no duplicates found


//train a fixed-effects model on some of the variables

xtreg cr058 cr054s9 lr026a cr056e, fe

//The Rsquared value of this model is quite low (0.0578) which means taht the model
//explains only 5.8% of the total variance in loneliness across individuals in different
//waves of the survey. The within individual R2 is 0.0008, indicating that the model
//explains only a very small fraction of the variation in cr058 (loneliness) within
//individuals over time. The between individual R2 is 0.0848, suggesting that there is a
//stronger relationship between individuals (differences in their average levels of loneliness).

//For cr054s9 (existing mental health condition), although the coefficient (-0.6)
//indicates that having a mental health condition is associated with a decrease in
//loneliness (cr058), the p-value of 0.228 shows that this result is not statistically significant. 

//Being married or having a partner(lr026a) is associated with a 0.112 increase in
//loneliness (cr058), which is statistically significant (p < 0.001). This might seem
//counterintuitive, but it could suggest that people who are in relationships experience
//loneliness as well, possibly due to relationship dynamics or other factors.

//There is a positive association between cr056e (depression) and loneliness, suggesting
//that those experiencing depression tend to report higher loneliness scores. The
//p-value of 0.084 indicates this result is not significant.

//A rho value of 0.824 indicates that 82.4% of the total variance is due to differences
//between individuals rather than fluctuations within individuals over time. This
//suggests that individual specific traits (unobserved) explain much of the variation in
//loneliness. The overall explanatory power of the model is quite low, which suggests
//that loneliness is influenced by other factors not captured in this model and we would
//need to add more variables to the model.


xtreg cr058 cr054s9 lr026a cr056e gender hhincome disabled, fe

//the explained variance of this model is still low. Significant factors affecting
//loneliness in this model include being married or partnered, gender, and household
//income. cr054s9, depression (cr056e), and disability status did not show statistically
//significant relationships with loneliness. Gender and income seem to have negative
//associations with loneliness (males and those with higher incomes report lower
//loneliness), while being in a relationship surprisingly appears to increase loneliness
//slightly, which contradicts the initial correlation analysis.


xtreg cr058 cr054s9 lr026a cr056e gender hhincome ei002 ei008 ei014 lr026, fe

//The Rsquared value of this model is quite low (0.016) indicating that it is unable to
//explain most of the variancce in the model. The variables cr054s9 and cr056e were
//omitted due to collinearity, suggesting that other included variables may overlap in
//what they explain, which could limit the model's interpretability regarding mental
//health conditions and depression. Variables like gender, household income, food
//insecurity(ei002), owing student loans (ei008) and renting status(ei014) are
//significant in this model. Higher food insecurity is associated with increased
//loneliness, with a decrease of 0.052 in loneliness for each unit increase in food
//insecurity. The model also indicates that higher income is associated with lower loneliness. 



xtreg cr058 lr026a cr056e gender hhincome ei002 ei008 ei014 cr056g cr056c cr056a maritalstatus, fe
//cr056a (anxiety disorder) and maritalstatus are not significant in this model.


xtreg cr058 lr026a cr056e gender hhincome ei002 ei008 ei014, fe
est store fe //store the estimates

//all of these fixed effects models have a very low R2 value. Unlike
//FE models, random effects models account for both within ndividual and between
//individual variations. Since loneliness is influenced by various personal
//characteristics, these between person differences might be important.

xtreg cr058 lr026a cr056e gender hhincome ei002 ei008 ei014, re
est store re

//the R squared value for the RE model is 0.1097. The model explains about 11% of the
//total variance in loneliness), which is better than the fixed effects models. Although
//the r2 value is better in the RE model, this doesn't automatically mean that the RE
//model is more appropriate.

//to choose between the RE and FE model, we perform the Hausman test

*
*
*
							*Hausman-Wu Test
							*===============


hausman fe re, sigmamore


//Null Hypothesis (H0): The difference in coefficients between the FE and RE models is
//not systematic (RE is appropriate)
//Ha: The difference in coefficients is systematic (FE is more appropriate)
//Since the p-value is 0, we reject the null hypothesis. This indicates that the FE
//model is more appropriate than the RE model (RE)

//The Hausman test is used in panel data analysis to decide between fixed effects and
//random effects models. It tests whether the unique errors (the unobserved individual
//effects) are correlated with the regressors. The FE model assumes that individual
//specific effects are correlated with the independent variables. The RE model assumes
//that individual specific effects are uncorrelated with the independent variables. The
//Hausman test checks if the preferred model is the RE model. The null hypothesis is
//that the preferred model is RE, and the alternative hypothesis is that the preferred
//model is FE.

//Coefficients (b) are from the FE model
//Coefficients (B) are from the RE Model (RE)

//The (b-B) column shows the difference between the FE and RE coefficient estimates.
//Significant differences between the two indicate that the RE estimator may be biased
//due to correlation between individual specific effects and the regressors. For example, for gender, the difference between FE and RE estimates is quite large (-0.507),
//suggesting that RE and FE provide very different results for this variable.

//The RE model assumes that the individual specific effects (ui) are not correlated with
//the independent variables. The ui are intrinsic factors like personality traits,
//long-term health conditions, biological gender etc that don't change over time but
//differ between individuals. If this assumption is violated, the RE model produces
//biased estimates, even if its R squared is higher. The Hausman test tests whether the
//individual specific effects (ui) are correlated with the independent variables.

//Here, the test result showed a significant difference between the FE and RE models
//(p-value = 0), indicating that the RE model is likely violating its assumption of no
//correlation between the (ui) and the regressors. The higher r2 is not valid due to the
//biased results. Further, r2 measures how well the model explains the variance in the
//dependent variable. A high R square can still be produced by a model that provides
//biased estimates if the assumptions of the model are not met.

//FE models control unobserved individual specific effects and assume that these
//unobserved factors are correlated with the independent variables, which seems to be
//the case here and as indicated by the Hausman test. The FE sacrifices the r2 and
//overall fit to produce unbiased and consistent estimates when the assumption of no
//correlation is violated.


*
*
*
							*Lagged Variables
							*================


//The FE model focuses on within individual variation and strips away the between
//individual variation, which often explains much more of the variation in the dependent
//variable (loneliness). The FE model is only explaining changes within each respondent
//over time and not differences between individuals.

//To fix this, we can try lagged variables. Sometimes, effects of variables like income,
//health conditions, or mental health don't appear immediately but have a delayed impact.

xtset uasid_num wave
xtreg cr058 L.lr026a L.cr056e L.hhincome L.ei002 L.ei008 L.ei014, fe

//creating lagged variables on the independent variables does not significantly improve
//the performance of the model. However, introducing the lagged variable for cr058
//(loneliness) as an independent variable improves the R2 significant.


xtreg cr058 L.cr058 lr026a cr056e hhincome ei002 ei008 ei014, fe

//R2 measures the proportion of variance in the dependent variable (cr058) that is
//explained by the independent variables in the model. When we include L.cr058, we're
//allowing the model to directly explain a large portion of the variation in current
//cr058 based on its past values. This significantly boosts the explanatory power of the
//model due to autocorrelation (the current value is highly predictable from past values).
//This is common in panel data. The variable is also persistent. It's likely that
//someone's mental helath is strongly related to their past condition. 

//Without L.cr058, the model has to rely solely on the other independent variables
//(income, marital status, food insecurity etc) to explain the variation in cr058. These
//variables seem to have limited explanatory power and they cannot account for the
//persistence or autocorrelation in the outcome as well as L.cr058 does.


xtreg cr058 L.cr058 L2.cr058 L.lr026a L2.lr026a L.cr056e L.hhincome L2.hhincome L.ei002 L2.ei002 L.ei008 L2.ei008 L.ei014 L2.ei014, fe







Dynamic panel models (like the Arellano-Bond estimator) could be useful if you're concerned about the endogeneity of lagged dependent variables.

