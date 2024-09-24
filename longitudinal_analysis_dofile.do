use "C:\Users\medasud\Downloads\DSDP Project 2 Loneliness\covidpanel_us_stata_jan_17_2023.dta", clear

describe cr058
list cr058 in 1/10
tabulate cr058

//view and drop missing values in the loneliness variable (cr058)
misstable summarize cr058
drop if missing(cr058)
count


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


//Most of the variables show statistically significant results (p value = 0 or close to 0), meaning that there is evidence of some relationship between cr058 and most of the variables, but the strength of the association varies.

//The variable cr054s9 (presence of a mental health condition) has the strongest association with loneliness (cr058) (Cramer's V = 0.2339). In large datasets, a cramer v of 0.25 suggest strong correlation. The high chi square value also indicates a highly significant relationship.

//Similarly, lr026a (married or with partner) (Cramer V = 0.2243) is another variable with a very strong association. Similarly for cr056e (depression) (Cramer's V = 0.2107). 'maritalstatus' has a significant relationship (Chi2 = 8667.1682) and a moderate association (Cramer's V = 0.1351). ei002 (food insecurity) has a moderately strong association  with cr058.

//There are some variables like lr026 (interaction with another person within 6 feet distance)(Cramer's V = 0.0319) where the association is weak but still statistically significant (p < 0.05). ei008 (owe money on student loans)(Cramer's V = 0.0795) and 'working' (Cramer V = 0.0680) both show moderate relationships with cr058.

//gender and hhincome also show some moderate associations, indicating that these variables have a meaningful but not very strong relationship with cr058.

//Overall, most of the associations between loneliness and the other variables are weak. We might be able to observe better associations by using regression modelling. However, as the data is panel data with multiple entries per respondent, we will perform longitudinal analysis.



//set up panel. Unique identifier for each participant is uasid and the wave number is the time variable here
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

//The Rsquared value of this model is quite low (0.0578) which means taht the model explains only 5.8% of the total variance in loneliness across individuals in different waves of the survey. The within individual R2 is 0.0008, indicating that the model explains only a very small fraction of the variation in cr058 (loneliness) within individuals over time. The between individual R2 is 0.0848, suggesting that there is a stronger relationship between individuals (differences in their average levels of loneliness).

//For cr054s9 (existing mental health condition), although the coefficient (-0.6) indicates that having a mental health condition is associated with a decrease in loneliness (cr058), the p-value of 0.228 shows that this result is not statistically significant. 

//Being married or having a partner(lr026a) is associated with a 0.112 increase in loneliness (cr058), which is statistically significant (p < 0.001). This might seem counterintuitive, but it could suggest that people who are in relationships experience loneliness as well, possibly due to relationship dynamics or other factors.

//There is a positive association between cr056e (depression) and loneliness, suggesting that those experiencing depression tend to report higher loneliness scores. The p-value of 0.084 indicates this result is not significant.

//A rho value of 0.824 indicates that 82.4% of the total variance is due to differences between individuals rather than fluctuations within individuals over time. This suggests that individual specific traits (unobserved) explain much of the variation in loneliness. The overall explanatory power of the model is quite low, which suggests that loneliness is influenced by other factors not captured in this model and we would need to add more variables to the model.


xtreg cr058 cr054s9 lr026a cr056e gender hhincome disabled, fe

//the explained variance of this model is still low. Significant factors affecting loneliness in this model include being married or partnered, gender, and household income. cr054s9, depression (cr056e), and disability status did not show statistically significant relationships with loneliness. Gender and income seem to have negative associations with loneliness (males and those with higher incomes report lower loneliness), while being in a relationship surprisingly appears to increase loneliness slightly, which contradicts the initial correlation analysis.


xtreg cr058 cr054s9 lr026a cr056e gender hhincome ei002 ei008 ei014 lr026, fe

//The Rsquared value of this model is quite low (0.016) indicating that it is unable to explain most of the variancce in the model. The variables cr054s9 and cr056e were omitted due to collinearity, suggesting that other included variables may overlap in what they explain, which could limit the model's interpretability regarding mental health conditions and depression. Variables like gender, household income, food insecurity(ei002), owing student loans (ei008) and renting status(ei014) are significant in this model. Higher food insecurity is associated with increased loneliness, with a decrease of 0.052 in loneliness for each unit increase in food insecurity. The model also indicates that higher income is associated with lower loneliness. 



xtreg cr058 lr026a cr056e gender hhincome ei002 ei008 ei014 cr056g cr056c cr056a maritalstatus, fe
//cr056a (anxiety disorder) and maritalstatus are not significant in this model.


xtreg cr058 lr026a cr054s9 gender hhincome ei002 ei008 ei014, fe




xtreg cr058 cr054s9 lr026a cr056e gender hhincome disabled ei002 working ei008 ei014 lr026, fe

