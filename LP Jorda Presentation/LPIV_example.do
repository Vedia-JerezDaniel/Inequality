**** LPIV example 	*****
**** Oscar Jorda  	*****
**** March 15, 2022 *****

clear
graph drop _all
cap drop all

use RR_monetary_shock_quarterly.dta
**** Romer and Romer (2004) shocks updated by Wieland and Yang (2019)
**** Available from ICPSR

**** "resid" are the original Romer-Romer (2004) shocks
**** "resid_romer" are the shocks based on the original Romer-Romer (2004)
**** regression
**** "resid_full" are the shocks based on running the Romer-Romer(2004)
**** regression on the full 1969-2007 sample

**** Next, merge the unemployment rate from the St. Louis Fred

merge 1:1 date using lpiv_15Mar2022.dta
drop _merge

**** Keep only nonmissing observations in resid_full i.e. 1969m1 - 2007m12
keep if resid_full != .

**** tsset to use time series commands
tsset date

* Choose impulse response horizon
local hmax = 16

/* Generate LHS variables for the LPs */
* Cumulative
forvalues h = 0/`hmax' {
	gen ur`h' = f`h'.UNRATE 
	 
}


* LP-OLS
eststo clear
cap drop b_ls u_ls d_ls Quarters Zero
gen Quarters = _n-1 if _n<=`hmax'
gen Zero =  0     if _n<=`hmax'
gen b_ls=0
gen u_ls=0
gen d_ls=0
qui forv h = 1/`hmax' {
	 newey ur`h' DFF l(1/4).DFF l(1/4).UNRATE, lag(`h')
replace b_ls = _b[DFF]                    if _n == `h'
replace u_ls = _b[DFF] + 1.645* _se[DFF]  if _n == `h'
replace d_ls = _b[DFF] - 1.645* _se[DFF]  if _n == `h'
eststo
}
*** Use this command if you want a summary of the LP coefficients
nois esttab , se nocons keep(DFF)

* LP-IV
eststo clear
cap drop b_iv u_iv d_iv 

gen b_iv=0
gen u_iv=0
gen d_iv=0
qui forv h = 1/`hmax' {
	  ivregress gmm ur`h' l(1/4).DFF l(1/4).UNRATE (DFF = resid_full), vce(hac nwest)
replace b_iv = _b[DFF]                    if _n == `h'
replace u_iv = _b[DFF] + 1.645* _se[DFF]  if _n == `h'
replace d_iv = _b[DFF] - 1.645* _se[DFF]  if _n == `h'
eststo
}
*** Use this command if you want a summary of the LP coefficients
nois esttab , se nocons keep(DFF)

twoway ///
(rarea u_ls d_ls  Quarters,  ///
fcolor(blue%15) lcolor(gs13) lw(none) lpattern(solid)) ///
(line b_ls Quarters, lcolor(blue%50) lpattern(dash) lwidth(thick)) ///
(rarea u_iv d_iv  Quarters,  ///
fcolor(purple%15) lcolor(gs13) lw(none) lpattern(solid)) ///
(line b_iv Quarters, lcolor(purple) lpattern(solid) lwidth(thick)) ///
(line Zero Quarters, lcolor(black)), legend(off) ///
title("Responses of the unemployment rate to monetary shock", color(black) size(med)) ///
subtitle("OLS (dash blue) vs. IV (solid purple)", color(black) size(small)) ///
ytitle("Percent", size(medsmall)) xtitle("Quarters", size(medsmall)) ///
note("Notes: 90 percent confidence bands") ///
graphregion(color(white)) plotregion(color(white))

gr rename fig_ls_v_iv, replace



