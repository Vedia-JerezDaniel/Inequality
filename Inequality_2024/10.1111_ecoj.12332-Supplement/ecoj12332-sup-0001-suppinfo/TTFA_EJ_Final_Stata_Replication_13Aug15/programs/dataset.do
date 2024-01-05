

** Read in the data for TTFA

* read in world GDP data from WDI
import excel  using ../data/wdi_worldgdp.xlsx, firstrow
tempfile wgdp
save `wgdp'
clear

* read in the JST dataset
use ../data/JST_panel2_v1.dta
replace iso="PRT" if iso=="POR" //hrrmph

* read in the full IMF-GLP dataset from Leigh
sort iso year
merge 1:1 iso year using ../data/IMF-fiscalshocks.dta
drop _merge

* get the Leigh and AA variables
sort iso year
tempfile data
save `data'
clear
use ../data/Leigh_database.dta
gen iso = wdicode
merge 1:1 iso year using `data'
drop _merge

* merge in AUT IRL data from WEO Oct 2012 to fill some gaps
merge 1:1 iso year using ../data/IMFWEO_AUTIRL.dta
drop _merge
replace debtgdp = debtgdpweo/100 if iso=="IRL"|iso=="AUT"
replace debtgdp = debtgdpweo/100 if iso=="IRL"|iso=="AUT"
gen rgdpnew = rgdpbarro
replace rgdpnew = rgdpweo if iso=="IRL"|iso=="AUT"

* cut down to the 17 country sample to match the IMF
drop if iso=="CHE"
drop if iso=="NOR"

* read in world GDP back in here
merge m:1 year using `wgdp'
drop _merge

* create treatment variable (fiscal consolidation action according to IMF)
gen treatment = 0 if year>=1978 & year<=2007
replace treatment = 1 if total~=.
gen control = 1-treatment

replace total=0 if treatment==0
replace tax=0 if treatment==0
replace spend=0 if treatment==0

* create numeric panel variable and sort and xtset 
capture drop ccode
egen ccode=group(iso)
sort iso year
xtset ccode year

* treatment happens at t=1 in IMF study setup, but known at t=0
* use ftreatment as the indicator of policy choice at t=0 to match the IMF setup
gen ftreatment = f.treatment

* drop events around time of German reunification to match AA variable
replace ftreatment=. if iso=="DEU" & year ==1990 | iso=="DEU" & year ==1991


* save
tempfile data
save `data'
clear

* more gaps to fill for broad datset
*** read in short- and long-term interest rates for IRL // 
*** short-term data from Israel Malkin
*** long-term data from Alan
import excel using ../data/03YR.xlsx, sheet(IRL) firstrow               

gen d = date(date, "MDY")
format d %td
gen year = year(d)
rename IRL stir
collapse stir, by(year)
replace stir=16 if year ==1992                  // this is a fix for the code error in the data
replace stir = stir/100 
gen iso = "IRL" 
tempfile sIRL
save `sIRL'
clear

import excel  using ../data/aut_irl_8Apr2013.xlsx, firstrow             // IRL ltrate from Alan
destring year, replace
keep year iso ltrate 
keep if iso=="IRL"
merge 1:1 iso year using `sIRL'
drop _merge
tempfile IRL
save `IRL'
clear

*** read in data for AUT from Paul Gaggl
use ../data/austria_gaggl
rename  at_i_3m_a stir
rename at_i_10y_a ltrate
replace stir = stir/100
replace ltrate = ltrate/100
merge 1:1 iso year using `IRL'
drop _merge

merge 1:1 iso year using `data'
drop _merge

gen lrgdp   = log(rgdpbarro)		// real GDP index from Barro
gen lrcon   = log(rconsbarro)		// real consumption index from Barro
gen lmoney  = log(money)			// M2, more or less
gen lstocks = log(stocks)			// Stock indices
gen lnarrow = log(narrowm)			// M1, more or less
gen cay		= ca/gdp				// Current Account over GDP ratio
gen lloans  = log(loans1)

tempfile data
save `data'
clear

*** read in data from Alan for AUT and IRL except for interest rates 
* (goes in here because he already applied the necessary transformations)

import excel  using ../data/aut_irl_8Apr2013.xlsx, firstrow
destring year, replace
drop ltrate
merge 1:1 year iso using `data'
drop _merge

replace ccode = 2 if ccode==. & iso=="AUT"
replace ccode = 11 if ccode==. & iso=="IRL"

