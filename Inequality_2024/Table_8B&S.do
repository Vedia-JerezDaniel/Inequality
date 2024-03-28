

forvalues i=0/4 {
foreach c in boom slump {
	teffects ipw (gini_net`i') (ed_bb gdp_gro`i' gdp_cycle less_15 gov_eff education_exp`i' , probit) if year < 2019 if `c'==1, aeq ate vce(robust) coeflegend
	eststo DR1`i'
}
}


forvalues i=0/4 {
foreach c in boom slump {
teffects ipw (gini_net`i') (soc_bb gdp_cycle gov_ex less_15 soc_payable`i', probit) if `c'==1 & year<2019, aeq ate vce(robust) coeflegend
}
}


forvalues i=0/4 {
foreach c in boom slump {
teffects ipw (gini_net`i') (kind_bb gdp_cycle gov_eff gov_debt _high , probit) if `c'==1 & year<2019, aeq ate vce(robust) 
}
}