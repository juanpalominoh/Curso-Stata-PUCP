
*===============================
* Descargar Base de Datos ENDES
*===============================

* Reemplazar esta ruta
global main "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/13. Modelos Logit y Probit Binomial/2. ENDES"

* Crear Carpetas (Solo se ejecuta una vez)
mkdir "$endes/Modulo Hogar"
mkdir "$endes/Modulo Individual"
mkdir "$endes/Modulo PS"
mkdir "$endes/Modulo Salud"
mkdir "$endes/Ejemplo"

* Eliminar Carpetas
rmdir "$endes/Ejemplo"

* Directorios
global dta       "$endes/Bases"
global dta_hogar "$endes/Modulo Hogar"
global dta_ind 	 "$endes/Modulo Individual"
global dta_ps    "$endes/Modulo PS"
global dta_salud "$endes/Modulo Salud"
global inei      "http://iinei.inei.gob.pe/iinei/srienaho/descarga/STATA"


* ENDES 2021 - Modulo Hogar
*---------------------------
cd "$dta_hogar"
forvalues i=1629/1630 {
copy "$inei/760-Modulo`i'.zip" "760-Modulo`i'.zip", replace
unzipfile "760-Modulo`i'.zip", replace
erase "760-Modulo`i'.zip"
}

clear
forvalues i=1629/1630 {
local files : dir "760-Modulo`i'" files "*.dta", respectcase
foreach tipo in `files' {
use "$dta_hogar/760-Modulo`i'/`tipo'", clear
save "$dta_hogar/`tipo'", replace
erase "$dta_hogar/760-Modulo`i'/`tipo'"
}
}


* ENDES 2021 - Modulo Individual
*--------------------------------
cd "$dta_ind"
forvalues i=1631/1639 {
copy "$inei/760-Modulo`i'.zip" "760-Modulo`i'.zip", replace
unzipfile "760-Modulo`i'.zip", replace
erase "760-Modulo`i'.zip"
}

clear
forvalues i=1631/1639 {
local files : dir "760-Modulo`i'" files "*.dta", respectcase
foreach tipo in `files' {
use "$dta_ind/760-Modulo`i'/`tipo'", clear
save "$dta_ind/`tipo'", replace
erase "$dta_ind/760-Modulo`i'/`tipo'"
}
}


* ENDES 2021 - Modulo Salud
*---------------------------
cd "$dta_salud"
copy "$inei/760-Modulo1640.zip" "760-Modulo1640.zip", replace
unzipfile "760-Modulo1640.zip", replace
erase "760-Modulo1640.zip"

clear
local files : dir "760-Modulo1640" files "*.dta", respectcase
foreach tipo in `files' {
use "$dta_salud/760-Modulo1640/`tipo'", clear
save "$dta_salud/`tipo'", replace
erase "$dta_salud/760-Modulo1640/`tipo'"
}


* ENDES 2021 - Modulo Programas Sociales
*----------------------------------------
cd "$dta_ps"
copy "$inei/760-Modulo1641.zip" "760-Modulo1641.zip", replace
unzipfile "760-Modulo1641.zip", replace
erase "760-Modulo1641.zip"

clear
local files : dir "760-Modulo1641" files "*.dta", respectcase
foreach tipo in `files' {
use "$dta_ps/760-Modulo1641/`tipo'", clear
save "$dta_ps/`tipo'", replace
erase "$dta_ps/760-Modulo1641/`tipo'"
}
