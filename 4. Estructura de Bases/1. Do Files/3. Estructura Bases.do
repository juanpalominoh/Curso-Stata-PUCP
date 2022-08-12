
*==========================================
* PONTIFICIA UNIVERSIDAD CATÓLICA DEL PERÚ 
* Docente: Juan Palomino 😎
*==========================================

global main  "/Users/juanpalomino/Google Drive/Cursos/Laboratorio de Stata/Capitulo 2"
global dos   "$main/1. Do Files"
global works "$main/3. Procesadas"

global enaho  "/Users/juanpalomino/Google Drive/ENAHO"
global dta_1  "$enaho/Modulo 100"
global dta_5  "$enaho/Modulo 500"
global dta_34 "$enaho/Sumaria"


*=================================================
* I. Creando una base de datos a partir de otra
*=================================================

* El comando collapse
*---------------------

* Sumaria 2020
use "$dta_34/sumaria-2021.dta", clear
gen ypc=inghog2d/(mieperho*12)
gen gpc=gashog2d/(mieperho*12)
gen dpto=substr(ubigeo,1,2)
destring dpto, replace
collapse (mean) ypc gpc (sd) sd_ypc=ypc (max) max_gpc=gpc, by(dpto)
gen year=2020
save "$works/aux_2021.dta", replace

* Sumaria 2010
use "$dta_34/sumaria-2010.dta", clear
gen ypc=inghog2d/(mieperho*12)
gen gpc=gashog2d/(mieperho*12)
gen dpto=substr(ubigeo,1,2)
destring dpto, replace
collapse (mean) ypc gpc (sd) sd_ypc=ypc (max) max_gpc=gpc, by(dpto)
gen year=2010
save "$works/aux_2010.dta", replace


*====================================
* II. Estructura de bases de datos
*====================================

* El comando append
*--------------------
use "$works/aux_2021.dta", clear
append using "$works/aux_2010.dta"
label define lab_dpto 1 "Amazonas" 2 "Ancash" 3 "Apurímac" 4 "Arequipa" ///
		5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" ///
		11 "Ica" 12 "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 	16 "Loreto" ///
		17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" ///
		23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values dpto lab_dpto


* El comando reshape wide
*-------------------------
reshape wide ypc gpc sd_ypc max_gpc, i(dpto) j(year)
save "$works/base_wide.dta", replace


* El comando reshape long
*-------------------------
reshape long ypc gpc sd_ypc max_gpc, i(dpto) j(year)
save "$works/base_long.dta", replace


*====================================
* III. El comando preserve y restore
*====================================

use "$works/base_laboral_2021.dta", clear  // 86,806 individuos

preserve
keep if dpto==15
save "$works/base_laboral_lima.dta", replace
restore

preserve
keep if dpto==01
save "$works/base_laboral_amazonas.dta", replace   // 3,091 observaciones
restore

* Uno ambas bases
use "$works/base_laboral_lima.dta", clear
append using "$works/base_laboral_amazonas.dta"


*==================================
* IV. Duplicados de Observaciones
*==================================

* Identificador: Conglomerado + Vivienda + Hogar 
* Identificador 2: Conglomerado + Vivienda + Hogar + Codperso

use "$works/base_laboral_2021.dta", clear  // 86,806  individuos
count
sort conglome vivienda hogar codperso

* El comando duplicates list
*----------------------------
duplicates list conglome vivienda hogar
duplicates list conglome vivienda hogar codperso


* El comando duplicates report
*------------------------------
duplicates report conglome vivienda hogar


* El comando duplicates tag
*----------------------------
duplicates tag conglome vivienda hogar, gen(id_copies)
br conglome vivienda hogar codperso id_copies


* El comando duplicates drop
*-----------------------------
duplicates drop conglome vivienda hogar, force
duplicates drop dpto, force


*==================================
* V. Combinación de base de datos
*==================================

use "$dta_1/enaho01-2021-100.dta", clear  // 43,524 hogares
duplicates list conglome vivienda hogar  // no hay duplicados
count
tab result


* El comando merge 1:1
*----------------------
use "$dta_34/sumaria-2021.dta", clear   // 34,245 hogares
duplicates list conglome vivienda hogar
keep conglome-hogar mieperho pobreza
merge 1:1 conglome vivienda hogar using "$dta_1/enaho01-2021-100.dta", keepusing(result p101 p102 p103 p103a)
tab result _merge


* El comando merge m:1
*----------------------
use "$dta_5/enaho01a-2021-500.dta", clear  // 86,806 individuos
duplicates list conglome vivienda hogar codperso
keep conglome vivienda hogar codperso p203-p209
merge m:1 conglome vivienda hogar using "$dta_34/sumaria-2021.dta", keepusing(mieperho pobreza)


* El comando merge 1:m
*----------------------
use "$dta_34/sumaria-2021.dta", clear   // 34,245 hogares
duplicates list conglome vivienda hogar
keep conglome-hogar mieperho pobreza
merge 1:m conglome vivienda hogar using "$dta_5/enaho01a-2021-500.dta", keepusing(codperso p203-p209) 
