* ************************************************************
* 3. 4to17 (vs. 0to3)_v2

* Author: Sungmee Kim
* Created: November 13, 2024
* ************************************************************
* NOTE

* (search each title to move to the code)

* [DID Robustness Test]
* 1. Parallel Trend - Pre / Post dummy // later, do honestdid
* 2. No Anticipation - 2019/3 as treatment month (placebo test)

* [DID]
* 0. Continuous Treatment
* 1. COUNTY-MONTH
	* 0) pre-pandemic vs. full-remote
	* 1) pre-pandemic vs. blended learning (prop_remote variation)
* 2. STATE-YEAR

* [EVENT STUDY]
* 1. COUNTY-MONTH
* 2. STATE-YEAR

* ************************************************************
* Set Working Folder           
* ************************************************************

global dir "/Users/sk889/Library/CloudStorage/Dropbox/*2024 Return to School and Allegations/"

global data "${dir}Data/"
global datap "${data}Processed/"
global output "${dir}Output/"
global outputv2 "${dir}Output/4to17_v2/"

* ************************************************************
* Set Log File                                  
* ************************************************************

//log using "${output}log/3.3. 4to17 (vs. 0to3)_v2.log", replace

* ************************************************************
* Analyses         
* ************************************************************

* [DID Test]

* ************************************************************

* 1. Parallel Trend - Pre / Post dummy
// later, do honestdid

use "${datap}master_county_month_4to17.dta", clear

egen stategr = group(state)

egen pop5to17 = rowtotal(age513_tot age1417_tot)

*----------------------------------*

// gen per 1000
foreach var in reported_total_4to17 reported_edu_4to17 reported_legal_4to17 reported_social_4to17 reported_medical_4to17 ///
		reported_pro_4to17 reported_nonpro_4to17 reported_missing_4to17 ///
		reported_black_4to17 reported_white_4to17 reported_asian_4to17 reported_hisp_4to17 ///
		reported_physical_4to17 reported_neglect_4to17 reported_sxabuse_4to17 reported_psyemo_4to17{
			gen `var'_1000=`var'/pop5to17*1000
}

foreach var in reported_total_0to3 reported_edu_0to3 reported_legal_0to3 reported_social_0to3 reported_medical_0to3 ///
		reported_pro_0to3 reported_nonpro_0to3 reported_missing_0to3 ///
		reported_black_0to3 reported_white_0to3 reported_asian_0to3 reported_hisp_0to3 ///
		reported_physical_0to3 reported_neglect_0to3 reported_sxabuse_0to3 reported_psyemo_0to3{
			gen `var'_1000=`var'/age04_tot*1000
}

// gen per 1000 "allegations"
foreach var in reported_total_4to17 reported_edu_4to17 reported_legal_4to17 reported_social_4to17 reported_medical_4to17 ///
		reported_pro_4to17 reported_nonpro_4to17 reported_missing_4to17 ///
		reported_black_4to17 reported_white_4to17 reported_asian_4to17 reported_hisp_4to17 ///
		reported_physical_4to17 reported_neglect_4to17 reported_sxabuse_4to17 reported_psyemo_4to17{
			gen `var'_sub_r=`var'_sub/`var'*1000
}

foreach var in reported_total_0to3 reported_edu_0to3 reported_legal_0to3 reported_social_0to3 reported_medical_0to3 ///
		reported_pro_0to3 reported_nonpro_0to3 reported_missing_0to3 ///
		reported_black_0to3 reported_white_0to3 reported_asian_0to3 reported_hisp_0to3 ///
		reported_physical_0to3 reported_neglect_0to3 reported_sxabuse_0to3 reported_psyemo_0to3{
			gen `var'_sub_r=`var'_sub/`var'*1000
}

/*
// gen per 1000 "children"
foreach var in reported_total_4to17 reported_edu_4to17 reported_nonedu_4to17 reported_nonpro_4to17 reported_legal_4to17 reported_social_4to17 reported_medical_4to17 ///
		reported_black_4to17 reported_white_4to17 reported_hisp_4to17 reported_asian_4to17 ///
		reported_physical_4to17 reported_neglect_4to17 reported_sxabuse_4to17{
			gen `var'_sub_c=`var'_sub/pop5to17*1000
}

foreach var in reported_total_0to3 reported_edu_0to3 reported_nonedu_0to3 reported_nonpro_0to3 reported_legal_0to3 reported_social_0to3 reported_medical_0to3 ///
		reported_black_0to3 reported_white_0to3 reported_hisp_0to3 reported_asian_0to3 ///
		reported_physical_0to3 reported_neglect_0to3 reported_sxabuse_0to3{
			gen `var'_sub_c=`var'_sub/age04_tot*1000
}
*/

// gen post dummy for each case
		
gen post1 = 1 if (year == 2020 & inrange(month, 9, 12)) | (year == 2021 & inrange(month, 1, 5))
replace post1 = 0 if (year == 2018 & inrange(month, 9, 12)) | (year == 2019 & inrange(month, 1, 5)) | ///
			(year == 2019 & inrange(month, 9, 12)) | (year == 2020 & inrange(month, 1, 2))

gen post2 = 1 if (year == 2020 & inrange(month, 9, 12)) | (year == 2021 & inrange(month, 1, 5)) | ///
				(year == 2021 & inrange(month, 9, 12)) | (year == 2022 & inrange(month, 1, 5))
replace post2 = 0 if (year == 2018 & inrange(month, 9, 12)) | (year == 2019 & inrange(month, 1, 5)) | ///
			(year == 2019 & inrange(month, 9, 12)) | (year == 2020 & inrange(month, 1, 2))

gen pre1 = 1 if (year == 2018 & inrange(month, 9, 12)) | (year == 2019 & inrange(month, 1, 5)) | ///
			(year == 2019 & inrange(month, 9, 12)) | (year == 2020 & month==1)
replace pre1 = 0 if (year==2020 & month==2) | (year == 2020 & inrange(month, 9, 12)) | (year == 2021 & inrange(month, 1, 5))

gen pre2 = 1 if (year == 2018 & inrange(month, 9, 12)) | (year == 2019 & inrange(month, 1, 5)) | ///
			(year == 2019 & inrange(month, 9, 12)) | (year == 2020 & month==1)
replace pre2 = 0 if (year==2020 & month==2) | (year == 2020 & inrange(month, 9, 12)) | (year == 2021 & inrange(month, 1, 5)) | ///
				(year == 2021 & inrange(month, 9, 12)) | (year == 2022 & inrange(month, 1, 5))

// gen dummy interaction variable

drop if missing(remote2016f)

gen remote = 1 if remote2016f==2
replace remote = 0 if remote2016f==1

gen treatpost1 = remote*post1
gen treatpost2 = remote*post2

gen treatpre1 = remote*pre1
gen treatpre2 = remote*pre2


// gen quantile interaction variable

forvalues i=1/4{
	gen quantile`i'= quantile2016f==`i'
}

forvalues i=1/4{
	gen q`i'post1=quantile`i'*post1
	gen q`i'post2=quantile`i'*post2
}

// gen continuous interaction variable

replace prop_remote_2021 = prop_remote_2021*50	// convert it to 50pp increment

gen treatpost1_cont = prop_remote_2021*post1
gen treatpost2_cont = prop_remote_2021*post2

gen treatpre1_cont = prop_remote_2021*pre1
gen treatpre2_cont = prop_remote_2021*pre2

*------------*

// impute 0 covid case & death to pre-pandemic period

replace covid_case = 0 if missing(covid_case)
replace covid_death = 0 if missing(covid_death)


