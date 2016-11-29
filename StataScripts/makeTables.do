//makeTables

clear
capture log close
set more off
set matsize 10000
ssc install estout, replace
ssc install tabout, replace
cd "$data"

//make Table 1
log using "$tables\table1.log", replace

use allYearsFull
count
bysort date matchupID: gen gameCount = _n==1
count if gameCount == 1
summ neutral
di "Full Sample"
table season, c(count date sum gameCount mean neutral) row format(%9.2f) center
clear

use allYearsReduced
count
bysort date matchupID: gen gameCount = _n==1
count if gameCount == 1
summ neutral
di "Random Reduced"
table season, c(count date sum gameCount mean neutral) row format(%9.2f) center
clear

use allYearsFull
keep if teamHome
count
bysort date matchupID: gen gameCount = _n==1
count if gameCount == 1
summ neutral
di "Home Team Reduced"
table season, c(count date sum gameCount mean neutral) row format(%9.2f) center
clear

use allYearsHH
keep if teamHome
count
di "Home and Home"
table season, c(count date) row format(%9.2f) center
clear

log close

//make Table 2

log using "$tables\table2.log", replace

use allYearsFull
keep if teamHome

label var beforeJan "Game Before January 1"
label def beforeJan 0 "After January 1" 1 "Before January 1"
label val beforeJan beforeJan

label var season "Season"
label def season 2014 "2013-2014" 2015 "2014-2015" 2016 "2015-2016"
label val season season

table beforeJan season, c(mean margin semean margin) column row ///
	format(%9.2f) center 
/*
gen wt = 1
svyset [pw=wt]

tabout beforeJan season using "$regs\table1B.txt", c(mean margin se) ///
	clab(Mean_margin SE) sum svy npos(lab) replace
*/
//beforeJan regressions
forvalues year = 2014/2016 {

	eststo: qui regress margin beforeJan if season==`year'

}

eststo: qui regress margin beforeJan

esttab using "$tables\table2B.csv", replace nostar nogaps onecell se ///
	mtitles("2013-14" "2014-15" "2015-16" "All Years")

eststo clear
clear

log close

//make Table 3

log using "$tables\table3.log", replace
use allYearsHH
keep if teamHome

table homeFirst season, c(mean matchupMarginDiff semean matchupMarginDiff) ///
	format (%9.2f) center column row
	
//tabout

forvalues year = 2014/2016 {

	eststo: qui regress margin homeFirst if season==`year'
	
}

eststo: qui regress margin homeFirst

esttab using "$tables\table3B.csv", replace nostar nogaps onecell se ///
	mtitles("2013-14" "2014-15" "2015-16" "All Years")

eststo clear
clear
log close

//make Table 4 (fixed effects regressions - full data with clustered SE)

use allYearsFull

forvalues year = 2014/2016 {

	eststo: qui regress margin teamHome teamAway i.teamFactor i.opponentFactor ///
	if season==`year', vce(cluster gameID)

}

esttab using "$tables\table4full.csv", replace nostar nogaps onecell se
esttab using "$tables\table4.csv", replace nostar nogaps onecell se ///
	keep(teamHome teamAway _cons) ///
	mtitles("2013-14" "2014-15" "2015-16")
	
eststo clear
clear
