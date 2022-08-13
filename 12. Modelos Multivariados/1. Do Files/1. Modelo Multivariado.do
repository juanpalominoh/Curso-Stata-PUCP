
global main 	"/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/12. Modelos Multivariados/"
global dta  	"$main/2. Data"
global graphs 	"$main/3. Gráficos"


*====================================
* ESTIMACIÓN DEL MODELO MULTIVARIADO
*====================================

use "$dta/enaho_laboral.dta", clear
count

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

*----------------------
* 1. Variable continua
*----------------------
regress lnwage edad
reg lnwage edad, level(95) cformat(%6.3fc) 

* e(b) acumula los parámetros estimados
matrix list e(b)
matrix list e(V)

* Estimamos la proyección de ingresos
predict double yhat if e(sample), xb
sum lnwage yhat

* Estimamos la proyección de residuos 
predict double uhat if e(sample), residuals
sum uhat

* Graficamos la relación entre edad e ingreso laboral
graph twoway (scatter lnwage edad) (lfit lnwage edad) if e(sample)==1, ///
		ytitle("Logaritmo del Ingreso Laboral") ///
		xlabel(14(5)66, labs(small)) ///
		ylabel(, nogrid) graphregion(color(white))
graph export "$graphs/scatter reg 1.png", as(png) replace

drop yhat uhat


*---------------------------------
* 2. Variable continua polinómica
*---------------------------------
gen edad_sq=edad*edad

reg lnwage edad edad_sq			, level(95) cformat(%6.3fc) 

reg lnwage c.edad c.edad#c.edad , level(95) cformat(%6.3fc) 

reg lnwage c.edad##c.edad 		, level(95) cformat(%6.3fc) 