/* add blue state indicator
gen blue = 1 if stateabbr=="WA" | stateabbr=="OR" | stateabbr=="CA" | stateabbr=="NV" |	///
				stateabbr=="CO" | stateabbr=="NM" | stateabbr=="MN" | stateabbr=="WI" | stateabbr=="MI" | stateabbr=="IL" | ///
				stateabbr=="PA" | stateabbr=="NY" | stateabbr=="VT" | stateabbr=="NH" | stateabbr=="ME" | ///
				stateabbr=="MA" | stateabbr=="RI" | stateabbr=="CT" | stateabbr=="NJ" | stateabbr=="DE" | stateabbr=="MD" | stateabbr=="DC" | ///
				stateabbr=="VA" | stateabbr=="HI"	//24
replace blue = 0.5 if stateabbr=="IA" | stateabbr=="OH" | stateabbr=="FL"	//3
replace blue = 0 if stateabbr=="AK" | ///
					stateabbr=="ID" | stateabbr=="MT" | stateabbr=="ND" | stateabbr=="SD" | stateabbr=="WY"	| ///
					stateabbr=="UT" | stateabbr=="AZ" | stateabbr=="NE" | stateabbr=="KS" | stateabbr=="OK"	| ///
					stateabbr=="TX" | stateabbr=="MO" | stateabbr=="AR" | stateabbr=="LA" | stateabbr=="MS"	| ///
					stateabbr=="IN" | stateabbr=="KY" | stateabbr=="WV" | stateabbr=="TN" | stateabbr=="NC"	| ///
					stateabbr=="SC" | stateabbr=="AL" | stateabbr=="GA" //24
*/
					
* 4 to 17, allegations

// by reporter type
eststo clear

eststo total: quietly reg reported_total_4to17_1000 treatpre1 treatpost1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo edu5to17: quietly reg reported_edu_4to17_1000 treatpre1 treatpost1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo legal: quietly reg reported_legal_4to17_1000 treatpre1 treatpost1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo social5to17: quietly reg reported_social_4to17_1000 treatpre1 treatpost1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
	
eststo medical5to17: quietly reg reported_medical_4to17_1000 treatpre1 treatpost1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo otherpro: quietly reg reported_pro_4to17_1000 treatpre1 treatpost1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo nonpro: quietly reg reported_nonpro_4to17_1000 treatpre1 treatpost1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
esttab using "${outputv2}parallel_dummy_4to17_1.tex", se label title(Parallel Trends Test (SY 19-20 vs. SY 21), Allegations, Ages 4-17) keep(treatpre1 treatpost1) scalars(Mean N r2) noobs  ///
mtitles("Total" "Edu" "Legal" "Social" "Medical" "Other Pro" "Non-Pro") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

*------------*

// by race
eststo clear
		
eststo black: quietly reg reported_black_4to17_1000 treatpre1 treatpost1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo white: quietly reg reported_white_4to17_1000 treatpre1 treatpost1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo asian: quietly reg reported_asian_4to17_1000 treatpre1 treatpost1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo hispanic: quietly reg reported_hisp_4to17_1000 treatpre1 treatpost1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo physical: quietly reg reported_physical_4to17_1000 treatpre1 treatpost1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo neglect: quietly reg reported_neglect_4to17_1000 treatpre1 treatpost1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo sexualabuse: quietly reg reported_sxabuse_4to17_1000 treatpre1 treatpost1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
				
esttab using "${outputv2}parallel_dummy_4to17_2.tex", se label title(Parallel Trends Test (SY 19-20 vs. SY 21), Allegations, Ages 4-17) keep(treatpre1 treatpost1) scalars(Mean N r2) noobs  ///
mtitles("Black" "White" "Asian" "Hisp." "Physical" "Neglect" "Sexual Abuse") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

*------------*

* 4 to 17, substantiations

// by reporter type
eststo clear

eststo total5to17: quietly reg reported_total_4to17_sub_r treatpre2 treatpost2 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo edu5to17: quietly reg reported_edu_4to17_sub_r treatpre2 treatpost2  ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo legal: quietly reg reported_legal_4to17_sub_r treatpre2 treatpost2 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo social5to17: quietly reg reported_social_4to17_sub_r treatpre2 treatpost2 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
	
eststo medical5to17: quietly reg reported_medical_4to17_sub_r treatpre2 treatpost2 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo otherpro: quietly reg reported_pro_4to17_sub_r treatpre2 treatpost2 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
	
eststo nonpro: quietly reg reported_nonpro_4to17_sub_r treatpre2 treatpost2 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

		
esttab using "${outputv2}parallel_dummy_4to17_sub_1.tex", se label title(Parallel Trends Test (SY 19-20 vs. SY 21-22), Substantiated Allegations, Ages 4-17) keep(treatpre2 treatpost2) scalars(Mean N r2) noobs  ///
mtitles("Total" "Edu" "Legal" "Social" "Medical" "Other Pro" "Non-Pro") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

*------------*

// by race
eststo clear
	
eststo black: quietly reg reported_black_4to17_sub_r treatpre2 treatpost2 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo white: quietly reg reported_white_4to17_sub_r treatpre2 treatpost2 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo asian: quietly reg reported_asian_4to17_sub_r treatpre2 treatpost2 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo hispanic: quietly reg reported_hisp_4to17_sub_r treatpre2 treatpost2 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo physical: quietly reg reported_physical_4to17_sub_r treatpre2 treatpost2 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo neglect: quietly reg reported_neglect_4to17_sub_r treatpre2 treatpost2 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo sexualabuse: quietly reg reported_sxabuse_4to17_sub_r treatpre2 treatpost2 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
esttab using "${outputv2}parallel_dummy_4to17_sub_2.tex", se label title(Parallel Trends Test (SY 19-20 vs. SY 21-22), Substantiated Allegations, Ages 4-17) keep(treatpre2 treatpost2) scalars(Mean N r2) noobs  ///
mtitles("Black" "White" "Asian" "Hisp." "Physical" "Neglect" "Sexual Abuse") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

*------------------*

/*
// 0 to 4

eststo clear

eststo total0to4: quietly reg reported_total_0to3_1000 treatpre treatpost ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=age04_tot], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo edu0to4: quietly reg reported_edu_0to3_1000 treatpre treatpost ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=age04_tot], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
eststo social0to4: quietly reg reported_social_0to3_1000 treatpre treatpost ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=age04_tot], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo medical0to4: quietly reg reported_medical_0to3_1000 treatpre treatpost ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=age04_tot], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo black: quietly reg reported_black_0to3_1000 treatpre treatpost ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=age04_tot], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo white: quietly reg reported_white_0to3_1000 treatpre treatpost ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=age04_tot], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo asian: quietly reg reported_asian_0to3_1000 treatpre treatpost ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=age04_tot], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo hispanic: quietly reg reported_hisp_0to3_1000 treatpre treatpost ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=age04_tot], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo physical: quietly reg reported_physical_0to3_1000 treatpre treatpost ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=age04_tot], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo neglect: quietly reg reported_neglect_0to3_1000 treatpre treatpost ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=age04_tot], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)

eststo sexualabuse: quietly reg reported_sxabuse_0to3_1000 treatpre treatpost ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=age04_tot], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & year==2020 & month==2 & remote==0
		estadd scalar Mean= r(mean)
		
esttab using "${output}4to17/parallel_dummy_0to3.tex", se label title(DID regression results (SY 19-20 vs. SY 21), Allegations, Ages 0-3) keep(treatpre treatpost) scalars(Mean N r2) noobs  ///
mtitles("Total" "Edu" "Social" "Medical" "Black" "White" "Asian" "Hispanic" "Physical" "Neglect" "Sexual Abuse") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

// add 0-4 substantiated parallel test here

*/

* ************************************************************

* 2. No Anticipation - 2019/3 as treatment month (placebo test)

// placebo test - 2019/5 instead of 2020/2

