
global main   "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/16. Análisis Series de Tiempo/"
global dta    "$main/2. Data"
global graphs "$main/3. Gráficos"
global works  "$main/4. Procesadas"


{ // Tipo de Cambio (USD-Soles)
*==============================
import excel "$dta/Tipo de Cambio Bancario Compra.xlsx", sheet("Mensuales") cellrange(A2:B363) firstrow clear

rename (A Tipodecambiopromediodelpe) (tiempo tc)

* Establecer series de tiempo
display 12*(1992-1960)
gen date=_n+383
format date %tm
tsset date
drop tiempo
order date

tsline tc
tsline tc, title("Tipo de Cambio USD-Soles", ///
		size(medium)) ytitle("Dolar") xtitle("Tiempo") ///
		ylabel(,nogrid) graphregion(color(white)) name(tc, replace)
graph export "$graphs/tc.png", as(png) replace


* Diferencia Tipo de Cambio 
gen D_tc=D1.tc  
  
tsline D_tc, title("Diferencia Tipo de Cambio USD-Soles", size(medium)) ytitle("Dif_Dolar") xtitle("Tiempo") ylabel(,nogrid) graphregion(color(white)) name(dif_tc, replace)
graph export "$graphs/dif_tc.png", as(png) replace

graph combine tc dif_tc, graphregion(color(white))
graph export "$graphs/tc_diftc.png", as(png) replace

save "$works/base_tc.dta", replace
}


{ // Inflación (IPC Variación Mensual)
*======================================
import excel "$dta/IPC Variación Mensual.xlsx",  sheet("Mensuales") cellrange(A2:B878) firstrow clear

rename (A ÍndicedepreciosLimaMetropoli) (tiempo IPC)
replace IPC="" if IPC=="n.d."
destring IPC, replace

* Establecer series de tiempo
gen date=_n-132
format date %tm
tsset date
drop tiempo
order date

tsline IPC, ///	
			title("Inflación Perú", size(medium)) ///
			ytitle("IPC") xtitle("Tiempo") ///
			ylabel(,nogrid) graphregion(color(white))
graph export "$graphs/inflacion.png", as(png) replace

save "$works/base_ipc.dta", replace
}


{ // PBI mensual
*================
import excel "$dta/PBI mensual.xlsx", sheet("Mensuales") cellrange(A2:B230) firstrow clear

rename (A Productobrutointernoydemanda) (tiempo PBI)

* Establecer series de tiempo
gen date=_n+515
format date %tm
tsset date
drop tiempo
order date

tsline PBI, ///
		title("PBI Perú", size(medium)) ///
		ytitle("PBI Mensual") xtitle("Tiempo") ///
		ylabel(,nogrid) graphregion(color(white)) name(pbi, replace)
graph export "$graphs/pbi.png", as(png) replace


* Diferencia PBI mensual
gen D_PBI=D1.PBI  
  
tsline D_PBI, ///
		title("Diferencia PBI mensual", size(medium)) ///
		ytitle("Dif_PBI") xtitle("Tiempo") ///
		ylabel(,nogrid) graphregion(color(white)) name(dif_pbi, replace)
graph export "$graphs/dif_pbi.png", as(png) replace

graph combine pbi dif_pbi, graphregion(color(white))
graph export "$graphs/pbi_difpbi.png", as(png) replace


* Componentes PBI
*------------------
tsfilter hp cycle_PBI=PBI, trend(trend_PBI)

label var PBI "PBI mensual"
label var cycle_PBI "PBI componente ciclico"
label var trend_PBI "PBI componente tendencia"

tsline PBI cycle_PBI trend_PBI, ///
		title("Componentes PBI", size(medium)) ///
		ytitle("PBI (Ìndice 2007=100)") xtitle("Tiempo") ///
		ylabel(,nogrid) graphregion(color(white)) 
graph export "$graphs/pbi_componentes.png", as(png) replace

save "$works/base_pbi.dta", replace
}

