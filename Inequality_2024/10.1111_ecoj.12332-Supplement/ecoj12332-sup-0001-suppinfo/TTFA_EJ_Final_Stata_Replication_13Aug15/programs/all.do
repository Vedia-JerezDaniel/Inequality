
* 13 August 2015 revision/final-preliminary
* The Time for Austerity: Estimating the Average Treatment Effect of Fiscal Policy
* ñscar Jordˆ, Alan M. Taylor
* Economic Journal, fothcoming

****** PREAMBLE ******************

*set path
capture cd "/Users/amtaylor/Documents/amt/Current/JordaSchularick/Fiscal/"
capture cd "TTFA_EJ_Final_Stata_13Aug15/programs/" // update this if subdirectory name changes

* do all file
capture log close
log using ../log/ttfa.log, replace
clear
set more off
set scheme s1color
graph set window fontface "Palatino"

pause on 

****** SETUP *********************
do globals // set globals first
do dataset

***** TABLES *********************

*** LP-OLS (AA style)
do table1
do table2andA1

*** LP-IV (IMF style)
do table3
do table4andA2

** Predictability of treatment
do table5 // balance check
do table6 // omitted variables
do table7 // probits


* LP-IPWRA using Davidian-Lunt DR/AIPW estimator
do table8and9

	
***** FIGURES ********************

// IPW scatters
do figure1

// Propensity score empirical distribution / overlap check
do figure2

// Comparing the AIPW estimates and the IV estimates

do figure3   // different slopes b0,b1 in outcome model m(b0,X) m(b1,X)


***** Other/Appendix *************

// Robustness Appendix
do tableA3
do tableA4

****** CLEANUP *******************

set more on
capture log close