gen yearmonth1 = ym(year,month)

drop if yearmonth1<704

drop if (year==2020 & month>2) | year>2020

forvalues i=704/721{
	gen ym`i'= yearmonth1==`i'

}

global event ym704##remote ym705##remote ym706##remote ym707##remote ym708##remote ym709##remote ym710##remote ym711##remote ym712##remote	///
			 ym716##remote ym717##remote ym718##remote ym719##remote ym720##remote ym721##remote 

replace ym712=0		// 2019/5
					
* 4 to 17, allegations

eststo clear

eststo total5to17: quietly reg reported_total_4to17_1000 $event  ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
								
eststo edu5to17: quietly reg reported_edu_4to17_1000 $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo legal: quietly reg reported_legal_4to17_1000 $event  ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo social5to17: quietly reg reported_social_4to17_1000 $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
eststo medical5to17: quietly reg reported_medical_4to17_1000 $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo otherpro: quietly reg reported_pro_4to17_1000 $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
eststo nonpro: quietly reg reported_nonpro_4to17_1000 $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

esttab using "${outputv2}placebo_4to17_1.tex", se label title(No Anticipation Test, Allegation, Ages 4-17) keep(0.ym712 1.ym716#1.remote 1.ym717#1.remote 1.ym718#1.remote 1.ym719#1.remote 1.ym720#1.remote 1.ym721#1.remote) scalars(N r2) noobs  ///
mtitles("Total" "Edu" "Legal" "Social" "Medical" "Other Pro" "Non-Pro") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

*------------*

eststo clear
		
eststo black: quietly reg reported_black_4to17_1000 $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
eststo white: quietly reg reported_white_4to17_1000 $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo asian: quietly reg reported_asian_4to17_1000 $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo hispanic: quietly reg reported_hisp_4to17_1000 $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo physical: quietly reg reported_physical_4to17_1000 $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo neglect: quietly reg reported_neglect_4to17_1000 $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo sexualabuse: quietly reg reported_sxabuse_4to17_1000 $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
esttab using "${outputv2}placebo_4to17_2.tex", se label title(No Anticipation Test, Allegation, Ages 4-17) keep(0.ym712 1.ym716#1.remote 1.ym717#1.remote 1.ym718#1.remote 1.ym719#1.remote 1.ym720#1.remote 1.ym721#1.remote) scalars(N r2) noobs  ///
mtitles("Black" "White" "Asian" "Hisp." "Physical" "Neglect" "Sexual Abuse") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

*------------------*
* 4 to 17, substantiated allegations

eststo clear

eststo total5to17: quietly reg reported_total_4to17_sub_r $event  ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
								
eststo edu5to17: quietly reg reported_edu_4to17_sub_r $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo legal: quietly reg reported_legal_4to17_sub_r $event  ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo social5to17: quietly reg reported_social_4to17_sub_r $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
eststo medical5to17: quietly reg reported_medical_4to17_sub_r $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo otherpro: quietly reg reported_pro_4to17_sub_r $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
eststo nonpro: quietly reg reported_nonpro_4to17_sub_r $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

esttab using "${outputv2}placebo_4to17_sub_1.tex", se label title(No Anticipation Test, Substantiation, Ages 4-17) keep(0.ym712 1.ym716#1.remote 1.ym717#1.remote 1.ym718#1.remote 1.ym719#1.remote 1.ym720#1.remote 1.ym721#1.remote) scalars(N r2) noobs  ///
mtitles("Total" "Edu" "Legal" "Social" "Medical" "Other Pro" "Non-Pro") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

*------------*

eststo clear
		
eststo black: quietly reg reported_black_4to17_sub_r $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
eststo white: quietly reg reported_white_4to17_sub_r $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo asian: quietly reg reported_asian_4to17_sub_r $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo hispanic: quietly reg reported_hisp_4to17_sub_r $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo physical: quietly reg reported_physical_4to17_sub_r $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo neglect: quietly reg reported_neglect_4to17_sub_r $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

eststo sexualabuse: quietly reg reported_sxabuse_4to17_sub_r $event ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
esttab using "${outputv2}placebo_4to17_sub_2.tex", se label title(No Anticipation Test, Substantiation, Ages 4-17) keep(0.ym712 1.ym716#1.remote 1.ym717#1.remote 1.ym718#1.remote 1.ym719#1.remote 1.ym720#1.remote 1.ym721#1.remote) scalars(N r2) noobs  ///
mtitles("Black" "White" "Asian" "Hisp." "Physical" "Neglect" "Sexual Abuse") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

* ************************************************************

* [DID]

* ************************************************************

* 0. Continuous Treatment

use "${datap}master_county_month_4to17.dta", clear

egen stategr = group(state)

egen pop5to17 = rowtotal(age513_tot age1417_tot)

*----------------------------------*

// gen per 1000
foreach var in reported_total_4to17 reported_edu_4to17 reported_legal_4to17 reported_social_4to17 reported_medical_4to17 ///
		reported_pro_4to17 reported_nonpro_4to17 reported_missing_4to17 ///
		reported_black_4to17 reported_white_4to17 reported_asian_4to17 reported_hisp_4to17 ///
		reported_physical_4to17 reported_neglect_4to17 reported_sxabuse_4to17 reported_psyemo_4to17{
			gen `var'_1000=`var'/pop5to17*1000
}

foreach var in reported_total_0to3 reported_edu_0to3 reported_legal_0to3 reported_social_0to3 reported_medical_0to3 ///
		reported_pro_0to3 reported_nonpro_0to3 reported_missing_0to3 ///
		reported_black_0to3 reported_white_0to3 reported_asian_0to3 reported_hisp_0to3 ///
		reported_physical_0to3 reported_neglect_0to3 reported_sxabuse_0to3 reported_psyemo_0to3{
			gen `var'_1000=`var'/age04_tot*1000
}

// gen per 1000 "allegations"
foreach var in reported_total_4to17 reported_edu_4to17 reported_legal_4to17 reported_social_4to17 reported_medical_4to17 ///
		reported_pro_4to17 reported_nonpro_4to17 reported_missing_4to17 ///
		reported_black_4to17 reported_white_4to17 reported_asian_4to17 reported_hisp_4to17 ///
		reported_physical_4to17 reported_neglect_4to17 reported_sxabuse_4to17 reported_psyemo_4to17{
			gen `var'_sub_r=`var'_sub/`var'*1000
}

foreach var in reported_total_0to3 reported_edu_0to3 reported_legal_0to3 reported_social_0to3 reported_medical_0to3 ///
		reported_pro_0to3 reported_nonpro_0to3 reported_missing_0to3 ///
		reported_black_0to3 reported_white_0to3 reported_asian_0to3 reported_hisp_0to3 ///
		reported_physical_0to3 reported_neglect_0to3 reported_sxabuse_0to3 reported_psyemo_0to3{
			gen `var'_sub_r=`var'_sub/`var'*1000
}

// logged

foreach var in reported_4to17 reported_edu_4to17 reported_social_4to17 reported_medical_4to17 ///
		reported_black_4to17 reported_white_4to17 reported_hisp_4to17 reported_asian_4to17 ///
		reported_physical_4to17 reported_neglect_4to17 reported_neglectmed_4to17 reported_sxabuse_4to17 reported_psyemo_4to17{
			gen `var'_1000l=ln(`var'_1000+1)
}

foreach var in reported_0to3 reported_edu_0to3 reported_social_0to3 reported_medical_0to3 ///
		reported_black_0to3 reported_white_0to3 reported_hisp_0to3 reported_asian_0to3 ///
		reported_physical_0to3 reported_neglect_0to3 reported_neglectmed_0to3 reported_sxabuse_0to3 reported_psyemo_0to3{
			gen `var'_1000l=ln(`var'_1000+1)
}


/*
// gen per 1000 "children"
foreach var in reported_total_4to17 reported_edu_4to17 reported_nonedu_4to17 reported_nonpro_4to17 reported_legal_4to17 reported_social_4to17 reported_medical_4to17 ///
		reported_black_4to17 reported_white_4to17 reported_hisp_4to17 reported_asian_4to17 ///
		reported_physical_4to17 reported_neglect_4to17 reported_sxabuse_4to17{
			gen `var'_sub_c=`var'_sub/pop5to17*1000
}

foreach var in reported_total_0to3 reported_edu_0to3 reported_nonedu_0to3 reported_nonpro_0to3 reported_legal_0to3 reported_social_0to3 reported_medical_0to3 ///
		reported_black_0to3 reported_white_0to3 reported_hisp_0to3 reported_asian_0to3 ///
		reported_physical_0to3 reported_neglect_0to3 reported_sxabuse_0to3{
			gen `var'_sub_c=`var'_sub/age04_tot*1000
}
*/
		
gen post1 = 1 if (year == 2020 & inrange(month, 9, 12)) | (year == 2021 & inrange(month, 1, 5))
replace post1 = 0 if (year == 2018 & inrange(month, 9, 12)) | (year == 2019 & inrange(month, 1, 5)) | ///
			(year == 2019 & inrange(month, 9, 12)) | (year == 2020 & inrange(month, 1, 2))

gen post2 = 1 if (year == 2020 & inrange(month, 9, 12)) | (year == 2021 & inrange(month, 1, 5)) | ///
				(year == 2021 & inrange(month, 9, 12)) | (year == 2022 & inrange(month, 1, 5))
replace post2 = 0 if (year == 2018 & inrange(month, 9, 12)) | (year == 2019 & inrange(month, 1, 5)) | ///
			(year == 2019 & inrange(month, 9, 12)) | (year == 2020 & inrange(month, 1, 2))

gen pre1 = 1 if (year == 2018 & inrange(month, 9, 12)) | (year == 2019 & inrange(month, 1, 5)) | ///
			(year == 2019 & inrange(month, 9, 12)) | (year == 2020 & month==1)
replace pre1 = 0 if (year==2020 & month==2) | (year == 2020 & inrange(month, 9, 12)) | (year == 2021 & inrange(month, 1, 5))

gen pre2 = 1 if (year == 2018 & inrange(month, 9, 12)) | (year == 2019 & inrange(month, 1, 5)) | ///
			(year == 2019 & inrange(month, 9, 12)) | (year == 2020 & month==1)
replace pre2 = 0 if (year==2020 & month==2) | (year == 2020 & inrange(month, 9, 12)) | (year == 2021 & inrange(month, 1, 5)) | ///
				(year == 2021 & inrange(month, 9, 12)) | (year == 2022 & inrange(month, 1, 5))


// dummy

drop if missing(remote2016f)

gen remote = 1 if remote2016f==2
replace remote = 0 if remote2016f==1

gen treatpost1 = remote*post1
gen treatpost2 = remote*post2

gen treatpre1 = remote*pre1
gen treatpre2 = remote*pre2


// quantile

forvalues i=1/4{
	gen quantile`i'= quantile2016f==`i'
}

forvalues i=1/4{
	gen q`i'post1=quantile`i'*post1
	gen q`i'post2=quantile`i'*post2
}

// continuous

replace prop_remote_2021 = prop_remote_2021*2	// convert it to 50pp increment

gen treatpost1_cont = prop_remote_2021*post1
gen treatpost2_cont = prop_remote_2021*post2

gen treatpre1_cont = prop_remote_2021*pre1
gen treatpre2_cont = prop_remote_2021*pre2

*------------*

replace covid_case = 0 if missing(covid_case)
replace covid_death = 0 if missing(covid_death)


/* add blue state indicator
gen blue = 1 if stateabbr=="WA" | stateabbr=="OR" | stateabbr=="CA" | stateabbr=="NV" |	///
				stateabbr=="CO" | stateabbr=="NM" | stateabbr=="MN" | stateabbr=="WI" | stateabbr=="MI" | stateabbr=="IL" | ///
				stateabbr=="PA" | stateabbr=="NY" | stateabbr=="VT" | stateabbr=="NH" | stateabbr=="ME" | ///
				stateabbr=="MA" | stateabbr=="RI" | stateabbr=="CT" | stateabbr=="NJ" | stateabbr=="DE" | stateabbr=="MD" | stateabbr=="DC" | ///
				stateabbr=="VA" | stateabbr=="HI"	//24
replace blue = 0.5 if stateabbr=="IA" | stateabbr=="OH" | stateabbr=="FL"	//3
replace blue = 0 if stateabbr=="AK" | ///
					stateabbr=="ID" | stateabbr=="MT" | stateabbr=="ND" | stateabbr=="SD" | stateabbr=="WY"	| ///
					stateabbr=="UT" | stateabbr=="AZ" | stateabbr=="NE" | stateabbr=="KS" | stateabbr=="OK"	| ///
					stateabbr=="TX" | stateabbr=="MO" | stateabbr=="AR" | stateabbr=="LA" | stateabbr=="MS"	| ///
					stateabbr=="IN" | stateabbr=="KY" | stateabbr=="WV" | stateabbr=="TN" | stateabbr=="NC"	| ///
					stateabbr=="SC" | stateabbr=="AL" | stateabbr=="GA" //24
*/					
// 4 to 17, allegations

eststo clear

eststo total5to17: quietly reg reported_total_4to17_1000 treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)

eststo edu5to17: quietly reg reported_edu_4to17_1000 treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)

eststo legal: quietly reg reported_legal_4to17_1000 treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)

eststo social5to17: quietly reg reported_social_4to17_1000 treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
	
eststo medical5to17: quietly reg reported_medical_4to17_1000 treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
eststo otherpro: quietly reg reported_pro_4to17_1000 treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
	
eststo nonpro: quietly reg reported_nonpro_4to17_1000 treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)


