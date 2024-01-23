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

sort idem year
xtset country year

capture drop invwt
gen a = ed_bb // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat0 + (1-a)/(1-pihat0) if pihat~=. 

reg gini_net dl.gini_net_dm  l(0/1).ed_bb gdp_cycle l(0/1).gdp_gro_dm dumiso1-dumiso22 if year < 2019 [pweight=invwt] , cluster(idem)

gen samp=e(sample) // set sample
predict mu0 if samp==1 & ed_bb==0 // actual
predict mu1 if samp==1 & ed_bb==1 // actual
replace mu0 = mu1 - _b[ed_bb] if samp==1 & f.ed_bb==1 // ghost
replace mu1 = mu0 + _b[ed_bb] if samp==1 & f.ed_bb==0 