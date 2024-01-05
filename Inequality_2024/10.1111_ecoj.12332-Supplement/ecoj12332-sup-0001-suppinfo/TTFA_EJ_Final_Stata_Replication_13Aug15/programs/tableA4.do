
*
* Table A4: ATE of treatment on treatment
*

* ftreatment LP

qui label var ftreatment "Treatment"
qui reg f.ftreatment ftreatment hply $rhs1 dmdumiso1-dmdumiso16  ///
	 if year>=1980 & year<=2007,  cluster(iso)
	eststo tr1

qui reg f2.ftreatment ftreatment hply $rhs1 dmdumiso1-dmdumiso16  ///
	 if year>=1980 & year<=2007,  cluster(iso)
	eststo tr2

qui reg f3.ftreatment ftreatment hply $rhs1 dmdumiso1-dmdumiso16  ///
	 if year>=1980 & year<=2007,  cluster(iso)
	eststo tr3

esttab	tr1 tr2 tr3, keep(ftreatment) ///
	b(3) se(3) sfmt(2) obslast label  nomtitles nonum

esttab	tr1 tr2 tr3 using ../tables/TableA4.tex ///
	, keep(ftreatment)  f replace ///
	title("Table A4. ATE of treatment on treatment") ///
	b(3) se(3) sfmt(2) obslast label  


	
* mean treatment size?

capture drop ftotal
gen ftotal = f.total
mean ftotal if ftreatment==1
mean ftotal if ftreatment==1, over(slump boom)
test _subpop_1 = _subpop_2

