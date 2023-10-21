import delimited test
egen id = group(idem)

xi: xtprobit ed_bb gini_netdm education_expdm gov_ex trade deficit id, noconstant pa vce(robust)