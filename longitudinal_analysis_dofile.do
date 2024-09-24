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




















//set up panel
xtset uasid wave







