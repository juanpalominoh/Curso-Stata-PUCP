
global main 	"/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/12. Modelos Multivariados"
global dta  	"$main/2. Data"
global graphs 	"$main/3. Gráficos"

*==================
* Comando Coefplot
*==================

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


* Ejemplo 1
*============
regress lnwage edad i.mujer i.civil

* Horizontal
coefplot, drop(_cons) xline(0) graphregion(color(white))
graph export "$graphs/coefplot 1.png", as(png) replace
coefplot, drop(_cons) xline(0) keep(*:) omitted baselevels
graph export "$graphs/coefplot 2.png", as(png) replace

* Vertical
coefplot, vertical drop(_cons) yline(0)
graph export "$graphs/coefplot 3.png", as(png) replace


* Ejemplo 2
*===========
regress lnwage edad i.educ i.civil if mujer==1
estimates store A

regress lnwage edad i.educ i.civil if mujer==0
estimates store B

* Superpuestos
coefplot A B, drop(_cons) xline(0) graphregion(color(white))
graph export "$graphs/coefplot 4.png", as(png) replace

coefplot (A, label(Mujeres) pstyle(p3))  ///
         (B, label(Hombres)  pstyle(p4))  ///
           , drop(_cons) xline(0) msymbol(S) graphregion(color(white))
graph export "$graphs/coefplot 5.png", as(png) replace
		   
		   
* Ejemplo 2.2
tab sector

regress lnwage edad i.mujer i.educ if sector==1
estimates store primar

regress lnwage edad i.mujer i.educ if sector==2
estimates store secund

regress lnwage edad i.mujer i.educ if sector==3
estimates store tercer

coefplot (primar, label(Primario) pstyle(p3))  ///
         (secund, label(Secundario)  pstyle(p4))  ///
		 (tercer, label(Terciario)  pstyle(p5))  ///
           , drop(_cons) xline(0) msymbol(S) graphregion(color(white))
graph export "$graphs/coefplot 6.png", as(png) replace


		   	   
* Ejemplo 3
*============

quietly eststo Mujer: regress lnwage edad informal i.zona if mujer==1
quietly eststo Hombre: regress lnwage edad informal i.zona if mujer==0
quietly eststo Total: regress lnwage edad informal i.zona

* Separados Horizontal
coefplot Mujer || Hombre, ///
	drop(_cons) yline(0) vertical byopts(yrescale) xlabel(,angle(90))
graph export "$graphs/coefplot 7.png", as(png) replace

* Separados Vertical 	
coefplot Mujer || Hombre, ///
	drop(_cons) xline(0) byopts(xrescale) 
graph export "$graphs/coefplot 8.png", as(png) replace

* Por Coeficientes
coefplot Mujer || Hombre, ///
	drop(_cons) yline(0) vertical bycoefs byopts(yrescale) graphregion(color(white))	   
graph export "$graphs/coefplot 9.png", as(png) replace
		  
