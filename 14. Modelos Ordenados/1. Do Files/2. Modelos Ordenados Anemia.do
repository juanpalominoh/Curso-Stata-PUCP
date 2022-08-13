
global main    "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/14. Modelos Ordenados"
global dta     "$main/2. Data"
global graphs  "$main/3. Gráficos"
global results "$main/4. Resultados"


* I. Distribución de la Salud Subjetiva y el Bienestar Subjetivo
*----------------------------------------------------------------

use "$dta/base_anemia.dta", clear

* Subjective Health Status (SAH)
histogram anemia, ///
	discrete width(0.5) fraction addlabel ///
	xtitle("Nivel de Anemia para niños 0-5 años") xlabel(, valuelabel) ylabel(,nogrid) ///
	scheme(sj) graphregion(color(white)) ///
	ytitle("Porcentage (%)", size(small)) saving(g_anemia, replace)	
graph export "$graphs/anemia.png", as(png) replace



* II. Modelos Ordenados
*-----------------------

sort HHID HVIDX HWIDX
global var_niño  "i.sexo edadmeses pesoalnacer"
global var_madre "edadmadre i.educmadre ib1.lengmaterna i.anemiamadre"
global var_geog  "i.area"
global var_socio "i.wealth_index"

findit spost13_ado

* Mismas observaciones
summarize anemia sexo edadmeses pesoalnacer edadmadre educmadre lengmaterna anemiamadre area wealth_index
eststo m0: oprobit anemia $var_niño $var_madre $var_geog $var_socio, rob
drop if _est_m0==0
summarize anemia sexo edadmeses pesoalnacer edadmadre educmadre lengmaterna anemiamadre area wealth_index

* Modelos
eststo p1: quietly oprobit anemia $var_niño, rob
estadd fitstat

eststo p2: quietly oprobit anemia $var_niño $var_madre, rob
estadd fitstat

eststo p3: quietly oprobit anemia $var_niño $var_madre $var_geog, rob
estadd fitstat

eststo p4: quietly oprobit anemia $var_niño $var_madre $var_geog $var_socio, rob
estadd fitstat

eststo l4: quietly ologit anemia $var_niño $var_madre $var_geog $var_socio, rob
estadd fitstat


esttab p1 p2 p3 p4, replace label title("Probit Ordenado") ///
        b(3) se(3) stats(N r2_p aic bic, /// 
        fmt(0 3 0 0) ///  
		labels("Observations" "Pseudo R2" "AIC" "BIC")) ///
		drop(0.sexo 0.educmadre 1.lengmaterna 0.anemiamadre 0.area 1.wealth_index) ///
		coeflabels(pesoalnacer "Peso al nacer/1000" edadmadre "Edad madre" anemiamadre "Anemia madre" ///
				   cut1 "Kappa 1"  cut2 "Kappa 2" cut3 "Kappa 3") ///
		star(* 0.10 ** 0.05 *** 0.01) ///
        mtitle("Model 1" "Model 2" "Model 3" "Model 4") ///
		note("Standard errors in parentheses - ME: SE computed using Delta Method")	

		
esttab p4 l4, /// 
		replace label title("Probit y Logit Ordenado") ///
        b(3) se(3) stats(N r2_p aic bic, /// 
        fmt(0 3 0 0) ///  
		labels("Observations" "Pseudo R2" "AIC" "BIC")) ///
		drop(0.sexo 0.educmadre 1.lengmaterna 0.anemiamadre 0.area 1.wealth_index) ///
		coeflabels(pesoalnacer "Peso al nacer/1000" edadmadre "Edad madre" anemiamadre "Anemia madre" ///
				   cut1 "Kappa 1"  cut2 "Kappa 2" cut3 "Kappa 3") ///
		star(* 0.10 ** 0.05 *** 0.01) ///
        mtitle("Probit" "Logit") ///
		note("Standard errors in parentheses - ME: SE computed using Delta Method")	


* III. Probabilidades Predichas
*-------------------------------

