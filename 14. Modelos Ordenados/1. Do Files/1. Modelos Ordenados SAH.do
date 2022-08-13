

global main    "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/14. Modelos Ordenados"
global inputs  "$main/2. Data"
global graphs  "$main/3. Gráficos"
global results "$main/4. Resultados"


* Modelos Ordenados
*===================

* Se usa la Ronda 5 de la Base de Niños del Milenio

use "$inputs/younglives_r5.dta", clear


* 1. Distribución de la Salud Subjetiva y el Bienestar Subjetivo
*----------------------------------------------------------------

* Subjective Health Status (SAH)
histogram sah_r5, ///
	discrete width(0.5) fraction addlabel xtitle("21 años") xlabel(, valuelabel) ylabel(,nogrid) ///
	title("Subjective Health Status: Round 5") scheme(sj) graphregion(color(white)) ///
	ytitle("Percentage (%)", size(small)) saving(r5_sah, replace)	
graph export "$graphs/sah5.png", as(png) replace
	
* Subjective Wellbeing
histogram ladder_r5, ///
	discrete width(0.5) fraction addlabel xtitle("21 años") xlabel(, valuelabel) ylabel(,nogrid) ///
	title("Subjective Wellbeing: Round 5") scheme(sj) graphregion(color(white)) ///
	ytitle("Percentage (%)", size(small)) saving(r5_swb, replace)	
graph export "$graphs/swb5.png", as(png) replace


* 2. Comparando Logit y Probit Ordenado
*---------------------------------------

global indiv   "age i.male i.educ"
global labor   "i.act c.lincome" 
global geogr   "i.region i.urban"
global health  "i.overweight i.ph_disab i.injury i.illnesses"

findit spost13_ado

eststo p4: quietly oprobit sah_r5 $ind $labor $geogr $health, rob
drop if _est_p4==0

set more off

eststo p1: quietly oprobit sah_r5 $indiv, rob
estadd fitstat

eststo p2: quietly oprobit sah_r5 $indiv $labor, rob
estadd fitstat

eststo p3: quietly oprobit sah_r5 $indiv $labor $geogr, rob
estadd fitstat

eststo p4: quietly oprobit sah_r5 $indiv $labor $geogr $health, rob
estadd fitstat

eststo l4: quietly ologit sah_r5 $indiv $labor $geogr $health, rob
estadd fitstat


esttab p1 p2 p3 p4, replace label title("Probit Ordenado") ///
        b(3) se(3) stats(N r2_p aic0 bic0, /// 
        fmt(0 3 3 3 ) ///  
		labels("Observations" "Pseudo R2" "AIC" "BIC")) ///
		drop(0.male 0.educ 0.act 1.region 0.urban 0.overweight 0.ph_disab 0.injury 0.illnesses) ///
		coeflabels(lincome "Log Income" 1.overweight "Overweight" 1.injury "Injury" 1.illnesses "Illnesses" ///
		cut1 "Kappa 1"  cut2 "Kappa 2" cut3 "Kappa 3" cut4 "Kappa 4") ///
		star(* 0.10 ** 0.05 *** 0.01) ///
        mtitle("Model 1" "Model 2" "Model 3" "Model 4") ///
		note("Standard errors in parentheses - ME: SE computed using Delta Method")	

		
esttab p4 l4, /// 
		replace label title("Probit y Logit Ordenado") ///
        b(3) se(3) stats(N r2_p aic0 bic0, /// 
        fmt(0 3 3 3) ///  
		labels("Observations" "Pseudo R2" "AIC" "BIC")) ///
		drop(0.male 0.educ 0.act 1.region 0.urban 0.overweight 0.ph_disab 0.injury 0.illnesses) ///
		coeflabels(lincome "Log Income" 1.overweight "Overweight" 1.injury "Injury" 1.illnesses "Illnesses" ///
		cut1 "Kappa 1"  cut2 "Kappa 2" cut3 "Kappa 3" cut4 "Kappa 4") ///
		star(* 0.10 ** 0.05 *** 0.01) ///
        mtitle("Probit" "Logit") ///
		note("Standard errors in parentheses - ME: SE computed using Delta Method")	


* 3. Probabilidades Predichas
*----------------------------

quie oprobit sah_r5 $indiv $labor $geogr $health, rob

