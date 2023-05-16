https://ds4ps.org/pe4ps-textbook/docs/p-040-fixed-effects.html



ivreg2 ly`i'   (fAA= f.`v') ///
		hply dml0dly dml1dly dmdumiso1-dmdumiso16 ///
		if year>=1980 & year<=2007,  cluster(iso) 

		eststo iv`v'`i'
		estadd scalar FirstStageFStat = e(widstat)

// Current Account over GDP ratio

gen dlrgdp  = 100*d.lrgdp			// Annual real per capita GDP growth in percent
gen dlriy	= 100*d.lriy			// Annual real per capita investment growth in percent
gen dlcpi   = 100*d.lcpi			// Annual inflation in percent
gen dlrcon  = 100*d.lrcon			// Annual real consumption growth in percent



https://www.andrewheiss.com/blog/2020/12/01/ipw-binary-continuous/

https://evalf20.classes.andrewheiss.com/example/matching-ipw/

https://www.math.umd.edu/~slud/s818M-MissingData/PropensityScoreWeightingR.pdf

https://cran.r-project.org/web/packages/ipw/ipw.pdf

<<<<<<< HEAD


### May

02/05 --> DB is updated with PIT

09/05 --> End global est with ia1, then continue to the rest.

15/05 --> First function for steps (1 to 3), next step 4 & 5 on multiple DF.

