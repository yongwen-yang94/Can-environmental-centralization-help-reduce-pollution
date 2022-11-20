

-------------------
**Baseline Regression
-------------------
**Independent variable:Y; dependent variable:X; Control variable:X_1 X_2 X_3 X_4

global control_variables "X_1 X_2 X_3 X_4"

reghdfe Y X  $control_variables  ,a(i.fixed_effects ) cluster( ) con
**Output：
outreg2 using Baseline_regression.doc,append tstat bdec(4) tdec(4) ///
ctitle("Column title") keep(X  $control_variables ) addtext( )


-------------------
**Parellel Test
-------------------
preserve  
drop treat_1  //treat_1 contribute the sample of a period prior to the change
reghdfe Y treat*  $control_variables ,a(i.fixed_effects ) cluster() con
coefplot , keep(treat* ) coeflabels(   ) ///
vertical yline(0)  addplot(line @b @at) xtitle("X") ///
ytitle("Y") ciopts(recast(rcap)) ylabel() levels(95)  scheme(s1mono) )
restore

g t = invttail("sampel size",0.05)  // t-value


drop treat_1
reghdfe lp_tfp treat_5_plus treat_4 treat_3 treat_2  treat0 treat1 treat2 treat3  lntotal_asset roa  leverage   tobin_q  lnmain_income topten lngdp lnfdi  lntec if register_distance<=15000&污染行业!=0 ,a(i.provincecode i.year i.stock ) cluster(stock)
g b_5_plus = _b[treat_5_plus]
g se_5_plus = _se[treat_5_plus]
g b_5_plusLB = b_5_plus - t5*se_5_plus
g b_5_plusUB = b_5_plus + t5*se_5_plus

forv i = 2/4{
g b_`i' = _b[treat_`i']
g se_`i' = _se[treat_`i']
g b_`i'LB = b_`i' - t5*se_`i'
g b_`i'UB = b_`i'+ t5*se_`i'
}

forv i = 0/3{
g b`i' = _b[treat`i']
g se`i' = _se[treat`i']
g b`i'LB = b`i' - t5*se`i'
g b`i'UB = b`i'+ t5*se`i'
}

g b = .
g LB = .
g UB = .  

replace b = b_5_plus if treat_5_plus == 1
replace LB = b_5_plusLB if treat_5_plus == 1
replace UB = b_5_plusUB if treat_5_plus == 1


forv i = 2/4{
replace b = b_`i' if treat_`i' == 1
replace LB = b_`i'LB if  treat_`i' == 1
replace UB = b_`i'UB if  treat_`i' == 1
}

forv i = 0/3{
replace b = b`i' if treat`i' == 1
replace LB = b`i'LB if  treat`i' == 1
replace UB = b`i'UB if  treat`i' == 1
} 

keep year_to_reform b LB UB
save temp.dta,replace
duplicates drop 
sort year_to_reform
drop if year_to_reform==.
drop if year_to_reform<-5

twoway (connected b year_to_reform, sort lcolor(navy) mcolor(navy) msymbol(circle_hollow) cmissing(n))  ///
       (rcap LB UB year_to_reform, lcolor(navy) lpattern(dash) msize(medium)),  ///
	   ytitle("Y") ytitle(, size(small))  ///
	   yline(0, lwidth(vthin) lpattern(dash) lcolor(teal)) ylabel(, labsize(small) angle(horizontal) nogrid) ///
	   xtitle("X") xtitle(, size(small))  ///
	   xline(-1, lwidth(vthin) lpattern(dash) lcolor(teal)) xlabel(, labsize(small)) xmtick(, nolabels ticks)   ///
       legend(off) ///
       graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))





-------------------------
**Placebo_test
-------------------------

qui forvalues i=1/1000{
use dataset.dta,clear  
preserve
	duplicates drop region,force
	keep region 
	g random_digit=runiform(1,10000)
	sort random_digit
	g random_id=[_n]
	keep if random_id<=15
	g placebo=1
	save placebo,replace
restore
use placebo,clear
merge 1:m region using dataset.dta,nogen
replace placebo=0 if placebo==.
g placebo_X=placebo*X
reghdfe Y placebo_X $control_variables , ,a(i.fixed_effects ) cluster( ) con
g b_placebo_X = _b[placebo_X] 
g se_placebo_X = _se[placebo_X] 
keep  b_placebo_X se_placebo_X
duplicates drop b_placebo_X se_placebo_X,force
save  placebo`i',replace
}


use placebo1.dta,clear
forvalues i=2/1000{
	append using placebo`i'.dta
}

g tvalue=b_placebo_X/se_placebo_X
kdensity b_placebo_X  , bw( ) normal xline( ) xlabel( )

 