esttab using "${outputv2}did_2019_2021_cluster_4to17_cont_1.tex", se label title(DID regression results (SY 19-20 vs. SY 21), Allegations with Continuous Treatment, Ages 4-17) keep(treatpost1_cont) scalars(Mean N r2) noobs  ///
mtitles("Total" "Edu" "Legal" "Social" "Medical" "Other Pro" "Non-Pro") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

*--------------*

eststo clear

eststo black: quietly reg reported_black_4to17_1000 treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
eststo white: quietly reg reported_white_4to17_1000 treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
eststo asian: quietly reg reported_asian_4to17_1000 treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
eststo hispanic: quietly reg reported_hisp_4to17_1000 treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
eststo physical: quietly reg reported_physical_4to17_1000 treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
eststo neglect: quietly reg reported_neglect_4to17_1000 treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
eststo sexualabuse: quietly reg reported_sxabuse_4to17_1000 treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
esttab using "${outputv2}did_2019_2021_cluster_4to17_cont_2.tex", se label title(DID regression results (SY 19-20 vs. SY 21), Allegations with Continuous Treatment, Ages 4-17) keep(treatpost1_cont) scalars(Mean N r2) noobs  ///
mtitles("Black" "White" "Asian" "Hisp." "Physical" "Neglect" "Sexual Abuse") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace


*------------------*

// 4 to 17, substantiations

eststo clear

eststo total5to17: quietly reg reported_total_4to17_sub_r treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)

eststo edu5to17: quietly reg reported_edu_4to17_sub_r treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)

eststo legal: quietly reg reported_legal_4to17_sub_r treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)

eststo social5to17: quietly reg reported_social_4to17_sub_r treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
	
