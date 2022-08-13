

*============================================
* Datos de Panel (Convergencia Regional PBI)
*============================================


{ // Data Panel - 1 time span
*-----------------------------

use "$dta/Base_CorteTransversal.dta", clear 

drop IDDPTO
gen id=_n
order id

rename (*_*) (**)

reshape long pbipc pet kf edu2564 neta1216, i(id dpto) j(año)

* Variables
gen lny=ln(pbipc)
bys id: gen tpet= (pet - pet[_n-1])/pet[_n-1]
gen lntpet=ln(abs(tpet)+0.05)
gen ln_sk=ln(kf)
gen ln_edu=ln(edu2564)
gen ln_sch=ln(neta1216)

* Set time and id
xtset id año

* Crecimiento y rezago
gen lagy=L1.lny
gen dly=(lny-lagy)/1

drop if año==1999 | año==2000

save "$works/Base_Panel_1span.dta", replace
}


{ // Estimaciones 1span
*-----------------------

use "$works/Base_Panel_1span.dta", clear

*===============
* Efectos Fijos
*===============
set more off

* Pooled
*========
eststo m1: reg dly lagy ln_sk lntpet ln_sch
estadd fitstat
estimates store pooled


* Region-fixed effects
*======================
eststo m2: reg dly lagy ln_sk lntpet ln_sch i.id
estadd fitstat

xtreg dly lagy ln_sk lntpet ln_sch, fe /*vce(rob)*/
estimates store imodel	


* Time-fixed effects
*====================
eststo m3: reg dly lagy ln_sk lntpet ln_sch i.año
estadd fitstat
estimates store tmodel


* Twoways-fixed effects
*======================
eststo m4: reg dly lagy ln_sk lntpet ln_sch i.año i.id
estadd fitstat

xtreg dly lagy ln_sk lntpet ln_sch i.año, fe /*vce(rob)*/
estimates store twomodel

esttab m1 m2 m3 m4 using "$results/Resultados Convergencia 1span.csv", ///
		replace label b(3) se(3) ///
		stats(N ll r2 aic0 bic0, fmt(0 3 3 3 3)) ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		mtitle("Pooling OLS" "Region-fixed effects" ///
			   "Time-fixed effecs" "Two-way fixed effects")

					
*================
* Random Effects
*================
xtreg dly lagy ln_sk lntpet ln_sch i.año, re
estimates store random



* Test de Hausman
*=================
hausman tmodel random
hausman imodel random
hausman twomodel random


lrtest pooled twomodel
lrtest imodel twomodel
lrtest tmodel twomodel

}





{ // Data Panel - 4 time span
*-----------------------------

use "$dta/Base_CorteTransversal.dta", clear 

drop IDDPTO
gen id=_n
order id

rename (*_*) (**)

reshape long pbipc pet kf edu2564 neta1216, i(id dpto) j(año)

* Tiempo
gen t=2000 if año==1999 | año==2000 
replace t=2004 if año==2001 | año==2002 | año==2003 | año==2004
replace t=2008 if año==2005 | año==2006 | año==2007 | año==2008
replace t=2012 if año==2009 | año==2010 | año==2011 | año==2012
replace t=2016 if año==2013 | año==2014 | año==2015 | año==2016
replace t=2020 if año==2017 | año==2018 | año==2019 | año==2020

collapse (mean) pbipc (mean) pet kf edu2564 neta1216, by(id t dpto)

* Set time and id
rename t año
xtset id año		

* Crecimiento y rezago
gen lny=ln(pbipc)
gen lagy=L4.lny
gen dly=(lny-lagy)/4

* Variables
bys id: gen tpet= (pet - pet[_n-1])/pet[_n-1]
gen lntpet=ln(abs(tpet)+0.05)
gen ln_sk=ln(kf)
gen ln_edu=ln(edu2564)
gen ln_sch=ln(neta1216)

drop if año==2000

save "$works/Base_Panel_4span.dta", replace
}


{ // Estimaciones 4span
*-----------------------

use "$works/Base_Panel_4span.dta", clear

*===============
* Efectos Fijos
*===============
set more off

* Pooled
*========
eststo m1: reg dly lagy ln_sk lntpet ln_sch
estadd fitstat
estimates store pooled


* Region-fixed effects
*======================
eststo m2: reg dly lagy ln_sk lntpet ln_sch i.id
estadd fitstat

xtreg dly lagy ln_sk lntpet ln_sch, fe /*vce(rob)*/
estimates store imodel	


* Time-fixed effects
*====================
eststo m3: reg dly lagy ln_sk lntpet ln_sch i.año
estadd fitstat
estimates store tmodel


* Twoways-fixed effects
*======================
eststo m4: reg dly lagy ln_sk lntpet ln_sch i.año i.id
estadd fitstat

xtreg dly lagy ln_sk lntpet ln_sch i.año, fe /*vce(rob)*/
estimates store twomodel

esttab m1 m2 m3 m4 /*using "$results/Resultados Convergencia 1span.csv"*/, ///
		replace label b(3) se(3) ///
		stats(N ll r2 aic0 bic0, fmt(0 3 3 3 3)) ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		mtitle("Pooling OLS" "Region-fixed effects" ///
			   "Time-fixed effecs" "Two-way fixed effects")

					
*================
* Random Effects
*================
xtreg dly lagy ln_sk lntpet ln_sch, re
estimates store random



* Test de Hausman
*=================
hausman tmodel random
hausman imodel random
hausman twomodel random


lrtest pooled twomodel
lrtest imodel twomodel
lrtest tmodel twomodel

}




