
global main 	"/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/12. Modelos Multivariados/"
global dta  	"$main/2. Data"
global results 	"$main/4. Resultados"


use "$dta/enaho_laboral.dta", clear
gen edad_sq=edad*edad

* Filtros
*---------

* Solo miembros del hogar (Establecer a los residentes habituales)
keep if residente==1

* Se va ocupaciones de fuerzas armadas
drop if skill_ocu==0 

* Edad 
keep if edad>=14 & edad<=65

* Pea ocupada
keep if peao==1


*=================
* Exportar Tablas
*=================

* Primer ejemplo:
*================

* 1) Guardar estimaciones
*=========================
eststo m1: reg lnwage edad 				, level(95) cformat(%6.3fc) 
eststo m2: reg lnwage edad edad_sq		, level(95) cformat(%6.3fc) 
eststo m3: reg lnwage c.edad ib0.mujer	, level(95) cformat(%6.3fc) 
eststo m4: reg lnwage c.edad ib1.educ 	, level(95) cformat(%6.3fc) 
eststo m5: reg lnwage c.edad##ib1.educ 	, level(95) cformat(%6.3fc) 


* 2) Uso del comando esttab
*===========================
esttab m1 m2 m3 m4 m5 using "$results/resultados 1.csv", replace label title("Estimaciones") ///
					   b(3) se(3) stats(N r2_p aic0 bic0, fmt(0 3 3 3) ///
					   labels("Observations" "R2" "AIC" "BIC")) ///
					   star(* 0.10 ** 0.05 *** 0.01) ///
					   mtitle("Model 1" "Model 2" "Model 3" "Model 4" "Model 5") ///
		               note("Standard errors in parentheses")	


* Segundo ejemplo
*=================					  

* 1) Uso del comando outreg2
*============================
* ssc install outreg2	

* Guardando los resultados (betas) en un archivo de excel con el comando outreg2:
reg lnwage edad, level(95) cformat(%6.3fc) 
outreg2 using "$results/regresiones.xls", stats(coef se) bdec(4) sdec(4) ctitle(Modelo 1) noparen addnote("Sea ***, **, * los niveles de significancia al 1%, 5% y 10%") excel replace
reg lnwage edad edad_sq, level(95) cformat(%6.3fc) 
outreg2 using "$results/regresiones.xls", stats(coef se) bdec(4) sdec(4) ctitle(Modelo 2) noparen excel
reg lnwage c.edad ib0.mujer, level(95) cformat(%6.3fc) 
outreg2 using "$results/regresiones.xls", stats(coef se) bdec(4) sdec(4) ctitle(Modelo 3) noparen excel
reg lnwage c.edad ib1.educ, level(95) cformat(%6.3fc) 
outreg2 using "$results/regresiones.xls", stats(coef se) bdec(4) sdec(4) ctitle(Modelo 4) noparen excel
reg lnwage c.edad##ib1.educ,  level(95) cformat(%6.3fc) 
outreg2 using "$results/regresiones.xls", stats(coef se) bdec(4) sdec(4) ctitle(Modelo 5) noparen excel


* Tercer ejemplo
*================

* 1) Resultados de varios modelos (en pantalla)
reg lnwage edad				, level(95) cformat(%6.3fc) 
estimates store mod1
reg lnwage edad edad_sq		, level(95) cformat(%6.3fc) 
estimates store mod2
reg lnwage c.edad ib0.mujer	, level(95) cformat(%6.3fc) 
estimates store mod3
reg lnwage c.edad ib1.educ	, level(95) cformat(%6.3fc) 
estimates store mod4
reg lnwage c.edad##ib1.educ	, level(95) cformat(%6.3fc) 
estimates store mod5

estimates table mod1 mod2 mod3 mod4	mod5


*========================
* Análisis de Resultados
*========================
global indiv "edad mujer i.civil i.educ i.jefe i.indigena"
global labor "i.sector ib3.skill_ocu i.informal"
global geogr "i.zona i.area" 

eststo r1: reg lnwage $indiv
eststo r2: reg lnwage $indiv $labor
eststo r3: reg lnwage $indiv $labor $geogr

esttab r1 r2 r3, replace label title("Estimaciones") ///
					   b(4) se(4) stats(N r2, fmt(0 3) ///
					   labels("Observations" "R2")) ///
					   star(* 0.10 ** 0.05 *** 0.01) ///
					   mtitle("Model 1" "Model 2" "Model 3") ///
		               note("Standard errors in parentheses")	

* Tabla estadística descriptiva
reg lnwage $indiv $labor $geogr
predict double yhat if e(sample), xb
drop if yhat==.
sum lnwage edad mujer civil educ jefe indigena sector skill_ocu informal zona area
