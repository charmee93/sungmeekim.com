* ************************************************************
* 2. graphs

* This do file is to generate graphs for data analysis and visualization.

* Author: Sungmee Kim
* Created: June 7, 2024
* Last Updated: November 6, 2024
* ************************************************************
* Notes

* 1. number of allegations / 1000 data comes from collapsing Child File (county-level)
	// discrepancies between Child File and state-level Child Maltreatment Report; check back
* 2. number of fatalities / 1000 data comes from Child Maltreatment Report (state-level)
	// didn't use numbers from county-level Child File since it doesn't have a "full" record. Refer to the Report.

*--------------------------------*

* (search each title to move to the code)

* 0. child fatality trend (0-3 vs. 4-17) using Child File 
* 0. controls pre-trend  
* 0. remote learning histogram (sample only)  
* 1.1. Maptile - prop_remote2021    
* 1.2. Maptile - prop_remote2021 (dummy)  
* 2. Forecast FFY 2020~2022 # of allegations (using FFY 2016~2019)
* 3. Allegation & Fatality Trend (full sample & by learning mode)

* ************************************************************
* Set Working Folder           
* ************************************************************

global dir "/Users/sk889/Library/CloudStorage/Dropbox/*2024 Return to School and Allegations/"

global data "${dir}Data/"
global datap "${data}Processed/"
global output "${dir}Output/"

* ************************************************************
* Set Log File                                  
* ************************************************************

//log using "${output}log/2.1. graphs.log", replace

* ************************************************************
* 0. child fatality trend (0-3 vs. 4-17) using Child File 
* updated 20240828                             
* ************************************************************

use "${datap}master_county_month_4to17.dta", clear

keep if stateabbr=="XX"	// fatality cases

// gen per 100,000 rate variables
egen pop5to17 = rowtotal(age513_tot age1417_tot)

gen fatality_0to3 = reported_0to3/age04_tot*100000
gen fatality_4to17 = reported_4to17/pop5to17*100000

drop if year==2022 & month>5	// drop out-of-sample periods

* by month

twoway connected fatality_0to3 yearmonth, sort msymbol(circle) mcolor(black) lcolor(black) lpattern(dash) yaxis(1) ytitle("Fatalities/100,000", axis(1)) ///
	|| connected fatality_4to17 yearmonth, sort msymbol(circle) mcolor(black) lcolor(black) lpattern(solid) yaxis(2) ytitle("Fatalities/100,000", axis(2))	///
	xtitle(Year-Month) xline(721, lpattern(dash) lcolor(red)) xline(727, lpattern(dash))  	///
	xlabel(680 "2016/9" 692 "2017/9" 704 "2018/9" 716 "2019/9" 728 "2020/9" 740 "2021/9")	///
	legend(label(1 "0 to 3") label(2 "4 to 17") cols(2) pos(6))
	
graph save "Graph" "${output}graph/_fatality trend by age_month.gph", replace
graph export "${output}graph/_fatality trend by age_month.pdf", as(pdf) name("Graph") replace


* by SY

gen quarter = 1 if inrange(month, 1, 3)
replace quarter = 2 if inrange(month, 4, 6)
replace quarter = 3 if inrange(month, 7, 9)
replace quarter = 4 if inrange(month, 10, 12)

tostring year, gen(yrstr)
tostring quarter, gen(qtrstr)
gen year_qtr_str=yrstr+" "+qtrstr
gen year_qtr = quarterly(year_qtr_str, "YQ")

format year_qtr %tq

drop if year==2016 & month==9

collapse (sum) reported_0to3 reported_4to17 (mean) age04_tot pop5to17, by(year_qtr)

gen fatality_0to3 = reported_0to3/age04_tot*100000
gen fatality_4to17 = reported_4to17/pop5to17*100000

twoway connected fatality_0to3 year_qtr, sort msymbol(circle) mcolor(black) lcolor(black) lpattern(dash) yaxis(1) ytitle("Fatalities/100,000", axis(1)) ///
	|| connected fatality_4to17 year_qtr, sort msymbol(circle) mcolor(black) lcolor(black) lpattern(solid) yaxis(2) ytitle("Fatalities/100,000", axis(2))	///
	xtitle(School Year) xline(240, lpattern(dash) lcolor(red)) xline(242, lpattern(dash))  	///
	xlabel(227 "SY 2016-17" 231 "SY18" 235 "SY19" 239 "SY20" 243 "SY21" 247 "SY22")	///
	legend(label(1 "0 to 3") label(2 "4 to 17") cols(2) pos(6))
	
