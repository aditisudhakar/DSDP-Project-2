use "C:\Users\medasud\Downloads\DSDP Project 2 Loneliness\covidpanel_us_stata_jan_17_2023.dta", clear

describe cr058
list cr058 in 1/10
tabulate cr058

//view and drop missing values in the loneliness variable (cr058)
misstable summarize cr058
drop if missing(cr058)
count