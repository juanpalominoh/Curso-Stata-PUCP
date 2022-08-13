
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

save "$works/base_tc.dta", replace
}


{ // Inflación (IPC Variación Mensual)
*======================================
import excel "$dta/IPC Variación Mensual.xlsx",  sheet("Mensuales") cellrange(A2:B878) firstrow clear

rename (A ÍndicedepreciosLimaMetropoli) (tiempo IPC)

replace IPC="" if IPC=="n.d."
destring IPC, replace

* Establecer series de tiempo
display 12*(1960-1949)
gen date=_n-132
format date %tm
tsset date
drop tiempo
order date

save "$works/base_ipc.dta", replace
}


{ // PBI mensual
*================
import excel "$dta/PBI mensual.xlsx", sheet("Mensuales") cellrange(A2:B230) firstrow clear

rename (A Productobrutointernoydemanda) (tiempo PBI)

* Establecer series de tiempo
display 12*(2003-1960)-1
gen date=_n+515
format date %tm
tsset date
drop tiempo
order date

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

save "$works/base_spbi.dta", replace
}


{ // PBI desestacionalizado variacion mensual
*==============================================
import excel "$dta/PBI desestacionalizado variacion mensual.xlsx", sheet("Mensuales") cellrange(A2:B229) firstrow clear

rename (A Productobrutointernoydemanda) (tiempo ds_PBI)

* Establecer series de tiempo
display 12*(2003-1960)-1
gen date=_n+516
format date %tm
tsset date
drop tiempo
order date

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

save "$works/base_ti.dta", replace
}


{ // Indice General de Bolsa Valores de Lima
*=============================================
import excel "$dta/IGBVL.xlsx", sheet("Mensuales") cellrange(A2:B278) firstrow clear

rename (A BolsadeValoresdeLimaÍndic) (tiempo IGBVL)

* Establecer series de tiempo
display 12*(1999-1960)
gen date=_n+467
format date %tm
tsset date
drop tiempo
order date

save "$works/base_igbvl.dta", replace
}

