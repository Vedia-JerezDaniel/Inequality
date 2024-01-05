

*
* Table 8. Fiscal treatment regression, pooled probit estimation in 1st stage
*

local m1 debtgdp
local m2 debtgdp hply dly
local m3 debtgdp hply treatment
local m4 debtgdp dly treatment

forvalues i=1/4 {

	probit ftreatment `m`i'' if year>=1980 & year<=2007

	predict phatm`i'
	roctab ftreatment phatm`i'
	
	*** AUC info -- see Figure 1
	local auc`i' = r(area)
	local se`i' = r(se)
	
	eststo auc`i'
	estadd scalar Model_AUC = r(area)
	estadd scalar se = r(se)
	
	margins, dydx(*) post
	eststo m`i'
}

* tables

label var ftreatment "Treatment(t+1)"

esttab m1 m2 m3 m4 using ../tables/Table7.tex ,  f replace ///
	title("Table 8. Fiscal treatment regression, pooled probit estimators, marginal effects") ///
	b(3) se(3) sfmt(2) obslast se label star(* 0.10 ** 0.05 *** 0.01)
	
*** add AUCs
esttab auc1 auc2 auc3 auc4 using ../tables/Table7.tex , f a ///
	drop(debtgdp hply dly treatment _cons) ///
	scalars("Model_AUC Model AUC" "se s.e.") noobs nomtitles nonum label