display "Punto Máximo= " abs(_b[edad]/(2*_b[c.edad#c.edad]))

* Estimamos la proyección de ingresos y residuos
predict double yhat if e(sample), xb
predict double uhat if e(sample), residuals

graph twoway (scatter lnwage edad, msize(vsmall) mfcolor(none) mlcolor(edkblue)) ///
		(qfit lnwage edad) if e(sample)==1, ///
		ytitle("Logaritmo del Ingreso Laboral") ///
		xlabel(14(5)66, labs(small)) ///
		ylabel(, nogrid) graphregion(color(white))
graph export "$graphs/scatter reg 2.png", as(png) replace

testparm c.edad##c.edad

drop yhat uhat


*------------------------
* 3. Variable dicotómica
*------------------------

reg lnwage c.edad i.mujer, level(95) cformat(%6.3fc) 

* "ib1": categoría base Mujer.
reg lnwage c.edad ib1.mujer, level(95) cformat(%6.3fc) 

* "ib0": categoría base Hombre
reg lnwage c.edad ib0.mujer, level(95) cformat(%6.3fc) 

* Estimamos la proyección de ingresos y residuos
reg lnwage c.edad i.mujer, level(95) cformat(%6.3fc) 
predict double yhat if e(sample), xb
separate yhat if e(sample), by(mujer) generate(yhat_sep)
predict double uhat if e(sample), residuals

* Analizamos el ingreso proyectado de acuerdo a los años de age para los dos males
#delimit;
twoway 	(scatter lnwage edad if mujer==1, msize(vsmall) mfcolor(none) mlcolor(edkblue)) 
		(scatter lnwage edad if mujer==0, msize(vsmall) mfcolor(none) mlcolor(orange))
		(mspline yhat_sep0 edad			, lcolor(edkblue)) 		
		(mspline yhat_sep1 edad			, lcolor(orange)) if e(sample)==1,
		ylabel(0(2)12, labs(small) angle(0) format(%4.1fc) nogrid) 
		xlabel(14(5)66, labs(small) angle(0) format(%4.1fc) nogrid) 
		legend(order(1 2) label(1 "Mujer") label(2 "Hombre") ring(1) pos(6) 
			   rows(1) region(fcolor(none) lcolor(none)))
		title("Valores observados y predichos de la función de regresión", size(medium)) 
		subtitle("Modelo con covariante continuo y dicotómico", size(small))
		plotregion(margin(zero)) scheme(s1color) xsize(5);
#delimit cr
more
quietly: graph export "$graphs/scatter reg 3.png", replace

* Aplicamos un test de diferencia en medias para el logaritmo de ingreso por sexo
ttest lnwage, by(mujer) level(95)

drop yhat* uhat


*--------------------
* 4. Multicategórica
*-------------------

label list educ

reg lnwage c.edad ib1.educ, level(95) cformat(%6.3fc) 

* Estimamos la proyección de ingresos y residuos
predict double yhat if e(sample), xb
separate yhat if e(sample), by(educ) generate(yhat_sep)
predict double uhat_auto if e(sample), residuals

* Analizamos las proyecciones de ingresos según los años de edad de acuerdo al nivel educativo
#delimit;
twoway 
	(mspline yhat_sep1 edad if educ==1 & e(sample), lcolor(red) lpattern(dash)) 	
	(mspline yhat_sep2 edad if educ==2 & e(sample), lcolor(orange) lpattern(dash)) 					
	(mspline yhat_sep3 edad if educ==3 & e(sample), lcolor(sand) lpattern(dash)) 	
	(mspline yhat_sep4 edad if educ==4 & e(sample), lcolor(sienna) lpattern(dash))
	(mspline yhat_sep5 edad if educ==5 & e(sample), lcolor(dkgreen) lpattern(dash))
	(mspline yhat_sep6 edad if educ==6 & e(sample), lcolor(blue) lpattern(dash)),
	ylabel(5(0.5)8.5, labs(small) angle(0) format(%4.1fc) nogrid) 
	xlabel(14(5)66, labs(small) angle(0) format(%4.1fc) nogrid) 
	legend(order(1 2 3 4 5 6) label(1 "Sin Nivel") label(2 "Primaria") 
			label(3 "Secundaria") label(4 "No Universitario")
			label(5 "Universitario") label(6 "Posgrado") size(small) pos(6) cols(3)
			region(fcolor(none) lcolor(none)))
	title("Valores observados y predichos de las funciones de regresión", size(medium))
	subtitle("Modelo con covariante continuo y dicotómico", size(small))
	plotregion(margin(zero)) scheme(s1color) xsize(5);
#delimit cr
more
quietly: graph export "$graphs/scatter reg 4.png", replace

drop yhat* uhat

* Test de significancia conjunta sobre las variables dummies
testparm ib1.educ

* Test de significacia individual
test _b[1.educ]=_b[2.educ]
test _b[2.educ]=_b[3.educ]
test _b[1.educ]=_b[3.educ]


*------------------------------------------------------------------
* 5. Variable covariante continuo y multicategórico (interacción)
*------------------------------------------------------------------

* El impacto de la edad en los ingresos difiere del nivel educativo
reg lnwage edad if educ==1, noheader cformat(%6.3fc) 
reg lnwage edad if educ==2, noheader cformat(%6.3fc) 
reg lnwage edad if educ==3, noheader cformat(%6.3fc) 
reg lnwage edad if educ==4, noheader cformat(%6.3fc) 
reg lnwage edad if educ==5, noheader cformat(%6.3fc) 
reg lnwage edad if educ==6, noheader cformat(%6.3fc) 

* Podemos generar los impactos de estas iteracciones (no es lo mismo que estimar en subgrupos)
reg lnwage c.edad##ib1.educ, noheader cformat(%6.3fc) 

* Observamos graficamente las ventajas de cada nivel educativo
predict double yhat if e(sample), xb
separate yhat if e(sample), by(educ) generate(yhat_sep)
predict double uhat  if e(sample), residuals

#delimit;
twoway 
	(mspline yhat_sep1 edad if educ==1 & e(sample), lcolor(red) lpattern(dash)) 	
	(mspline yhat_sep2 edad if educ==2 & e(sample), lcolor(orange) lpattern(dash)) 					
	(mspline yhat_sep3 edad if educ==3 & e(sample), lcolor(sand) lpattern(dash)) 	
	(mspline yhat_sep4 edad if educ==4 & e(sample), lcolor(sienna) lpattern(dash))
	(mspline yhat_sep5 edad if educ==5 & e(sample), lcolor(dkgreen) lpattern(dash))
	(mspline yhat_sep6 edad if educ==6 & e(sample), lcolor(blue) lpattern(dash)),
	ylabel(5.5(0.5)8.5, labs(small) angle(0) format(%4.1fc) nogrid) 
	xlabel(14(5)66, labs(small) angle(0) format(%4.1fc) nogrid) 
	legend(order(1 2 3 4 5 6) label(1 "Sin Nivel") label(2 "Primaria") 
			label(3 "Secundaria") label(4 "No Universitario")
			label(5 "Universitario") label(6 "Posgrado") size(small) pos(6) cols(3)
			region(fcolor(none) lcolor(none)))
	title("Valores observados y predichos de las funciones de regresión", size(medium))
	subtitle("Modelo con covariante continuo y dicotómico", size(medium))
	plotregion(margin(zero)) scheme(s1color) xsize(5);
#delimit cr
quietly: graph export "$graphs/scatter reg 5.png", replace

drop yhat* uhat*

* Test de significancia conjunta 
testparm ib1.educ#c.edad
testparm ib1.educ
testparm c.edad

* Test de significacia individual
test _b[1.educ]=_b[2.educ]
test _b[2.educ]=_b[3.educ]
test _b[1.educ#c.edad]=_b[2.educ#c.edad]
test _b[2.educ#c.edad]=_b[3.educ#c.edad]


 