eststo medical5to17: quietly reg reported_medical_4to17_sub_r treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
eststo otherpro: quietly reg reported_pro_4to17_sub_r treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
	
eststo nonpro: quietly reg reported_nonpro_4to17_sub_r treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)


esttab using "${outputv2}did_2019_2021_cluster_4to17_cont_sub_1.tex", se label title(DID regression results (SY 19-20 vs. SY 21), Allegations with Continuous Treatment, Ages 4-17) keep(treatpost1_cont) scalars(Mean N r2) noobs  ///
mtitles("Total" "Edu" "Legal" "Social" "Medical" "Other Pro" "Non-Pro") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

*--------------*

eststo clear

eststo black: quietly reg reported_black_4to17_sub_r treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
eststo white: quietly reg reported_white_4to17_sub_r treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
eststo asian: quietly reg reported_asian_4to17_sub_r treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
eststo hispanic: quietly reg reported_hisp_4to17_sub_r treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
eststo physical: quietly reg reported_physical_4to17_sub_r treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
eststo neglect: quietly reg reported_neglect_4to17_sub_r treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
eststo sexualabuse: quietly reg reported_sxabuse_4to17_sub_r treatpost1_cont ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post1==0 & prop_remote_2021==0
		estadd scalar Mean= r(mean)
		
esttab using "${outputv2}did_2019_2021_cluster_4to17_cont_sub_2.tex", se label title(DID regression results (SY 19-20 vs. SY 21), Allegations with Continuous Treatment, Ages 4-17) keep(treatpost1_cont) scalars(Mean N r2) noobs  ///
mtitles("Black" "White" "Asian" "Hisp." "Physical" "Neglect" "Sexual Abuse") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

* ************************************************************

* 1. COUNTY-MONTH

use "${datap}master_county_month_4to17.dta", clear

egen stategr = group(state)

egen pop5to17 = rowtotal(age513_tot age1417_tot)

*----------------------------------*

// gen per 1000
foreach var in reported_total_4to17 reported_edu_4to17 reported_legal_4to17 reported_social_4to17 reported_medical_4to17 ///
		reported_pro_4to17 reported_nonpro_4to17 reported_missing_4to17 ///
		reported_black_4to17 reported_white_4to17 reported_asian_4to17 reported_hisp_4to17 ///
		reported_physical_4to17 reported_neglect_4to17 reported_sxabuse_4to17 reported_psyemo_4to17{
			gen `var'_1000=`var'/pop5to17*1000
}

foreach var in reported_total_0to3 reported_edu_0to3 reported_legal_0to3 reported_social_0to3 reported_medical_0to3 ///
		reported_pro_0to3 reported_nonpro_0to3 reported_missing_0to3 ///
		reported_black_0to3 reported_white_0to3 reported_asian_0to3 reported_hisp_0to3 ///
		reported_physical_0to3 reported_neglect_0to3 reported_sxabuse_0to3 reported_psyemo_0to3{
			gen `var'_1000=`var'/age04_tot*1000
}

// gen per 1000 "allegations"
foreach var in reported_total_4to17 reported_edu_4to17 reported_legal_4to17 reported_social_4to17 reported_medical_4to17 ///
		reported_pro_4to17 reported_nonpro_4to17 reported_missing_4to17 ///
		reported_black_4to17 reported_white_4to17 reported_asian_4to17 reported_hisp_4to17 ///
		reported_physical_4to17 reported_neglect_4to17 reported_sxabuse_4to17 reported_psyemo_4to17{
			gen `var'_sub_r=`var'_sub/`var'*1000
}

foreach var in reported_total_0to3 reported_edu_0to3 reported_legal_0to3 reported_social_0to3 reported_medical_0to3 ///
		reported_pro_0to3 reported_nonpro_0to3 reported_missing_0to3 ///
		reported_black_0to3 reported_white_0to3 reported_asian_0to3 reported_hisp_0to3 ///
		reported_physical_0to3 reported_neglect_0to3 reported_sxabuse_0to3 reported_psyemo_0to3{
			gen `var'_sub_r=`var'_sub/`var'*1000
}

/*
// gen per 1000 "children"
foreach var in reported_total_4to17 reported_edu_4to17 reported_nonedu_4to17 reported_nonpro_4to17 reported_legal_4to17 reported_social_4to17 reported_medical_4to17 ///
		reported_black_4to17 reported_white_4to17 reported_hisp_4to17 reported_asian_4to17 ///
		reported_physical_4to17 reported_neglect_4to17 reported_sxabuse_4to17{
			gen `var'_sub_c=`var'_sub/pop5to17*1000
}

foreach var in reported_total_0to3 reported_edu_0to3 reported_nonedu_0to3 reported_nonpro_0to3 reported_legal_0to3 reported_social_0to3 reported_medical_0to3 ///
		reported_black_0to3 reported_white_0to3 reported_hisp_0to3 reported_asian_0to3 ///
		reported_physical_0to3 reported_neglect_0to3 reported_sxabuse_0to3{
			gen `var'_sub_c=`var'_sub/age04_tot*1000
}
*/
		
gen post1 = 1 if (year == 2020 & inrange(month, 9, 12)) | (year == 2021 & inrange(month, 1, 5))
replace post1 = 0 if (year == 2018 & inrange(month, 9, 12)) | (year == 2019 & inrange(month, 1, 5)) | ///
			(year == 2019 & inrange(month, 9, 12)) | (year == 2020 & inrange(month, 1, 2))

gen post2 = 1 if (year == 2020 & inrange(month, 9, 12)) | (year == 2021 & inrange(month, 1, 5)) | ///
				(year == 2021 & inrange(month, 9, 12)) | (year == 2022 & inrange(month, 1, 5))
replace post2 = 0 if (year == 2018 & inrange(month, 9, 12)) | (year == 2019 & inrange(month, 1, 5)) | ///
			(year == 2019 & inrange(month, 9, 12)) | (year == 2020 & inrange(month, 1, 2))

gen pre1 = 1 if (year == 2018 & inrange(month, 9, 12)) | (year == 2019 & inrange(month, 1, 5)) | ///
			(year == 2019 & inrange(month, 9, 12)) | (year == 2020 & month==1)
replace pre1 = 0 if (year==2020 & month==2) | (year == 2020 & inrange(month, 9, 12)) | (year == 2021 & inrange(month, 1, 5))

gen pre2 = 1 if (year == 2018 & inrange(month, 9, 12)) | (year == 2019 & inrange(month, 1, 5)) | ///
			(year == 2019 & inrange(month, 9, 12)) | (year == 2020 & month==1)
replace pre2 = 0 if (year==2020 & month==2) | (year == 2020 & inrange(month, 9, 12)) | (year == 2021 & inrange(month, 1, 5)) | ///
				(year == 2021 & inrange(month, 9, 12)) | (year == 2022 & inrange(month, 1, 5))


// dummy

drop if missing(remote2016f)

gen remote = 1 if remote2016f==2
replace remote = 0 if remote2016f==1

gen treatpost1 = remote*post1
gen treatpost2 = remote*post2

gen treatpre1 = remote*pre1
gen treatpre2 = remote*pre2


// quantile

forvalues i=1/4{
	gen quantile`i'= quantile2016f==`i'
}

forvalues i=1/4{
	gen q`i'post1=quantile`i'*post1
	gen q`i'post2=quantile`i'*post2
}

// continuous

replace prop_remote_2021 = prop_remote_2021*50	// convert it to 50pp increment

gen treatpost1_cont = prop_remote_2021*post1
gen treatpost2_cont = prop_remote_2021*post2

gen treatpre1_cont = prop_remote_2021*pre1
gen treatpre2_cont = prop_remote_2021*pre2

