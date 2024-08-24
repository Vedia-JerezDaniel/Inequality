locproj gini_net , s(gdpr, soc_payable)

locproj gini_net if year <= 2019, s(l.soc_payable gdp_gro) c(l.gov_ex trade ) h(5) tr(cmlt) noisily yl(1) sl(1) z met(newey) force hopt(lag)

locproj gini_net s(l.soc_payable gdp_gro) (l.gov_ex trade 2021.year 2022.year), h(5) tr(diff) noisily yl(1) sl(1) z cluster(idem) fe

locproj gini_net s(l.soc_payable gdp_gro) (l.gov_ex trade), h(5) tr(diff) noisily yl(1) sl(1) z met(xtabond) inst(soc_payable_dm) vce(robust) twostep

locproj gini_net s(l.soc_payable gdp_gro) (l.gov_ex trade), h(5) tr(diff) noisily yl(1) sl(1) z met(xtivreg) inst(soc_payable_dm) fe vce(robust)

XTIVREG
xtreg gdp_gro l.gdp_gro l.sav_gdp gov_debt trade , fe robust
predict resid, xb
locproj gini_net s(soc_payable resid) (l.gov_ex trade), h(4) tr(cmlt) noisily yl(1) sl(1) z  fe vce(robust)

how to graph gdp_gro as an instrument?