{ // PBI mensual desestacionalizado
*====================================
import excel "$dta/PBI mensual - desestacionalizado.xlsx", sheet("Mensuales") cellrange(A2:B230) firstrow clear

rename (A Productobrutointernoydemanda) (tiempo seasonal_PBI)

* Establecer series de tiempo
gen date=_n+515
format date %tm
tsset date
drop tiempo
order date

tsline seasonal_PBI, ///
		title("PBI desestacionalizado Perú", size(medium)) ///
		ytitle("PBI Mensual") xtitle("Tiempo") ///
		ylabel(,nogrid) graphregion(color(white)) name(seasonal_pbi, replace)
graph export "$graphs/seasonal_pbi.png", as(png) replace
save "$works/base_spbi.dta", replace
}


{ // PBI desestacionalizado variacion mensual
*==============================================
import excel "$dta/PBI desestacionalizado variacion mensual.xlsx", sheet("Mensuales") cellrange(A2:B229) firstrow clear

rename (A Productobrutointernoydemanda) (tiempo ds_PBI)

* Establecer series de tiempo
display 12*(2003-1960)
gen date=_n+516
format date %tm
tsset date
drop tiempo
order date

tsline ds_PBI, ///
		title("PBI desestacionalizado variacion mensual", size(medium)) ///
		ytitle("Variación PBI") xtitle("Tiempo") ///
		ylabel(,nogrid) graphregion(color(white)) name(ds_pbi, replace)
graph export "$graphs/ds_pbi.png", as(png) replace

save "$works/base_dspbi.dta", replace
}


{ // Desempleo mensual
*=======================
import excel "$dta/Tasa Desempleo Lima.xlsx", sheet("Mensuales") cellrange(A2:B251) firstrow clear

rename (A EmpleoenLimaMetropolitanaP) (tiempo desempleo)

* Establecer series de tiempo
display 12*(2001-1960)+3
gen date=_n+495
format date %tm
tsset date
drop tiempo
order date

tsline desempleo, ///
		title("Tasa Desempleo mensual", size(medium)) ///
		ytitle("Desempleo %") xtitle("Tiempo") ///
		ylabel(,nogrid) graphregion(color(white)) name(desempleo, replace)
graph export "$graphs/desempleo.png", as(png) replace

save "$works/base_desempleo.dta", replace
}


{ // Tasa de interés
*=====================
import excel "$dta/Tasa Interes.xlsx", sheet("Mensuales") cellrange(A2:B362) firstrow clear

rename (A TasasdeinterésdelBancoCentr) (tiempo interes)

* Establecer series de tiempo
display 12*(1992-1960)
gen date=_n+384-1
format date %tm
tsset date
drop tiempo
order date

tsline interes, ///
		title("Tasa Interes mensual", size(medium)) ///
		ytitle("Interes") xtitle("Tiempo") ///
		ylabel(,nogrid) graphregion(color(white)) name(interes, replace)
graph export "$graphs/tasa_interes.png", as(png) replace

save "$works/base_ti.dta", replace
}


{ // Indice General de Bolsa Valores de Lima
*=============================================
import excel "$dta/IGBVL.xlsx", sheet("Mensuales") cellrange(A2:B278) firstrow clear

rename (A BolsadeValoresdeLimaÍndic) (tiempo IGBVL)

display 12*(1999-1960)

gen date=_n+467
format date %tm
tsset date

* A partir de 2007
keep if _n>=97
drop tiempo
order date

tsline IGBVL, ///
			title("IGBVL Bolsa de Lima", size(medium)) ///
			ytitle("IGBVL") xtitle("Tiempo") ///
			ylabel(,nogrid) graphregion(color(white)) name(igbvl, replace)
graph export "$graphs/igbvl.png", as(png) replace


* Diferencia IGBVL
gen D_IGBVL=D1.IGBVL

tsline D_IGBVL, ///
		title("Diferencia mensual IGBVL Bolsa de Lima", size(medium)) ///
		ytitle("dif_IGBVL") xtitle("Tiempo") ///
		ylabel(,nogrid) graphregion(color(white)) name(dif_igbvl, replace)
graph export "$graphs/dif_igbvl.png", as(png) replace

graph combine igbvl dif_igbvl, graphregion(color(white))
graph export "$graphs/igbvl_difigbvl.png", as(png) replace

save "$works/base_igbvl.dta", replace
}


