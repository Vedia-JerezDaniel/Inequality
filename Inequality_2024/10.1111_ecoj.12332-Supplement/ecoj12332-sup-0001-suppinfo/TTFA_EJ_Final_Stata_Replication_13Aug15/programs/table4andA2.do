

*
* Table 4: Fiscal multiplier, d.CAPB, IV estimate (binary), boom/slump
*

local t1 4    // case j=1 goes to Table 4
local t2 A2   // case j=1 goes to Table A2 (with WGDP control)


foreach c in boom slump {
	gen z`c'=f.treatment*`c'
}

forvalues j=1/2 {								// one or two-way fixed effects
	forvalues i = 1/6   {						// years forward
		foreach c in boom slump {		// 
		
		* the dummy for the U.S. is dropped to avoid collinearity with the constant
		ivreg2 ly`i'   (fAA= zboom zslump) ///
			hply dml0dly dml1dly dmdumiso1-dmdumiso16 ${fe`j'} ///
			if `c'==1 & year>=1980 & year<=2007,  cluster(iso) 


		eststo `c'`i'iv`j'
		estadd scalar FirstStageFStat = e(widstat)

	}
}
	
	
label var fAA "Fisc multiplier, y = boom"

esttab boom1iv`j' boom2iv`j' boom3iv`j' boom4iv`j' boom5iv`j' boom6iv`j' ///
	using ../tables/Table`t`j''.tex , f replace keep(fAA) scalars(FirstStageFStat) ///
	b(2) se(2) sfmt(2) obslast se label star(* 0.10 ** 0.05 *** 0.01)	
	
	
label var fAA "Fisc multiplier, y = slump"

esttab slump1iv`j' slump2iv`j' slump3iv`j' slump4iv`j' slump5iv`j' slump6iv`j' ///
	using ../tables/Table`t`j''.tex , f a keep(fAA) scalars(FirstStageFStat) ///
	b(2) se(2) sfmt(2) obslast se label star(* 0.10 ** 0.05 *** 0.01)  nomtitles nonum	

}
