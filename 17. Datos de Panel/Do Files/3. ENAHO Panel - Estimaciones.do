

*============================
* ESTIMACIONES - ENAHO PANEL
*============================

use "$works/base_panel_enaho.dta", clear

global id id
global t year
global ylist lnwage
global xlist jefe edad mujer civil indigenous educ peao informal per zona dpto area

describe $id $t $ylist $xlist
summarize $id $t $ylist $xlist

* Set data as panel data
*------------------------
sort $id $t
xtset id year
xtdescribe
xtsum $id $t $ylist $xlist


* Filtros
*---------
keep if peao==1
keep if edad>=18 & edad<=65


* Regresiones
*-------------
global xlist jefe edad mujer i.civil indigenous i.educ informal per ib4.zona i.area

* Pooled OLS estimator
eststo m1: reg $ylist $xlist, cformat(%6.3fc)
estadd fitstat

* Between estimator
eststo m2: xtreg $ylist $xlist, be cformat(%6.3fc)

* Fixed effects or within estimator
eststo m3: xtreg $ylist $xlist, fe cformat(%6.3fc)

* Random effects estimator
eststo m4: xtreg $ylist $xlist, re theta cformat(%6.3fc)

esttab m1 m2 m3 m4 using "$results/Estimaciones Panel ENAHO.csv", replace label b(3) se(3) ///
                    stats(N ll r2 r2_w r2_o r2_b sigma sigma_u sigma_e rho theta aic0 bic0, ///
					fmt(0 3 3 3 3)) star(* 0.10 ** 0.05 *** 0.01) ///
					mtitle("Pooling OLS" "Between" "Within" "Random")
					
					
/* Interpretación:

Pooled: a través de individuos y con el tiempo, tener estudios universitarios 
		conduce a salarios un 83.9% más altos que aquellos que no tienen 
		nivel educativo.

Between: los salarios promedio son un 68.7% más altos para individuos con 
		 estudios universitarios que aquellos que no tienen nivel educativo, en promedio.

Within: a través del tiempo, tener estudios universitarios por encima del 
		promedio para un individuo conduce a un aumento de salarios del 30.7%

Random: misma interpretación que within.
*/					
					
					
* Hausman test for fixed versus random effects model
quietly xtreg $ylist $xlist, fe
estimates store fixed
quietly xtreg $ylist $xlist, re
estimates store random
hausman fixed random

* Breusch-Pagan LM test for random effects versus OLS
quietly xtreg $ylist $xlist, re
xttest0

* Recovering individual-specific effects
quietly xtreg $ylist $xlist, fe
predict alphafehat, u
sum alphafehat	

* Resumen Estadístico luego de estimar
global xlist jefe edad mujer civil indigenous educ informal per zona dpto area
xtsum $ylist $xlist if alphafehat!=.
				
