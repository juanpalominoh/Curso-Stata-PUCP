
global dta "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/Consultas/Consulta 2"

use "$dta/Base.dta", clear

* Quitar espacios
replace nombre=itrim(ltrim(rtrim(trim(nombre))))

* Reemplazar letras
replace nombre=subinstr(nombre, "i", "í", .) 
replace nombre=subinstr(nombre, "I", "í", .)
replace nombre=subinstr(nombre, "o", "ó", .)
replace nombre=subinstr(nombre, "Ó", "ó", .)
replace nombre=subinstr(nombre, "O", "ó", .)

collapse (sum) negocios, by(nombre)
