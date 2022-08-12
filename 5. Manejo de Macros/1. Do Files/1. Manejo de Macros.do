

*==================
* MANEJO DE MACROS
*==================

global main "/Users/juanpalomino/Google Drive/Cursos/Laboratorio de Stata/Capitulo 3"
global dta  "$main/2. Data"

use "$dta/base_laboral_2021.dta", clear

*============
* I. Display
*============

* Display (String)
display "Hola"
display "Estudio Economia"
display "3+3"
display "((4+2)^3)/4"

* Display (Numérico)
display 3+3
display ((4+2)^3)/4
display %5.0fc 40.250
display pais " , " edad " , " civil


*=============
* II. Scalars
*=============

scalar num=4
scalar nombre="algún nombre que deseemos"
scalar suma=3+3
display "El contenido del scalar suma es " suma


* Primera forma
br conglome-codperso ingreso
sum ingreso
gen ingreso_prom=599.7474
gen ingreso_des1=ingreso - ingreso_prom
br ingreso ingreso_prom ingreso_des1

* Segunda Forma
sum ingreso
gen ingreso_des2=ingreso-599.7474

* Tercera Forma
sum ingreso
return list
display r(mean)
display r(max)
gen ingreso_des3=ingreso-r(mean)


*=============
* III. Locals
*=============

local one 1
display `one'

local two=`one'+1
display `two'

local suma 3+3
display `suma'
local suma=3+3
display `suma'

local vars pais ingreso
display `vars'
local vars pais ingreso
display "`vars'"

local variables edad ingreso
sum `variables'


local texto "Hola"
display "Cuando llego dijo `texto'"
display "Cuando llego dijo `algo'"

local  num=500
display "El contenido del scalar num es " `num'


local i 1
display "el valor de i es `i'"
local i `i'+1
display "el valor de i es `i'"
local i `i'+2
display "el valor de i es `i'"

local i=1
display "el valor de i es `i'"
local i=`i'+1
display "el valor de i es `i'"
local i=`i'+2
display "el valor de i es `i'"


*=============
* IV. Globals
*=============

global one 1
display $one

global main   "/Users/juanpalomino/Google Drive/Cursos/Laboratorio de Stata/Capitulo 3"
global dta   "$main/2. Data"

use "$dta/base_laboral_2021.dta", clear

global indiv  "mujer edad jefe civil educ indigena"
global labor  "pea peao informal ingreso lnwage"
global geogr  "dpto zona area"
sum $indiv $labor $geogr


global ejemplo A
display "El contenido del global ejemplo es `ejemplo'"

global ejemplo A
local  ejemplo B
display "El contenido del global ejemplo es `ejemplo'"

local  ejemplo B
display "El local ejemplo contiene `ejemplo' y el global ejemplo contiene ${ejemplo}"

