//make Figures

clear
capture log close
set more off
set matsize 10000
ssc install estout, replace
ssc install tabout, replace
cd "$data"

//Figures 1-3

//check FE model for heteroscedasticity and evaluate SE of predicted values

foreach year in 2014 2015 2016 {
	clear
	use "$data\allYearsFull"
	drop if season != `year'
	
	regress margin teamHome teamAway i.teamFactor i.opponentFactor
	
	predict hat
	predict res, res
	predict stdf, stdf
	gen lo = hat - 1.96*stdf
	gen hi = hat + 1.96*stdf
	
	//randomly select which game observation to keep
	sort date teamFactor
	gen rand = runiform()
	bysort date matchupID (rand): keep if _n == 1
	
	# delimit ;
	
	//Figure 1
	twoway 
	(scatter margin hat, msize(small) msymbol(smcircle))
	(line lo hi hat, pstyle(p2 p2) sort),
		ytitle("Scoring Margin") 
		xtitle("Predicted Scoring Margin") 
		title("Actual vs. Predicted Scoring Margin") 
		subtitle("Fixed Effects Model - `year' Season") 
		legend(label(2 "95% Confidence Interval"))
		saving("$figs\predictedActualMargin`year'", replace);
	graph export "$figs\predictedActualMargin`year'.pdf", replace;
	graph export "$figs\predictedActualMargin`year'.png", replace;
	
	//Figure 2
	twoway (scatter res hat, msize(small) msymbol(smcircle)), 
		yscale(range(-50 50))
		ytitle("Residuals") 
		xtitle("Predicted Scoring Margin") 
		title("Residual Plot")
		subtitle("Fixed Effects Model - `year' Season") 
		saving("$figs\residualPlotFE`year'", replace);
	graph export "$figs\residualPlotFE`year'.pdf", replace;
	graph export "$figs\residualPlotFE`year'.png", replace;
	
	//Figure 3
	qnorm res, 
		title("Normal Probability Plot")
		subtitle("Fixed Effects Model - `year' Season")
		saving("$figs\residualsNormPlot`year'", replace);
	graph export "$figs\residualsNormPlot`year'.pdf", replace;
	graph export "$figs\residualsNormPlot`year'.png", replace;
	
	# delimit cr
		
}

//Figure 4

//export 2016 fixed effects data to Matlab for win probability analysis
clear
use "$data\allYearsReduced"
drop if season != 2016
	
//regress margin teamHome teamAway i.teamFactor i.opponentFactor, vce(cluster gameID)
regress margin teamHome teamAway i.teamFactor i.opponentFactor
predict predMargin
predict res, res
predict stdf, stdf

gen predMarginNeutral = predMargin
replace predMarginNeutral = predMargin - _b[teamAway] if teamAway==1
replace predMarginNeutral = predMargin - _b[teamHome] if teamHome==1

gen teamHomeCoef = _b[teamHome]

keep predMarginNeutral stdf teamHomeCoef

export excel using "$matlab\winProbData.xlsx", firstrow(variables) sheetreplace

