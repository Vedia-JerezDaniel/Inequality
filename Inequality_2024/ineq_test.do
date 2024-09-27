sort idem year serie
encode idem, generate(country)
xtset  country year, yearly


local var gini_net gdp_gro education_exp health_exp soc_payable soc_kind ind_tx property_taxes pit

local var ed_bb he_bb soc_bb kind_bb indt_bb prt_bb pit_bb


foreach v of local var {
	forvalues i=0/4 {
		if "`v'"=="gini_net" {
		gen `v'`i' = f`i'.`v' - `v'
		}
		if "`v'"!="gini_net" {
		gen `v'`i' = f`i'.`v'
		}
		label var `v'`i' "Year `i'"
	}
}

forvalues i=0/4 {
	    gen gini_net`i' = f`i'.gini_net
	}
	

// To construct Dummy variables for countries.
tabulate idem, gen(dumiso)

// Table 1
reg gini_net dl.gini_net l(0/1).gdp_gro l(0/1).gov_debt l(0/1).gov_ex l(0/1).reg_qual l(0/1).education_exp  gdp_cycle gini_net_dm  dumiso1 - dumiso22 , cluster(country)

xtreg gini_net dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex l(0/1).education_exp gdp_cycle, fe vce(robust)

// EDUCATION EXP
forvalues i=0/4 {
	xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex l(0/1).education_exp`i' gdp_cycle if year < 2020, fe vce(robust)
	eststo ols`i'	
}

esttab ols0 ols1 ols2 ols3 ols4 using results/Table_1/edu.rtf, ar2

// HEALTH EXP
forvalues i=0/4 {
	xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex l(0/1).health_exp`i' gdp_cycle if year < 2020, fe vce(robust)
	eststo ols`i'	
}

esttab ols0 ols1 ols2 ols3 ols4 using results/Table_1/health.rtf, ar2

// TRANSFERS IN PAY
forvalues i=0/4 {
	xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(1).gov_ex l(0/1).soc_payable`i' gdp_cycle if year < 2020, fe vce(robust)
	eststo ols`i'	
}

esttab ols0 ols1 ols2 ols3 ols4 using results/Table_1/soc.rtf, ar2 replace

// TRANSFERS IN KIND
forvalues i=0/4 {
	xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(1).gov_ex l(0/1).soc_kind`i' gdp_cycle if year < 2020, fe vce(robust)
	eststo pols`i'	
}

esttab pols0 pols1 pols2 pols3 pols4 using results/Table_1/kind.rtf, ar2 re

// INDIRECT TAXATION
forvalues i=0/4 {
	xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(0/1).gov_ex l(0/1).ind_tx gdp_cycle if year < 2020, fe vce(robust)
	eststo itols`i'	
}
	
esttab itols0 itols1 itols2 itols3 itols4 using results/Table_1/ind_tx.rtf, ar2 re

// PROPERTY TAXATION
forvalues i=0/4 {
	xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(1).gov_ex l(0/1).property_taxes`i' gdp_cycle if year < 2020, fe vce(robust)
	eststo ptols`i'	
}

esttab ptols0 ptols1 ptols2 ptols3 ptols4 using results/Table_1/property_taxes.rtf, ar2 re

// PIT
forvalues i=0/4 {
	xtreg gini_net`i' dl.gini_net l(0/1).gdp_gro l(1).gov_ex l(0/1).pit`i' gdp_cycle if year < 2020, fe vce(robust)
	eststo pitols`i'	
}

esttab pitols0 pitols1 pitols2 pitols3 pitols4 using results/Table_1/pit.rtf, ar2 re

