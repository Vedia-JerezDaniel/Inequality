* Tables 8 and 9. DR ATE of fiscal consolidation on real GDP, inverse propensity score weights.
* Log real GDP (relative to Year 0, x 100)

/* health_exp  soc_kind ind_tx */
/* he_bb kind_bb indt_bb */

pause on 
drop a 
drop pihat pihat0
drop inv*

xtprobit ed_bb l.gdp_gro l.education_exp gdp_cycle gov_ex gov_debt rule_law if year < 2019, nolog corr(ar 1) pa iter(500) vce(robust) nocons

predict pihat0

// Akaike's information criterion and Bayesian information criterion
//
// -----------------------------------------------------------------------------
//        Model |          N   ll(null)  ll(model)      df        AIC        BIC
// -------------+---------------------------------------------------------------
//            . |        644          .  -432.0554       7   878.1109   909.3848
// -----------------------------------------------------------------------------


* truncate ipws at 10 (pihat)
gen pihat=pihat0
replace pihat = .9 if pihat>.8 & pihat~=.
replace pihat = .1 if pihat<.2 & pihat~=.

sort idem year
xtset country year

capture drop invwt
gen a = ed_bb 
gen invwt=a/pihat0 + (1-a)/(1-pihat0) if pihat~=. 

forvalues i=0/4 {
	xtgls gini_net`i' dl.gini_net gdp_cycle l.gdp_gro c.education_exp#ed_bb dumiso1-dumiso22 if year < 2019 [weight=invwt] , panels(h) igls
	
	gen samp=e(sample) 
	predict mu0 if samp==1 & ed_bb==0 
	predict mu1 if samp==1 & ed_bb==1 
	replace mu0 = mu1 - _b[0.ed_bb#c.education_exp] if samp==1 & f.ed_bb==1 
	replace mu1 = mu0 + _b[1.ed_bb#c.education_exp] if samp==1 & f.ed_bb==0 

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


esttab DR10 DR11 DR12 DR13 DR14 using results/Table_8/Table8.rtf, replace scalars(RobustSE pvalue) title("Table 8. IPW") b(4) se(4) sfmt(5) obslast label star(* 0.10 ** 0.05 *** 0.01)

// ETEFFECTES 
forvalues i=0/4 {
	eteffects (gini_net`i' gdp_gro education_exp gov_eff rule_law) (ed_bb gdp_cycle gov_ex less_15 rule_law) if year < 2019, atet aeq vce(cluster idem)
	eststo DR1`i'
}

//mas asociado con el efecto de paises ricos
forvalues i=0/4 {
	eteffects (gini_net`i' gdp_gro health_exp gov_eff ) (he_bb gdp_cycle gov_ex ) if year < 2019, aeq vce(cluster idem)
	eststo DR1`i'
}


forvalues i=0/4 {
	eteffects (gini_net`i' gdp_gro gov_ex soc_payable gov_eff) (soc_bb gdp_cycle gov_eff _high ) if year < 2019, aeq vce(cluster idem) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	eteffects (gini_net`i' gdp_cycle  gov_ex soc_kind gov_eff) (kind_bb gdp_gro  gov_eff less_15 ) if year < 2019, aeq vce(cluster idem) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	eteffects (gini_net`i' gdp_cycle gov_ex property_taxes gov_eff) (prt_bb gdp_gro gov_eff ) if year < 2019, aeq vce(cluster idem) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	eteffects (gini_net`i' gdp_cycle gov_ex ind_tx gov_eff sav_gdp ) (indt_bb gdp_gro gov_eff) if year < 2019, aeq vce(cluster idem) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	eteffects (gini_net`i' gdp_cycle gov_ex pit gov_eff sav_gdp ) (pit_bb gdp_gro gov_eff ) if year < 2019, aeq vce(cluster idem) coeflegend
	eststo DR1`i'
}

//----------
// TEFFECTES IPW

forvalues i=0/4 {
	teffects ipw (gini_net`i') (ed_bb gdp_gro`i' gdp_cycle less_15 gov_eff education_exp`i' , probit) if year < 2019, aeq ate vce(robust) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	teffects ipw (gini_net`i') (he_bb  gdp_cycle gov_eff health_exp`i' , probit) if year < 2019, aeq ate vce(robust) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	teffects ipw (gini_net`i') (soc_bb gdp_cycle gov_eff less_15 gov_debt soc_payable`i', probit) if year < 2019, aeq ate vce(robust) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	teffects ipw (gini_net`i') (kind_bb gdp_cycle gov_eff gov_debt _high , probit) if year < 2019, aeq ate vce(robust) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	teffects ipw (gini_net`i') (prt_bb gdp_gro gdp_cycle`i' gov_debt gov_ex, probit) if year < 2019, aeq ate vce(robust) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	teffects ipw (gini_net`i') (indt_bb gdp_gro`i' gov_debt gov_eff gov_ex , probit) if year < 2019, aeq ate vce(robust) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	teffects ipw (gini_net`i') (pit_bb gdp_gro gdp_cycle gov_eff gov_ex  sav_gdp, probit) if year < 2019, aeq ate vce(robust) coeflegend
	eststo DR1`i'
}

//----------
// TEFFECTES IPWRA

forvalues i=0/4 {
teffects aipw (gini_net`i' gdp_gro`i' gdp_cycle gov_debt gov_eff) (ed_bb gdp_gro`i' gdp_cycle gov_eff education_exp`i' , probit) if year < 2019,  aeq vce(robust) coeflegend
	eststo DR1`i'
}


forvalues i=0/4 {
	teffects ipwra (gini_net`i' gdp_gro`i' gdp_cycle  gov_eff  gov_debt) (ed_bb gdp_gro`i' gdp_cycle less_15 gov_eff education_exp`i', probit) if year < 2019, aeq vce(robust) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	teffects ipwra (gini_net`i' gdp_gro`i' gdp_cycle  gov_eff  gov_debt) (he_bb  gdp_cycle gov_eff health_exp`i', probit) if year < 2019, aeq vce(robust) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	teffects ipwra (gini_net`i' gdp_gro`i' gdp_cycle gov_eff ) (soc_bb gdp_cycle gov_eff gov_debt,probit) if year < 2019, aeq vce(robust) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	teffects ipwra (gini_net`i' gdp_gro`i' gdp_cycle gov_eff ) (kind_bb gdp_cycle gov_eff gov_debt,probit) if year < 2019, aeq vce(robust) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	teffects ipwra (gini_net`i' gdp_gro`i' gdp_cycle gov_eff ) (prt_bb gdp_gro`i' gov_eff gov_debt,probit) if year < 2019, aeq vce(robust)
	eststo DR1`i'
}

forvalues i=0/4 {
	teffects ipwra (gini_net`i' gdp_gro`i' gdp_cycle gov_eff ) (prt_bb gdp_gro`i' gov_eff gov_debt,probit) if year < 2019, aeq vce(robust)
	eststo DR1`i'
}

