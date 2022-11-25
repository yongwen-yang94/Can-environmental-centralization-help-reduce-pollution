
global control "innovation fiscal_decentralization industrial structure  ///
                openness economic_development pollution_fee urbanization rainfall" 
***********
**Table 2**
***********				
sum edi pollution $control do nh3-n river_length official_promotion ///
    absolute_frequency relative_frequency,detail
				
***********
**Table 3**
***********				
reg  pollution post_treat treat post,cluster(prov)
est store m1
reghdfe pollution post_treat treat post $control, a(region_dummy) cluster(prov)
est store m2
reg pollution  post_edi   edi post,cluster(prov) 
est store m3
reghdfe pollution post_edi   edi post $control, a(region_dummy) cluster(prov)
est store m4

local model "m1 m2 m3 m4"
esttab `model', mtitle(`model') replace   ///
	  b(%8.4f) se(%6.3f)   ///
                  star(* 0.1 ** 0.05 *** 0.01)  drop(  )   ///
                  scalar(F r2_a N N_g)     ///
				  compress nogaps
				  
**write to Excel              
      local mm "m1 m2 m3 m4"  
      esttab `mm' using baseline regression.csv, ///
              mtitle(`mm') b(%6.3f) t(%6.3f) compress  drop(  )   ///
              nogaps star(* 0.1 ** 0.05 *** 0.01) replace  ///
              s(N r2_a ll) sfmt(%6.0f %4.3f %12.2f)


                                                          
														  
***********
**Table 4**
***********	
 g Dyear=year-2008
 forv i=1/3{
 g before`i'=(Dyear==-`i'&treat==1) 
 g after`i'=(Dyear==`i'&treat==1)
 }
 g current=(Dyear==0&treat==1)

reghdfe pollution before3-after3 $control, a(region_dummy) cluster(prov)
reghdfe pollution edi_before3-edi_after3 $control if year<=2007, a(region_dummy) cluster(prov)

************
**Figure 2**
************	
coefplot (Standard, label(Standard model) pstyle(p3) levels(95) ) ///
         (Continuous, label(Continuous model) pstyle(p4) levels(95)) , ///
		 legend(order ///
		 (1 "95%confidence intervals" 2 "Standard model" 3 "95%confidence intervals" 4 "Continuous model") row(2))  ///
		 omitted drop( $control  _cons)  vertical yline(0) ///
		 ytitle(Coef. of Post×Treat(Post×EDI)) xtitle(year) 


***********
**Table 5**
***********	

logit treat $control

set seed 0001
gen u = uniform()
sort u
psmatch2 treat $control  ,radius caliper(0.0005)  logit 
pstest $control ,both
g common=_support

preserve 
  drop if common ==0
  reghdfe pollution post_treat treat post $control, a(region_dummy) cluster(prov)
restore

 *-(a)before matching: 
 twoway (kdensity _ps if du==1,lp(solid) lw(*2.5))      ///
        (kdensity _ps if du==0,lp(dash)  lw(*2.5)),     ///
         ytitle("Density")                                      ///
		 ylabel(,angle(0))                                      ///
         xtitle("Propensity Score")                             ///
	     xscale(titlegap(2))                                    ///
         xlabel(0(0.2)0.8, format(%2.1f))                       ///
         legend(label(1 "Incentive") label(2 "Control") row(2)  ///
         position(3) ring(0))                            ///
         scheme(s1mono) 
			
			 
 *-(b)after matching: 
 twoway (kdensity _ps if du==1,lp(solid) lw(*2.5))         ///
        (kdensity _ps if du==0&_wei!=.,lp(dash) lw(*2.5)), ///
         ytitle("Density") ylabel(,angle(0))                    ///
         xtitle("Propensity Score") xscale(titlegap(2))         ///
         xlabel(0(0.2)0.8, format(%2.1f))                       ///
         legend(label(1 "Incentive") label(2 "Control") row(2)  ///
         position(3) ring(0))                            ///
         scheme(s1mono) 

***********
**Table 6**
***********			 
forv i = 1/3{
g post_`i'=0 
replace post_`i'=1 if year>=2008-`1'
g post_`i'_treat = post_`i'*treat
g post_`i'_edi = post_`i'*edi
reghdfe pollution post_`i'_treat treat post_`i' $control, a(region_dummy) cluster(prov)
reghdfe pollution post_`i'_edi   edi   post_`i' $control, a(region_dummy) cluster(prov)
}
***********
**Table 7**
***********			 
preserve
 drop if prov_=="Tianjin"|prov_=="Beijing"
 reghdfe pollution post_treat treat post $control, a(region_dummy) cluster(prov)
 reghdfe pollution post_edi   edi   post $control, a(region_dummy) cluster(prov)
restore

reghdfe alternative_pollution_indicator ///
        post_treat treat post $control, a(region_dummy) cluster(prov)
reghdfe alternative_pollution_indicator ///
        post_edi   edi   post $control, a(region_dummy) cluster(prov)


***********
**Table 8**
***********			 

reghdfe nh3-n ///
        post_treat treat post $control, a(region_dummy) cluster(prov)
reghdfe do///
        post_treat treat  post $control, a(region_dummy) cluster(prov)

reghdfe nh3-n ///
        post_edi edi post $control, a(region_dummy) cluster(prov)
reghdfe do///
        post_edi edi   post $control, a(region_dummy) cluster(prov)


***********
**Table 9**
***********			 
reghdfe absolute_frequency ///
        post_treat treat post $control, a(region_dummy) cluster(prov)
reghdfe relative_frequency///
        post_treat treat  post $control, a(region_dummy) cluster(prov)

reghdfe absolute_frequency ///
        post_edi edi post $control, a(region_dummy) cluster(prov)
reghdfe relative_frequency///
        post_edi edi   post $control, a(region_dummy) cluster(prov)
