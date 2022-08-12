
*==========================================
* PONTIFICIA UNIVERSIDAD CATÓLICA DEL PERÚ 
* Docente: Juan Palomino 😎
*==========================================

*=============================
* I. Organizacion de Carpetas
*=============================

* Primera Opción
cd "/Users/juanpalomino/Google Drive/Cursos/Laboratorio de Stata/Capitulo 2/2. Data"

* Segunda Opción
global main  "/Users/juanpalomino/Google Drive/Cursos/Laboratorio de Stata/Capitulo 2"
global dos   "$main/1. Do Files"
global dta   "$main/2. Data"
global works "$main/3. Procesadas"


*==============================================
* II. Descargando de la web una base de datos
*==============================================

global inei  "http://iinei.inei.gob.pe/iinei/srienaho/descarga/STATA/"
copy "$inei/759-Modulo05.zip" "759-Modulo05.zip", replace
unzipfile "759-Modulo05", replace
erase "759-Modulo05.zip"

copy  "$dta/759-Modulo05/enaho01a-2021-500.dta" "$dta/enaho01a-2021-500.dta", replace
erase "$dta/759-Modulo05/enaho01a-2021-500.dta"


*=============================
* III. Cargando Bases de datos 
*=============================

* El comando sysuse
sysuse auto, clear

* El comando import excel
import excel "$dta/pwt100.xlsx", sheet("Data") firstrow clear

* El comando use 
use "$dta/enaho01a-2021-500.dta", clear
use conglome vivienda hogar ubigeo dominio estrato using "$dta/enaho01a-2020-500.dta", clear      


*=============================
* IV. Traducir Base de datos
*=============================

clear all
unicode analyze "enaho01a-2021-500.dta"
unicode encoding set "latin1"  				// puede ser con ISO-8859-10 también 
unicode translate "enaho01a-2021-500.dta"


*==============================
* V. Explorando las variables
*==============================

use "$dta/enaho01a-2021-500.dta", clear

* El comando browse
browse
browse ubigeo estrato conglome vivienda hogar codperso
browse ubigeo estrato conglome vivienda hogar codperso p207 p208a
browse ubigeo estrato conglome vivienda hogar codperso p207 p208a if ubigeo=="150101"
browse ubigeo estrato conglome vivienda hogar codperso p207 p208a in 1/8
br

* El comando describe
describe
describe ubigeo estrato conglome vivienda hogar codperso p207 p208a

* El comando codebook
br p208a ubigeo
codebook p208a
codebook ubigeo


*======================
* VI. Tipo de Variables
*======================

browse ubigeo estrato conglome vivienda hogar codperso p207 p208a p524a1

* String
format ubigeo %18s
format ubigeo %6s

* Numéricas
format p524a1 %5.0f
format p524a1 %5.2f
format p524a1 %6.0fc

* Numéricas con etiqueta
label list p207
label list estrato

* Missing Values
gen newvar=.
* ssc install mdesc
mdesc p524a1 newvar


*===========================
* VII. Manipulando Variables
*===========================

* Renombrar Variables
*======================

* Edad
rename p208a age

* Sexo
rename p207 gender

rename (age gender) (edad sexo)


* Creando Variables
*======================

* Comando gen:
*--------------

* Edad al cuadrado
gen sq_edad=edad*edad

* Departamento
br ubigeo
gen dpto = substr(ubigeo,1,2)

* Pais
gen pais="Perú"


* Comando egen:
*--------------

br conglome vivienda hogar codperso i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t

* Ingreso Total
egen ing_ocu_pri=rowtotal(i524a1 d529t i530a d536)						
egen ing_ocu_sec=rowtotal(i538a1 d540t i541a d543)						
rename d544t ing_extra
egen ingreso = rowtotal(ing_ocu_pri ing_ocu_sec ing_extra) 
br conglome vivienda hogar codperso i524a1 d529t i530a d536 i538a1 d540t i541a d543 ing_extra ingreso

br conglome vivienda hogar codperso ingreso
egen mean_ingreso=mean(ingreso)
egen median_ingreso=median(ingreso)
egen sd_ingreso=sd(ingreso)
egen max_ingreso=max(ingreso)
egen min_ingreso=min(ingreso)


br conglome vivienda hogar codperso ingreso
bys conglome vivienda hogar: egen ingr_lab_hog=mean(ingreso)


* Cambiando el tipo de almacenaje de las variables
*==================================================

* El comando destring
*---------------------
br dpto
destring dpto, replace

* El comando tostring
*---------------------
tostring dpto, gen(str_dpto) force

* El comando encode
*-------------------
br ubigeo
encode ubigeo, gen(id_ubigeo)
label list id_ubigeo

* El comando decode
*-------------------
br dominio
label list dominio
decode dominio, gen(str_dominio)


*================================
* VIII. Manipulando Observaciones
*================================

* Reemplazando valores
*======================

