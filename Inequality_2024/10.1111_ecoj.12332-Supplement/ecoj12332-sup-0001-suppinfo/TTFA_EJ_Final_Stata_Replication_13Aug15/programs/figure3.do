

*
* Fgure 3. Compare LPIV with LPIPWRA with different outcome slopes  m(X,b1) m(X,b0)
*


preserve // will redefine outcome variables for second pass

graph drop _all


* go out to year 5

drop ly1 ly2 ly3 ly4 ly5

* dep vars for h-step ahead forecast (h=1,...,4)
local var ly 		// ftreatment depvar used in Table A5

foreach v of local var {
	forvalues i=1/5 {
		if "`v'"=="ly" {
		gen `v'`i' = f`i'.`v' - `v'
		}
		if "`v'"=="ftreatment" {
		gen `v'`i' = f`i'.`v'
		}
		label var `v'`i' "Year `i'"
	}
}


**** first pass: use level impacts in each year

* make variables
capture drop LPIV* LPIP* _Year
gen LPIVboom  = .
gen LPIVslump = .
gen LPIVboomse  = .
gen LPIVslumpse = .
gen LPIPboom  = .
gen LPIPslump = .
gen LPIPboomse  = .
gen LPIPslumpse = .
gen _Year = _n if _n <=5
label var _Year "Year"

* copy code below from Tables 4 and 9/10


*
* Tables 9 and 10. DR ATE of fiscal consolidation on real GDP, inverse propensity score weights.
* Log real GDP (relative to Year 0, x 100)
*

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



* Preferred ATE (Table 10)
* By bin with no truncation, common betas

* DR - IPWRA - ATE weighted by IPWT (Davidian/Lunt) WITH different SLOPEs
* ATE split by bin
* no truncations (use phat0)
capture drop a invwt
gen a=ftreatment // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat0 + (1-a)/(1-pihat0) if pihat~=. // invwt from Lunt et al.
	forvalues i=1/5 {
	capture scalar drop dr1m
	* SAME OUTCOME REG IN BOTH T&C THIS TIME, REST ALL THE SAME
	capture drop  mu1 mu0 
	gen mu0=.
	gen mu1=.
	foreach bin in boom slump {
	
		qui reg ly`i'  hply dml0dly  dml1dly dmdumiso1-dmdumiso16 [pweight=invwt] ///
			if year>=1980 & year<=2007 & `bin'==1 & ftreatment==0,  cluster(iso)
		capture drop temp
		predict temp
		replace mu0 = temp if year>=1980 & year<=2007 & `bin'==1  
		
		qui reg ly`i'  hply dml0dly  dml1dly dmdumiso1-dmdumiso16 [pweight=invwt] ///
			if year>=1980 & year<=2007 & `bin'==1 & ftreatment==1,  cluster(iso)
		capture drop temp
		predict temp
		replace mu1 = temp if year>=1980 & year<=2007 & `bin'==1  
		
		}
	*from Lunt et al
	capture drop mdiff1 iptw dr1 Isq ATE_IPWRA*
	generate mdiff1=(-(a-pihat0)*mu1/pihat0)-((a-pihat0)*mu0/(1-pihat0))
	generate iptw=(2*a-1)*ly`i'*invwt
	generate dr1=iptw+mdiff1
	sum dr1
	local dr1m = r(mean)
	gen Isq  = (dr1-`dr1m')^2
	qui gen ATE_IPWRA_boom  = boom  // constant for convenience in next reg to get mean
	qui gen ATE_IPWRA_slump  = slump  // constant for convenience in next reg to get mean
	qui reg dr1 ATE_IPWRA_boom ATE_IPWRA_slump , nocons cluster(iso)
	
		* store for charts
		replace LPIPboom     = _b[ATE_IPWRA_boom]    if _Year==`i'
		replace LPIPslump    = _b[ATE_IPWRA_slump]   if _Year==`i'
		replace LPIPboomse 	 = _se[ATE_IPWRA_boom]   if _Year==`i'
		replace LPIPslumpse  = _se[ATE_IPWRA_slump]   if _Year==`i'

	eststo DR3_`i'
	sum dr1 if boom==1
	local dr1m = r(mean)
	sum Isq if boom==1
	estadd scalar RobustSEboom = sqrt(r(mean)/r(N))

		* store for charts
		*replace LPIPboomse 	 = sqrt(r(mean)/r(N))   if _Year==`i'
	
	estadd scalar pvalueboom = normal(`dr1m'/sqrt(r(mean)/r(N)))	
	sum dr1 if slump==1
	local dr1m = r(mean)
	sum Isq if slump==1
	estadd scalar RobustSEslump = sqrt(r(mean)/r(N))

		* store for charts
		*replace LPIPslumpse  = sqrt(r(mean)/r(N))   if _Year==`i'
	
	estadd scalar pvalueslump = normal(`dr1m'/sqrt(r(mean)/r(N)))	

	capture drop iptw Isq mdiff1 dr1 mu1 mu0 ATE_IPWRA*
		
	}


	
* Table 4: Fiscal multiplier, d.CAPB, IV estimate (binary), boom/slump
*

local t1 4    // case j=1 goes to Table 4
local t2 A2   // case j=1 goes to Table A2 (with WGDP control)

capture drop zboom zslump
foreach c in boom slump {
	gen z`c'=f.treatment*`c'
}

	forvalues i = 1/5   {						// years forward
		foreach c in boom slump {		// 

		ivreg ly`i'   (fAA= zboom zslump) ///
			hply dml0dly dml1dly dmdumiso1-dmdumiso16  ///
			if `c'==1 & year>=1980 & year<=2007,  cluster(iso)

			* store for charts
			replace LPIV`c'    = _b[fAA]       if _Year==`i'
			replace LPIV`c'se  = _se[fAA]      if _Year==`i'

		eststo `c'`i'iv`j'
		
	}
}
	
	


* charts

capture drop x_* up_* dn_* up10_* dn10_*

* SCALE UP GIVEN AVG TREATMENT SIZE IN EACH BIN
local scaling_LPIPboom   1.00/0.9726035
local scaling_LPIPslump  1.00/0.9726035
local scaling_LPIVboom   1.00
local scaling_LPIVslump  1.00

foreach s in LPIPboom LPIPslump LPIVboom LPIVslump {
	gen x_`s'      = `scaling_`s'' * `s'
	gen up_`s'     = `scaling_`s'' * (`s' + 1.96 * `s'se)
	gen dn_`s'     = `scaling_`s'' * (`s' - 1.96 * `s'se)
	gen up10_`s'   = `scaling_`s'' * (`s' + 1.64 * `s'se)
	gen dn10_`s'   = `scaling_`s'' * (`s' - 1.64 * `s'se)
	}
	
