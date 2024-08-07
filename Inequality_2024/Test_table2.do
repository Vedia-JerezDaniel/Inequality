// TABLE 2

gen boom = cond(gdp_bb>+0,1,0)
gen slump = 1 - boom


forvalues j=1/2 {
	forvalues i=0/4 {
		foreach c in boom slump {
		
	reg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex l(0/1).education_exp gdp_cycle dumiso1-dumiso22 ${fe`j'} if `c'==1, cluster(idem)
		}
	}
eststo `c'`i'`j'
}

// Payable Transfers
forvalues i=0/4 {
foreach c in boom slump {

xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex l(0/1).soc_payable`i' gdp_cycle ${fe`j'} if `c'==1, fe vce(robust)
	
eststo pay`c'`i'
}
}

esttab payboom0 payboom1 payboom2 payboom3 payboom4 using results/Table_1/pay_boom.rtf, ar2
esttab paybust0 paybust1 paybust2 paybust3 paybust4 using results/Table_1/pay_boom.rtf, ar2


// Kind Transfers
forvalues i=0/4 {
foreach c in boom slump {

xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex l(0/1).soc_kind`i' gdp_cycle ${fe`j'} if `c'==1, fe vce(robust)
	
eststo pay`c'`i'
}
}

esttab kindboom0 kindboom1 kindboom2 kindboom3 kindboom4 using results/Table_1/kind_boom.rtf, ar2
esttab kindslump0 kindslump1 kindslump2 kindslump3 kindslump4 using results/Table_1/kind_slump.rtf, ar2


// Indirect Taxes
forvalues i=0/4 {
foreach c in boom slump {

xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex l(0/1).ind_tx`i' gdp_cycle ${fe`j'} if `c'==1, fe vce(robust)
	
eststo ind_tx`c'`i'
}
}

esttab ind_txboom0 ind_txboom1 ind_txboom2 ind_txboom3 ind_txboom4 using results/Table_1/ind_tx_boom.rtf, ar2
esttab ind_txslump0 ind_txslump1 ind_txslump2 ind_txslump3 ind_txslump4 using results/Table_1/ind_tx_slump.rtf, ar2


// PRoperty Taxes
forvalues i=0/4 {
foreach c in boom slump {

xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex l(0/1).property_taxes`i' gdp_cycle ${fe`j'} if `c'==1, fe vce(robust)
	
eststo pro_tx`c'`i'
}
}

esttab pro_tx_txboom0 pro_tx_txboom1 pro_tx_txboom2 pro_tx_txboom3 pro_tx_txboom4 using results/Table_1/pro_tx_tx_boom.rtf, ar2
esttab pro_tx_txslump0 pro_tx_txslump1 pro_tx_txslump2 pro_tx_txslump3 pro_tx_txslump4 using results/Table_1/pro_tx_tx_slump.rtf, ar2

//Progresivity taxes
forvalues i=0/4 {
foreach c in boom slump {

xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex l(0/1).pit`i' gdp_cycle ${fe`j'} if `c'==1, fe vce(robust)
	
eststo pit`c'`i'
}
}

esttab pitboom0 pitboom1 pitboom2 pitboom3 pitboom4 using results/Table_1/pit_boom.rtf, ar2
esttab pitslump0 pitslump1 pitslump2 pitslump3 pitslump4 using results/Table_1/pit_slump.rtf, ar2
