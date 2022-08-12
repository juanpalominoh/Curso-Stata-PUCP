
global main 	"/Users/juanpalomino/Google Drive/Cursos/Laboratorio de Stata/Capitulo 4"
global dta      "$main/Data"
global works 	"$main/Procesadas"
global graphs 	"$main/Graficos"


*===================
* Gráfico Bivariado
*===================

use "$works/base_sumaria_2021.dta", clear

gen lypc=ln(ypc)
gen lgpc=ln(gpc)


* Gráfico de Dispersión (Scatter Plot)
*----------------------------------------
scatter lgpc lypc, graphregion(color(white)) ///
	xtitle("Logaritmo del Ingreso per cápita") ///
	ytitle("Logaritmo del Gasto per cápita")
graph export "$graphs/scatter.png", as(png) replace 


* Graph Twoway (Dispersión y Predicción Lineal)
*-------------------------------------------------
graph twoway (scatter lgpc lypc) (lfit lgpc lypc), /// 
	graphregion(color(white)) ylabel(,nogrid) ///
	xtitle("Logaritmo del Ingreso per cápita") ///
	ytitle("Logaritmo del Gasto per cápita") ///
	legend(label(1 "Log GPC-Log YPC") label(2 "Fitted Values") ///
		   rows(1) region(lcolor(white)))  
graph export "$graphs/scatter_fit.png", as(png) replace 


* Gráfico de Linea y Área
*-------------------------
import excel "$dta/PBI sectores.xlsx", sheet("Anuales") firstrow clear
rename *, lower


* Gráfico de Área
*-----------------
graph twoway (area manufactura año) (area agropecuario año), ///
     graphregion(color(white)) xlabel(1950(10)2020) ylabel(,nogrid) ///
	 ytitle("Millones S/. 2007") ///
	 legend(label(1 "PIB Manufactura") label(2 "PIB Agropecuario") ///
			rows(1) region(lcolor(white)))  
graph export "$graphs/area_plot.png", as(png) replace 

 	 
* Gráfico de Línea
*-------------------
graph twoway (line agropecuario año, color(edkblue)) ///
			 (line manufactura año, color(red)), ///
	graphregion(color(white)) xlabel(1950(10)2020) ylabel(,nogrid) ///
	ytitle("Millones S/. 2007") ///
	legend(label(1 "PIB Agropecuario") label(2 "PIB Manufactura") ///
	rows(1) region(lcolor(white)))	
graph export "$graphs/line_plot.png", as(png) replace 	
