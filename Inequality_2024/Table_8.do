*
* Tables 8 and 9. DR ATE of fiscal consolidation on real GDP, inverse propensity score weights.
* Log real GDP (relative to Year 0, x 100)
*


pause on 
capture drop pihat pihat0

* basic probit
*xi: probit ftreatment debtgdp hply dly ldly treatment if year>=1980 & year<=2007 
* saturated probit
xi: probit ftreatment debtgdp hply dly ldly treatment ///
	drprv dlcpi dlriy stir ltrate cay dmdumiso1-dmdumiso16 if year>=1980 & year<=2007 


xi: probit f.gi_bb gi_bb gdp_gro gov_ex ed_bb gov_debt dumiso1-dumiso16

* raw prscore, not truncated (pihat0)
predict pihat0

* truncate ipws at 10 (pihat)
gen pihat=pihat0
replace pihat = .9 if pihat>.9 & pihat~=.
replace pihat = .1 if pihat<.1 & pihat~=.
