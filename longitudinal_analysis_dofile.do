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









