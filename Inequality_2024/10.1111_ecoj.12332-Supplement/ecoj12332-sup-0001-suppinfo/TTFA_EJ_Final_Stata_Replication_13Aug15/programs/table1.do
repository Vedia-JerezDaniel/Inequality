

*
* Table 1: Fiscal muliplier, d.CAPB, OLS estimate
*

gen lgfAA = 0
replace lgfAA = fAA if abs(fAA)>1.5

gen smfAA = 0
replace smfAA = fAA if abs(fAA)<=1.5

*** OLS AA all changes in dCAPB full sample

label var fAA "Fisc multiplier. Full sample"
label var lgfAA "Fisc multiplier. Large Cons."
label var smfAA "Fisc multiplier. Small Cons."


forvalues i=1/6 {

	* the dummy for the U.S. is dropped to avoid collinearity with the constant

	* specification a la AA
	reg ly`i'   fAA ///
		hply dml0dly dml1dly dmdumiso1-dmdumiso16 ///
		if year>=1980 & year<=2007,  cluster(iso) 
		
	eststo ols`i'	
	
	reg ly`i'   smfAA lgfAA  ///
		hply dml0dly dml1dly dmdumiso1-dmdumiso16  ///
		if year>=1980 & year<=2007,  cluster(iso) 
		
	eststo lgsm`i'

}
	
esttab ols1 ols2 ols3 ols4 ols5 ols6 using ../tables/Table1.tex , keep(fAA) f replace ///
	title("Table 1. Fiscal multiplier, d.CAPB, OLS estimate. Log real GDP (relative to Year0, x 100") ///
	b(2) se(2) sfmt(2) obslast se label star(* 0.10 ** 0.05 *** 0.01) 

esttab lgsm1 lgsm2 lgsm3 lgsm4 lgsm5 lgsm6 using ../tables/Table1.tex , keep(lgfAA) f a ///
	b(2) se(2) sfmt(2) obslast se label star(* 0.10 ** 0.05 *** 0.01)  nomtitles nonum
	
esttab lgsm1 lgsm2 lgsm3 lgsm4 lgsm5 lgsm6 using ../tables/Table1.tex , keep(smfAA) f a ///
	b(2) se(2) sfmt(2) obslast se label star(* 0.10 ** 0.05 *** 0.01)  nomtitles nonum	

	