* El comando replace
*--------------------
br conglome vivienda hogar codperso ingreso
replace ingreso=ingreso/12
gen lnwage=ln(ingreso)


* El comando recode
*-------------------
br estrato dominio

* Variables Geográficas
*-----------------------
label list estrato 
recode estrato (1/5=1) (6/8=0), gen(area) 

label list dominio
recode dominio (1/3=1 "Costa") (4/6=2 "Sierra") (7=3 "Selva") (8=4 "Lima Metropolitana"), gen(zona)


* Variables Socioeconómicas
*---------------------------

* Mujer:
br sexo
recode sexo (2=1 "Mujer") (1=0 "Hombre"), gen(mujer)
	
* Estado Civil
label list p209
recode p209 (1/2=1 "Casado/Conviviente") (3=2 "Viudo") (4/5=3 "Divorciado/Separado") (6=4 "Soltero"), gen(civil)

* Nivel educativo
recode p301a (1/2=1 "Sin Nivel/Inicial") (3/4=2 "Primaria") (5/6=3 "Secundaria") (12=4 "Basica Especial") (7/8=5 "Superior no universitaria") (9/10=6 "Superior universitaria") (11=7 "Maestria/Doctorado"), gen(educ)

* Jefe de hogar
label list p203
br p203
recode p203 (1=1 "Jefe") (0 2/11=0 "Otro"), gen(jefe)

* Raza
label list p558c
recode p558c (1/4 6 9=1 "Indigena") (5 7/8=0 "Otro"), gen(indigena)


* Variables Laborales
*---------------------

* Participación Laboral
label list ocu500
recode ocu500 (1/2=1 "PEA") (3/4=0 "NO PEA") (0=.), gen(pea)

* Pea Ocupada
label list ocu500
recode ocu500 (1=1 "Pea Ocupada") (2/4=0 "Otro"), gen(peao)

* Empleo informal:
recode ocupinf (1=1 "Informal") (2=0 "Formal"), gen(informal)


*========================================
* IX. Borrando y manteniendo variables
*========================================

browse

* El comando keep
keep pais conglome vivienda hogar codperso dpto area zona p204 p205 p206 edad sq_edad jefe mujer civil educ indigena pea peao informal ing_* ingreso lnwage fac500a 

* El comando drop
drop ing_*


*=========================================
* X. Ordenando Observaciones y Variables
*=========================================

* Ordenando Observaciones
*=========================

* El comando sort
*-----------------
br conglome-codperso ingreso
sort ingreso  // Ordenar ascendentemente

* El comando gsort
*------------------
gsort -ingreso // Ordenar descendentemente

sort conglome vivienda hogar codperso


* Subindices de Observacion
*===========================
br conglome vivienda hogar codperso

* El subindice _n
gen orden_obs= _n

* El subindice _N
gen total_obs=_N

drop orden_obs total_obs


* Ordenando Variables 
*======================
br
order pais dpto zona area, before(conglome)
order mujer edad sq_edad jefe p204 p205 p206 civil-indigena, after(codperso)
order ingreso lnwage fac500a, last


*====================================
* XI. Etiquetando Variables y Valores
*====================================

* El comando label var
*----------------------
describe

label var pais 		"País" 
label var dpto 		"Departamento"
label var zona 		"Zona Geográfica"
label var area 		"Área Geográfica"
label var mujer 	"Mujer"
label var edad 		"Edad (años)"
label var sq_edad 	"Edad al cuadrado"
label var jefe 		"Jefe de hogar"
label var civil 	"Estado Civil"
label var educ 		"Nivel educativo"
label var indigena 	"Indigena"
label var ingreso 	"Ingreso Mensual"
label var lnwage 	"Log(Ingreso Mensual)"
label var pea 		"PEA"
label var peao 		"PEA ocupada"
label var informal 	"Empleo Informal"

describe


* El comando label define
*-------------------------
br area dpto

label define lab_area 1 "Urbano" 0 "Rural"

label define lab_dpto 1 "Amazonas" 2 "Ancash" 3 "Apurímac" 4 "Arequipa" ///
		5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" ///
		11 "Ica" 12 "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 	16 "Loreto" ///
		17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" ///
		23 "Tacna" 24 "Tumbes" 25 "Ucayali"


* El comando label values
*-------------------------
label values area lab_area
label values dpto lab_dpto

codebook area dpto

br

*============================
* XII. Guardar y Exportar
*============================

* El comando save
*------------------
save "base_laboral_2021.dta", replace
save "$works/base_laboral_2021.dta", replace


* El comando export excel
*-------------------------
export excel using "$works/base_laboral_2021.xlsx", firstrow(variables) replace
export excel using "$works/base_laboral_2021.xlsx" if dpto==15, firstrow(variables) sheet("lima") 
export excel using "$works/base_laboral_2021.xlsx" in 1/7, firstrow(variables) sheet("selec_in") 


* El comando erase
*------------------
erase "base_laboral_2021.dta"
erase "$works/base_laboral_2021.xlsx"