*------------*

replace covid_case = 0 if missing(covid_case)
replace covid_death = 0 if missing(covid_death)

*----------------------------------*
**# Bookmark #4

* 0) pre-pandemic vs. full-remote

gen post0 = 1 if (year == 2020 & inrange(month, 3, 8))
replace post0 = 0 if (year == 2019 & inrange(month, 9, 12)) | (year == 2020 & inrange(month, 1, 2))

// 5 to 17

eststo clear

eststo total: quietly reg reported_total_4to17_1000 i.post0 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post0==0
		estadd scalar Mean= r(mean)

eststo edu: quietly reg reported_edu_4to17_1000 i.post0 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post0==0
		estadd scalar Mean= r(mean)

eststo legal: quietly reg reported_legal_4to17_1000 i.post0 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post0==0
		estadd scalar Mean= r(mean)

eststo social: quietly reg reported_social_4to17_1000 i.post0 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post0==0
		estadd scalar Mean= r(mean)

eststo medical: quietly reg reported_medical_4to17_1000 i.post0 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post0==0
		estadd scalar Mean= r(mean)
		
eststo otherpro: quietly reg reported_pro_4to17_1000 i.post0 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post0==0
		estadd scalar Mean= r(mean)

eststo nonpro: quietly reg reported_nonpro_4to17_1000 i.post0 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post0==0
		estadd scalar Mean= r(mean)
		
esttab using "${outputv2}post_cluster_4to17_1.tex", se label title(Parallel Trends Test (SY 19-20 vs. SY 21), Allegation, Ages 4-17) keep(1.post0) scalars(Mean N r2) noobs  ///
mtitles("Total" "Edu" "Legal" "Social" "Medical" "Other Pro" "Non-Pro") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

*------------*
	
eststo clear

eststo black: quietly reg reported_black_4to17_1000 i.post0 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post0==0
		estadd scalar Mean= r(mean)

eststo white: quietly reg reported_white_4to17_1000 i.post0 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post0==0
		estadd scalar Mean= r(mean)

eststo asian: quietly reg reported_asian_4to17_1000 i.post0 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post0==0
		estadd scalar Mean= r(mean)

eststo hispanic: quietly reg reported_hisp_4to17_1000 i.post0 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post0==0
		estadd scalar Mean= r(mean)
		
eststo physical: quietly reg reported_physical_4to17_1000 i.post0 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post0==0
		estadd scalar Mean= r(mean)

eststo neglect: quietly reg reported_neglect_4to17_1000 i.post0 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post0==0
		estadd scalar Mean= r(mean)

eststo sexualabuse: quietly reg reported_sxabuse_4to17_1000 i.post0 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post0==0
		estadd scalar Mean= r(mean)
				
esttab using "${outputv2}post_cluster_4to17_2.tex", se label title(Parallel Trends Test (SY 19-20 vs. SY 21), Allegation, Ages 4-17) keep(1.post0) scalars(Mean N r2) noobs  ///
mtitles("Black" "White" "Asian" "Hisp." "Physical" "Neglect" "Sexual Abuse") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

*----------------------------------*
*----------------------------------*

* 1) pre-pandemic vs. blended learning (prop_remote variation)

* 4 to 17, allegations

eststo clear

eststo total5to17: quietly reg reported_total_4to17_1000 remote##post1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post1==0 & remote==1
		estadd scalar Mean= r(mean)
		
eststo edu5to17: quietly reg reported_edu_4to17_1000 remote##post1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & remote==1
		estadd scalar Mean= r(mean)

eststo legal: quietly reg reported_legal_4to17_1000 remote##post1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & remote==1
		estadd scalar Mean= r(mean)

eststo social5to17: quietly reg reported_social_4to17_1000 remote##post1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & remote==1
		estadd scalar Mean= r(mean)
		
eststo medical5to17: quietly reg reported_medical_4to17_1000 remote##post1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & post1==0 & remote==1
		estadd scalar Mean= r(mean)
	
eststo otherpro: quietly reg reported_pro_4to17_1000 remote##post1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & remote==1
		estadd scalar Mean= r(mean)
		
eststo nonpro: quietly reg reported_nonpro_4to17_1000 remote##post1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
	
		qui sum `e(depvar)' if e(sample) & post1==0 & remote==1
		estadd scalar Mean= r(mean)

esttab using "${outputv2}did_2019_2021_cluster_4to17_1.tex", se label title(DID regression results (SY 19-20 vs. SY 21), Allegation, Ages 4-17) keep(1.remote#1.post1) scalars(Mean N r2) noobs  ///
mtitles("Total" "Edu" "Legal" "Social" "Medical" "Other Pro" "Non-Pro") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

*----------------*

eststo clear
		
eststo black: quietly reg reported_black_4to17_1000 remote##post1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & remote==1
		estadd scalar Mean= r(mean)
		
eststo white: quietly reg reported_white_4to17_1000 remote##post1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & remote==1
		estadd scalar Mean= r(mean)

eststo asian: quietly reg reported_asian_4to17_1000 remote##post1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & remote==1
		estadd scalar Mean= r(mean)

eststo hispanic: quietly reg reported_hisp_4to17_1000 remote##post1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		qui sum `e(depvar)' if e(sample) & post1==0 & remote==1
		estadd scalar Mean= r(mean)

eststo physical: quietly reg reported_physical_4to17_1000 remote##post1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post1==0 & remote==1
		estadd scalar Mean= r(mean)

eststo neglect: quietly reg reported_neglect_4to17_1000 remote##post1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post1==0 & remote==1
		estadd scalar Mean= r(mean)

eststo sexualabuse: quietly reg reported_sxabuse_4to17_1000 remote##post1 ///
		c.unemp c.lfp ///
		c.poverty_percent c.hhincome_med	///
		c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
		c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
		c.covid_case c.covid_death ///
		i.countyfips i.yearmonth ///
		if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)
		
		qui sum `e(depvar)' if e(sample) & post1==0 & remote==1
		estadd scalar Mean= r(mean)
		
esttab using "${outputv2}did_2019_2021_cluster_4to17_2.tex", se label title(DID regression results (SY 19-20 vs. SY 21), Allegation, Ages 4-17) keep(1.remote#1.post1) scalars(Mean N r2) noobs  ///
mtitles("Black" "White" "Asian" "Hisp." "Physical" "Neglect" "Sexual Abuse") addnote("Source") star(* 0.10 ** 0.05 *** 0.01) replace

* ************************************************************

* [EVENT STUDY]

* ************************************************************

* 1. COUNTY-MONTH

use "${datap}master_county_month_4to17.dta", clear

egen stategr = group(state)

egen pop5to17 = rowtotal(age513_tot age1417_tot)

*----------------------------------*

// gen per 1000
foreach var in reported_total_4to17 reported_edu_4to17 reported_nonedu_4to17 reported_nonpro_4to17 reported_legal_4to17 reported_social_4to17 reported_medical_4to17 ///
		reported_black_4to17 reported_white_4to17 reported_hisp_4to17 reported_asian_4to17 ///
		reported_physical_4to17 reported_neglect_4to17 reported_sxabuse_4to17{
			gen `var'_1000=`var'/pop5to17*1000
}

foreach var in reported_total_0to3 reported_edu_0to3 reported_nonedu_0to3 reported_nonpro_0to3 reported_legal_0to3 reported_social_0to3 reported_medical_0to3 ///
		reported_black_0to3 reported_white_0to3 reported_hisp_0to3 reported_asian_0to3 ///
		reported_physical_0to3 reported_neglect_0to3 reported_sxabuse_0to3{
			gen `var'_1000=`var'/age04_tot*1000
}