quietly oprobit anemia $var_niño $var_madre $var_geog riqueza, rob

* Calcula la probabilidad de cada individuo y luego los promedia: esto cuando no se coloca atmeans
margins, at(riqueza=(-2.1(0.4)2.2)) predict(outcome(4))  
marginsplot 
graph export "$graphs/margins_riqueza_anemia4.png", as(png) replace
* Mientras aumenta la riqueza, menor probabilidad de que tenga anemia grave


margins, at(edadmeses=(4(1)59)) predict(outcome(1))
marginsplot
graph export "$graphs/margins_edad_anemia1.png", as(png) replace
* Mientras aumenta la edad, la probabilidad de estar sin anemia aumenta


margins, at(edadmeses=(4(1)59)) predict(outcome(4))
marginsplot  
graph export "$graphs/margins_edad_anemia4.png", as(png) replace
* Mientras aumenta la edad, la probabilidad de estar con anemia grave disminuye


* Probabilidad predicha de la edad por sexo. 
oprobit anemia $var_niño $var_madre $var_geog riqueza, rob
margins, at(edadmeses=(4(1)59)) predict(outcome(1)) over(sexo)
marginsplot
graph export "$graphs/margins_edad_sexo_anemia1.png", as(png) replace
* El efecto de la edad no es lo mismo para hombre que para mujer


* IV. Efectos Marginales
*------------------------
set more off

* At means: Calcular el efecto marginal en el promedio de las variables
oprobit anemia $var_niño $var_madre $var_geog $var_socio, rob
margins, dydx(*) predict(outcome(4)) atmeans 
marginsplot, horizontal unique xline(0) recast(scatter) yscale(reverse) graphregion(color(white)) allx ///
			 title("Marginal Effects Pr(Anemia=4)") ytitle("Variables") xtitle("") ///
			 ylabel(, nogrid) name(A, replace)

oprobit anemia $var_niño $var_madre $var_geog $var_socio, rob
margins, dydx(*) predict(outcome(3)) atmeans 
marginsplot, horizontal unique xline(0) recast(scatter) yscale(reverse) graphregion(color(white)) allx ///
			 title("Marginal Effects Pr(Anemia=3)") ytitle("Variables") xtitle("") ///
			 ylabel(, nogrid) name(B, replace)
			 
oprobit anemia $var_niño $var_madre $var_geog $var_socio, rob
margins, dydx(*) predict(outcome(2)) atmeans 
marginsplot, horizontal unique xline(0) recast(scatter) yscale(reverse) graphregion(color(white)) allx ///
			 title("Marginal Effects Pr(Anemia=2)") ytitle("Variables") xtitle("") ///
			 ylabel(, nogrid) name(C, replace)
			 
oprobit anemia $var_niño $var_madre $var_geog $var_socio, rob
margins, dydx(*) predict(outcome(1)) atmeans 
marginsplot, horizontal unique xline(0) recast(scatter) yscale(reverse) graphregion(color(white)) allx ///
			 title("Marginal Effects Pr(Anemia=1)") ytitle("Variables") xtitle("") ///
			 ylabel(, nogrid) name(D, replace)		 

graph combine A B C D, graphregion(color(white))
graph export "$graphs/margins_anemia.png", as(png) replace


* Exportacion de efectos marginales
oprobit anemia $var_niño $var_madre $var_geog $var_socio, rob 
margins, dydx(*) predict(outcome(4)) atmeans post // La opción post es para que en exportaciones aparezca efectos marginales
outreg2 using "$results/Probit Ordenado anemia.xls", stats(coef se) ctitle("Efectos Marginales") addnote("Sea ***, **, * los niveles de significancia al 1%, 5% y 10%") excel replace



* Average Marginal Effects: para cada uno de los individuos y despues se promedia
quietly oprobit anemia $var_niño $var_madre $var_geog $var_socio, rob 
margins, dydx(*) predict(outcome(1))
margins, dydx(*) predict(outcome(2))
margins, dydx(*) predict(outcome(3)) 
margins, dydx(*) predict(outcome(4))

