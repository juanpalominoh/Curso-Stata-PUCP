

global enaho  	"/Users/juanpalomino/Google Drive/ENAHO"
global dta_34 	"$enaho/Sumaria"
global works 	"/Users/juanpalomino/Google Drive/Cursos/Laboratorio de Stata/Capitulo 4/Procesadas"


*===================================
* Limpieza de Datos - ENAHO SUMARIA
*===================================

use "$dta_34/sumaria-2021.dta", clear

* Departamento
gen dpto=substr(ubigeo,1,2)
destring dpto, replace
label var dpto "Departamento"
label define lab_dpto 1 "Amazonas" 2 "Ancash" 3 "Apurímac" 4 "Arequipa" ///
		5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" ///
		11 "Ica" 12 "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 	16 "Loreto" ///
		17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" ///
		23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values dpto lab_dpto

* Area
recode estrato (1/5=1 "Urbano") (6/8=0 "Rural"), gen(area) 
label var area "Área Geográfica"

* Zona
recode dominio (1/3=1 "Costa") (4/6=2 "Sierra") (7=3 "Selva") (8=4 "Lima Metropolitana"), gen(zona)
label var zona "Zona Geográfica"

* Pobreza
recode pobreza (1/2=1 "Pobre") (3=0 "No Pobre"), gen(poverty) 
label var poverty "Pobreza"

* Ingreso per capita mensual
gen ypc= inghog1d/(12*mieperho)
label var ypc "Ingreso per capita mensual"

* Gasto per capita mensual
gen gpc= gashog2d/(12*mieperho)
label var gpc "Gasto per capita mensual"

* Estrato Social
capture label define  estrsocial 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 6 "Rural", modify
capture label list estrsocial

* Ponderador a nivel poblacional
gen facpob07=mieperho*factor07

keep conglome-hogar dpto area zona poverty ypc gpc estrsocial mieperho factor07 facpob07
order factor07 facpob07, last

save "$works/base_sumaria_2021.dta", replace
