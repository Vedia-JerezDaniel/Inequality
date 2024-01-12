
local m1 gdp_gro
local m2 gdp_gro gov_debt
local m3 gdp_gro gov_debt ind_tx


forvalues i=1/3 {

	xtprobit indt_bb `m`i'' , nolog corr( ar 1) pa iter(100)

	predict phatm`i'
	roctab indt_bb phatm`i'
	
	*** AUC info -- see Figure 1
	local auc`i' = r(area)
	local se`i' = r(se)
	
	eststo auc`i'
	estadd scalar Model_AUC = r(area)
	estadd scalar se = r(se)
	
	margins, dydx(*) post
	eststo m`i'
}

esttab m1 m2 m3 using results/Table_7/Table7i.rtf, replace title("Table 7. Fiscal treatment regression, pooled probit estimators, marginal effects") b(3) se(3) sfmt(2) obslast se label star(* 0.10 ** 0.05 *** 0.01)
	
*** add AUCs
esttab auc1 auc2 auc3 using results/Table_7/Table7i.rtf, a drop(gdp_gro gov_debt ind_tx _cons) scalars("Model_AUC Model AUC" "se s.e.") noobs nomtitles nonum label
	

	