forvalues i=0/4 {
	teffects ipwra (gini_net`i' gdp_gro`i' gdp_cycle gov_eff gov_ex ) (indt_bb gdp_gro`i' gov_eff sav_gdp  ,probit) if year < 2019, aeq vce(robust) coeflegend
	eststo DR1`i'
}

forvalues i=0/4 {
	teffects ipwra (gini_net`i' gdp_gro`i' gdp_cycle gov_eff ) (pit_bb gdp_gro gov_eff gov_debt pit`i' ,probit) if year < 2019, aeq vce(robust)
	eststo DR1`i'
}

// ------------------------------ SELECTED MODELS
eteffects (gini_net gdp_gro gdp_cycle gov_debt) (ed_bb education_exp gov_ex),  aeq vce(cluster idem)

teffects ipw (gini_net) (ed_bb  gdp_gro  gov_eff  education_exp , probit  ) if year < 2019, aeq ate vce(robust) coefl
nlcom _b[ATE:r1vs0.ed_bb] / _b[POmean:0.ed_bb]

teffects ipwra (gini_net gdp_gro gov_debt gov_eff  ) (ed_bb gdp_gro gdp_cycle gov_debt gov_eff education_exp , probit) if year < 2019,  aeq

// ------------------------------

teffects ipwra (gini_net gdp_gro gov_debt gov_eff  ) (ed_bb gdp_gro gdp_cycle gov_debt gov_eff education_exp , probit) if year < 2019,  aeq
eteffects (gini_net gdp_gro gdp_cycle gov_debt) (ed_bb education_exp gov_ex),  aeq vce(cluster idem)
// El coff de ATE es muy elevado cerca del -0.23

etregress gini_net gdp_gro gdp_cycle ed_bb#c.education_exp gov_debt , treat(ed_bb = gdp_gro gov_ex) vce(robust)
margins r.ed_bb , vce(unconditional) contrast(nowald)
//Bien me gusta, search for interpretations

teffects ra (gini_net gdp_gro gdp_cycle gov_debt education_exp gov_ex ) (ed_bb ), atet aeq vce(robust) coeflegend
nlcom _b[ATET:r1vs0.ed_bb] / _b[POmean:0.ed_bb]
// non significant & and opposite sign

teffects ipw (gini_net) (ed_bb  gdp_gro  gov_eff  education_exp , probit  ), aeq
teffects ipw (gini_net) (ed_bb  gdp_gro  gov_eff  education_exp , probit  ) if year < 2019, aeq ate vce(robust) coefl
nlcom _b[ATE:r1vs0.ed_bb] / _b[POmean:0.ed_bb]
// me gusta pero solo ATE, no ATET (read) 

teffects aipw (gini_net gdp_gro gov_debt gov_eff  ) (ed_bb gdp_gro gdp_cycle gov_debt gov_eff education_exp  , probit) if year < 2019,  aeq vce()
// Usar pomeans para buscar diferencias entres signos y encontrar diferencias

teffects ipwra (gini_net gdp_gro gov_debt gov_eff  ) (ed_bb gdp_gro gdp_cycle gov_debt gov_eff education_exp , probit) if year < 2019,  aeq


telasso (gini_net gdp_gro gdp_cycle gov_debt gov_ex) (ed_bb gov_debt gov_ex gdp_gro  gov_eff  education_exp dumiso1-dumiso22 , probit  )
bfit logit ed_bb  gdp_gro  gov_eff  education_exp
display r(bvlist)

So, how do we choose?
//
// Here are some rules of thumb:
//
// Under correct specification, all the estimators should produce similar results. (Similar estimates do not guarantee correct specification because all the specifications could be wrong.)
// When you know the determinants of treatment status, IPW is a natural base-case estimator.
// When you instead know the determinants of the outcome, RA is a natural base-case estimator.
// The doubly robust estimators, AIPW and IPWRA, give us an extra shot at correct specification.
// When you have lots of continuous covariates, NNM will crucially hinge on the bias adjustment, and the computation gets to be extremely difficult.
When you know the determinants of treatment status, PSM is another base-case estimator.
The IPW estimators are not reliable when the estimated treatment probabilities get too close to 0 or 1.


