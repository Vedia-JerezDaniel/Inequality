
forvalues i=0/4 {
foreach c in boom slump {
teffects ipw (gini_net`i') (soc_bb gdp_cycle gov_ex less_15 gov_debt soc_payable`i', probit) if `c'==1 & year<2019, aeq ate vce(robust) coeflegend
eststo DR1`i'`c'
}
}


forvalues i=0/4 {
foreach c in boom slump {
teffects ipw (gini_net`i') (kind_bb gdp_cycle gov_eff gov_debt _high , probit) if `c'==1 & year<2019, aeq ate vce(robust) coeflegend
eststo DR1`i'`c'
}
}


forvalues i=0/4 {
foreach c in boom slump {
teffects ipwra (gini_net`i' gdp_gro`i' gdp_cycle gov_eff ) (prt_bb gdp_gro`i' gov_eff gov_debt,probit) if `c'==1 & year<2019, aeq ate vce(robust) coeflegend
eststo DR1`i'`c'
}
}


forvalues i=0/4 {
foreach c in boom slump {
teffects ipwra (gini_net`i' gdp_gro`i' gdp_cycle gov_eff gov_ex ) (indt_bb gdp_gro`i' gov_eff sav_gdp,probit) if `c'==1 & year<2019, aeq vce(robust) coeflegend
eststo DR1`i'`c'
}
}


forvalues i=0/4 {
foreach c in boom slump {
teffects ipwra (gini_net`i' gdp_gro`i' gdp_cycle gov_eff ) (pit_bb gdp_gro gov_eff gov_debt pit`i' ,probit) if `c'==1 & year<2019, aeq vce(robust)
eststo DR1`i'`c'
}

esttab DR10boom DR11boom DR12boom DR13boom DR14boom using results/Table_8/Table9_Boom.rtf, replace scalars(RobustSE pvalue) title("Table 9. IPW") b(4) se(4) sfmt(5) obslast label star(* 0.10 ** 0.05 *** 0.01)
esttab DR10slump DR11slump DR12slump DR13slump DR14slump using results/Table_8/Table9_Slump.rtf, replace scalars(RobustSE pvalue) title("Table 9. IPW") b(4) se(4) sfmt(5) obslast label star(* 0.10 ** 0.05 *** 0.01)