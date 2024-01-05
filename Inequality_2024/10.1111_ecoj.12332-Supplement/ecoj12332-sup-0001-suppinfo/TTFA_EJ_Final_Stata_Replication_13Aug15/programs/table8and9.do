

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

* raw prscore, not truncated (pihat0)
predict pihat0

* truncate ipws at 10 (pihat)
gen pihat=pihat0
replace pihat = .9 if pihat>.9 & pihat~=.
replace pihat = .1 if pihat<.1 & pihat~=.


* sort again
sort iso year
xtset ccode year

* 6 estimations:
*
* Table 9:
* DR1 = ATE no truncation of phat, common betas for controls in treatment/control
* DR2 = ATE truncation of phat, common betas for controls in treatment/control
* DR3 = ATE split by boom slump bin, common betas for controls in treatment/control
* Table 10:
* DR5 = ATE no truncation of phat, different betas for controls in treatment/control
* DR6 = ATE split by boom slump bin, different betas for controls in treatment/control


* DR - IPWRA - ATE weighted by IPWT (Davidian/Lunt) WITH COMMON SLOPE/CFEs (beta1=beta0)
* no truncations (use phat0)
capture drop a invwt
gen a=ftreatment // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat0 + (1-a)/(1-pihat0) if pihat~=. // invwt from Lunt et al.
forvalues i=1/6 {
	* SAME OUTCOME REG IN BOTH T&C THIS TIME, REST ALL THE SAME
	/*qui*/ reg ly`i' ftreatment hply dml0dly  dml1dly dmdumiso1-dmdumiso16 [pweight=invwt] ///
		if year>=1980 & year<=2007,  cluster(iso)
	gen samp=e(sample) // set sample
	predict mu0 if samp==1 & ftreatment==0 // actual
	predict mu1 if samp==1 & ftreatment==1 // actual
	replace mu0 = mu1 - _b[ftreatment] if samp==1 & ftreatment==1 // ghost
	replace mu1 = mu0 + _b[ftreatment] if samp==1 & ftreatment==0 // ghost
	*from Lunt et al
	generate mdiff1=(-(a-pihat0)*mu1/pihat0)-((a-pihat0)*mu0/(1-pihat0))
	generate iptw=(2*a-1)*ly`i'*invwt
	generate dr1=iptw+mdiff1
	qui gen ATE_IPWRA=1 // constant for convenience in next reg to get mean
	qui reg dr1 ATE_IPWRA, nocons cluster(iso)
	eststo DR1_`i'
	sum dr1
	local dr1m = r(mean)
	gen Isq  = (dr1-`dr1m')^2
	sum Isq
	estadd scalar RobustSE = sqrt(r(mean)/r(N))
	estadd scalar pvalue = normal(`dr1m'/sqrt(r(mean)/r(N)))	
	capture drop iptw Isq mdiff1 dr1 mu1 mu0 samp ATE_IPWRA
	capture scalar drop dr1m
	}



* DR - IPWRA - ATE weighted by IPWT (Davidian/Lunt) WITH COMMON SLOPE/CFEs (beta1=beta0)
* truncations (use phat)
capture drop a invwt
gen a=ftreatment // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat + (1-a)/(1-pihat) if pihat~=. // invwt from Lunt et al.
	forvalues i=1/6 {
	* SAME OUTCOME REG IN BOTH T&C THIS TIME, REST ALL THE SAME
	/*qui*/ reg ly`i' ftreatment hply dml0dly  dml1dly dmdumiso1-dmdumiso16 [pweight=invwt] ///
		if year>=1980 & year<=2007,  cluster(iso)
	gen samp=e(sample) // set sample
	predict mu0 if samp==1 & ftreatment==0 // actual
	predict mu1 if samp==1 & ftreatment==1 // actual
	replace mu0 = mu1 - _b[ftreatment] if samp==1 & ftreatment==1 // ghost
	replace mu1 = mu0 + _b[ftreatment] if samp==1 & ftreatment==0 // ghost
	*from Lunt et al
	generate mdiff1=(-(a-pihat)*mu1/pihat)-((a-pihat)*mu0/(1-pihat))
	generate iptw=(2*a-1)*ly`i'*invwt
	generate dr1=iptw+mdiff1
	qui gen ATE_IPWRA=1 // constant for convenience in next reg to get mean
	qui reg dr1 ATE_IPWRA, nocons cluster(iso)
	eststo DR2_`i'
	sum dr1
	local dr1m = r(mean)
	gen Isq  = (dr1-`dr1m')^2
	sum Isq
	estadd scalar RobustSE = sqrt(r(mean)/r(N))
	estadd scalar pvalue = normal(`dr1m'/sqrt(r(mean)/r(N)))	
	capture drop iptw Isq mdiff1 dr1 mu1 mu0 samp ATE_IPWRA*
	capture scalar drop dr1m
	}



* DR - IPWRA - ATE weighted by IPWT (Davidian/Lunt) WITH COMMON SLOPE/CFEs (beta1=beta0)
* ATE split by bin
* no truncations (use phat0)
capture drop a invwt
gen a=ftreatment // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat0 + (1-a)/(1-pihat0) if pihat~=. // invwt from Lunt et al.
	forvalues i=1/6 {
	* SAME OUTCOME REG IN BOTH T&C THIS TIME, REST ALL THE SAME
	capture drop mu1 mu0
	gen mu0=.
	gen mu1=.
	foreach bin in boom slump {
		/*qui*/ reg ly`i' ftreatment hply dml0dly  dml1dly dmdumiso1-dmdumiso16 [pweight=invwt] ///
			if year>=1980 & year<=2007 & `bin'==1 ,  cluster(iso)
		gen samp=e(sample) // set sample
		predict temp
		replace mu0 = temp                 if samp==1 & ftreatment==0 & `bin'==1 // actual
		replace mu1 = temp                 if samp==1 & ftreatment==1 & `bin'==1 // actual
		replace mu0 = mu1 - _b[ftreatment] if samp==1 & ftreatment==1 & `bin'==1 // ghost
		replace mu1 = mu0 + _b[ftreatment] if samp==1 & ftreatment==0 & `bin'==1 // ghost
		capture drop samp temp
		}
	*from Lunt et al
	generate mdiff1=(-(a-pihat0)*mu1/pihat0)-((a-pihat0)*mu0/(1-pihat0))
	generate iptw=(2*a-1)*ly`i'*invwt
	generate dr1=iptw+mdiff1
	sum dr1
	local dr1m = r(mean)
	gen Isq  = (dr1-`dr1m')^2
	qui gen ATE_IPWRA_boom  = boom  // constant for convenience in next reg to get mean
	qui gen ATE_IPWRA_slump  = slump  // constant for convenience in next reg to get mean
	qui reg dr1 ATE_IPWRA_boom ATE_IPWRA_slump , nocons cluster(iso)
	eststo DR3_`i'
	sum dr1 if boom==1
	local dr1m = r(mean)
	sum Isq if boom==1
	estadd scalar RobustSEboom = sqrt(r(mean)/r(N))
	estadd scalar pvalueboom = normal(`dr1m'/sqrt(r(mean)/r(N)))	
	sum dr1 if slump==1
	local dr1m = r(mean)
	sum Isq if slump==1
	estadd scalar RobustSEslump = sqrt(r(mean)/r(N))
	estadd scalar pvalueslump = normal(`dr1m'/sqrt(r(mean)/r(N)))	
	capture drop iptw Isq mdiff1 dr1 mu1 mu0 ATE_IPWRA*
	capture scalar drop dr1m
	}






* DR - IPWRA - ATE weighted by IPWT (Davidian/Lunt) WITH DIFFERENT SLOPE/CFEs (beta1.NEQ.beta0)
* ATE split by bin
* no truncations (use phat0)
capture drop a invwt
gen a=ftreatment // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat0 + (1-a)/(1-pihat0) if pihat~=. // invwt from Lunt et al.
	forvalues i=1/6 {
	* SAME OUTCOME REG IN BOTH T&C THIS TIME, REST ALL THE SAME
	gen mu0=.
	gen mu1=.
	
		/*qui*/ reg ly`i'  hply dml0dly  dml1dly dmdumiso1-dmdumiso16 [pweight=invwt] ///
			if year>=1980 & year<=2007 & ftreatment==0,  cluster(iso)
		capture drop temp
		predict temp
		replace mu0 = temp if year>=1980 & year<=2007   
		
		
		/*qui*/ reg ly`i'  hply dml0dly  dml1dly dmdumiso1-dmdumiso16 [pweight=invwt] ///
			if year>=1980 & year<=2007 & ftreatment==1,  cluster(iso)
		capture drop temp
		predict temp
		replace mu1 = temp if year>=1980 & year<=2007   
		
	*from Lunt et al
	generate mdiff1=(-(a-pihat0)*mu1/pihat0)-((a-pihat0)*mu0/(1-pihat0))
	generate iptw=(2*a-1)*ly`i'*invwt
	generate dr1=iptw+mdiff1
	
	qui gen ATE_IPWRA=1 // constant for convenience in next reg to get mean
	qui reg dr1 ATE_IPWRA, nocons cluster(iso)
	eststo DR5_`i'
	sum dr1
	local dr1m = r(mean)
	gen Isq  = (dr1-`dr1m')^2
	sum Isq
	estadd scalar RobustSE = sqrt(r(mean)/r(N))
	estadd scalar pvalue = normal(`dr1m'/sqrt(r(mean)/r(N)))	
	capture drop iptw Isq mdiff1 dr1 mu1 mu0 ATE_IPWRA
	capture scalar drop dr1m

	}






* DR - IPWRA - ATE weighted by IPWT (Davidian/Lunt) WITH DIFFERENT SLOPE/CFEs (beta1.NEQ.beta0)
* ATE split by bin
* no truncations (use phat0)
capture drop a invwt
gen a=ftreatment // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat0 + (1-a)/(1-pihat0) if pihat~=. // invwt from Lunt et al.
	forvalues i=1/6 {
	* SAME OUTCOME REG IN BOTH T&C THIS TIME, REST ALL THE SAME
	capture drop mu1 mu0
	gen mu0=.
	gen mu1=.
	foreach bin in boom slump {
	
		/*qui*/ reg ly`i'  hply dml0dly  dml1dly dmdumiso1-dmdumiso16 [pweight=invwt] ///
			if year>=1980 & year<=2007 & `bin'==1 & ftreatment==0,  cluster(iso)
		capture drop temp
		predict temp
		replace mu0 = temp if year>=1980 & year<=2007 & `bin'==1  

		
		/*qui*/ reg ly`i'  hply dml0dly  dml1dly dmdumiso1-dmdumiso16 [pweight=invwt] ///
			if year>=1980 & year<=2007 & `bin'==1 & ftreatment==1,  cluster(iso)
		capture drop temp
		predict temp
		replace mu1 = temp if year>=1980 & year<=2007 & `bin'==1  

		}
	*from Lunt et al
	generate mdiff1=(-(a-pihat0)*mu1/pihat0)-((a-pihat0)*mu0/(1-pihat0))
	generate iptw=(2*a-1)*ly`i'*invwt
	generate dr1=iptw+mdiff1
	
	gen Isq=.
	sum dr1 if boom==1
	local dr1m = r(mean)
	replace Isq  = (dr1-`dr1m')^2  if boom==1
	sum dr1 if slump==1
	local dr1m = r(mean)
	replace Isq  = (dr1-`dr1m')^2  if slump==1
	
	qui gen ATE_IPWRA_boom  = boom  // constant for convenience in next reg to get mean
	qui gen ATE_IPWRA_slump  = slump  // constant for convenience in next reg to get mean
	qui reg dr1 ATE_IPWRA_boom ATE_IPWRA_slump , nocons cluster(iso)
	eststo DR6_`i'
	
	sum dr1 if boom==1
	local dr1m = r(mean)
	sum Isq if boom==1
	estadd scalar RobustSEboom = sqrt(r(mean)/r(N))
	estadd scalar pvalueboom = normal(`dr1m'/sqrt(r(mean)/r(N)))
	
	sum dr1 if slump==1
	local dr1m = r(mean)
	sum Isq if slump==1
	estadd scalar RobustSEslump = sqrt(r(mean)/r(N))
	estadd scalar pvalueslump = normal(`dr1m'/sqrt(r(mean)/r(N)))	
	capture drop iptw Isq mdiff1 dr1 mu1 mu0 ATE_IPWRA*
	capture scalar drop dr1m
	}






* Table 8: same slope vs. different slopes

* fix labels
	qui gen ATE_IPWRA=1 // constant for convenience in next reg to get mean
	qui gen ATE_IPWRA_boom  = boom  // constant for convenience in next reg to get mean
	qui gen ATE_IPWRA_slump  = slump  // constant for convenience in next reg to get mean


label var ATE_IPWRA "ATE u wts"

esttab DR1_1 DR1_2 DR1_3 DR1_4 DR1_5 DR1_6 , /// 
	scalars(RobustSE pvalue)  ///
	title("Table 8. ATE-IP (DR) i.p. weights, Unrestricted, b0=b1") ///
	b(2) se(2) sfmt(2) obslast label star(* 0.10 ** 0.05 *** 0.01)

esttab DR5_1 DR5_2 DR5_3 DR5_4 DR5_5 DR5_6 , /// 
	scalars(RobustSE pvalue)  ///
	title("Table 8. ATE-IP (DR) i.p. weights, Unrestricted, b0.neq.b1") 

esttab DR1_1 DR1_2 DR1_3 DR1_4 DR1_5 DR1_6  ///
	using ../tables/Table8.tex ,  f replace ///
	title("Table 9a. ATE-IP (DR) i.p. weights, Unrestricted, b0=b1") ///
	b(2) se(2) sfmt(2) obslast label   star(* 0.10 ** 0.05 *** 0.01)

esttab DR5_1 DR5_2 DR5_3 DR5_4 DR5_5 DR5_6  /// 
	using ../tables/Table8.tex ,  f append ///
	title("Table 8. ATE-IP (DR) i.p. weights, Unrestricted, b0.neq.b1") ///
	b(2) se(2) sfmt(2) obslast label   star(* 0.10 ** 0.05 *** 0.01)


label var ATE_IPWRA_boom "ATE u wts boom"
label var ATE_IPWRA_slump "ATE u wts slump"

esttab DR6_1 DR6_2 DR6_3 DR6_4 DR6_5 DR6_6 , ///
	title("Table 9. ATE-IP (DR) i.p. weights, Unrestricted, H/L, b0.neq.b1") ///
	scalars(RobustSEboom pvalueboom RobustSEslump  pvalueslump) ///
	b(2) se(2) sfmt(2) obslast label   nonum star(* 0.10 ** 0.05 *** 0.01)

* Table 9 by bin, different slopes b1 ne b0


esttab DR6_1 DR6_2 DR6_3 DR6_4 DR6_5 DR6_6 ///
	using ../tables/Table9.tex ,  f replace ///
	title("Table 9. ATE-IP (DR) i.p. weights, Unrestricted, H/L, b0.neq.b1") ///
	b(2) se(2) sfmt(2) obslast label   nonum star(* 0.10 ** 0.05 *** 0.01)

capture drop ATE_IPWRA*


