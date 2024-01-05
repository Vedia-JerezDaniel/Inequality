/* ifs indicates the country */
sort ifs year								
xtset  ifs year, yearly

/******************** Some Data transformations ***************/
/* convert to RGDP and take log */
gen lgdpr = 100*ln(rgdppc*pop)				
gen lcpi = 100*ln(cpi)						

gen dlcpi = d.lcpi
gen dlgdpr = d.lgdpr
gen dstir = d.stir
gen lstir = l.stir

foreach x in lgdpr lcpi stir {
forv h = 0/4 {
gen `x'`h' = f`h'.`x' - l.f`h'.`x'		

}
}

lev lgdpr lcpi lstir

forvalues i=0/4 {
	reg lgdpr`i' crisisJST lev lcpi lstir  [pweight=invwt] if year>=1980 & year<=2007,  cluster(ifs)
	gen samp=e(sample) // set sample
	predict mu0 if samp==1 & ftreatment==0 // actual
	predict mu1 if samp==1 & ftreatment==1 // actual
	replace mu0 = mu1 - _b[ftreatment] if samp==1 & ftreatment==1 // ghost
	replace mu1 = mu0 + _b[ftreatment] if samp==1 & ftreatment==0 // ghost
	*from Lunt et al
	generate mdiff1=(-(a-pihat0)*mu1/pihat0)-((a-pihat0)*mu0/(1-pihat0))
	generate iptw=(2*a-1)*lgdpr`i'*invwt
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
	
	
	
forvalues i=0/4 {
	reg lgdpr`i' crisisJST lev lcpi lstir  [pweight=invwt] if year>=1980 & year<=2007,  cluster(ifs)
	gen samp=e(sample) 
	predict mu0 if samp==1 & crisisJST ==0 
	predict mu1 if samp==1 & crisisJST ==1 
	replace mu0 = mu1 - _b[crisisJST ] if samp==1 & crisisJST ==1 
	replace mu1 = mu0 + _b[crisisJST ] if samp==1 & crisisJST ==0 
	generate mdiff1=(-(a-pihat0)*mu1/pihat0)-((a-pihat0)*mu0/(1-pihat0))
	generate iptw=(2*a-1)*lgdpr`i'*invwt
	generate dr1=iptw+mdiff1
	qui gen ATE_IPWRA=1 
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
	
	
esttab DR1_1 DR1_2 DR1_3 DR1_4 DR1_5 DR1_6 , scalars(RobustSE pvalue)  title("Table 8. ATE-IP (DR) i.p. weights, Unrestricted, b0=b1") b(2) se(2) sfmt(2) obslast label star(* 0.10 ** 0.05 *** 0.01)