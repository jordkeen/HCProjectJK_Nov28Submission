clear
set more off
set seed 375937663

//import and clean game result data for 2014, 2015 and 2016 season
foreach year in 2014 2015 2016 {

clear
cd "$raw"
import excel "`year' Game Results Data.xlsx", firstrow

//dummy variable for if team is home
gen teamHome = 0
replace teamHome = 1 if TeamLocation=="Home"

//dummy variable for if game is at neutral site
gen neutral = 0
replace neutral = 1 if NeutralSite=="Neutral Site"

//dummy variable for if game is away (not neutral and not home)
gen teamAway = 0
replace teamAway = 1 if neutral==0 & teamHome==0

//dummy variable for if team wins game
gen teamWin = 0
replace teamWin = 1 if TeamResult=="Win"

//variable for game margin (team score - opponent score
gen margin = TeamScore - OpponentScore
gen opponentMargin = OpponentScore - TeamScore

// keep selected variables and adjust variable names
keep Date Team Opponent TeamScore OpponentScore margin ///
 teamHome neutral teamWin opponentMargin teamAway
 
rename Date date
rename Team teamSchool
rename TeamScore teamScore
rename Opponent opponentSchool
rename OpponentScore opponentScore

//add season year tag
gen season = `year'
tostring season, generate(seasonStr)

//add year to end of team to make teams school-year specific
gen team = teamSchool + seasonStr
gen opponent = opponentSchool + seasonStr
drop seasonStr

//add beforeJan variable as proxy for conference game
gen beforeJan = year(date)<season

//one data restriction: only include teams that play full Div. 1 seasons
bysort team: gen teamGameCount = _N
bysort opponent: gen oppGameCount = _N
drop if teamGameCount < 15 | oppGameCount < 15
drop teamGameCount
drop oppGameCount


//save full dataset with all Div. 1 games
cd "$data"
save "`year'dataFull", replace

//limit to home and home matchups

//drop neutral site games, then matchups with only one game
drop if neutral == 1
drop neutral

bysort team opponent: gen matchupCount = _N
drop if matchupCount < 2


//limit to first home and road game in each matchup
bysort team opponent teamHome(date): keep if _n==1
bysort team opponent: replace matchupCount = _N
drop if matchupCount < 2
bysort team opponent: assert _N == 2


//variables for within matchup regression
by team opponent, sort: egen matchupAvgMargin = mean(margin)
gen matchupMarginDiff = margin - matchupAvgMargin


//save only home and home matchups
cd "$data"
save "`year'dataHH", replace
}

//create combined datasets
clear
cd "$data"

use 2014dataHH
append using 2015dataHH
append using 2016dataHH

//drop any duplicates of date matchup and scoring margin
duplicates drop date team opponent margin, force


//create team and opponent factor variables
encode team, generate(teamFactor)
encode opponent, generate(opponentFactor)
encode teamSchool, generate(teamSchoolFactor)
encode opponentSchool, generate(opponentSchoolFactor)


//make similar dataset but at the game level, with random team-game observation
assert teamFactor != opponentFactor
gen matchupID_1 = teamFactor
replace matchupID_1 = opponentFactor if opponentFactor < teamFactor
gen matchupID_2 = teamFactor
replace matchupID_2 = opponentFactor if opponentFactor > teamFactor

tostring matchupID_1 matchupID_2, replace
gen matchupID = matchupID_1 + "_" + matchupID_2

//2014-2016 seasons of home and home matchups
save allYearsHH, replace

//randomly choose which team-game observation to drop for each game
sort date teamFactor
gen rand = runiform()

bysort date matchupID (rand): keep if _n == 1

//drop unnecessary variables
drop matchupID_1 matchupID_2 rand

//2014-2016 seasons, home and home matchups, game level, random team of interest
save allYearsHHreduced, replace

clear
cd "$data"

use 2014dataFull
append using 2015dataFull
append using 2016dataFull

//drop any duplicates of date matchup and scoring margin
duplicates drop date team opponent margin, force

//create team and opponent factor variables
encode team, generate(teamFactor)
encode opponent, generate(opponentFactor)
encode teamSchool, generate(teamSchoolFactor)
encode opponentSchool, generate(opponentSchoolFactor)

//make similar dataset but at the game level, with random team-game observation
assert teamFactor != opponentFactor
gen matchupID_1 = teamFactor
replace matchupID_1 = opponentFactor if opponentFactor < teamFactor
gen matchupID_2 = teamFactor
replace matchupID_2 = opponentFactor if opponentFactor > teamFactor

tostring matchupID_1 matchupID_2, replace
gen matchupID = matchupID_1 + "_" + matchupID_2

//make gameID variable
tostring date, generate(dateStr)
gen gameID = dateStr + matchupID

//2014-2016 seasons, all games, team-game level of observation
save allYearsFull, replace

//randomly choose which team-game observation to drop for each game
sort date teamFactor
gen rand = runiform()

bysort date matchupID (rand): keep if _n == 1

//drop unnecessary variables
drop matchupID_1 matchupID_2 rand

//2014-16, all games at game level, random team of interest
save allYearsReduced, replace


//redo homeFirst variable in HH data
clear
use allYearsHH

sort matchupID date
by matchupID (date): gen firstGame = _n <= 2


gen homeFirst = teamHome * firstGame

sort date team opponent
list date team opponent firstGame teamHome homeFirst in 1/30

save allYearsHH, replace
