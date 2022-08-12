
global main 	"/Users/juanpalomino/Google Drive/Cursos/Laboratorio de Stata/Capitulo 4"
global dta      "$main/Data"
global works 	"$main/Procesadas"
global graphs 	"$main/Graficos"

use "$works/enaho_laboral.dta", clear

*=========
* Filtros
*=========

* Solo miembros del hogar (Establecer a los residentes habituales)
keep if residente==1

* Se va ocupaciones de fuerzas armadas
drop if skill_ocu==0 

* Redondear factor de expansión
gen facfw=round(fac500a)

* PEA e ingresos positivos
keep if pea==1 & ingreso>0


*=============
* Univariante
*=============

* Gráfico Circular (Pie Plot)
*------------------------------
graph pie pea, over(zona)

graph pie pea [fw=facfw], over(zona) 

graph pie pea [fw=facfw], over(zona) ///
    plabel(_all percent, size(medium) format(%16.1fc)) ///
	title("PEA por zona 2021") ///
	legend(rows(1) region(lcolor(white))) ///
	graphregion(color(white))
	
graph save   "$graphs/pie_plot.gph", replace
graph export "$graphs/pie_plot.png", as(png) replace 


* Gráfico de Barras
*--------------------
sum ingreso
local mean_ingr=r(mean) 
display `mean_ingr'

* Barra horizontal
graph hbar ingreso [fw=facfw], ///
		over(dpto, sort(ingreso) descending label(labsize(vsmall))) ///
		blabel(total, format(%12.0fc) size(vsmall)) yline(`mean_ingr') ///
		title("Ingreso del trabajador por departamento", size(medium)) ///
		ytitle("S/.") ylabel(,nogrid) subtitle("Año 2021") ///
		graphregion(color(white)) 
graph save "$graphs/grafico_barra.gph", replace
graph export "$graphs/hbar_plot.png", as(png) replace 


* Barra vertical
summ ingreso
local mean_ingr=r(mean) 

graph bar ingreso [fw=facfw], ///
		over(dpto, sort(ingreso) descending label(labsize(vsmall) angle(90))) ///
		blabel(total, format(%12.0fc) size(vsmall)) yline(`mean_ingr') ///
		ytitle("Ingreso del trabajador por departamento") ///
		graphregion(color(white)) ylabel(,nogrid)
graph export "$graphs/bar_plot.png", as(png) replace 


* Histogramas
*-------------
histogram ingreso, graphregion(color(white))
histogram ingreso if ingreso<6000, graphregion(color(white))

histogram ingreso if ingreso<6000 [fw=facfw], percent fcolor(purple) ///
	ytitle("Porcentaje") xtitle("Ingreso S/.") ///
	title("Ingreso del trabajador") subtitle("Distribución Empírica 2021") ///
	graphregion(color(white)) ///
	note("Fuente: Elaboración propia en base a la ENAHO 2021")	
graph export "$graphs/histograma.png", as(png) replace


* Densidad de Kernel
*--------------------
kdensity ingreso [fw=facfw]

kdensity ingreso [fw=facfw] if ingreso<6000, ///
	ytitle("Densidad") xtitle("Ingreso del trabajador") ///
	title("Distribución Empírica 2021") ///
	graphregion(color(white)) ylabel(, nogrid) ///
	legend(label(1 "2021") region(lcolor(white))) 
graph export "$graphs/kernel.png", replace


* Gráfico de cajas (Box Plot)
*------------------------------

* Box vertical
graph box lnwage [fw=facfw], ///
	graphregion(color(white)) ylabel(, nogrid) ///
	ytitle("Logaritmo del Ingreso")	
graph export "$graphs/box_plot.png", as(png) replace 

graph box lnwage [fw=facfw], ///
	over(area) graphregion(color(white))   	


* Box horizontal
graph hbox lnwage [fw=facfw], ///
	over(dpto) graphregion(color(white)) ///
	ytitle("Logaritmo del Ingreso por Departamento")		
graph export "$graphs/box_plot_dpto.png", as(png) replace 


