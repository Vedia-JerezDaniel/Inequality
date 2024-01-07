
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

biprobit (f.soc_bb gdp_gro soc_payable soc_bb  ) (gi_bb gdp_cycle gdp_gro soc_payable gov_ex ), cluster(idem) const(3) nolog robust

constraint 1 gdp_gro
constraint 3 high_debt=0
biprobit (soc_bb gdp_gro high_debt gov_ex gini_net ) (gi_bb gdp_cycle gdp_gro  soc_payable gov_ex ), cluster(idem) const(3) nolog