* Calcula la probabilidad de cada individuo y luego los promedia: esto cuando no se coloca atmeans
margins, at(lincome=(2(1)10)) predict(outcome(5))  
marginsplot 
graph export "$graphs/margins_income_sah5.png", as(png) replace
* Mientras aumenta el ingreso, mayor probabilidad de que tenga excelente salud


margins, at(age=(21(1)26)) predict(outcome(1))
marginsplot
graph export "$graphs/margins_edad_sah1.png", as(png) replace


margins, at(age=(21(1)26)) predict(outcome(5))
marginsplot  
graph export "$graphs/margins_edad_sah5.png", as(png) replace
* Mientras aumenta la edad, la probabilidad de tener excelente salud disminuye


* Probabilidad predicha de la edad por genero. El efecto de la edad no es lo mismo para hombre que para mujer
oprobit sah_r5 $indiv $labor $geogr $health, rob
margins, at(age=(21(1)26)) predict(outcome(1)) over(male)
marginsplot
graph export "$graphs/margins_edad_genero_sah5.png", as(png) replace


* 4. Efectos Marginales
*-----------------------
set more off

* At means: Calcular el efecto marginal en el promedio de las variables
oprobit sah_r5 $indiv $labor $geogr $health, rob 
margins, dydx(*) predict(outcome(5)) atmeans 
marginsplot, horizontal unique xline(0) recast(scatter) yscale(reverse) graphregion(color(white)) allx ///
			 title("Marginal Effects Pr(SAH=5)") ytitle("Variables") xtitle("") ///
			 ylabel(, nogrid) name(A, replace)

oprobit sah_r5 $indiv $labor $geogr $health, rob 
margins, dydx(*) predict(outcome(4)) atmeans 
marginsplot, horizontal unique xline(0) recast(scatter) yscale(reverse) graphregion(color(white)) allx ///
			 title("Marginal Effects Pr(SAH=4)") ytitle("Variables") xtitle("") ///
			 ylabel(, nogrid) name(B, replace)
			 
oprobit sah_r5 $indiv $labor $geogr $health, rob 
margins, dydx(*) predict(outcome(3)) atmeans 
marginsplot, horizontal unique xline(0) recast(scatter) yscale(reverse) graphregion(color(white)) allx ///
			 title("Marginal Effects Pr(SAH=3)") ytitle("Variables") xtitle("") ///
			 ylabel(, nogrid) name(C, replace)
			 
oprobit sah_r5 $indiv $labor $geogr $health, rob 
margins, dydx(*) predict(outcome(2)) atmeans 
marginsplot, horizontal unique xline(0) recast(scatter) yscale(reverse) graphregion(color(white)) allx ///
			 title("Marginal Effects Pr(SAH=2)") ytitle("Variables") xtitle("") ///
			 ylabel(, nogrid) name(D, replace)		 

oprobit sah_r5 $indiv $labor $geogr $health, rob 
margins, dydx(*) predict(outcome(1)) atmeans 
marginsplot, horizontal unique xline(0) recast(scatter) yscale(reverse) graphregion(color(white)) allx ///
			 title("Marginal Effects Pr(SAH=1)") ytitle("Variables") xtitle("") ///
			 ylabel(, nogrid) name(E, replace)			 

graph combine A B C D E, graphregion(color(white))
graph export "$graphs/margins_sah.png", as(png) replace


* Exportacion de efectos marginales
oprobit sah_r5 $indiv $labor $geogr $health, rob 
margins, dydx(*) predict(outcome(3)) atmeans post // La opción post es para que en exportaciones aparezca efectos marginales
outreg2 using "$results/Probit Ordenado.xls", stats(coef se) ctitle("Efectos Marginales") addnote("Sea ***, **, * los niveles de significancia al 1%, 5% y 10%") excel replace



			 
* Average Marginal Effects: para cada uno de los individuos y despues se promedio
quietly oprobit sah_r5 $indiv $labor $geogr $health, rob 
margins, dydx(*) predict(outcome(1))
margins, dydx(*) predict(outcome(2))
margins, dydx(*) predict(outcome(3)) 
margins, dydx(*) predict(outcome(4))
margins, dydx(*) predict(outcome(5))			 
			 
			 

* 5. Testing
*------------

oprobit sah_r5 $indiv $labor $geogr $health, rob 

matrix list e(b) 
testparm i(1/3).region
			