graph save "Graph" "${output}graph/_fatality trend by age_sy.gph", replace
graph export "${output}graph/_fatality trend by age_sy.pdf", as(pdf) name("Graph") replace


* ************************************************************
* 0. controls pre-trend  
* updated 20241031                        
* ************************************************************

use "${datap}master_county_month_4to17.dta", clear

egen stategr = group(state)

egen pop5to17 = rowtotal(age513_tot age1417_tot)

gen remote = 1 if remote2016f==2
replace remote = 0 if remote2016f==1

replace covid_case = 0 if missing(covid_case)
replace covid_death = 0 if missing(covid_death)


collapse (mean) unemp lfp poverty_percent hhincome_med pop_white pop_black pop_asian pop_hispanic ///
		pop_0to19 pop_20to24 pop_25to34 pop_35to44 pop_45to54 pop_55to64 pop_female, by(year remote)
		
drop if missing(remote)
keep if inrange(year, 2016, 2019)

foreach var in unemp lfp poverty_percent hhincome_med pop_white pop_black pop_asian pop_hispanic ///
		pop_0to19 pop_20to24 pop_25to34 pop_35to44 pop_45to54 pop_55to64 pop_female{
			
twoway (connected `var' year if remote==0, sort msymbol(circle) mcolor(navy) lcolor(navy) lpattern(dash)) ///
	(connected `var' year if remote==1, sort msymbol(circle) mcolor(navy) lcolor(navy) lpattern(solid)),	///
	ytitle(`var') xtitle(Year) ///
	legend(label(1 "In-Person") label(2 "Remote") cols(2) pos(6))

graph save "Graph" "${output}graph/pre_trend_`var'.gph", replace
graph export "${output}graph/pre_trend_`var'.pdf", as(pdf) name("Graph") replace

}

***********************************************************
* 0. remote learning histogram (sample only)        
* updated 20241031               
* ************************************************************

// Figure 1

use "${datap}master_county_month_4to17.dta", clear

drop if stateabbr=="XX"

// by semester
gen semester = 1 if year==2020 & inrange(month, 9, 12)
replace semester = 2 if year==2021 & inrange(month, 1, 5)

drop if missing(semester)

collapse (mean) prop_remote, by(countyfips semester)

twoway (hist prop_remote if semester==1, width(.05) color(red%40) fraction)	///
		(hist prop_remote if semester==2, width(.05) color(blue%40) fraction),	///
		ytitle(Fraction of Total % of Counties)	///
		xtitle(% Remote (SY 2020-21))					  ///
		xline(0.45, lpattern(dash))	///
		legend(order(1 "Fall 2020" 2 "Spring 2021")) legend(pos(6) col(2))
		
graph save "Graph" "${output}graph/SY21 remote_all_sample_semester.gph", replace
graph export "${output}graph/SY21 remote_all_sample_semester.pdf", as(pdf) name("Graph") replace

// by county-month
use "${datap}master_county_month_4to17.dta", clear

drop if stateabbr=="XX"

gen semester = 1 if year==2020 & inrange(month, 9, 12)
replace semester = 2 if year==2021 & inrange(month, 1, 5)

drop if missing(semester)

collapse (mean) prop_remote, by(countyfips month semester)

twoway (hist prop_remote if semester==1, width(.05) color(red%40) fraction)	///
		(hist prop_remote if semester==2, width(.05) color(blue%40) fraction),	///
		ytitle(Fraction of Total % of Counties)	///
		xtitle(% Remote (SY 2020-21))					  ///
		xline(0.45, lpattern(dash))	///
		legend(order(1 "Fall 2020" 2 "Spring 2021")) legend(pos(6) col(2))
		
graph save "Graph" "${output}graph/SY21 remote_all_sample_month.gph", replace
graph export "${output}graph/SY21 remote_all_sample_month.pdf", as(pdf) name("Graph") replace

* ************************************************************

// Figure 2
// proportion of counties with remote learning ~ year-month

use "${datap}master_county_month_4to17.dta", clear

drop if stateabbr=="XX"

gen num_county = 1

gen remote_county=1 if prop_remote>0.45 & !missing(prop_remote)

collapse (sum) remote_county num_county , by(year month yearmonth)

drop in 1/48
drop in 22/25

gen temp = remote_county/num_county

graph bar temp, over(yearmonth)

graph save "Graph" "${output}graph/proportion of remote counties by yearmonth.gph"

* ************************************************************
* 1.1. Maptile - prop_remote2021                                
* ************************************************************

ssc inst maptile
ssc inst spmap
// state map
maptile_install using "http://files.michaelstepner.com/geo_state.zip", replace
maptile_install using "http://files.michaelstepner.com/geo_county2014.zip", replace

*-----------------------------*
* 1. State
*-----------------------------*
// prep state coord data
use "${data}geo_state_creation/geo_templates/state/state_coords_clean.dta", clear
drop if missing(_X) | missing(_Y)
collapse (mean) _X _Y, by(_ID)
tempfile stateco
save "`stateco'"
// _ID _X _Y

// merge coordinates data with state abbreviation data
use "${data}geo_state_creation/geo_templates/state/state_database_clean.dta", clear
rename _polygonid _ID
merge 1:1 _ID using "`stateco'", nogen
tempfile state
save "`state'"

*-----------------------------*

use "${datap}master_state.dta", clear

// state fips code
tab statefips

// merge state abbreviation & state coordinates
merge m:1 statefips using "`state'", nogen

keep if year==2021

collapse (sum) prop_remote2021, by(state statefips year)	// _X _Y
drop if state == "Arizona" | state == "Maine" | state == "Massachusetts"

replace prop_remote2021=prop_remote2021*100

maptile prop_remote2021, geo(state) geoid(statefips) cutvalues(20(20)60) ///
	twopt(legend(size(medsmall)) ysize(4) xsize(7)) legd(0) fcolor(Blues)	///
	savegraph("${output}graph/maptile_state.gph") replace

maptile prop_remote2021, geo(state) geoid(statefips) cutvalues(20(20)60) ///
	twopt(legend(size(medsmall)) ysize(4) xsize(7)) legd(0) fcolor(Blues)	///
	savegraph("${output}graph/maptile_state.pdf") replace
	
*-----------------------------*
* 2. County
*-----------------------------*
// prep state coord data
use "${data}geo_county2014_creation/geo_templates/county2014/county2014_coords.dta", clear
drop if missing(_X) | missing(_Y)
collapse (mean) _X _Y, by(_ID)
tempfile countyco
save "`countyco'"
// _ID _X _Y

// merge coordinates data with state abbreviation data
use "${data}geo_county2014_creation/geo_templates/county2014/county2014_database.dta", clear
rename id _ID
merge 1:1 _ID using "`countyco'", nogen
rename county countyfips
tempfile county
save "`county'"

*-----------------------------*

use "${datap}master_county_year.dta", clear
drop if missing(countyfips)

// merge state abbreviation & state coordinates
merge m:1 countyfips using "`county'", nogen

keep if year==2021

collapse (sum) prop_remote2021, by(countyfips year)	// _X _Y

replace prop_remote2021=prop_remote2021*100

rename countyfips county 

// gotta fix the coordinates
maptile prop_remote2021, geo(county2014) cutvalues(20(20)60) ///
	twopt(legend(size(medsmall)) ysize(4) xsize(7)) legd(0) fcolor(Blues)	///
	savegraph("${output}graph/maptile_county.gph") replace

maptile prop_remote2021, geo(county2014) cutvalues(20(20)60) ///
	twopt(legend(size(medsmall)) ysize(4) xsize(7)) legd(0) fcolor(Blues)	///
	savegraph("${output}graph/maptile_county.pdf") replace

* ************************************************************
* 1.2. Maptile - prop_remote2021 (dummy)                              
* ************************************************************

ssc inst maptile
ssc inst spmap
// state map
maptile_install using "http://files.michaelstepner.com/geo_state.zip", replace
maptile_install using "http://files.michaelstepner.com/geo_county2014.zip", replace

*-----------------------------*
* 1. State
*-----------------------------*
// prep state coord data
use "${data}geo_state_creation/geo_templates/state/state_coords_clean.dta", clear
drop if missing(_X) | missing(_Y)
collapse (mean) _X _Y, by(_ID)
tempfile stateco
save "`stateco'"
// _ID _X _Y

// merge coordinates data with state abbreviation data
use "${data}geo_state_creation/geo_templates/state/state_database_clean.dta", clear
rename _polygonid _ID
merge 1:1 _ID using "`stateco'", nogen
tempfile state
save "`state'"

*-----------------------------*

use "${datap}master_state.dta", clear

// state fips code
tab statefips

// merge state abbreviation & state coordinates
merge m:1 statefips using "`state'", nogen

keep if year==2021

collapse (sum) prop_remote2021, by(state statefips year)	// _X _Y

replace prop_remote2021=prop_remote2021*100

drop if state == "Arizona" | state == "Maine" | state == "Massachusetts"
xtile remote = prop_remote2021, n(2)

maptile remote, geo(state) geoid(statefips) cutvalues(1(1)2) ///
	twopt(legend(size(medsmall)) ysize(4) xsize(7)) legd(0)	fcolor(Blues) ///
	savegraph("${output}graph/maptile_state_dummy.gph") replace

	// manually edit legend & save the graph (pdf)

*-----------------------------*
* 2. County
*-----------------------------*
// prep state coord data
use "${data}geo_county2014_creation/geo_templates/county2014/county2014_coords.dta", clear
drop if missing(_X) | missing(_Y)
collapse (mean) _X _Y, by(_ID)
tempfile countyco
save "`countyco'"
// _ID _X _Y

// merge coordinates data with state abbreviation data
use "${data}geo_county2014_creation/geo_templates/county2014/county2014_database.dta", clear
rename id _ID
merge 1:1 _ID using "`countyco'", nogen
rename county countyfips
tempfile county
save "`county'"

*-----------------------------*

use "${datap}master_county_year.dta", clear
drop if missing(countyfips)

// merge state abbreviation & state coordinates
merge m:1 countyfips using "`county'", nogen

keep if year==2021

collapse (sum) prop_remote2021, by(countyfips year)	// _X _Y

replace prop_remote2021=prop_remote2021*100

xtile remote = prop_remote2021, n(2)

rename countyfips county 

// gotta fix the coordinates
maptile remote, geo(county2014) cutvalues(1(1)2) ///
	twopt(legend(size(medsmall)) ysize(4) xsize(7)) legd(0)	fcolor(Blues) ///
	savegraph("${output}graph/maptile_county_dummy.gph") replace
	
* ************************************************************
* 2. Forecast FFY 2020~2022 # of allegations (using FFY 2016~2019)
* ************************************************************

/* clear all

* 1. state level: report + fatality

use "${datap}master_state.dta", clear

gen tt2 = tt*tt
gen tt3 = tt*tt*tt

keep if inrange(year, 2016, 2022)

reg numreport_raw i.statefips i.year tt tt2 tt3 if inrange(year, 2016, 2019)
																
predict counterfactual             

order counterfactual, before(numreport_raw)    


collapse (sum) numreport_raw counterfactual pop0to17 , by(year)

gen numreport = numreport_raw/pop0to17 * 1000
replace counterfactual = counterfactual/pop0to17 * 1000

twoway (connected numreport year, sort msymbol(circle) mcolor(orange) lcolor(orange) lpattern(solid)) ///
		(connected counterfactual year, sort msymbol(circle) mcolor(orange) lcolor(orange) lpattern(dash)), ///
		ytitle("Allegations/1,000") ///
		xtitle(Year) xlabel(2016(1)2022) xline(2020, lpattern(dash)) xline(2021, lpattern(dash))  	///
		legend(label(1 "Actual") label(2 "Counterfactual") cols(2) pos(6))

graph save "Graph" "${output}graph/counterfactual_2016.gph", replace
graph export "${output}graph/counterfactual_2016.pdf", as(pdf) name("Graph") replace

* ************************************************************

* 2.1. county-year level

use "${datap}master_county_year.dta", clear

gen tt2 = tt*tt
gen tt3 = tt*tt*tt

keep if inrange(year, 2016, 2022)

replace countyfips = 0 if missing(countyfips)

reg reported_total i.countyfips i.year tt tt2 tt3 if inrange(year, 2016, 2019)
																
predict counterfactual             

order counterfactual, before(reported_total)    


collapse (sum) reported_total counterfactual pop0to17 , by(year)

gen reported_total_1000 = reported_total/pop0to17 * 1000
replace counterfactual = counterfactual/pop0to17 * 1000

twoway (connected reported_total_1000 year, sort msymbol(circle) mcolor(orange) lcolor(orange) lpattern(solid)) ///
		(connected counterfactual year, sort msymbol(circle) mcolor(orange) lcolor(orange) lpattern(dash)), ///
		ytitle("Allegations/1,000") ///
		xtitle(Year) xlabel(2016(1)2022) xline(2020, lpattern(dash)) xline(2021, lpattern(dash))  	///
		legend(label(1 "Actual") label(2 "Counterfactual") cols(2) pos(6))

graph save "Graph" "${output}graph/counterfactual_2016.gph", replace
graph export "${output}graph/counterfactual_2016.pdf", as(pdf) name("Graph") replace
      
* ************************************************************

* 2.2. county-month level

use "${datap}master_county_month.dta", clear

gen tt2 = tt*tt
gen tt3 = tt*tt*tt

/*
In most situations I would code these as 1996 = 1, 1998 = 3, 1999 = 4. That's because in most situation what you want the time trend variable to represent is the elapsed time.

An exception to this general principle might arise depending on why there is no 1997 data. If the effects you are analyzing were actually suspended or otherwise inoperative during 1997, then it would be more correct to code 1998 as year 2 and 1999 as year 3, because nothing actually happened in 1997.
*/


//reg reported_total_raw i.countyfips i.year i.month tt tt2 tt3 if ( inrange(year, 2016, 2018) | (year==2019 & inrange(month, 1, 5)) ) & stateabbr!="XX"
reg reported_total i.countyfips i.year i.month tt tt2 if (inrange(year, 2016, 2019)| (year==2020 & inrange(month,1,2) ) )& stateabbr!="XX"
																
predict counterfactual if stateabbr!="XX"              

order counterfactual, before(reported_total)          
		
// maltreatment trend (actual vs. counterfactual)

preserve

collapse (sum) reported_total counterfactual pop0to17 if stateabbr!="XX", by(yearmonth)

gen reported_total_1000 = reported_total/pop0to17 * 1000
replace counterfactual = counterfactual/pop0to17 * 1000

twoway (connected reported_total_1000 yearmonth, sort msymbol(circle) mcolor(orange) lcolor(orange) lpattern(solid)) ///
		(connected counterfactual yearmonth, sort msymbol(circle) mcolor(orange) lcolor(orange) lpattern(dash)), ///
		ytitle("Allegations/1,000") ///
		xtitle(Year-Month) xlabel(680(12)736) xline(722, lpattern(dash)) xline(728, lpattern(dash))  	///
		legend(label(1 "Actual") label(2 "Counterfactual") cols(2) pos(6))

graph save "Graph" "${output}graph/counterfactual_2016m9_67.gph", replace
graph export "${output}graph/counterfactual_2016m9_67.pdf", as(pdf) name("Graph") replace

*-------------*

keep if yearmonth>703

twoway (connected reported_total_1000 yearmonth, sort msymbol(circle) mcolor(orange) lcolor(orange) lpattern(solid)) ///
		(connected counterfactual yearmonth, sort msymbol(circle) mcolor(orange) lcolor(orange) lpattern(dash)), ///
		ytitle("Allegations/1,000") ///
		xtitle(Year-Month) xlabel(704(12)736) xline(722, lpattern(dash)) xline(728, lpattern(dash))  	///
		legend(label(1 "Actual") label(2 "Counterfactual") cols(2) pos(6))

graph save "Graph" "${output}graph/counterfactual_2018m9_67.gph", replace
graph export "${output}graph/counterfactual_2018m9_67.pdf", as(pdf) name("Graph") replace

restore

*/

* ************************************************************
* 3. Allegation & Fatality Trend (full sample & by learning mode)
* ************************************************************

* 1. Full Sample

* [Child File] - county-month

use "${datap}master_county_month.dta", clear

gen fatality = stateabbr=="XX"

collapse (sum) reported_total pop0to17, by(fatality yearmonth)

gen reported_total_1000 = reported_total/pop0to17 * 1000
replace reported_total_1000 = reported_total/pop0to17 * 100000 if fatality==1

// allegation
twoway (connected reported_total_1000 yearmonth if fatality==0, sort msymbol(circle) mcolor(black) lcolor(black) lpattern(solid)), ///
	ytitle("Allegations/1,000") ///
	xtitle(Year-Month) xlabel(680(12)736) xline(722, lpattern(dash) lcolor(red)) xline(728, lpattern(dash) lcolor(red))	///
	legend(label(1 "Allegations per 1,000 Children") cols(2) pos(6))

graph save "Graph" "${output}graph/allegation trend full_2016m9_67.gph", replace
graph export "${output}graph/allegation trend full_2016m9_67.pdf", as(pdf) name("Graph") replace

*----------------------------------*

// fatality
twoway (connected reported_total_1000 yearmonth if fatality==1, sort msymbol(circle) mcolor(black) lcolor(black) lpattern(solid)), ///
	ytitle("Fatalities/100,000") ///
	xtitle(Year-Month) xlabel(680(12)736) xline(722, lpattern(dash) lcolor(red)) xline(728, lpattern(dash) lcolor(red))	///
	legend(label(1 "Fatalities per 100,000 Children") cols(2) pos(6))

graph save "Graph" "${output}graph/fatality trend full_2016m9_67.gph", replace
graph export "${output}graph/fatality trend full_2016m9_67.pdf", as(pdf) name("Graph") replace

*----------------------------------*

// combined
twoway connected reported_total_1000 yearmonth if fatality==0, sort msymbol(circle) mcolor(black) lcolor(black) lpattern(dash) yaxis(1) ytitle("Allegations/1,000", axis(1)) ///
	|| connected reported_total_1000 yearmonth if fatality==1, sort msymbol(circle) mcolor(black) lcolor(black) lpattern(solid) yaxis(2) ytitle("Fatalities/100,000", axis(2))	///
	xtitle(Year-Month) xlabel(680(12)736) xline(722, lpattern(dash) lcolor(red)) xline(728, lpattern(dash) lcolor(red))	///
	legend(label(1 "Allegations per 1,000 Children") label(2 "Fatalities per 100,000 Children") cols(2) pos(6))
	
graph save "Graph" "${output}graph/COMBINED trend full_2016m9_67.gph", replace
graph export "${output}graph/COMBINED trend full_2016m9_67.pdf", as(pdf) name("Graph") replace

*----------------------------------*
*----------------------------------*

* [Child Maltreatment Report] - state-year

use "${datap}master_state.dta", clear

collapse (sum) numreport_raw numfatality_raw pop0to17, by(year)

gen reported_total_1000 = numreport_raw/pop0to17 * 1000
gen fatality_total_100000 = numfatality_raw/pop0to17 * 100000

// allegation
twoway (connected reported_total_1000 year, sort msymbol(circle) mcolor(black) lcolor(black) lpattern(solid)), ///
	ytitle("Allegations/1,000") ///
	xtitle(Year) xlabel(2016(1)2022) xline(2019, lpattern(dash) lcolor(red)) 	///
	legend(label(1 "Allegations per 1,000 Children") cols(2) pos(6))

graph save "Graph" "${output}graph/allegation trend full_2016_2022.gph", replace
graph export "${output}graph/allegation trend full_2016_2022.pdf", as(pdf) name("Graph") replace

*----------------------------------*

// fatality
twoway (connected fatality_total_100000 year, sort msymbol(circle) mcolor(black) lcolor(black) lpattern(solid)), ///
	ytitle("Fatalities/100,000") ///
	xtitle(Year) xlabel(2016(1)2022) xline(2019, lpattern(dash) lcolor(red)) 	///
	legend(label(1 "Fatalities per 100,000 Children") cols(2) pos(6))

graph save "Graph" "${output}graph/fatality trend full_2016_2022.gph", replace
graph export "${output}graph/fatality trend full_2016_2022.pdf", as(pdf) name("Graph") replace

*----------------------------------*

// combined
twoway connected reported_total_1000 year, sort msymbol(circle) mcolor(black) lcolor(black) lpattern(dash) yaxis(1) ytitle("Allegations/1,000", axis(1)) ///
	|| connected fatality_total_100000 year, sort msymbol(circle) mcolor(black) lcolor(black) lpattern(solid) yaxis(2) ytitle("Fatalities/100,000", axis(2))	///
	xtitle(Year) xlabel(2016(1)2022) xline(2019, lpattern(dash) lcolor(red)) 	///
	legend(label(1 "Allegations per 1,000 Children") label(2 "Fatalities per 100,000 Children") cols(2) pos(6))
	
graph save "Graph" "${output}graph/COMBINED trend full_2016_2022.gph", replace
graph export "${output}graph/COMBINED trend full_2016_2022.pdf", as(pdf) name("Graph") replace

* ************************************************************

* [Child Maltreatment Report] - by remote learning group

/*
note:
xtile remote2010r = prop_remote2021 if stateabbr!="AZ" & stateabbr!="HI" & stateabbr!="ID" & stateabbr!="IL" & stateabbr!="NC" & ///
									stateabbr!="ND" & stateabbr!="NJ" & stateabbr!="NY" & stateabbr!="PA", nq(2)
xtile remote2010f = prop_remote2021 if stateabbr!="AZ" & stateabbr!="ID" & stateabbr!="MA" & stateabbr!="ME" & stateabbr!="NC", nq(2)
xtile remote2015r = prop_remote2021 if stateabbr!="AZ", nq(2)
xtile remote2015f = prop_remote2021 if stateabbr!="AZ" & stateabbr!="MA" & stateabbr!="ME", nq(2)


xtile quantile2010r = prop_remote2021 if stateabbr!="AZ" & stateabbr!="HI" & stateabbr!="ID" & stateabbr!="IL" & stateabbr!="NC" & ///
									stateabbr!="ND" & stateabbr!="NJ" & stateabbr!="NY" & stateabbr!="PA", nq(4)
xtile quantile2010f = prop_remote2021 if stateabbr!="AZ" & stateabbr!="ID" & stateabbr!="MA" & stateabbr!="ME" & stateabbr!="NC", nq(4)
xtile quantile2015r = prop_remote2021 if stateabbr!="AZ", nq(4)
xtile quantile2015f = prop_remote2021 if stateabbr!="AZ" & stateabbr!="MA" & stateabbr!="ME", nq(4)
*/

use "${datap}master_state.dta", clear

gen remote = 1 if remote2016f==2
replace remote = 0 if remote2016f==1

collapse (sum) numreport_raw numfatality_raw pop0to17, by(remote year)
drop if missing(remote)	// stateabbr = "XX"?

gen numreport = numreport_raw/pop0to17 * 1000
gen numfatality = numfatality_raw/pop0to17 * 100000

*----------------------------------*
// allegation
// 40

gen upper = 40

twoway 	(bar upper y if inrange(y, 2020.5, 2021.5), bcolor(gs14%30) base(24))	///
		(connected numreport year if remote==0, sort msymbol(circle) mcolor(navy) lcolor(navy) lpattern(dot)) ///
		(connected numreport year if remote==1, sort msymbol(circle) mcolor(navy) lcolor(navy) lpattern(solid)),	///
	ytitle("Allegations/1,000") ///
	xtitle(Fiscal Year) xlabel(2016(1)2022) xline(2019.5, lpattern(dash) lcolor(red)) 	///
	plotregion(margin(b=0 t=0))	///
	legend(order(2 "In-Person" 3 "Remote") cols(2) pos(6))

graph save "Graph" "${output}graph/allegation trend 2q_2016_2022.gph", replace
graph export "${output}graph/allegation trend 2q_2016_2022.pdf", as(pdf) name("Graph") replace

*----------------------------------*
// fatality
// 3.5

drop upper
gen upper = 3.5

twoway 	(bar upper y if inrange(y, 2020.5, 2021.5), bcolor(gs14%30) base(1.5))	///
		(connected numfatality year if remote==0, sort msymbol(circle) mcolor(navy) lcolor(navy) lpattern(dot)) ///
		(connected numfatality year if remote==1, sort msymbol(circle) mcolor(navy) lcolor(navy) lpattern(solid)), ///
	ytitle("Fatalities/100,000") ///
	xtitle(Fiscal Year) xlabel(2016(1)2022) xline(2019.5, lpattern(dash) lcolor(red)) 	///
	plotregion(margin(b=0 t=0))	///
	legend(order(2 "In-Person" 3 "Remote") cols(2) pos(6))

graph save "Graph" "${output}graph/fatality trend 2q_2016_2022.gph", replace
graph export "${output}graph/fatality trend 2q_2016_2022.pdf", as(pdf) name("Graph") replace


// log close



