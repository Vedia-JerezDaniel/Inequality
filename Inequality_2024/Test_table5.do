*
* Table 5 / Balance check
*

label var gdp_cycle "Deviation of log output from trend"
label var gdp_gro "Output growth rate"
label var gov_debt "Public debt to GDP ratio"
label var gov_ex "Government expenditure"


gen f_ed = f.ed_bb
label var f_ed "Treatment edu. exp."
gen f_he = f.he_bb
label var f_he "Treatment Hea. exp."
gen f_soc = f.soc_bb
label var f_soc "Treatment Payable"
gen f_kind = f.kind_bb
label var f_kind "Treatment In-kind"
gen f_ind_t = f.indt_bb
label var f_ind_t "Treatment Ind. taxes"
gen f_pro_t = f.prt_bb
label var f_pro_t "Treatment Prop. taxes"
gen f_pit = f.pit_bb
label var f_pit "Treatment PIT"


eststo clear

gen c_ed = 1 - ed_bb 
gen c_he = 1 - he_bb
gen c_soc = 1-soc_bb
gen c_kind = 1-kind_bb
gen c_ind_t = 1-indt_bb
gen c_pro_t = 1-prt_bb
gen c_pit = 1-pit_bb

label var ed_bb "Treatment Edu. exp."
label var he_bb "Treatment Health. exp."
label var soc_bb "Treatment Payable Trans."
label var kin_bb_bb "Treatment In-kind Trans."
label var indt_bb "Treatment Ind. taxes"
label var prt_bb "Treatment Prop. taxes"
label var pit_bb "Treatment Progressivity"



estpost ttest gdp_gro gdp_cycle gov_debt gov_ex ed_bb, by (c_ed)
estpost ttest gdp_gro gdp_cycle gov_debt gov_ex fe_bb, by (c_fe)

esttab using results/Table_1/Table5.rtf, replace wide mtitle("difference") b(2) se(2) sfmt(2) obslast se label star(* 0.10 ** 0.05 *** 0.01)
	