// gen per 1000 "allegations"
foreach var in reported_total_4to17 reported_edu_4to17 reported_nonedu_4to17 reported_nonpro_4to17 reported_legal_4to17 reported_social_4to17 reported_medical_4to17 ///
		reported_black_4to17 reported_white_4to17 reported_hisp_4to17 reported_asian_4to17 ///
		reported_physical_4to17 reported_neglect_4to17 reported_sxabuse_4to17{
			gen `var'_sub_r=`var'_sub/`var'*1000
}

foreach var in reported_total_0to3 reported_edu_0to3 reported_nonedu_0to3 reported_nonpro_0to3 reported_legal_0to3 reported_social_0to3 reported_medical_0to3 ///
		reported_black_0to3 reported_white_0to3 reported_hisp_0to3 reported_asian_0to3 ///
		reported_physical_0to3 reported_neglect_0to3 reported_sxabuse_0to3{
			gen `var'_sub_r=`var'_sub/`var'*1000
}

// gen per 1000 "children"
foreach var in reported_total_4to17 reported_edu_4to17 reported_nonedu_4to17 reported_nonpro_4to17 reported_legal_4to17 reported_social_4to17 reported_medical_4to17 ///
		reported_black_4to17 reported_white_4to17 reported_hisp_4to17 reported_asian_4to17 ///
		reported_physical_4to17 reported_neglect_4to17 reported_sxabuse_4to17{
			gen `var'_sub_c=`var'_sub/pop5to17*1000
}

foreach var in reported_total_0to3 reported_edu_0to3 reported_nonedu_0to3 reported_nonpro_0to3 reported_legal_0to3 reported_social_0to3 reported_medical_0to3 ///
		reported_black_0to3 reported_white_0to3 reported_hisp_0to3 reported_asian_0to3 ///
		reported_physical_0to3 reported_neglect_0to3 reported_sxabuse_0to3{
			gen `var'_sub_c=`var'_sub/age04_tot*1000
}

		
gen post1 = 1 if (year == 2020 & inrange(month, 9, 12)) | (year == 2021 & inrange(month, 1, 5))
replace post1 = 0 if year==2020 & month==2
gen post2 = 1 if (year == 2020 & inrange(month, 9, 12)) | (year == 2021 & inrange(month, 1, 5)) | ///
				(year == 2021 & inrange(month, 9, 12)) | (year == 2022 & inrange(month, 1, 5))
replace post2 = 0 if year==2020 & month==2

gen pre = 1 if (year == 2018 & inrange(month, 9, 12)) | (year == 2019 & inrange(month, 1, 5)) | ///
			(year == 2019 & inrange(month, 9, 12)) | (year == 2020 & month==1)
replace pre = 0 if year==2020 & month==2


// dummy

drop if missing(remote2016f)

gen remote = 1 if remote2016f==2
replace remote = 0 if remote2016f==1

gen treatpre = remote*pre
gen treatpost1 = remote*post1
gen treatpost2 = remote*post2

// quantile

forvalues i=1/4{
	gen quantile`i'= quantile2016f==`i'
}

forvalues i=1/4{
	gen q`i'post1=quantile`i'*post1
	gen q`i'post2=quantile`i'*post2
}

// continuous

replace prop_remote_2021 = prop_remote_2021*50	// convert it to 50pp increment

gen treatpre_cont = prop_remote_2021*pre
gen treatpost1_cont = prop_remote_2021*post1
gen treatpost2_cont = prop_remote_2021*post2

*------------*

replace covid_case = 0 if missing(covid_case)
replace covid_death = 0 if missing(covid_death)

*------------*

gen yearmonth1 = ym(year,month)

drop if yearmonth1<704

drop if year==2022 & month>5

forvalues i=704/748{
	gen ym`i'= yearmonth1==`i'

}

replace ym721=0		// omit 2020/2 (reference month)

*----------------------------------*

// 2018/9 ~ 2022/5

// 4 to 17


global event ym704##remote ym705##remote ym706##remote ym707##remote ym708##remote ym709##remote ym710##remote ym711##remote ym712##remote	///
			 ym713##remote ym714##remote ym715##remote	///
			 ym716##remote ym717##remote ym718##remote ym719##remote ym720##remote ym721##remote ym722##remote ym723##remote ym724##remote	///
			 ym725##remote ym726##remote ym727##remote	///
			 ym728##remote ym729##remote ym730##remote ym731##remote ym732##remote ym733##remote ym734##remote ym735##remote ym736##remote 	///
			 ym737##remote ym738##remote ym739##remote	///
			 ym740##remote ym741##remote ym742##remote ym743##remote ym744##remote ym745##remote ym746##remote ym747##remote ym748##remote 
			
