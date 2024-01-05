

*
* Table 6: Omitted Variables Explain Output Fluctuations
*

local instrument treatment total

local var dly drprv dlcpi dlriy stir ltrate cay

gen var="."
gen ols=.
gen iv_treatment=.
gen iv_total=.

local count 1

foreach v of local var {
	replace var="`v'" if _n==`count'
	
	local count = `count' + 1
}	


foreach v of local var {

xtreg ly1 hply fAA dly ldly `v' l`v'  if year>=1980 & year<=2007, fe vce(cluster iso)
	test (`v'=0) (l`v'=0)
	
	replace ols=round(r(p), 0.01) if var=="`v'"
	
}

foreach z of local instrument {
	foreach v of local var {
		
		xtivreg2 ly1 hply (fAA=f.`z') `v' l`v'  if year>=1980 & year<=2007, fe cluster(iso)
			test (`v'=0) (l`v'=0)

		replace iv_`z'=round(r(p), 0.01) if var=="`v'"

	}
}

*AMT use listtab for stata 11+

listtab var ols iv_treatment iv_total using ../tables/Table6.tex if ols!=. , replace ///
	type rstyle(tabular) ///
	head("\begin{tabular}{rrrr}""\textit{}&\textit{OLS}&\textit{IV (binary)}&\textit{IV (continuous)}\\\\") ///
	foot("\end{tabular}")
	
