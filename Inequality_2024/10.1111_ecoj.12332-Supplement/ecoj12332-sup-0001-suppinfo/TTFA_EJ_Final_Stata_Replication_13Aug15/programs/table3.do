

*
* Table 3: Fiscal multiplier, d.CAPB, IV estimates. Log real GDP (relative to Year 0, x 100)
*

local instru treatment total

foreach v of local instru {
	forvalues i = 1/6   {
	
	* the dummy for the U.S. is dropped to avoid collinearity with the constant
	ivreg2 ly`i'   (fAA= f.`v') ///
		hply dml0dly dml1dly dmdumiso1-dmdumiso16 ///
		if year>=1980 & year<=2007,  cluster(iso) 

		eststo iv`v'`i'
		estadd scalar FirstStageFStat = e(widstat)
	
	}
}


label var fAA " Fisc multiplier, binary IV"

esttab ivtreatment1 ivtreatment2 ivtreatment3 ivtreatment4 ivtreatment5 ivtreatment6 ///
	using ../tables/Table3.tex , f replace keep(fAA) scalars(FirstStageFStat) ///
	title("Table 3. Fiscal multiplier, d.CAPB, IV = IMF treatment or total") ///
	b(2) se(2) sfmt(2) obslast se label star(* 0.10 ** 0.05 *** 0.01)  	


label var fAA " Fisc multiplier, cts. IV"

esttab ivtotal1 ivtotal2 ivtotal3 ivtotal4 ivtotal5 ivtotal6 ///
	using ../tables/Table3.tex , f a keep(fAA) scalars(FirstStageFStat) ///
	b(2) se(2) sfmt(2) obslast se label star(* 0.10 ** 0.05 *** 0.01)  nomtitles nonum	


