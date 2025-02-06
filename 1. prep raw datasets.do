* ************************************************************
* 0. Prep raw datasets

* Author: Sungmee Kim
* Created: May 14, 2024
* Last Updated: September 10, 2024
* ************************************************************

* Notes

* 20240612
* proportion of remote learning by public & charter
* later, when county-level Child File is available, run regs with 3 analysis samples:
	* 1. public + charter (full sample)
	* 2. public only
	* 3. charter only (probably won't need this)

* ************************************************************
* Set Working Folder           
* ************************************************************

global dir "/Users/sk889/Library/CloudStorage/Dropbox/*2024 Return to School and Allegations"

global data "${dir}Data/"
global datap "${data}Processed/"
global output "${dir}Output/"

* ************************************************************
* Set Log File                                  
* ************************************************************

//log using "${output}log/0. prep raw datasets.log", replace

* ************************************************************
* Clean + Merge Data
	* 0. COVID cases+deaths
	* 1. countyfips state county zip
	* 2. learning modality, 2020-21 & 2021-22
	* 3. child maltreatment - number of allegations, fatalities by state
	* 4.1. Census 0to19 population + linear time trend
	* 4.2. Census 0to19 population (by race)
	* 5. BLS unemp
* ************************************************************

* 0. COVID cases+deaths

// county-month
import delimited "${data}Original/Weekly_United_States_COVID-19_Cases_and_Deaths_by_County_-_ARCHIVED_20240906.csv", numericcols(1 4 6 7 8 9) clear

split date, p("/")
destring date*, replace
rename (date1 date2 date3) (month day year)
rename (fips_code state_fips) (countyfips statefips)

order month day year statefips countyfips state county newcases newdeaths
drop date cumulative*

drop if year==2023
drop if year==2022 & inrange(month, 10, 12)
drop if year==2020 & inrange(month, 1, 2)

collapse (sum) newcases newdeaths, by(month year statefips countyfips state county)

save "${datap}covid cases and deaths_county_monthly_2020_2022", replace

// state-year
import delimited "${data}Original/Weekly_United_States_COVID-19_Cases_and_Deaths_by_County_-_ARCHIVED_20240906.csv", numericcols(1 4 6 7 8 9) clear

split date, p("/")
destring date*, replace
rename (date1 date2 date3) (month day year)
rename (fips_code state_fips) (countyfips statefips)

order month day year statefips countyfips state county newcases newdeaths
drop date cumulative*

collapse (sum) newcases newdeaths, by(month year statefips countyfips state county)

drop if year==2023
drop if year==2022&inrange(month, 10, 12)

rename year calendaryear
gen year = calendaryear if inrange(month, 1, 9)
replace year = calendaryear + 1 if inrange(month, 10, 12)

collapse (sum) newcases newdeaths, by(year statefips state)

save "${datap}covid cases and deaths_state_yearly_2020_2022", replace

* ************************************************************

* 1. countyfips state county zip
import excel "${data}Original/ZIP_COUNTY_032024.xlsx", ///
	sheet("Export Worksheet") firstrow case(lower) clear
	
rename zip zip_code
gen city = lower(usps_zip_pref_city)	
drop usps_zip_pref_city
rename usps_zip_pref_state state
destring zip_code county, replace

// there are zipcodes that covers portions of multiple different counties.
bys zip_code: egen count = count(county)
tab count

/*
      count |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |     28,180       51.72       51.72
          2 |     16,480       30.25       81.96
          3 |      7,560       13.87       95.84
          4 |      1,980        3.63       99.47
          5 |        215        0.39       99.87
          6 |         66        0.12       99.99
          7 |          7        0.01      100.00
------------+-----------------------------------
      Total |     54,488      100.00
*/

drop count

** keep those with the highest residence ratio**
bys zip_code: egen double max = max(res_ratio)
keep if res_ratio == max

bys zip_code: egen count = count(county)
tab count
list if count>1	// still multiple counties-- do the same for tot
drop max count

bys zip_code: egen double max = max(tot_ratio)
keep if tot_ratio == max

bys zip_code: egen count = count(county)
tab count
list if count>1	// still multiple counties, but only 2-- check the modality data if it'd matter if I drop these two

frame create modality
frame modality: import delimited "${data}Original/School_Learning_Modalities__2020-2021_20240514.csv", clear
frame modality: list if zip_code==51603		// no obs
// frlink m:1 zip_code
// fralias add hhincome, from(frame)
//							use it from state stats dataset without merging!

drop if count==2
drop max count

save "${datap}countyzip crosswalk.dta", replace

* ************************************************************

* 2. learning modality, 2020-21 & 2021-22

*------------------------------------------------------*
* 2020-21
*------------------------------------------------------*

import delimited "${data}Original/School_Learning_Modalities__2020-2021_20240514.csv", stringcols(1) clear 
replace city = lower(city)

/*
* explore modality data
1. no PR
2. BI: check back

tab zip_code if state=="BI"

   zip_code |      Freq.     Percent        Cum.
------------+-----------------------------------
       4468 |          9        1.73        1.73
      39051 |         12        2.30        4.03
      39350 |          8        1.54        5.57
      54150 |         39        7.49       13.05
      54155 |          5        0.96       14.01
      56626 |         11        2.11       16.12
      57361 |         10        1.92       18.04
      57548 |          7        1.34       19.39
      57639 |          9        1.73       21.11
      57748 |         14        2.69       23.80
      57764 |         10        1.92       25.72
      58075 |          9        1.73       27.45
      58504 |          7        1.34       28.79
      73005 |          9        1.73       30.52
      85121 |         17        3.26       33.78
      85339 |         17        3.26       37.04
      85926 |         14        2.69       39.73
      86035 |          8        1.54       41.27
      86039 |         16        3.07       44.34
      86044 |         11        2.11       46.45
      86045 |          9        1.73       48.18
      86054 |         13        2.50       50.67
      86538 |         13        2.50       53.17
      86544 |         36        6.91       60.08
      87001 |         39        7.49       67.56
      87313 |          7        1.34       68.91
      87420 |         15        2.88       71.79
      87455 |         17        3.26       75.05
      87506 |         39        7.49       82.53
      87566 |         16        3.07       85.60
      87571 |          1        0.19       85.80
      92581 |         31        5.95       91.75
      98226 |         32        6.14       97.89
      98350 |         11        2.11      100.00
------------+-----------------------------------
      Total |        521      100.00
	  

*/
	  
merge m:1 zip_code using "${datap}countyzip crosswalk.dta"

sort state county week
order district_nces_id state county zip_code week learning_modality operational_schools student_count

rename county countyfips

*----------------------------------*

* extract month & year from week variable
split week, p("")
gen date = date(week1, "MDY")
format %td date

gen month = month(date)
gen year = year(date)
gen day = day(date)

drop week2 week3

sort state countyfips district_nces_id year month day

*----------------------------------*

* import nces school directory to identify non-public school districts (charter, other alternatives)
* and merge

frame create nces
frame nces: import delimited "${data}Original/CCD NCES/ccd_lea_029_2021_w_1a_080621.csv", stringcols(9) clear 
frame nces: keep leaid sy_status_text updated_status_text effective_date lea_type lea_type_text
frame nces: rename leaid district_nces_id
frame nces: save "${datap}ccd 2021.dta", replace
frame drop nces

merge m:1 district_nces_id using "${datap}ccd 2021.dta"
keep if _merge==3
drop _merge

gen charter = lea_type==7
tab charter // about 4 percent of the sample
drop if lea_type==7
drop sy_status_text updated_status_text effective_date lea_type lea_type_text

*----------------------------------*

* gen learning mode dummies

tab learning_modality, m
gen prop_remote = 1 if learning_modality == "Remote"
replace prop_remote = 0.5 if learning_modality == "Hybrid"
replace prop_remote = 0 if learning_modality == "In Person"

*----------------------------------*
* collapse by countyfips
// note:
// student count: per district, not zipcode!
// multiple school districts under one zipcode
/// collapse, get mean of student_count by district and then sum student_count by countyfips

* 1. MONTH

// county

preserve

collapse (mean) prop_remote [w=student_count], by(state countyfips year month)

drop if missing(countyfips)

order state countyfips year month

save "${datap}modality2020_2021_county_month.dta", replace

restore

// state (for fatality analysis)

preserve

collapse (mean) prop_remote [w=student_count], by(state year month)

drop if missing(state)

order state year month

rename state stateabbr

save "${datap}modality2020_2021_state_month.dta", replace

restore

*------------------*

* 2. YEAR

// county

preserve

collapse (mean) prop_remote [w=student_count], by(state countyfips)

drop if missing(countyfips)

gen year = 2021

order countyfips year

save "${datap}modality2020_2021_county_year.dta", replace

restore

// state (for fatality analysis)

preserve

collapse (mean) prop_remote [w=student_count], by(state)

drop if missing(state)

gen year = 2021

order state year

rename state stateabbr

save "${datap}modality2020_2021_state_year.dta", replace

restore

*----------------------------------*

// create the modality histogram

use "${datap}modality2020_2021_county_month.dta", clear

gen semester = 1 if year==2020 & inrange(month, 9, 12)
replace semester = 2 if year==2021 & inrange(month, 1, 5)

drop if missing(semester)

preserve

collapse (mean) prop_remote, by(countyfips month semester)

twoway (hist prop_remote if semester==1, width(.05) color(red%40) fraction)	///
		(hist prop_remote if semester==2, width(.05) color(blue%40) fraction),	///
		xtitle(% Remote (SY 2020-21))					  ///
		xline(0.32, lpattern(dash))	///
		legend(order(1 "Fall 2020" 2 "Spring 2021")) legend(pos(6) col(2))
		
graph save "Graph" "${output}graph/SY21 remote_all_v2.gph", replace
graph export "${output}graph/SY21 remote_all_v2.pdf", as(pdf) name("Graph") replace

*------------------------------------------------------*
* 2021-22
*------------------------------------------------------*

import delimited "${data}Original/School_Learning_Modalities__2021-2022.csv", stringcols(1) clear 
replace city = lower(city)
rename (districtncesid districtname week learningmodality operationalschools studentcount city state zipcode)	///
		(district_nces_id district_name week learning_modality operational_schools student_count city state zip_code)
		
/*
* explore modality data
1. PR
2. BI: check back

tab zip_code if state=="BI"

   ZIP Code |      Freq.     Percent        Cum.
------------+-----------------------------------
       4468 |         74        2.60        2.60
       4668 |         74        2.60        5.20
      28719 |         95        3.34        8.53
      49783 |         52        1.83       10.36
      49896 |         74        2.60       12.96
      54150 |         37        1.30       14.26
      56626 |         74        2.60       16.85
      57028 |         72        2.53       19.38
      57262 |         53        1.86       21.24
      57273 |         74        2.60       23.84
      57361 |         74        2.60       26.44
      57501 |         74        2.60       29.04
      57572 |         74        2.60       31.64
      57621 |         74        2.60       34.23
      57639 |         74        2.60       36.83
      57652 |         53        1.86       38.69
      57714 |         74        2.60       41.29
      57748 |         49        1.72       43.01
      57764 |         20        0.70       43.71
      57770 |         23        0.81       44.52
      58075 |         74        2.60       47.12
      58316 |         74        2.60       49.72
      58329 |         53        1.86       51.58
      58335 |         46        1.62       53.20
      58504 |         53        1.86       55.06
      58636 |         66        2.32       57.37
      70544 |         74        2.60       59.97
      85121 |         74        2.60       62.57
      85128 |         33        1.16       63.73
      85339 |         65        2.28       66.01
      85926 |         53        1.86       67.87
      86033 |         66        2.32       70.19
      86039 |         74        2.60       72.79
      86047 |         13        0.46       73.24
      86053 |         74        2.60       75.84
      86505 |          7        0.25       76.09
      86507 |         71        2.49       78.58
      87053 |         52        1.83       80.41
      87326 |         52        1.83       82.23
      87420 |         74        2.60       84.83
      87455 |         74        2.60       87.43
      87571 |         53        1.86       89.29
      89424 |         46        1.62       90.91
      92581 |         53        1.86       92.77
      98226 |        127        4.46       97.23
      98371 |         27        0.95       98.17
      98841 |         52        1.83      100.00
------------+-----------------------------------
      Total |      2,848      100.00

*/

merge m:1 zip_code using "${datap}countyzip crosswalk.dta"

rename county countyfips

*----------------------------------*

* extract month & year from week variable
split week, p("")
gen date = date(week1, "MDY")
format %td date

gen month = month(date)
gen year = year(date)
gen day = day(date)

drop week2 week3

sort state countyfips year month day

*----------------------------------*

* import nces school directory to identify non-public school districts (charter, other alternatives)
* and merge

frame create nces
frame nces: import delimited "${data}Original/CCD NCES/ccd_lea_029_2122_w_1a_071722.csv", stringcols(9) clear 
frame nces: keep leaid sy_status_text updated_status_text effective_date lea_type lea_type_text
frame nces: rename leaid district_nces_id
frame nces: save "${datap}ccd 2022.dta", replace
frame drop nces

merge m:1 district_nces_id using "${datap}ccd 2022.dta"
keep if _merge==3
drop _merge

gen charter = lea_type==7	// charter; about 15 percent of the sample
drop if lea_type==7
drop if lea_type==9			// specialized public school district; 0.04% sample
drop sy_status_text updated_status_text effective_date lea_type lea_type_text

*----------------------------------*

* gen learning mode dummies
tab learning_modality, m
gen prop_remote = 1 if learning_modality == "Remote"
replace prop_remote = 0.5 if learning_modality == "Hybrid"
replace prop_remote = 0 if learning_modality == "In Person"

*----------------------------------*
* collapse by countyfips
// note:
// student count: per district, not zipcode!
// multiple school districts under one zipcode
/// collapse, get mean of student_count by district and then sum student_count by countyfips

drop if state == "PR"	// drop PR since SY2021 obs missing. 

* 1. MONTH

// county

preserve

collapse (mean) prop_remote [w=student_count], by(countyfips year month)

drop if missing(countyfips)

order countyfips year month

save "${datap}modality2021_2022_county_month.dta", replace

restore

// state (for fatality analysis)

preserve

collapse (mean) prop_remote [w=student_count], by(state year month)

drop if missing(state)

order state year month

rename state stateabbr

save "${datap}modality2021_2022_state_month.dta", replace

restore

*------------------*

* 2. YEAR

// county

preserve

collapse (mean) prop_remote [w=student_count], by(countyfips)

drop if missing(countyfips)

gen year = 2022

order countyfips year

save "${datap}modality2021_2022_county_year.dta", replace

restore

// state (for fatality analysis)

preserve

collapse (mean) prop_remote [w=student_count], by(state)

drop if missing(state)

gen year = 2022

order state year

rename state stateabbr

save "${datap}modality2021_2022_state_year.dta", replace

restore

*----------------------------------*

// create the modality histogram

use "${datap}modality2021_2022_county_month.dta", clear

gen semester = 1 if inrange(month, 9, 12)
replace semester = 2 if inrange(month, 1, 5)


collapse (mean) prop_remote, by(countyfips semester)

twoway (hist prop_remote if semester==1, width(.05) color(red%30))	///
		(hist prop_remote if semester==2, width(.05) color(blue%30)),	///
		xtitle(% Remote (SY 2021-22)) xlabel(0(0.2)1) 			  ///
		xline(0.005, lpattern(dash))	///
		legend(order(1 "Fall 2021" 2 "Spring 2022")) legend(pos(6) col(2))
		
graph save "Graph" "${output}graph/SY22 remote_all_v2.gph", replace
graph export "${output}graph/SY22 remote_all_v2.pdf", as(pdf) name("Graph") replace


*----------------------------------*
*----------------------------------*

* combine SY2021 & SY2022 modality data

* 1. MONTH

// county
clear all

append using "${datap}modality2020_2021_county_month.dta"
append using "${datap}modality2021_2022_county_month.dta"

gen yearmonth = ym(year, month)
format yearmonth %tm

replace countyfips=2261 if countyfips==2063 | countyfips==2066

collapse (mean) prop_remote, by(countyfips year month yearmonth)

save "${datap}modality2020_2022_county_month.dta", replace

*--------------*

// state
clear all

append using "${datap}modality2020_2021_state_month.dta"
append using "${datap}modality2021_2022_state_month.dta"

gen yearmonth = ym(year, month)
format yearmonth %tm

save "${datap}modality2020_2022_state_month.dta", replace

*---------------------*

* 2. YEAR

// county
clear all

append using "${datap}modality2020_2021_county_year.dta"
append using "${datap}modality2021_2022_county_year.dta"

reshape wide prop_remote, i(countyfips) j(year)

replace countyfips=2261 if countyfips==2063 | countyfips==2066

collapse (mean) prop_remote2021 prop_remote2022, by(countyfips)

save "${datap}modality2020_2022_county_year.dta", replace

*--------------*

// state
clear all

append using "${datap}modality2020_2021_state_year.dta"
append using "${datap}modality2021_2022_state_year.dta"

reshape wide prop_remote, i(stateabbr) j(year)

save "${datap}modality2020_2022_state_year.dta", replace

* ************************************************************

* 3. child maltreatment - number of allegations, fatalities by state
// update it to county level once receiving NCANDS Child Files

// import excel spreadsheet

import excel "${data}Original/number of child maltreatment report by state FFY2010-22.xlsx", ///
		sheet("Sheet1") cellrange(A1:AE53) firstrow clear
		
drop childpop*
		
reshape long numreport numfatality, i(state) j(year)

save "${datap}maltreatment_fatality2010_2022_state.dta", replace

* ************************************************************

* 4.1. Census 0to19 population + linear time trend

** COUNTY 2010-2020

import delimited "${data}Original/Census/county/age/CC-EST2020-AGESEX-ALL.csv", numericcols(7 8 9 10 13 16 22 37 40 43 46 49 52 55 58 61 64 67 70 73 76) clear 

// first construct complete fips code
replace state = state*1000
gen countyfips = state + county

keep countyfips stname ctyname year popestimate popest_male popest_fem under5_tot age513_tot age1417_tot age16plus_tot age65plus_tot ///
age04_tot age59_tot age1014_tot age1519_tot age2024_tot age2529_tot age3034_tot age3539_tot age4044_tot age4549_tot age5054_tot age5559_tot age6064_tot
order countyfips stname ctyname year popestimate popest_male popest_fem under5_tot age513_tot age1417_tot age16plus_tot age65plus_tot ///
age04_tot age59_tot age1014_tot age1519_tot age2024_tot age2529_tot age3034_tot age3539_tot age4044_tot age4549_tot age5054_tot age5559_tot age6064_tot
keep if inrange(year, 3, 14)
drop if year == 13
replace year = 13 if year==14
rename year tt
replace tt = tt-2
gen year = tt+2009

egen pop0to17 = rowtotal(under5_tot age513_tot age1417_tot)
egen pop0to19 = rowtotal(age04_tot age59_tot age1014_tot age1519_tot)
gen pop16to64 = age16plus_tot - age65plus_tot
drop age16plus_tot age65plus_tot

egen pop25to34 = rowtotal(age2529_tot age3034_tot)
egen pop35to44 = rowtotal(age3539_tot age4044_tot)
egen pop45to54 = rowtotal(age4549_tot age5054_tot)
egen pop55to64 = rowtotal(age5559_tot age6064_tot)

rename stname state

replace countyfips=2261 if countyfips==2063 | countyfips==2066
collapse (sum) under5_tot pop* age*, by(countyfips state tt year)

order under5_tot, before(age513_tot)

save "${datap}population2010_2020_county.dta", replace

** COUNTY 2021-2022 & append

import delimited "${data}Original/Census/county/age/cc-est2022-agesex-all.csv", numericcols(7 8 9 10 13 16 22 37 40 43 46 49 52 55 58 61 64 67 70 73 76) clear 

// first construct complete fips code
replace state = state*1000
gen countyfips = state + county

keep countyfips stname ctyname year popestimate popest_male popest_fem under5_tot age513_tot age1417_tot age16plus_tot age65plus_tot ///
age04_tot age59_tot age1014_tot age1519_tot age2024_tot age2529_tot age3034_tot age3539_tot age4044_tot age4549_tot age5054_tot age5559_tot age6064_tot
order countyfips stname ctyname year popestimate popest_male popest_fem under5_tot age513_tot age1417_tot age16plus_tot age65plus_tot ///
age04_tot age59_tot age1014_tot age1519_tot age2024_tot age2529_tot age3034_tot age3539_tot age4044_tot age4549_tot age5054_tot age5559_tot age6064_tot
keep if inrange(year, 3, 4)
rename year tt
replace tt = tt+9
gen year = tt+2009

egen pop0to17 = rowtotal(under5_tot age513_tot age1417_tot)
egen pop0to19 = rowtotal(age04_tot age59_tot age1014_tot age1519_tot)
gen pop16to64 = age16plus_tot - age65plus_tot
drop age16plus_tot age65plus_tot

egen pop25to34 = rowtotal(age2529_tot age3034_tot)
egen pop35to44 = rowtotal(age3539_tot age4044_tot)
egen pop45to54 = rowtotal(age4549_tot age5054_tot)
egen pop55to64 = rowtotal(age5559_tot age6064_tot)

rename stname state

replace countyfips=2261 if countyfips==2063 | countyfips==2066
collapse (sum) under5_tot pop* age*, by(countyfips state tt year)

order under5_tot, before(age513_tot)

*---------------------*

// 20240716 update:
// change to county-equivalents in the State of Connecticut

// Fairfield (9001) = Greater Bridgeport (9120) + Western Connecticut (9190)
/// Hartford (9003) + Tolland (9013) = Capitol (9110)
// Litchfield (9005) = Northwest Hills (9160)
// Middlesex (9007) = Lower Connecticut River Valley (9130)
// New Haven (9009) = Naugatuck Valley (9140) + South Central Connecticut (9170)
// New London (9011) = Southeastern Connecticut (9180)
// Windham (9015) = Northeastern Connecticut (9150)

replace countyfips = 9001 if countyfips==9120 | countyfips==9190
replace countyfips = 9003 if countyfips==9110
replace countyfips = 9005 if countyfips==9160
replace countyfips = 9007 if countyfips==9130
replace countyfips = 9009 if countyfips==9140 | countyfips==9170
replace countyfips = 9011 if countyfips==9180
replace countyfips = 9015 if countyfips==9150

*---------------------*

append using "${datap}population2010_2020_county.dta"

sort state county tt year

collapse (sum) under5_tot pop* age*, by (state countyfips year tt)	// re-collapse after fixing CT countyfips

order under5_tot, before(age513_tot)

drop age2529_tot age3034_tot age3539_tot age4044_tot age4549_tot age5054_tot age5559_tot age6064_tot

save "${datap}population2010_2022_county.dta", replace

collapse (sum) under5_tot pop* age*, by (state year tt)

order under5_tot, before(age513_tot)

save "${datap}population2010_2022_state.dta", replace

* ************************************************************

* 4.2. Census 0to19 population (by race)

** COUNTY

// 2016-2020
	
import delimited "${data}Original/Census/county/race/CC-EST2020-ALLDATA.csv", numericcols(8 11 12 13 14 17 18 57 58) clear 

// only keep "total" age group
keep if agegrp==0

// first construct complete fips code
replace state = state*1000
gen countyfips = state + county

keep countyfips stname ctyname year agegrp tot_pop wa_male wa_female ba_male ba_female aa_male aa_female h_male h_female
order countyfips stname ctyname year agegrp tot_pop wa_male wa_female ba_male ba_female aa_male aa_female h_male h_female

keep if inrange(year, 9, 13)
replace year = year+2007

egen white = rowtotal(wa_male wa_female)
egen black = rowtotal(ba_male ba_female)
egen asian = rowtotal(aa_male aa_female)
egen hispanic = rowtotal(h_male h_female)
		
rename stname state

replace countyfips=2261 if countyfips==2063 | countyfips==2066
collapse (sum) tot_pop white black asian hispanic, by(countyfips state year)

save "${datap}population2016_2020_race_county.dta", replace

collapse (sum) tot_pop white black asian hispanic, by(state year)

save "${datap}population2016_2020_race_state.dta", replace

// 2021-2022

import delimited "${data}Original/Census/county/race/cc-est2022-all.csv", numericcols(8 11 12 13 14 17 18 57 58) clear  

// only keep "total" age group
keep if agegrp==0

// first construct complete fips code
replace state = state*1000
gen countyfips = state + county

keep countyfips stname ctyname year agegrp tot_pop wa_male wa_female ba_male ba_female aa_male aa_female h_male h_female
order countyfips stname ctyname year agegrp tot_pop wa_male wa_female ba_male ba_female aa_male aa_female h_male h_female
keep if inrange(year, 3, 4)
replace year = year+2018

egen white = rowtotal(wa_male wa_female)
egen black = rowtotal(ba_male ba_female)
egen asian = rowtotal(aa_male aa_female)
egen hispanic = rowtotal(h_male h_female)

rename stname state

replace countyfips=2261 if countyfips==2063 | countyfips==2066
collapse (sum) tot_pop white black asian hispanic, by(countyfips state year)

*---------------------*

// 20240716 update:
// change to county-equivalents in the State of Connecticut

// Fairfield (9001) = Greater Bridgeport (9120) + Western Connecticut (9190)
/// Hartford (9003) + Tolland (9013) = Capitol (9110)
// Litchfield (9005) = Northwest Hills (9160)
// Middlesex (9007) = Lower Connecticut River Valley (9130)
// New Haven (9009) = Naugatuck Valley (9140) + South Central Connecticut (9170)
// New London (9011) = Southeastern Connecticut (9180)
// Windham (9015) = Northeastern Connecticut (9150)

replace countyfips = 9001 if countyfips==9120 | countyfips==9190
replace countyfips = 9003 if countyfips==9110
replace countyfips = 9005 if countyfips==9160
replace countyfips = 9007 if countyfips==9130
replace countyfips = 9009 if countyfips==9140 | countyfips==9170
replace countyfips = 9011 if countyfips==9180
replace countyfips = 9015 if countyfips==9150

*---------------------*

collapse (sum) tot_pop white black asian hispanic, by (state countyfips year)	// re-collapse after fixing CT countyfips

append using "${datap}population2016_2020_race_county.dta"

save "${datap}population2016_2022_race_county.dta", replace

collapse (sum) tot_pop white black asian hispanic, by(state year)

save "${datap}population2016_2022_race_state.dta", replace

* ************************************************************

* 5. BLS unemp

forvalues i=10/19{
	
	import excel "${data}Original/BLS/laucnty`i'.xlsx", sheet("laucnty`i'") firstrow clear
	keep statefips countyfips countyname year laborforce unemp
	drop if missing(unemp)

	// construct fips code
	gen temp = statefips + countyfips
	drop *fips
	destring temp year, replace
	rename temp countyfips
	
	// extract state
	split countyname, p(", ")
	rename (countyname1 countyname2) (county stateabbr)
	drop countyname
	replace stateabbr = "DC" if missing(stateabbr) // DC

	order stateabbr county countyfips year laborforce unemp
	
	save "${datap}unemp`i'_county.dta", replace

	collapse (sum) laborforce (mean) unemp, by (stateabbr year)

	save "${datap}unemp`i'_state.dta", replace

}

* 2020 - no emp data for PR ("N.A.")
import excel "${data}Original/BLS/laucnty20.xlsx", sheet("laucnty20") firstrow clear
keep statefips countyfips countyname year laborforce unemp
drop if missing(unemp)
drop if unemp == "N.A."

destring laborforce, replace

// construct fips code
gen temp = statefips + countyfips
drop *fips
destring temp year unemp, replace
rename temp countyfips
	
// extract state
split countyname, p(", ")
rename (countyname1 countyname2) (county stateabbr)
drop countyname
replace stateabbr = "DC" if missing(stateabbr) // DC

order stateabbr county countyfips year laborforce unemp
	
save "${datap}unemp20_county.dta", replace

collapse (sum) laborforce (mean) unemp, by (stateabbr year)

save "${datap}unemp20_state.dta", replace
	
	
forvalues i=21/22{
	
	import excel "${data}Original/BLS/laucnty`i'.xlsx", sheet("laucnty`i'") firstrow clear
	keep statefips countyfips countyname year laborforce unemp
	drop if missing(unemp)

	// construct fips code
	gen temp = statefips + countyfips
	drop *fips
	destring temp year, replace
	rename temp countyfips
	
	// extract state
	split countyname, p(", ")
	rename (countyname1 countyname2) (county stateabbr)
	drop countyname
	replace stateabbr = "DC" if missing(stateabbr) // DC

	order stateabbr county countyfips year laborforce unemp
	
	save "${datap}unemp`i'_county.dta", replace

	collapse (sum) laborforce (mean) unemp, by (stateabbr year)

	save "${datap}unemp`i'_state.dta", replace

}

*----------------------------------*

// append county

clear all

forvalues i=10/22{
	
	append using "${datap}unemp`i'_county.dta"
	
}

sort stateabbr countyfips year

replace countyfips=2261 if countyfips==2063 | countyfips==2066
collapse (sum) laborforce (mean) unemp, by(stateabbr countyfips year)

save "${datap}unemp2010_2022_county.dta", replace

// append state

clear all

forvalues i=10/22{
	
	append using "${datap}unemp`i'_state.dta"
	
}

sort stateabbr year

save "${datap}unemp2010_2022_state.dta", replace


* ************************************************************
* ************************************************************

* MERGE state-year-level maltreatment + modality + census + unemp

use "${datap}maltreatment_fatality2010_2022_state.dta", clear

merge m:1 stateabbr using "${datap}modality2020_2022_state_year.dta"
// PR getting dropped
keep if _merge==3
drop _merge
sort state year

merge m:1 state year using "${datap}population2010_2022_state.dta"
keep if _merge==3
drop _merge

merge m:1 state year using "${datap}population2016_2022_race_state.dta"
keep if _merge==3
drop _merge

merge m:1 stateabbr year using "${datap}unemp2010_2022_state.dta"
// PR getting dropped
keep if _merge==3
drop _merge

merge m:1 stateabbr year using "${datap}SAIPE2016_2022_state.dta"
keep if _merge==3
drop _merge

merge m:1 statefips year using "${datap}covid cases and deaths_state_yearly_2020_2022"
drop if _merge==2	// Puerto Rico
drop _merge

rename (numreport numfatality) (numreport_raw numfatality_raw)

// generate "rate" or report, fatalities & lfp
gen numreport = numreport_raw/pop0to17 * 1000
gen numfatality = numfatality_raw/pop0to17 * 100000

order state year tt stateabbr statefips numreport numfatality numreport_raw numfatality_raw

gen lfp = laborforce/pop16to64

*----------------------------------*
// generate quantile dummy by SY2020-2021 exposure to remote learning

// 20240713 note: check states with missing report and/or fatality. do not assign quantile to them

/*

tab stateabbr year if missing(numreport)

           |                               year
 stateabbr |      2010       2011       2012       2013       2014       2021 |     Total
-----------+------------------------------------------------------------------+----------
        AZ |         0          0          0          0          0          1 |         1 
        HI |         1          1          1          1          1          0 |         5 
        ID |         0          0          1          0          0          0 |         1 
        IL |         1          1          0          0          0          0 |         2 
        NC |         1          1          1          1          1          0 |         5 
        ND |         0          0          0          0          1          0 |         1 
        NJ |         1          1          0          0          0          0 |         2 
        NY |         1          1          1          1          1          0 |         5 
        PA |         1          1          1          1          1          0 |         5 
-----------+------------------------------------------------------------------+----------
     Total |         6          6          5          4          5          1 |        27 


tab stateabbr year if missing(numfatality)


 stateabbr |      2010       2011       2012       2013       2014       2015       2016       2018       2019       2020       2021       2022 |     Total
-----------+------------------------------------------------------------------------------------------------------------------------------------+----------
        AZ |         0          0          0          0          0          0          0          0          0          0          1          0 |         1 
        ID |         0          0          1          0          0          0          0          0          0          0          0          0 |         1 
        MA |         1          1          1          1          1          1          1          1          1          1          1          1 |        12 
        ME |         0          0          1          1          1          1          1          0          0          0          0          0 |         5 
        NC |         0          0          0          0          0          1          0          0          0          0          0          0 |         1 
-----------+------------------------------------------------------------------------------------------------------------------------------------+----------
     Total |         1          1          3          2          2          3          2          1          1          1          2          1 |        20 


*/

*----------------------------------*

xtile remote2010r = prop_remote2021 if stateabbr!="AZ" & stateabbr!="HI" & stateabbr!="ID" & stateabbr!="IL" & stateabbr!="NC" & ///
									stateabbr!="ND" & stateabbr!="NJ" & stateabbr!="NY" & stateabbr!="PA", nq(2)
xtile remote2010f = prop_remote2021 if stateabbr!="AZ" & stateabbr!="ID" & stateabbr!="MA" & stateabbr!="ME" & stateabbr!="NC", nq(2)
xtile remote2016r = prop_remote2021 if stateabbr!="AZ", nq(2)
xtile remote2016f = prop_remote2021 if stateabbr!="AZ" & stateabbr!="MA" & stateabbr!="ME", nq(2)


xtile quantile2010r = prop_remote2021 if stateabbr!="AZ" & stateabbr!="HI" & stateabbr!="ID" & stateabbr!="IL" & stateabbr!="NC" & ///
									stateabbr!="ND" & stateabbr!="NJ" & stateabbr!="NY" & stateabbr!="PA", nq(4)
xtile quantile2010f = prop_remote2021 if stateabbr!="AZ" & stateabbr!="ID" & stateabbr!="MA" & stateabbr!="ME" & stateabbr!="NC", nq(4)
xtile quantile2016r = prop_remote2021 if stateabbr!="AZ", nq(4)
xtile quantile2016f = prop_remote2021 if stateabbr!="AZ" & stateabbr!="MA" & stateabbr!="ME", nq(4)


lab var remote2010r "remote dummy for numreport, 2010 onward"
lab var remote2010f "remote dummy for numfatality, 2010 onward"
lab var remote2016r "remote dummy for numreport, 2016 onward"
lab var remote2016f "remote dummy for numfatality, 2016 onward"

lab var quantile2010r "remote quantile for numreport, 2010 onward"
lab var quantile2010f "remote quantile for numfatality, 2010 onward"
lab var quantile2016r "remote quantile for numreport, 2016 onward"
lab var quantile2016f "remote quantile for numfatality, 2016 onward"

/*
forvalues i=1/4{
	gen q`i' = quantile == `i'
}
*/

* ************************************************************

//gen dataset = "state"

* Gen additional variables as rates

gen pop_white = white/popestimate
gen pop_black = black/popestimate
gen pop_asian = asian/popestimate
gen pop_hispanic = hispanic/popestimate

gen pop_0to19 = pop0to19/popestimate
gen pop_20to24 = pop25to34/popestimate
gen pop_25to34 = pop25to34/popestimate
gen pop_35to44 = pop35to44/popestimate
gen pop_45to54 = pop45to54/popestimate
gen pop_55to64 = pop55to64/popestimate

gen pop_female = popest_fem/popestimate

gen covid_case = newcases/popestimate*100000
gen covid_death = newdeaths/popestimate*100000

drop tot_pop white black asian hispanic age2024_tot pop25to34 pop35to44 pop45to54 pop55to64

save "${datap}master_state.dta", replace

* ************************************************************

tab state if quantile2015f==1
/*

               state |      Freq.     Percent        Cum.
---------------------+-----------------------------------
            Arkansas |         13        8.33        8.33
             Florida |         13        8.33       16.67
                Iowa |         13        8.33       25.00
              Kansas |         13        8.33       33.33
           Louisiana |         13        8.33       41.67
         Mississippi |         13        8.33       50.00
            Missouri |         13        8.33       58.33
            Nebraska |         13        8.33       66.67
        North Dakota |         13        8.33       75.00
        South Dakota |         13        8.33       83.33
               Texas |         13        8.33       91.67
             Wyoming |         13        8.33      100.00
---------------------+-----------------------------------
               Total |        156      100.00


*/

tab state if quantile2015f==2
/*
               state |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             Alabama |         13        8.33        8.33
              Alaska |         13        8.33       16.67
         Connecticut |         13        8.33       25.00
             Georgia |         13        8.33       33.33
               Idaho |         13        8.33       41.67
             Indiana |         13        8.33       50.00
            Michigan |         13        8.33       58.33
             Montana |         13        8.33       66.67
                Ohio |         13        8.33       75.00
      South Carolina |         13        8.33       83.33
           Tennessee |         13        8.33       91.67
           Wisconsin |         13        8.33      100.00
---------------------+-----------------------------------
               Total |        156      100.00



*/

tab state if quantile2015f==3
/*

               state |      Freq.     Percent        Cum.
---------------------+-----------------------------------
            Colorado |         13        8.33        8.33
            Delaware |         13        8.33       16.67
              Hawaii |         13        8.33       25.00
           Minnesota |         13        8.33       33.33
       New Hampshire |         13        8.33       41.67
            New York |         13        8.33       50.00
            Oklahoma |         13        8.33       58.33
        Pennsylvania |         13        8.33       66.67
        Rhode Island |         13        8.33       75.00
                Utah |         13        8.33       83.33
             Vermont |         13        8.33       91.67
       West Virginia |         13        8.33      100.00
---------------------+-----------------------------------
               Total |        156      100.00



*/

tab state if quantile2015f==4
/*
               state |      Freq.     Percent        Cum.
---------------------+-----------------------------------
          California |         13        8.33        8.33
District of Columbia |         13        8.33       16.67
            Illinois |         13        8.33       25.00
            Kentucky |         13        8.33       33.33
            Maryland |         13        8.33       41.67
              Nevada |         13        8.33       50.00
          New Jersey |         13        8.33       58.33
          New Mexico |         13        8.33       66.67
      North Carolina |         13        8.33       75.00
              Oregon |         13        8.33       83.33
            Virginia |         13        8.33       91.67
          Washington |         13        8.33      100.00
---------------------+-----------------------------------
               Total |        156      100.00



*/
	



// log close



