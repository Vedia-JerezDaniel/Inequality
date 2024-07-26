locproj gini_net, shock(soc_payable) hor(5) c(gdp_gro gov_ex rule_law l.gini_net)  sl(1) noisily
locproj gini_net if year < 2020, shock(soc_payable) hor(5) c(gdp_gro gov_ex rule_law) yl(1) sl(1) tr(diff) noisily nograph

locproj gini_net, shock(soc_payable) hor(5) c(gdp_gro gov_ex rule_law l.gini_net) sl(1) met(newey) hopt(lag) force


locproj gini_net, shock(lX.soc_payable) hor(4) c(l(1/2).gdp_gro l.gov_ex rule_law) yl(1) sl(1) trans(diff) z cluster(idem) noisily