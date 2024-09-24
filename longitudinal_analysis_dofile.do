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

//check association between cr058 (loneliness) and hhincome
tabulate cr058 hhincome, chi2
//cr058 and marital status
tabulate cr058 maritalstatus, chi2
//cr058 and education level
tabulate cr058 education, chi2
//cr058 and retirement status
tabulate cr058 retired, chi2
//cr058 and race
tabulate cr058 race, chi2
//cr058 and disabled (y/n)
tabulate cr058 disabled, chi2
//cr058 and gender
tabulate cr058 gender, chi2
//cr058 and hhmembernumber
tabulate cr058 hhmembernumber, chi2
//cr058 and coping_socmedia
tabulate cr058 coping_socmedia, chi2
//cr058 and coping_drinking
tabulate cr058 coping_drinking, chi2
//cr058 and coping_cigarettes
tabulate cr058 coping_cigarette, chi2
//cr058 and coping_drugs
tabulate cr058 coping_drugs, chi2
//cr058 and working
tabulate cr058 working, chi2
//cr058 and cr056a (Anxiety disorder)
tabulate cr058 cr056a, chi2
//cr058 and cr056b (ADHD)
tabulate cr058 cr056b, chi2
//cr058 and cr056c (Bipolar disorder)
tabulate cr058 cr056c, chi2
//cr058 and cr056d (Eating disorder)
tabulate cr058 cr056d, chi2
//cr058 and cr056e (Depression)
tabulate cr058 cr056e, chi2
//cr058 and cr056f (OCD)
tabulate cr058 cr056f, chi2
//cr058 and cr056g (PTSD)
tabulate cr058 cr056g, chi2
//cr058 and cr056h (Schizophrenia)
tabulate cr058 cr056h, chi2
//cr058 and cr056i (Other mental issue)
tabulate cr058 cr056i, chi2
//cr058 and cr054s1 (Diabetes)
tabulate cr058 cr054s1, chi2
//cr058 and cr054s2 (Cancer)
tabulate cr058 cr054s2, chi2
//cr058 and cr054s3 (Heart disease)
tabulate cr058 cr054s3, chi2
//cr058 and cr054s4 (High blood pressure)
tabulate cr058 cr054s4, chi2
//cr058 and cr054s5 (Asthma)
tabulate cr058 cr054s5, chi2
//cr058 and cr054s6 (Chronic lung disease)
tabulate cr058 cr054s6, chi2
//cr058 and cr054s7 (Kidney disease)
tabulate cr058 cr054s7, chi2
//cr058 and cr054s8 (Autoimmune disorder)
tabulate cr058 cr054s8, chi2
//cr058 and cr054s9 (A mental health condition)
tabulate cr058 cr054s9, chi2
//cr058 and cr054s10 (Obesity)
tabulate cr058 cr054s10, chi2
//cr058 and ei002 (worried you would run out of food)
tabulate cr058 ei002, chi2
//cr058 and ei005c (has social security)
tabulate cr058 ei005c, chi2
//cr058 and ei008 (has student loans)
tabulate cr058 ei008, chi2
//cr058 and ei014 (is renting)
tabulate cr058 ei014, chi2
//cr058 and healthinsurance
tabulate cr058 healthinsurance, chi2
//cr058 and lr026 (interaction with another person)
tabulate cr058 lr026, chi2
//cr058 and lr026a (married or with partner)
tabulate cr058 lr026a, chi2
//cr058 and lr031 (applied for unemployment benefit)
tabulate cr058 lr031, chi2
//cr058 and cr068s6 (religious or not)
tabulate cr058 cr068s6, chi2

//all of these variables show association with cr058. Now, let us do Cramer's V to test //the strength of the association

