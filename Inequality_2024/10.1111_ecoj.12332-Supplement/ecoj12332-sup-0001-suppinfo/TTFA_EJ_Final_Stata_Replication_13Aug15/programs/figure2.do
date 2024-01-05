

*
* Figure 2. Propensity Score Empirical Distribution of Treated and Control Units
*

* Overlap check

*** phat plot

twoway (kdensity pihat0 if ftreatment==1, lpattern(dash) color(red) lwidth(medthick)) ///
	(kdensity pihat0 if ftreatment==0, color(blue) lwidth(thick)), ///
	text(2.9 .16 "Distribution for control units", placement(e) color(blue) size()) ///
	text(1.9 .58 "Distribution for treated units", placement(e) color(red) size()) ///
	title("") legend(label(1 "Treatment dist.") label(2 "Control dist.")) ///
	ylabel(, labsize(small)) xlabel(0(1)1, labsize(small)) ///
	ytitle("Frequency") ///
	xtitle("Estimated probability of treatment") ///
	plotregion(lpattern(blank)) scheme(s1color) legend(off)

graph export ../figures/figure2.pdf, replace
graph save ../figures/figure2.gph, replace

graph drop _all
