
global main    "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/13. Modelos Logit y Probit Binomial"
global works   "$main/3. Procesadas"
global graphs  "$main/4. Gráficos"

global enaho_5 	  "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/7. Gráficos Univariados/3. Procesadas"
global enaho_sum  "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/8. Gráficos Bivariados/3. Procesadas"


use "$enaho_5/enaho_laboral.dta", clear
merge m:1 conglome vivienda hogar using "$enaho_sum/base_sumaria_2021.dta", nogen


* Ejemplos de estimación de determinantes de inclusión financiera
*-----------------------------------------------------------------

* Modelo 1
eststo m1: logit incl_financ poverty 

* Modelo 2
eststo m2: logit incl_financ mujer edad jefe poverty 

* Resultados
esttab m1 m2, replace label title("Logit Binomial") ///
					   b(3) se(3) stats(N r2_p aic bic, fmt(0 3 0 0) ///
					   labels("Observations" "Pseudo R2" "AIC" "BIC")) ///
					   star(* 0.10 ** 0.05 *** 0.01) ///
					   mtitle("Modelo 1" "Modelo 2") ///
		               note("Standard errors in parentheses")	

* Efectos Marginales
*-----------------------

logit incl_financ poverty 
margins, dydx(*) atmeans 

logit incl_financ mujer edad jefe poverty 
margins, dydx(*) atmeans 

	
* Graficando los efectos marginales
logit incl_financ mujer edad jefe poverty, nolog
margins, dydx(*) atmeans 
marginsplot, horizontal unique xline(0) recast(scatter) yscale(reverse) graphregion(color(white)) allx ///
			 title("Marginal Effects Pr(Inclusión Financiera)") ytitle("Variables") xtitle("") ///
			 ylabel(, nogrid) 