replace cay = cay/100 if iso=="AUT" | iso=="IRL"
gen lcpi    = log(cpi)				// CPI
gen lpop    = log(pop)

replace lrgdp = log(rgdp) - lpop if iso=="AUT" | iso=="IRL"

gen rprv  = lloans - lcpi - lpop 	// real per capita private loans
replace rprv = log(realloans) - lpop if iso=="AUT" | iso=="IRL"

gen riy = iy*rgdpbarro				// real per capita investment
replace riy = realinv/pop if iso=="AUT" | iso=="IRL"
gen lriy = log(riy)

gen rlmoney = lmoney - lcpi

sort ccode year
gen dlrgdp  = 100*d.lrgdp			// Annual real per capita GDP growth in percent
gen dlriy	= 100*d.lriy			// Annual real per capita investment growth in percent
gen dlcpi   = 100*d.lcpi			// Annual inflation in percent
gen dlrcon  = 100*d.lrcon			// Annual real consumption growth in percent

gen drprv = 100*d.rprv					// Annual real per capita private loan growth 
gen drlmoney= 100*d.rlmoney 			// Annual Growth in M2 

replace cay = 100*cay
replace stir = 100*stir
replace ltrate = 100*ltrate 

* match IMF: cumulate IMF real GDP growth rate (N=17) to recoup levels
* g = growth of real GDP (OECD)
gen dlogy = log(1+g) if year>=1978
by ccode: gen logyIMF=sum(dlogy) if year>=1978 // cumulate log diffs
by ccode: replace logyIMF=0 if year==1977 // start year =0


** datset now complete
** now prepare for the empirical analysis 

* define dependent variable and lags
gen ly = 100*logyIMF
gen dly = d.ly
gen ldly = l.dly

* generate lags of the broad set of controls
gen ldrprv = l.drprv 
gen ldlcpi = l.dlcpi
gen ldlriy = l.dlriy 
gen lstir = l.stir 
gen lltrate = l.ltrate 
gen lcay = l.cay	

* construct the HP filter of log y
drop if year > 2011					
capture adopath ++ "U:\Early\ado"  // early's directory

bysort ccode: hprescott ly, stub(HP) smooth(100)
	// VERY HIGH smoothing (cf 6.25 Ravn-Uhlig)
	// but we want something like "output gap"
	
sum ccode
local countries = r(max)

gen hply=.
forvalues i=1/`countries' {
	replace hply = HP_ly_`i' if ccode==`i'
}


* now drop unwanted years after the HP filtering
* all regressions are restricted to year>=1980 & year<=2007
drop if year<=1977
drop if year>=2008

* bins
gen boom = cond(hply>+0,1,0)
gen slump = 1 - boom

gen Hi = cond(hply>+1,1,0)
gen Mid = cond(hply>-1&hply<=+1,1,0)
gen Low = 1 - Hi - Mid

* dummy interactions
gen ccodeLMH = ccode							
replace ccodeLMH =  ccodeLMH+100 if Mid==1
replace ccodeLMH =  ccodeLMH+200 if Hi==1
tabulate ccodeLMH, gen(ccodeLMHdum)

* dep vars for h-step ahead forecast (h=1,...,4)
local var ly ftreatment 		// ftreatment depvar used in Table A5

foreach v of local var {
	forvalues i=1/5 {
		if "`v'"=="ly" {
		gen `v'`i' = f`i'.`v' - `v'
		}
		if "`v'"=="ftreatment" {
		gen `v'`i' = f`i'.`v'
		}
		label var `v'`i' "Year `i'"
	}
}

gen ly6 = (ly1+ly2+ly3+ly4+ly5)
label var ly6 "Sum"

* transform and interact AA dCAPB measure
gen AA = AA_*100
gen fAA = f.AA
gen lfAA = l.fAA
gen fAAMid=fAA*Mid
gen fAALo=fAA*Lo

* housekeeping
tab year, gen(y)
tabulate year, gen(dumyr)
tabulate iso, gen(dumiso)

* dmdum = demeaned dummies

forvalues k = 1/17 {
	gen dmdumiso`k' = dumiso`k' - 1/17
	}
	
* dml0dly dml1dly = demeaned growth rates

sum dly 
gen dml0dly = dly - r(mean)
	
sum ldly 
gen dml1dly = ldly - r(mean)


