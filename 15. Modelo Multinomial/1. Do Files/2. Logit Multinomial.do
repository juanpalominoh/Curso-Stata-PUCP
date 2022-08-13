
global main     "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/15. Modelo Multinomial"
global dta      "$main/2. Data"
global works 	"$main/3. Procesadas"

use "$works/enaho_laboral.dta", clear

*=========
* Filtros
*=========

* Solo miembros del hogar (Establecer a los residentes habituales)
keep if residente==1

* Solo PEA ocupada
keep if peao==1 

* Solo Ingresos positivos
keep if ingreso>0

* Solo Individios mayores a 18 años 
keep if edad>=18

* Se va ocupaciones de fuerzas armadas
drop if skill_ocu==0 


*===============================
* Tabla Estadística Descriptiva
*===============================
		
sum
tab cat_pens [iw=fac500a]

*===============
* Estimaciones
*===============

global indiv   "i.etario i.mujer i.educ i.civil"
global labor   "b3.sector c.lnwage i.informal" 
global geogr   "i.zona_geo"

*ssc install fitstat

* ESTIMACIONES 
mlogit cat_pens $indiv $labor $geogr, b(1)
mlogit cat_pens $indiv $labor $geogr, b(2)
mlogit cat_pens $indiv $labor $geogr, b(3)
mlogit cat_pens $indiv $labor $geogr, b(4)

mlogit cat_pens $indiv $labor $geogr, b(1) rrr

* Primero se estima
eststo l1: quietly mlogit cat_pens $indiv $labor $geogr, b(1) 
drop if _est_l1==0
estadd fitstat

* Luego se hace el resumen estadístico
sum cat_pens etario mujer educ civil sector lnwage informal zona_geo

esttab l1, replace label title("Logit Multinomial") ///
        b(3) se(3) stats(N r2_p aic bic, /// 
        fmt(0 3 0 0) ///  
		labels("Observations" "Pseudo R2" "AIC" "BIC")) ///
		drop(1.etario 0.mujer 1.educ 1.civil 1.sector 0.informal 1.zona_geo) ///
		star(* 0.10 ** 0.05 *** 0.01) ///
        mtitle("Modelo 1") ///
		note("Standard errors in parentheses - ME: SE computed using Delta Method")	
		
* drop(1.etario 0.sexo 1.edu 0.escivil 1.rubro 0.informal 1.zona_geo) ///
* coeflabels(ln_ingreso "Log Ingreso Mensual" cut1 "Kappa 1"  cut2 "Kappa 2" cut3 "Kappa 3")


* Si se quiere cambiar de base:
quietly mlogit cat_pens $indiv $labor $geogr, b(2)
quietly mlogit cat_pens $indiv $labor $geogr, b(3)
quietly mlogit cat_pens $indiv $labor $geogr, b(4)

* Para usar Relative risk ratio
quietly mlogit cat_pens $indiv $labor $geogr, b(1) rrr


* EFECTOS MARGINALES
* At means: Calcular el efecto marginal en el promedio de las variables
mlogit cat_pens $indiv $labor $geogr
margins, dydx(*) predict(outcome(1)) atmeans
margins, dydx(*) predict(outcome(2)) atmeans
margins, dydx(*) predict(outcome(3)) atmeans
margins, dydx(*) predict(outcome(4)) atmeans


* Grafico Efectos Marginales
mlogit cat_pens $indiv $labor $geogr, vce(rob)
eststo margin1: margins, dydx(*) predict(outcome(1)) atmeans 
marginsplot, horizontal unique xline(0) recast(scatter) yscale(reverse) graphregion(color(white)) allx ///
			 title("Efectos Marginales Pr(No Afiliados)") ytitle("Variables") xtitle("") ///
			 ylabel(, nogrid) name(A, replace)

mlogit cat_pens $indiv $labor $geogr, vce(rob)
eststo margin2: margins, dydx(*) predict(outcome(2)) atmeans 
marginsplot, horizontal unique xline(0) recast(scatter) yscale(reverse) graphregion(color(white)) allx ///
			 title("Efectos Marginales Pr(AFP)") ytitle("Variables") xtitle("") ///
			 ylabel(, nogrid) name(B, replace)

mlogit cat_pens $indiv $labor $geogr, vce(rob)
eststo margin3: margins, dydx(*) predict(outcome(3)) atmeans 
marginsplot, horizontal unique xline(0) recast(scatter) yscale(reverse) graphregion(color(white)) allx ///
			 title("Efectos Marginales Pr(ONP)") ytitle("Variables") xtitle("") ///
			 ylabel(, nogrid) name(C, replace)
			 
mlogit cat_pens $indiv $labor $geogr, vce(rob)
eststo margin4: margins, dydx(*) predict(outcome(4)) atmeans
marginsplot, horizontal unique xline(0) recast(scatter) yscale(reverse) graphregion(color(white)) allx ///
			 title("Efectos Marginales Pr(Otros Sistemas)") ytitle("Variables") xtitle("") ///
			 ylabel(, nogrid) name(D, replace)

graph combine A B C D, graphregion(color(white))



* Nota: Efectos Marginales siempre serán los mismos independientes de que categoría base se utilice

set more off

quietly mlogit cat_pens $indiv $labor $geogr, b(1)
margins, dydx(*) predict(outcome(1)) atmeans

quietly mlogit cat_pens $indiv $labor $geogr, b(2)
margins, dydx(*) predict(outcome(1)) atmeans
		
