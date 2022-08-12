

*==================
* MANEJO DE LOOPS
*==================

global enaho  	"/Users/juanpalomino/Google Drive/ENAHO"
global dta_34 	"$enaho/Sumaria"
global works 	"/Users/juanpalomino/Google Drive/Cursos/Laboratorio de Stata/Capitulo 3/3. Procesadas"


use "$dta_34/sumaria-2021.dta", clear
keep ubigeo conglome vivienda hogar gashog1d gashog2d inghog1d inghog2d pobreza factor07
gen dpto=substr(ubigeo,1,2)
order dpto, a(ubigeo)

*=========
* foreach 
*=========

* foreach in
*------------

* Lista general
foreach var in inghog1d inghog2d gashog1d gashog2d {
	summarize `var'
}

foreach animal in cats and dogs {
	display "`animal'"
}


* foreach varlist
*-----------------
br gashog1d gashog2d inghog1d inghog2d
foreach var of varlist inghog1d inghog2d gashog1d gashog2d  {
	gen `var'_mens=`var'/12
}

br
foreach var of varlist conglome - pobreza  {
	sum `var'
}


* foreach numlist
*-----------------
br inghog1d
foreach num of numlist 1(1)8 {
	gen ingreso_`num'=inghog1d/`num'
}
br inghog1d ingreso_1-ingreso_8


*===========
* forvalues 
*===========

* Se usa para trabajar variables utilizando algun componente numerico:

* Primera especificacion: a(espacio)b

* Repetición del 1 al 8
br conglome-hogar gashog2d
forvalues x=1(1)8 {
gen gasto_`x'=gashog2d/`x'
sum gasto_`x'
}


* Con intervalo de 2 en 2:
forvalues x=1(2)8 {
sum gasto_`x'
}
br conglome-hogar gasto_*


* Segunda especificacion: a/b
forvalues x=1/8 {
	gen ln_gasto`x'=ln(gasto_`x')
	mean ln_gasto`x'
}
*
br ln_gasto*


* Tercera especificacion: a b .. to z
* Valor 1, 3-11
forvalues x= 1 3 to 11 {
gen prueba_`x'=`x' + 2
}
br prueba_1-prueba_11


*=======
* while
*=======
destring dpto, replace

* Sin break
local i=1
while `i' {
	display "El código de departamento es " `i'
	tab pobreza if dpto==`i'
	local i=`i'+1
}

* Con break
local i=1
while `i' {
	display "El código de departamento es " `i'
	tab pobreza if dpto==`i'
	local i=`i'+1
if `i'==6 continue, break	
}

* Itera solo la especificación verdadera
local i=1
while `i'<=6 {
	display "El código de departamento es " `i'
	tab pobreza if dpto==`i'
	local i=`i'+1
}


*==========================================
* Ejecución condicional: if, if else, else
*==========================================

clear all

forvalues i=2017/2021 {
append using "$dta_34/sumaria-`i'.dta"

keep ubigeo conglome vivienda hogar gashog1d gashog2d inghog1d inghog2d pobreza factor07
gen año=`i'
gen dpto=substr(ubigeo,1,2)
order dpto, a(ubigeo)

if año==2017 {
	collapse (sum) gashog2d, by(dpto)
} 
else if año==2018 {
	collapse (mean) gashog2d, by(dpto)
} 
else {
	collapse (min) gashog2d, by(dpto)
}

save "$works/base_`i'.dta", replace
}


*============
* Aplicación
*============

* Sumaria 2021
*---------------
use "$dta_34/sumaria-2021.dta", clear

* Departamento
gen dpto=substr(ubigeo,1,2)
destring dpto, replace

* Pobreza
label list pobreza
recode pobreza (1/2=1 "Pobre") (3=0 "No Pobre"), gen(poverty) 
label var poverty "Pobreza"

* Generamos nuevo ponderador
gen facpob07=mieperho*factor07

tab poverty [iw=factor07] // A nivel de hogar
tab poverty [iw=facpob07] // A nivel poblacional

collapse (mean) poverty [iw=facpob07], by(dpto)
gen year=2021
order year
save "$works/aux_2021.dta", replace


* Sumaria 2004 - 2021
*---------------------
forvalues i=2004/2021 {
use "$dta_34/sumaria-`i'.dta", clear

* Departamento
gen dpto=substr(ubigeo,1,2)
destring dpto, replace

* Pobreza
recode pobreza (1/2=1 "Pobre") (3=0 "No Pobre"), gen(poverty) 
label var poverty "Pobreza"

* Generamos nuevo ponderador
gen facpob07=mieperho*factor07

tab poverty [iw=factor07] // A nivel de hogar
tab poverty [iw=facpob07] // A nivel poblacional

collapse (mean) poverty [iw=facpob07], by(dpto)
gen year=`i'
order year
save "$works/aux_`i'.dta", replace
}

clear all
forvalues i=2004/2021 {
append using "$works/aux_`i'.dta"
}

reshape wide poverty, i(dpto) j(year)

label define lab_dpto 1 "Amazonas" 2 "Ancash" 3 "Apurímac" 4 "Arequipa" ///
		5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" ///
		11 "Ica" 12 "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 	16 "Loreto" ///
		17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" ///
		23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values dpto lab_dpto

forvalues i=2004/2021 {
replace poverty`i'=poverty`i'*100
format poverty`i' %3.1f
}

export excel "$works/pobreza_2004-2021.xlsx", firstrow(variable) replace
