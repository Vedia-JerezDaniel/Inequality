// TABLE 2

gen boom = cond(gdp_bb>+0,1,0)
gen slump = 1 - boom



forvalues i=0/4 {
foreach c in boom slump {
	xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).education_exp`i' gdp_cycle if year < 2020 &  `c'==1, fe vce(robust) 
	
eststo edu`c'`i'
		}
	}

esttab eduboom0 eduboom1 eduboom2 eduboom3 eduboom4 using results/Table_2/edu_boom.rtf, ar2
esttab eduslump0 eduslump1 eduslump2 eduslump3 eduslump4 using results/Table_2/edu_slump.rtf, ar2

// HEALTH EXPENDITURE

forvalues i=0/4 {
foreach c in boom slump {
	xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex l(0/1).health_exp`i' gdp_cycle if year < 2020 &  `c'==1, fe vce(robust) 
	
eststo hea`c'`i'
		}
	}

esttab heaboom0 heaboom1 heaboom2 heaboom3 heaboom4 using results/Table_2/hea_boom.rtf, ar2 re
esttab heaslump0 heaslump1 heaslump2 heaslump3 heaslump4 using results/Table_2/hea_slump.rtf, ar2 re

// Payable Transfers
forvalues i=0/4 {
foreach c in boom slump {
	xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).soc_payable`i' gdp_cycle ${fe`j'} if year < 2020 & `c'==1, fe vce(robust)
	eststo pay`c'`i'
}
}

esttab payboom0 payboom1 payboom2 payboom3 payboom4 using results/Table_2/pay_boom.rtf, ar2 re 
esttab payslump0 payslump1 payslump2 payslump3 payslump4 using results/Table_2/pay_boom.rtf, ar2 re 


// Kind Transfers
forvalues i=0/4 {
foreach c in boom slump {
	xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).soc_kind`i' gdp_cycle ${fe`j'} if year < 2020 & `c'==1, fe vce(robust)
	
eststo kind`c'`i'
}
}

esttab kindboom0 kindboom1 kindboom2 kindboom3 kindboom4 using results/Table_2/kind_boom.rtf, ar2 re
esttab kindslump0 kindslump1 kindslump2 kindslump3 kindslump4 using results/Table_2/kind_slump.rtf, ar2 re


// Indirect Taxes
forvalues i=0/4 {
foreach c in boom slump {
xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).ind_tx`i' gdp_cycle ${fe`j'} if year < 2020 & `c'==1, fe vce(robust)
	
eststo ind_tx`c'`i'
}
}

esttab ind_txboom0 ind_txboom1 ind_txboom2 ind_txboom3 ind_txboom4 using results/Table_2/ind_tx_boom.rtf, ar2 re 
esttab ind_txslump0 ind_txslump1 ind_txslump2 ind_txslump3 ind_txslump4 using results/Table_2/ind_tx_slump.rtf, ar2 re


// PRoperty Taxes
forvalues i=0/4 {
foreach c in boom slump {

xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex l(0/1).property_taxes`i' gdp_cycle ${fe`j'} if year < 2020 & `c'==1, fe vce(robust)
	
eststo pro_tx`c'`i'
}
}

esttab pro_txboom0 pro_txboom1 pro_txboom2 pro_txboom3 pro_txboom4 using results/Table_2/pro_txboom.rtf, ar2 re 
esttab pro_txslump0 pro_txslump1 pro_txslump2 pro_txslump3 pro_txslump4 using results/Table_2/pro_txslump.rtf, ar2 re

//Progresivity taxes
forvalues i=0/4 {
foreach c in boom slump {

xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex l(0/1).pit`i' gdp_cycle ${fe`j'} if year < 2020 & `c'==1, fe vce(robust)
eststo pit`c'`i'
}
}

esttab pitboom0 pitboom1 pitboom2 pitboom3 pitboom4 using results/Table_2/pit_boom.rtf, ar2 re 
esttab pitslump0 pitslump1 pitslump2 pitslump3 pitslump4 using results/Table_2/pit_slump.rtf, ar2 re
