*
* Tables 8 and 9. DR ATE of fiscal consolidation on real GDP, inverse propensity score weights.
* Log real GDP (relative to Year 0, x 100)
*


pause on 
capture drop pihat pihat0

xtprobit ed_bb l.gdp_gro l.education_exp gdp_cycle gov_ex gov_debt rule_law if year < 2019, nolog corr(ar 1) pa iter(500) vce(robust) nocons

predict pihat0

* truncate ipws at 10 (pihat)
gen pihat=pihat0
replace pihat = .9 if pihat>.8 & pihat~=.
replace pihat = .1 if pihat<.2 & pihat~=.
