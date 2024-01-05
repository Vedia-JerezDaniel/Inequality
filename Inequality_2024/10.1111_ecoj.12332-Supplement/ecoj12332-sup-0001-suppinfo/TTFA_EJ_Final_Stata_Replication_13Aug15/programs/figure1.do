*
* Figure 1. Illustrative scatters for GM, IP, RA, IPWRA
*


preserve

* control
clear
input x
1
2
3
4
5
6
7
8
9
end

* p(treatment)=p(T) depends on x, n= nobs

gen nt = x
gen nc = 10-x

gen pt = nt/10
gen pc = nc/10

gen ipwt = 1/pt
sum ipwt
replace ipwt = ipwt/r(sum)

gen ipwc = 1/pc
sum ipwc
replace ipwc = ipwc/r(sum)


* outcome y depends on x and T

gen yt = x + 1
gen yc = x

gen ten=10

* means with n weghts

sum yc [fweight=nc]
sum yt [fweight=nt]



* scatters

set scheme s1color

graph set window fontface "Palatino"


gr drop _all

twoway   (scatter yc x [w=nc], mc(blue)) (scatter yt x [w=nt], mc(red)) ///
	, ytitle("y") title("(a) Group Means") legend(off) ///
	text(9.8   1 "Treated mean = 7.33",  place(e)) ///
	text(9.1   1 "Control mean = 3.67",  place(e)) ///
	text(8.4   1 "ATE-GM = 3.67",        place(e)) 
	
gr rename GM

twoway  (scatter yc x [w=nc], mc(blue)) (scatter yt x [w=nt], mc(red))  (line yc x, lc(black)) (line yt x, lc(black)) ///
	, ytitle("y") title("(b) Regression Adjustment") legend(off) ///
	text(9.8   1 "Treated mean = 6",  place(e)) ///
	text(9.1   1 "Control mean = 5",  place(e)) ///
	text(8.4   1 "ATE-RA = 1",        place(e)) 
gr rename RA
	
twoway  (scatter yc x [w=ten], mc(blue)) (scatter yt x [w=ten], mc(red))  ///
	, ytitle("y") title("(c) Inverse Probability Weights") legend(off) ///
	text(9.8   1 "Treated mean = 6",  place(e)) ///
	text(9.1   1 "Control mean = 5",  place(e)) ///
	text(8.4   1 "ATE-IPW = 1",        place(e)) 
gr rename IPW
	
twoway  (scatter yc x [w=ten], mc(blue)) (scatter yt x [w=ten], mc(red)) (line yc x, lc(black)) (line yt x, lc(black))  ///
	, ytitle("y") title("(d) IPWRA (doubly robust)") legend(off) ///
	text(9.8   1 "Treated mean = 6",  place(e)) ///
	text(9.1   1 "Control mean = 5",  place(e)) ///
	text(8.4   1 "ATE-IPWRA = 1",        place(e)) 
gr rename IPWRA


gr combine GM RA IPW IPWRA,  iscale(.6) ///
	note("Outcome model: y = x + Treated; Treatment model: p(Treated) = x/10; True ATE = 1.")
	

gr save       ../figures/figure1.gph, replace
gr export     ../figures/figure1.pdf, replace

restore
