

global main 	"/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/11. Test Paramétricos"
global dta  	"$main/2. Data"
global graphs 	"$main/3. Graficos"


*====================
* TEST PARAMÉTRICOS
*====================

use "$dta/enaho_laboral.dta", clear
count
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



* 1) Test de Proporciones
*=========================
sum ingreso
gen ing_sup=(ingreso>r(mean))
br ingreso ing_sup
label define lab_ing 1 "Superior a la media" 0 "Inferior a la media"
label values ing_sup lab_ing

tab2 area ing_sup, row
prtest ing_sup, by(area) level(95)



* 2) Test de Varianza
*=====================
bys area: sum ingreso   	// urbano la dispersión es mayor

sdtest ingreso, by(area)   // Las dos varianzas son diferentes


* 3) Test de Medias
*===================

mean ingreso, over(area) level(95)

ttest ingreso, by(area) level(95)

ttest ingreso, by(area) unequal level(95)   // Las dos medias son diferentes


*================
* CORRELACIONES
*================

graph twoway (scatter ingreso edad), ///
	ylabel(0(10000)60000, labs(small) nogrid) ///
	xlabel(14(5)66) graphregion(color(white)) ///
	xtitle("Edad (años)") ytitle("Ingreso Laboral")
graph export "$graphs/scatter_edad_ingreso.png", as(png) replace

* Estimamos el coeficiente de correlación de Pearson
corr ingreso edad
corr ingreso edad, means
corr ingreso edad, covariance

pwcorr ingreso edad, obs sig star(0.01)

* Graficamos correlaciones
graph matrix ingreso edad edad_sq mujer area, ///
	diagonal(,bfcolor(eggshell)) graphregion(color(white))
graph export "$graphs/matrix correlaciones.png", replace


* Correlaciones
pwcorr ingreso edad edad_sq mujer area, obs sig star(0.01) listwise
pwcorr ingreso edad edad_sq mujer area, obs sig star(0.01) listwise bonferroni


* Generamos correlación de Spearman
spearman ingreso mujer area, star(0.01) 