capture drop _Zero
gen _Zero = 0


twoway	(rarea up_LPIPboom dn_LPIPboom _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LPIPboom dn10_LPIPboom _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LPIPboom _Year, lcolor(red) lpattern(solid) lwidth(thick)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, legend(off) title("AIPW estimates: boom")
		graph rename g1a

twoway	(rarea up_LPIVboom dn_LPIVboom _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LPIVboom dn10_LPIVboom _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LPIVboom _Year, lcolor(blue) lpattern(solid) lwidth(thick)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, legend(off) title("IV estimates: boom")
		graph rename g2a

		
twoway	(rarea up_LPIPslump dn_LPIPslump _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LPIPslump dn10_LPIPslump _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LPIPslump _Year, lcolor(red) lpattern(solid) lwidth(thick)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, legend(off) title("AIPW estimates: slump")
		graph rename g3a
		

twoway	(rarea up_LPIVslump dn_LPIVslump _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LPIVslump dn10_LPIVslump _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LPIVslump _Year, lcolor(blue) lpattern(solid) lwidth(thick)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, legend(off) title("IV estimates: slump")
		graph rename g4a
	

gr combine g1a g2a g3a g4a, ycommon title("(a) Year-by-year ATE output losses")
graph rename ga

graph export ../figures/figure3xa.pdf, replace
graph save   ../figures/figure3xa.gph, replace


****second pass: use cumulative impacts up to each year


replace ly2 = ly1 + ly2
replace ly3 = ly2 + ly3
replace ly4 = ly3 + ly4
replace ly5 = ly4 + ly5

* make variables
capture drop LPIV* LPIP* _Year
gen LPIVboom  = .
gen LPIVslump = .
gen LPIVboomse  = .
gen LPIVslumpse = .
gen LPIPboom  = .
gen LPIPslump = .
gen LPIPboomse  = .
gen LPIPslumpse = .
gen _Year = _n if _n <=5
label var _Year "Year"

* copy code below from Tables 4 and 9/10


*
* Tables 9 and 10. DR ATE of fiscal consolidation on real GDP, inverse propensity score weights.
* Log real GDP (relative to Year 0, x 100)
*

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



* Preferred ATE (Table 10)
* By bin with no truncation, common betas

* DR - IPWRA - ATE weighted by IPWT (Davidian/Lunt) WITH different SLOPEs
* ATE split by bin
* no truncations (use phat0)
capture drop a invwt
gen a=ftreatment // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat0 + (1-a)/(1-pihat0) if pihat~=. // invwt from Lunt et al.
	forvalues i=1/5 {
	capture drop  mu1 mu0 
	* SAME OUTCOME REG IN BOTH T&C THIS TIME, REST ALL THE SAME
	gen mu0=.
	gen mu1=.
	foreach bin in boom slump {
	
		qui reg ly`i'  hply dml0dly  dml1dly dmdumiso1-dmdumiso16 [pweight=invwt] ///
			if year>=1980 & year<=2007 & `bin'==1 & ftreatment==0,  cluster(iso)
		capture drop temp
		predict temp
		replace mu0 = temp if year>=1980 & year<=2007 & `bin'==1  
		
		qui reg ly`i'  hply dml0dly  dml1dly dmdumiso1-dmdumiso16 [pweight=invwt] ///
			if year>=1980 & year<=2007 & `bin'==1 & ftreatment==1,  cluster(iso)
		capture drop temp
		predict temp
		replace mu1 = temp if year>=1980 & year<=2007 & `bin'==1  
		
		}
	*from Lunt et al
	capture drop mdiff1 iptw dr1 Isq ATE_IPWRA*
	generate mdiff1=(-(a-pihat0)*mu1/pihat0)-((a-pihat0)*mu0/(1-pihat0))
	generate iptw=(2*a-1)*ly`i'*invwt
	generate dr1=iptw+mdiff1
	sum dr1
	local dr1m = r(mean)
	gen Isq  = (dr1-`dr1m')^2
	qui gen ATE_IPWRA_boom  = boom  // constant for convenience in next reg to get mean
	qui gen ATE_IPWRA_slump  = slump  // constant for convenience in next reg to get mean
	qui reg dr1 ATE_IPWRA_boom ATE_IPWRA_slump , nocons cluster(iso)
	
		* store for charts
		replace LPIPboom     = _b[ATE_IPWRA_boom]    if _Year==`i'
		replace LPIPslump    = _b[ATE_IPWRA_slump]   if _Year==`i'
		replace LPIPboomse 	 = _se[ATE_IPWRA_boom]   if _Year==`i'
		replace LPIPslumpse  = _se[ATE_IPWRA_slump]   if _Year==`i'

	eststo DR3_`i'
	sum dr1 if boom==1
	local dr1m = r(mean)
	sum Isq if boom==1
	estadd scalar RobustSEboom = sqrt(r(mean)/r(N))

		* store for charts
		*replace LPIPboomse 	 = sqrt(r(mean)/r(N))   if _Year==`i'
	
	estadd scalar pvalueboom = normal(`dr1m'/sqrt(r(mean)/r(N)))	
	sum dr1 if slump==1
	local dr1m = r(mean)
	sum Isq if slump==1
	estadd scalar RobustSEslump = sqrt(r(mean)/r(N))

		* store for charts
		*replace LPIPslumpse  = sqrt(r(mean)/r(N))   if _Year==`i'
	
	estadd scalar pvalueslump = normal(`dr1m'/sqrt(r(mean)/r(N)))	

	drop iptw Isq mdiff1 dr1 mu1 mu0 ATE_IPWRA*
		
	}


	

	


* Table 4: Fiscal multiplier, d.CAPB, IV estimate (binary), boom/slump
*

local t1 4    // case j=1 goes to Table 4
local t2 A2   // case j=1 goes to Table A2 (with WGDP control)

capture drop zboom zslump
foreach c in boom slump {
	gen z`c'=f.treatment*`c'
}

	forvalues i = 1/5   {						// years forward
		foreach c in boom slump {		// 

		ivreg ly`i'   (fAA= zboom zslump) ///
			hply dml0dly dml1dly dmdumiso1-dmdumiso16  ///
			if `c'==1 & year>=1980 & year<=2007,  cluster(iso)

			* store for charts
			replace LPIV`c'    = _b[fAA]       if _Year==`i'
			replace LPIV`c'se  = _se[fAA]      if _Year==`i'

		eststo `c'`i'iv`j'
		
	}
}
	
	



* charts

capture drop x_* up_* dn_* up10_* dn10_*

* SCALE UP GIVEN AVG TREATMENT SIZE IN EACH BIN
local scaling_LPIPboom   1.00/0.9726035
local scaling_LPIPslump  1.00/0.9726035
local scaling_LPIVboom   1.00
local scaling_LPIVslump  1.00

foreach s in LPIPboom LPIPslump LPIVboom LPIVslump {
	gen x_`s'      = `scaling_`s'' * `s'
	gen up_`s'     = `scaling_`s'' * (`s' + 1.96 * `s'se)
	gen dn_`s'     = `scaling_`s'' * (`s' - 1.96 * `s'se)
	gen up10_`s'   = `scaling_`s'' * (`s' + 1.64 * `s'se)
	gen dn10_`s'   = `scaling_`s'' * (`s' - 1.64 * `s'se)
	}
	
capture drop _Zero
gen _Zero = 0
	
capture drop _Zero
gen _Zero = 0

twoway	(rarea up_LPIPboom dn_LPIPboom _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LPIPboom dn10_LPIPboom _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LPIPboom _Year, lcolor(red) lpattern(solid) lwidth(thick)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, legend(off) title("AIPW estimates: boom")
		graph rename g1b

twoway	(rarea up_LPIVboom dn_LPIVboom _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LPIVboom dn10_LPIVboom _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LPIVboom _Year, lcolor(blue) lpattern(solid) lwidth(thick)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, legend(off) title("IV estimates: boom")
		graph rename g2b

		
twoway	(rarea up_LPIPslump dn_LPIPslump _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LPIPslump dn10_LPIPslump _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LPIPslump _Year, lcolor(red) lpattern(solid) lwidth(thick)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, legend(off) title("AIPW estimates: slump")
		graph rename g3b
		

twoway	(rarea up_LPIVslump dn_LPIVslump _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LPIVslump dn10_LPIVslump _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LPIVslump _Year, lcolor(blue) lpattern(solid) lwidth(thick)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, legend(off) title("IV estimates: slump")
		graph rename g4b
	
gr combine g1b g2b g3b g4b, ycommon title("(b) Cumulative ATE output losses")
graph rename gb

graph export ../figures/figure3xb.pdf, replace
graph save   ../figures/figure3xb.gph, replace

/*
gr combine ga gb , title("Different treatment model slopes b1 ­ b0")

graph export ../figures/figure3x.pdf, replace
graph save   ../figures/figure3x.gph, replace
*/

gr combine ga gb , // no title

graph export ../figures/figure3.pdf, replace
graph save   ../figures/figure3.gph, replace


gr drop _all



restore // **** second pass done