foreach x in reported_total_4to17 reported_edu_4to17 reported_legal_4to17 reported_social_4to17 reported_medical_4to17 ///
		reported_black_4to17 reported_white_4to17 reported_asian_4to17 reported_hisp_4to17 ///
		reported_physical_4to17 reported_neglect_4to17 reported_sxabuse_4to17{

		eststo clear
		
		eststo allegation: reg `x'_1000 $event ///
			c.unemp c.lfp ///
			c.poverty_percent c.hhincome_med	///
			c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
			c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
			c.covid_case c.covid_death ///
			i.countyfips  ///
			if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		coefplot allegation, bylabel(A) vertical omitted drop(_cons) ///
			keep( ///
			0.ym721	///
			1.ym704#1.remote 1.ym705#1.remote 1.ym706#1.remote 1.ym707#1.remote 1.ym708#1.remote 1.ym709#1.remote 1.ym710#1.remote 1.ym711#1.remote 1.ym712#1.remote ///
			1.ym716#1.remote 1.ym717#1.remote 1.ym718#1.remote 1.ym719#1.remote	1.ym720#1.remote 1.ym722#1.remote 1.ym723#1.remote 1.ym724#1.remote ///
			1.ym728#1.remote 1.ym729#1.remote 1.ym730#1.remote 1.ym731#1.remote 1.ym732#1.remote 1.ym733#1.remote 1.ym734#1.remote 1.ym735#1.remote 1.ym736#1.remote ///
			1.ym740#1.remote 1.ym741#1.remote 1.ym742#1.remote 1.ym743#1.remote 1.ym744#1.remote 1.ym745#1.remote 1.ym746#1.remote 1.ym747#1.remote 1.ym748#1.remote) /// 
			ciopts(recast(rcap)) name(Graph, replace) ytitle(β(`x'/1,000)) yline(0) ///
			xline(10, lpattern(dash))  /// 
			xline(15, lpattern(dash) lcolor(red))	///
			xline(19, lpattern(dash))  /// 
			xline(28, lpattern(dash))  /// 
			coeflabels( ///
			1.ym704#1.remote = "2018/9" 1.ym716#1.remote = "2019/9"	///
			0.ym721 = "2020/2" 1.ym728#1.remote = "2020/9" ///
			1.ym740#1.remote = "2021/9")	///
			legend(order(1 "95% Confidence intervals") pos(6))

		graph save "Graph" "${outputv2}2019_2022_event_allegation_`x'.gph", replace
		//graph export "${output}graph/event_allegation_`x'.pdf", as(pdf) name("Graph") replace

		}

		
foreach x in reported_total_4to17_sub reported_edu_4to17_sub reported_legal_4to17_sub reported_social_4to17_sub reported_medical_4to17_sub  ///
	reported_black_4to17_sub reported_white_4to17_sub reported_asian_4to17_sub reported_hisp_4to17_sub ///
	reported_physical_4to17_sub reported_neglect_4to17_sub reported_sxabuse_4to17_sub{

		eststo clear
		
		
		eststo allegation: reg `x'_r $event ///
			c.unemp c.lfp ///
			c.poverty_percent c.hhincome_med	///
			c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
			c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
			c.covid_case c.covid_death ///
			i.countyfips  ///
			if stateabbr!="XX" [w=pop5to17], vce(cluster stategr)

		coefplot allegation, bylabel(A) vertical omitted drop(_cons) ///
			keep( ///
			0.ym721	///
			1.ym704#1.remote 1.ym705#1.remote 1.ym706#1.remote 1.ym707#1.remote 1.ym708#1.remote 1.ym709#1.remote 1.ym710#1.remote 1.ym711#1.remote 1.ym712#1.remote ///
			1.ym716#1.remote 1.ym717#1.remote 1.ym718#1.remote 1.ym719#1.remote	1.ym720#1.remote 1.ym722#1.remote 1.ym723#1.remote 1.ym724#1.remote ///
			1.ym728#1.remote 1.ym729#1.remote 1.ym730#1.remote 1.ym731#1.remote 1.ym732#1.remote 1.ym733#1.remote 1.ym734#1.remote 1.ym735#1.remote 1.ym736#1.remote ///
			1.ym740#1.remote 1.ym741#1.remote 1.ym742#1.remote 1.ym743#1.remote 1.ym744#1.remote 1.ym745#1.remote 1.ym746#1.remote 1.ym747#1.remote 1.ym748#1.remote) /// 
			ciopts(recast(rcap)) name(Graph, replace) ytitle(β(`x'/1,000)) yline(0) ///
			xline(10, lpattern(dash))  /// 
			xline(15, lpattern(dash) lcolor(red))	///
			xline(19, lpattern(dash))  /// 
			xline(28, lpattern(dash))  /// 
			coeflabels( ///
			1.ym704#1.remote = "2018/9" 1.ym716#1.remote = "2019/9"	///
			0.ym721 = "2020/2" 1.ym728#1.remote = "2020/9" ///
			1.ym740#1.remote = "2021/9")	///
			legend(order(1 "95% Confidence intervals") pos(6))

		graph save "Graph" "${outputv2}2019_2022_event_allegation_`x'.gph", replace
		//graph export "${output}graph/event_allegation_`x'.pdf", as(pdf) name("Graph") replace

		}

// 0 to 3
			 
foreach x in reported_total_0to3 reported_edu_0to3 reported_legal_0to3 reported_social_0to3 reported_medical_0to3 ///
		reported_black_0to3 reported_white_0to3 reported_asian_0to3 reported_hisp_0to3  ///
		reported_physical_0to3 reported_neglect_0to3 reported_sxabuse_0to3{
		
		eststo clear

		eststo allegation: reg `x'_1000 $event ///
			c.unemp c.lfp ///
			c.poverty_percent c.hhincome_med	///
			c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
			c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
			c.covid_case c.covid_death ///
			i.countyfips  ///
			if stateabbr!="XX" [w=age04_tot], vce(cluster stategr)

		coefplot allegation, bylabel(A) vertical omitted drop(_cons) ///
			keep( ///
			0.ym721	///
			1.ym704#1.remote 1.ym705#1.remote 1.ym706#1.remote 1.ym707#1.remote 1.ym708#1.remote 1.ym709#1.remote 1.ym710#1.remote 1.ym711#1.remote 1.ym712#1.remote ///
			1.ym716#1.remote 1.ym717#1.remote 1.ym718#1.remote 1.ym719#1.remote	1.ym720#1.remote 1.ym722#1.remote 1.ym723#1.remote 1.ym724#1.remote ///
			1.ym728#1.remote 1.ym729#1.remote 1.ym730#1.remote 1.ym731#1.remote 1.ym732#1.remote 1.ym733#1.remote 1.ym734#1.remote 1.ym735#1.remote 1.ym736#1.remote ///
			1.ym740#1.remote 1.ym741#1.remote 1.ym742#1.remote 1.ym743#1.remote 1.ym744#1.remote 1.ym745#1.remote 1.ym746#1.remote 1.ym747#1.remote 1.ym748#1.remote) /// 
			ciopts(recast(rcap)) name(Graph, replace) ytitle(β(`x'/1,000)) yline(0) ///
			xline(10, lpattern(dash))  /// 
			xline(15, lpattern(dash) lcolor(red))	///
			xline(19, lpattern(dash))  /// 
			xline(28, lpattern(dash))  /// 
			coeflabels( ///
			1.ym704#1.remote = "2018/9" 1.ym716#1.remote = "2019/9"	///
			0.ym721 = "2020/2" 1.ym728#1.remote = "2020/9" ///
			1.ym740#1.remote = "2021/9")	///
			legend(order(1 "95% Confidence intervals") pos(6))
	
	graph save "Graph" "${outputv2}2019_2022_event_allegation_`x'.gph", replace
	//graph export "${output}graph/event_allegation_`x'.pdf", as(pdf) name("Graph") replace

	}

			 
foreach x in reported_total_0to3_sub reported_edu_0to3_sub reported_legal_0to3_sub reported_social_0to3_sub reported_medical_0to3_sub  ///
	reported_black_0to3_sub reported_white_0to3_sub reported_hisp_0to3_sub reported_asian_0to3_sub  ///
	reported_physical_0to3_sub reported_neglect_0to3_sub reported_sxabuse_0to3_sub{
		
		eststo clear

		eststo allegation: reg `x'_r $event ///
			c.unemp c.lfp ///
			c.poverty_percent c.hhincome_med	///
			c.pop_white c.pop_black c.pop_asian c.pop_hispanic	///
			c.pop_0to19 c.pop_20to24 c.pop_25to34 c.pop_35to44 c.pop_45to54 c.pop_55to64 c.pop_female	///
			c.covid_case c.covid_death ///
			i.countyfips  ///
			if stateabbr!="XX" [w=age04_tot], vce(cluster stategr)

		coefplot allegation, bylabel(A) vertical omitted drop(_cons) ///
			keep( ///
			0.ym721	///
			1.ym704#1.remote 1.ym705#1.remote 1.ym706#1.remote 1.ym707#1.remote 1.ym708#1.remote 1.ym709#1.remote 1.ym710#1.remote 1.ym711#1.remote 1.ym712#1.remote ///
			1.ym716#1.remote 1.ym717#1.remote 1.ym718#1.remote 1.ym719#1.remote	1.ym720#1.remote 1.ym722#1.remote 1.ym723#1.remote 1.ym724#1.remote ///
			1.ym728#1.remote 1.ym729#1.remote 1.ym730#1.remote 1.ym731#1.remote 1.ym732#1.remote 1.ym733#1.remote 1.ym734#1.remote 1.ym735#1.remote 1.ym736#1.remote ///
			1.ym740#1.remote 1.ym741#1.remote 1.ym742#1.remote 1.ym743#1.remote 1.ym744#1.remote 1.ym745#1.remote 1.ym746#1.remote 1.ym747#1.remote 1.ym748#1.remote) /// 
			ciopts(recast(rcap)) name(Graph, replace) ytitle(β(`x'/1,000)) yline(0) ///
			xline(10, lpattern(dash))  /// 
			xline(15, lpattern(dash) lcolor(red))	///
			xline(19, lpattern(dash))  /// 
			xline(28, lpattern(dash))  /// 
			coeflabels( ///
			1.ym704#1.remote = "2018/9" 1.ym716#1.remote = "2019/9"	///
			0.ym721 = "2020/2" 1.ym728#1.remote = "2020/9" ///
			1.ym740#1.remote = "2021/9")	///
			legend(order(1 "95% Confidence intervals") pos(6))
	
	graph save "Graph" "${outputv2}2019_2022_event_allegation_`x'.gph", replace
	//graph export "${output}graph/event_allegation_`x'.pdf", as(pdf) name("Graph") replace

	}



*---------------------------*
*---------------------------*

// log close
