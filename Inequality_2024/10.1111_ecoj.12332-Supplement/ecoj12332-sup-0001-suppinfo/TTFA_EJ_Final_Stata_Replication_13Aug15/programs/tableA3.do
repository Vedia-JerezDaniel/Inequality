

*
* Table A3. Fiscal average treatment effect, inverse propensity score weighted estimate (ATE-IPW),
* boom v slumps, robustness checks using different p-score models
*

local method probit logit

*** country FE probit/logit; country and world GDP FE probit/logit


xi: probit ftreatment debtgdp hply dly ldly treatment ///
	drprv dlcpi dlriy stir ltrate cay dmdumiso1-dmdumiso16 if year>=1980 & year<=2007 
	predict pp
xi: probit ftreatment debtgdp hply dly ldly treatment ///
	drprv dlcpi dlriy stir ltrate cay dmdumiso1-dmdumiso16 wgdp if year>=1980 & year<=2007 
	predict ppw

xi: xtlogit ftreatment debtgdp hply dly ldly treatment ///
	drprv dlcpi dlriy stir ltrate cay  if year>=1980 & year<=2007 ,fe
	predict pl
xi: xtlogit ftreatment debtgdp hply dly ldly treatment ///
	drprv dlcpi dlriy stir ltrate cay dmdumiso1-dmdumiso16 wgdp if year>=1980 & year<=2007 ,fe 
	predict plw


* truncations: none, 0.1, 0.2
foreach psc in pp ppw pl plw {

gen p = `psc'

gen `psc'_nt=p if p~=.

gen     `psc'_10=min(.9,p) if p~=.
replace `psc'_10=max(.1,p) if p~=.

gen     `psc'_5=min(.8,p) if p~=.
replace `psc'_5=max(.2,p) if p~=.

capture drop p
}

*** Models (5)
*** 0. country FE probit (not shown; main result)
*** 1. country FE probit and world GDP in 1/2 stages
*** 2. country FE logit 
*** 3. country FE logit and world GDP in 1/2 stages
*** 4. country FE probit, truncate 0.1<psc<0.9 
*** 5. country FE probit, truncate 0.2<psc<0.8 

* rhs for each model
global rhs_m0 
global rhs_m1 wgdp
global rhs_m2 
global rhs_m3 wgdp
global rhs_m4 
global rhs_m5 

* psc for each model
gen p_m0 = pp
gen p_m1 = ppw
gen p_m2 = pl
gen p_m3 = plw
gen p_m4 = pp_10
gen p_m5 = pp_5


* DR - IPWRA - ATE weighted by IPWT (Davidian/Lunt) WITH DIFFERENT SLOPE/CFEs (beta1 neq beta0)
* ATE split by bin

	forvalues x=1/5 {
	capture drop pihat a invwt
	capture drop iptw Isq mdiff1 dr1 mu1 mu0 ATE_boom ATE_slump
	gen pihat = p_m`x'
	gen a=ftreatment // define treatment indicator as a from Lunt et al.
	generate invwt=a/pihat + (1-a)/(1-pihat) if pihat~=. // invwt from Lunt et al.
	capture drop mu1 mu0
	gen mu0=.
	gen mu1=.
	foreach bin in boom slump {
		/*qui*/ reg ly6  hply dml0dly  dml1dly dmdumiso1-dmdumiso16 [pweight=invwt] /// ly6 = sum
			if year>=1980 & year<=2007 & `bin'==1 & ftreatment==0,  cluster(iso)
		capture drop temp
		predict temp
		replace mu0 = temp if year>=1980 & year<=2007 & `bin'==1  
		
		/*qui*/ reg ly6  hply dml0dly  dml1dly dmdumiso1-dmdumiso16 [pweight=invwt] /// ly6 = sum
			if year>=1980 & year<=2007 & `bin'==1 & ftreatment==1,  cluster(iso)
		capture drop temp
		predict temp
		replace mu1 = temp if year>=1980 & year<=2007 & `bin'==1  		
		}
	*from Lunt et al
	generate mdiff1=(-(a-pihat)*mu1/pihat)-((a-pihat)*mu0/(1-pihat))
	generate iptw=(2*a-1)*ly6*invwt
	generate dr1=iptw+mdiff1
	sum dr1
	capture scalar drop dr1m
	local dr1m = r(mean)
	gen Isq  = (dr1-`dr1m')^2
	qui gen ATE_boom  = boom  // constant for convenience in next reg to get mean
	qui gen ATE_slump  = slump  // constant for convenience in next reg to get mean
	qui reg dr1 ATE_boom ATE_slump , nocons cluster(iso)
	eststo phat`x'drBS
	sum Isq if boom==1
	estadd scalar RobSEboom = sqrt(r(mean)/r(N))
	sum Isq if slump==1
	estadd scalar RobSEslump = sqrt(r(mean)/r(N))

	* 1st stage auc
	qui roctab ftreatment pihat
	estadd scalar Stage1AUC = r(area)
	estadd scalar se = r(se)
	
	
	}


esttab phat1drBS phat2drBS phat3drBS phat4drBS phat5drBS, ///
	title("A3. ATE-IP (DR) i.p. weights, Truncated, H/M/L") ///
	scalars(RobSEboom  RobSEslump  Stage1AUC se) nostar not

esttab phat1drBS phat2drBS phat3drBS phat4drBS phat5drBS ///
	using ../tables/TableA3.tex ,  f replace ///
	title("A3. ATE-IP (DR) i.p. weights, Truncated, H/M/L") ///
	scalars(RobSEboom  RobSEslump  Stage1AUC se ) ///
	b(2) se(2) sfmt(2) obslast label  star(* 0.10 ** 0.05 *** 0.01)

eststo clear

