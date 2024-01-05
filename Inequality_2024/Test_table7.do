
local m1 "gov_debt"
local m2 gov_debt gdp_gro gdp_cycle
local m3 gov_debt gdp_cycle ed_bb
local m4 gov_debt gdp_gro ed_bb


forvalues i=1/4 {

	probit gi_bb `m`i'' 

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


probit gi_bb