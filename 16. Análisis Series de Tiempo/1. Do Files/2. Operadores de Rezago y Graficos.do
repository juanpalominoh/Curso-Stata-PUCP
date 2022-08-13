
global main   "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/16. Análisis Series de Tiempo/"
global dta    "$main/2. Data"
global graphs "$main/3. Gráficos"
global works  "$main/4. Procesadas"


use "$works/base_tc.dta", clear
merge 1:1 date using "$works/base_ipc.dta", nogen
merge 1:1 date using "$works/base_pbi.dta", nogen
merge 1:1 date using "$works/base_spbi.dta", nogen
merge 1:1 date using "$works/base_dspbi.dta", nogen
merge 1:1 date using "$works/base_desempleo.dta", nogen
merge 1:1 date using "$works/base_ti.dta", nogen
merge 1:1 date using "$works/base_igbvl.dta", nogen


* Filtrar observaciones
keep if date>=ym(2003,1)
drop if date==ym(2022,1)


* II. Operadores de series de tiempo
*====================================		

* 2.1. Operador de rezagos
*---------------------------
br date desempleo PBI

* Primer rezago de la variable desempleo:
gen desempleoL1=L1.desempleo
gen PBIL1=L1.PBI

* Segundo rezago de la variable desempleo:
gen desempleoL2=L2.desempleo
list date desempleo desempleoL1 desempleoL2 if _n<=10


* 2.2. Operador Forward
*-------------------------
br date desempleo*

* Operador F para adelantar datos:
gen desempleoF1=F1.desempleo
gen desempleoF2=F2.desempleo
list date desempleo desempleoF1 desempleoF2 in 1/10


* 2.3. Operadores de Diferencias
*--------------------------------

* Podemos ocupar el operador D para calcular la primera y segunda diferencia:

* Diferencia Desempleo
gen D_desempleo=D1.desempleo

* Diferencia Tipo de Cambio 
gen D_tc=D1.tc  

* Diferencia PBI mensual
gen D_PBI=D1.PBI		// D1= y_t - y_t-1 
gen D2_PBI=D2.PBI		// D2= (y_t - y_t-1) - (y_t-1 - y_t-2) 

* Diferencia IGBVL
gen D_IGBVL=D1.IGBVL  


* 2.4. Operadores Estacionales
*------------------------------

* Podemos ocupar el operador S para calcular la primera y segunda estación de la variable:
gen desempleoS1=S1.desempleo    // S1= y_t - y_t-1 
gen desempleoS2=S2.desempleo	// S2= y_t - y_t-2
list date desempleo desempleoS1 desempleoS2 in 1/10

br date desempleo*

br date *PBI*
gen growthPBI=(PBI-PBIL1)/PBIL1
replace growthPBI=growthPBI*100

* Operadores en estimaciones para especificar rezagos:
reg desempleo growthPBI
reg desempleo growthPBI L(1/5).desempleo



* III. Gráficos Series de Tiempo
*================================		

* Tipo de Cambio
*-----------------
tsline tc, title("Tipo de Cambio USD-Soles", ///
		size(medium)) ytitle("Dolar") xtitle("Tiempo") ///
		ylabel(,nogrid) graphregion(color(white)) name(tc, replace)
		
tsline D_tc, title("Diferencia Tipo de Cambio USD-Soles", size(medium)) ///
		ytitle("Dif_Dolar") xtitle("Tiempo") ///
		ylabel(,nogrid) graphregion(color(white)) name(dif_tc, replace)

graph combine tc dif_tc, graphregion(color(white))
graph export "$graphs/tc_diftc.png", as(png) replace


* Componentes PBI
*-----------------
br *PBI*

tsfilter hp cycle_PBI=PBI, trend(trend_PBI)
order cycle_PBI trend_PBI, a(PBI)

label var PBI "PBI mensual"
label var cycle_PBI "PBI componente ciclico"
label var trend_PBI "PBI componente tendencia"
label var seasonal_PBI "PBI componente estacional"

tsline PBI cycle_PBI trend_PBI seasonal_PBI, ///
		title("Componentes PBI", size(medium)) ///
		ytitle("PBI (Ìndice 2007=100)") xtitle("Tiempo") ///
		ylabel(,nogrid) graphregion(color(white)) 
graph export "$graphs/pbi_cycle_trend_seasonal.png", as(png) replace
		

* Indice General de Bolsa Valores de Lima
*-----------------------------------------		
tsline IGBVL, ///
			title("IGBVL Bolsa de Lima", size(medium)) ///
			ytitle("IGBVL") xtitle("Tiempo") ///
			ylabel(,nogrid) graphregion(color(white)) name(igbvl, replace)

tsline D_IGBVL, ///
		title("Diferencia mensual IGBVL Bolsa de Lima", size(medium)) ///
		ytitle("dif_IGBVL") xtitle("Tiempo") ///
		ylabel(,nogrid) graphregion(color(white)) name(dif_igbvl, replace)

graph combine igbvl dif_igbvl, graphregion(color(white))
graph export "$graphs/igbvl_difigbvl.png", as(png) replace

br
order date tc D_tc IPC PBI PBIL1 D_PBI D2_PBI growthPBI ///
	cycle_PBI-seasonal_PBI ds_PBI ///
	desempleo desempleoL1-D_desempleo desempleoS1 desempleoS2 IGBVL D_IGBVL

label list	
	
save "$works/base_timeseries.dta", replace		

