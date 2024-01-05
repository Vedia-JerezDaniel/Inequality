

*
* Table 5 / Balance check
*

label var hply "Deviation of log output from trend"
label var dly "Output growth rate"
label var debtgdp "Public debt to GDP ratio"
label var treatment "Treatment (lagged)"

eststo clear

gen fcontrol = 1-ftreatment // ttest will use control as the reference group

estpost ttest debtgdp hply dly treatment, by(fcontrol)

esttab using ../tables/Table5.tex , wide nonumber mtitle("diff.") f replace ///
	title("Balance") ///
	b(2) se(2) sfmt(2) obslast se label star(* 0.10 ** 0.05 *** 0.01)
	
