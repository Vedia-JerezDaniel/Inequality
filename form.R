pfe <- plm(Gini_net ~ lag(diff(GDP_con)) + lag(Secondary_ed) + lag(Trade)
  + Gov_ex + lag(diff(Net_len_wi))
  
## INST
pfe <- plm(Gini_net ~ lag(diff(GDP_con)) + lag(Secondary_ed) + lag(Trade)
           + Gov_ex + ((goveff + instdepth + insaccess + ins_effic))

#KIND EXPE
pfe <- plm(Gini_net ~ lag(diff(GDP_con))  + lag(Trade) + 
      Gov_ex + diff(Health_exp) , data = ine, model = "within", index = 'idem')

pfe <- plm(Gini_net ~ lag(diff(GDP_con))  + lag(Trade) + Gov_ex 
           + (diff(Education_exp)
            
# TAXES
            
pfe <- plm(Gini_net ~ lag(diff(GDP_con)) + lag(Secondary_ed) + lag(Trade)
   + Gov_ex + (ind_tx*arp_mid)
   
# SOC TRANS

pfe <- plm(Gini_net ~ lag(diff(GDP_con)) + lag(Secondary_ed) + lag(Trade)
   + ((Social_prot))
   
pfe <- plm(Gini_net ~ lag(diff(GDP_con)) + lag(Secondary_ed) + lag(Trade)
   + ((Social_prot_ex_pen))
   
pfe <- plm(Gini_net ~ lag(diff(GDP_con)) + lag(Secondary_ed) + lag(Trade)
              + Gov_ex + (diff(Soc_kind))
           
pfe <- plm(Gini_net ~ lag(diff(GDP_con)) + lag(Secondary_ed) + lag(Trade)
      + Gov_ex + (lag(Soc_payable))

