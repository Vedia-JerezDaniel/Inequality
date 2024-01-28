*
* Tables 8 and 9. DR ATE of fiscal consolidation on real GDP, inverse propensity score weights.
* Log real GDP (relative to Year 0, x 100)
*

pause on 
drop a 
drop pihat pihat0
drop inv*

xtprobit soc_bb l.gdp_gro l.soc_payable gdp_cycle gov_ex gov_debt rule_law if year < 2019, nolog corr(ar 1) pa iter(500) vce(robust) nocons

predict pihat0

* truncate ipws at 10 (pihat)
gen pihat=pihat0
replace pihat = .9 if pihat>.8 & pihat~=.
replace pihat = .1 if pihat<.2 & pihat~=.

sort idem year
xtset country year

capture drop invwt
gen a = soc_bb 
gen invwt=a/pihat0 + (1-a)/(1-pihat0) if pihat~=. 

forvalues i=0/4 {
	xtgls gini_net`i' dl.gini_net gdp_cycle l.gdp_gro c.soc_payable#soc_bb dumiso1-dumiso22 if year < 2019 [weight=invwt] , panels(h) igls
	
	gen samp=e(sample) 
	predict mu0 if samp==1 & soc_bb==0 
	predict mu1 if samp==1 & soc_bb==1 
	replace mu0 = mu1 - _b[0.soc_bb#c.soc_payable] if samp==1 & f.soc_bb==1 
	replace mu1 = mu0 + _b[1.soc_bb#c.soc_payable] if samp==1 & f.soc_bb==0 

	generate mdiff1=(-(a-pihat0)*mu1/pihat0)-((a-pihat0)*mu0/(1-pihat0))
	generate iptw=(2*a-1)*gini_net`i'*invwt
	generate dr1=iptw+mdiff1
	qui gen ATE_IPWRA=1 
	qui reg dr1 ATE_IPWRA, nocons cluster(idem)
	eststo DR1`i'

	sum dr1
	local dr1m = r(mean)
	gen Isq  = (dr1-`dr1m')^2
	sum Isq
	estadd scalar RobustSE = sqrt(r(mean)/r(N))
	estadd scalar pvalue = normal(`dr1m'/sqrt(r(mean)/r(N)))
	drop samp iptw Isq mdiff1 dr1 mu1 mu0 ATE_IPWRA 
	capture scalar drop dr1m
	}
// capture drop iptw Isq mdiff1 dr1 mu1 mu0 samp ATE_IPWRA

esttab DR10 DR11 DR12 DR13 DR14, scalars(RobustSE pvalue) title("Table 8. ATE-IP (DR) i.p. weights, Unrestricted, b0=b1") b(4) se(4) sfmt(5) obslast label star(* 0.10 ** 0.05 *** 0.01)






drop gini_net1 gini_net0  gini_net2 gini_net3 gini_net4

reg gini_net`i' soc_bb gdp_cycle l(`i').gdp_gro dumiso1-dumiso22 if year < 2019 [pweight=invwt] , cluster(idem)
xtgls gini_net1 dl.gini_net soc_bb gdp_gro dumiso1-dumiso22 if year < 2019 [weight=invwt] , panels(h) igls
