

ivreg2 gini_net (education_exp= ed_bb) dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex gdp_cycle if year<=2020, cluster(iso) 

// EDUCATION EXP
forvalues i=0/4 {
	
	ivreg2 gini_net`i' (education_exp`i'= ed_bb`i') dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex gdp_cycle if year<=2020, cluster(idem)

	eststo ivr`i'
	estadd scalar FirstStageFStat = e(widstat)
}

esttab ivr0 ivr1 ivr2 ivr3 ivr4 using results/Table_3/edu.rtf, ar2

// HEALTH EXP
forvalues i=0/4 {
	
	ivreg2 gini_net`i' (health_exp`i'= he_bb`i') dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex gdp_cycle if year<=2020, cluster(idem)

	eststo ivr`i'	
}

esttab ivr0 ivr1 ivr2 ivr3 ivr4 using results/Table_3/hea.rtf, ar2


// TRANSFERS IN PAY
forvalues i=0/4 {
	
	ivreg2 gini_net`i' (soc_payable`i'= soc_bb`i') dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex gdp_cycle if year<=2020, cluster(idem)

	eststo ivr`i'	
}

esttab ivr0 ivr1 ivr2 ivr3 ivr4 using results/Table_3/pay.rtf, ar2

// TRANSFERS IN KIND
forvalues i=0/4 {
	
	ivreg2 gini_net`i' (soc_kind`i'= kind_bb`i') dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex gdp_cycle if year<=2020, cluster(idem)

	eststo ivr`i'	
}

esttab ivr0 ivr1 ivr2 ivr3 ivr4 using results/Table_3/kind.rtf, ar2

// INDIRECT TAXATION
forvalues i=0/4 {
	
	ivreg2 gini_net`i' (ind_tx`i'= indt_bb`i') dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex gdp_cycle if year<=2020, cluster(idem)

	eststo ivr`i'	
}

esttab ivr0 ivr1 ivr2 ivr3 ivr4 using results/Table_3/indt.rtf, ar2

// PROPERTY TAXATION
forvalues i=0/4 {
	
	ivreg2 gini_net`i' (property_taxes`i'= prt_bb`i') dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex gdp_cycle if year<=2020, cluster(idem)

	eststo ivr`i'	
}

esttab ivr0 ivr1 ivr2 ivr3 ivr4 using results/Table_3/prop_tx.rtf, ar2


// PIT
forvalues i=0/4 {
	
	ivreg2 gini_net`i' (pit`i'= pit_bb`i') dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex gdp_cycle if year<=2020, cluster(idem)

	eststo ivr`i'	
}

esttab ivr0 ivr1 ivr2 ivr3 ivr4 using results/Table_3/pit.rtf, ar2
