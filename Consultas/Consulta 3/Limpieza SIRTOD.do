
global main 	"/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/Consultas/Consulta 3"
global dta      "$main/1. Data"
global works 	"$main/2. Procesadas"
global maps      "$main/3. Shapefiles"



* Importar Base Excel y guardarlo en Stata
*===========================================
import excel "$dta2/pbi.xlsx", sheet("SIECYSC-INEI") firstrow clear

rename DEPARTAMENTO NOMBDEP
replace NOMBDEP=subinstr(NOMBDEP, "Í", "I", .)
replace NOMBDEP=subinstr(NOMBDEP, "Á", "A", .)

save "$works/basepbi.dta", replace



cd "$maps"
* Descargar Shapefiles
copy "$inei/5_Informacion_Cartografica-Shape.zip" "5_Informacion_Cartografica-Shape.zip", replace
unzipfile "5_Informacion_Cartografica-Shape", replace
erase "$maps/5_Informacion_Cartografica-Shape.zip"

* Trabajar con el shapefile
*==========================

* Creando archivos de mapas
shp2dta using "$maps/5_Informacion_Cartografica-Shape/LIMITE_DEPARTAMENTO/LIMITE_DEP.shp", ///
	database("$works/perushp_dpto.dta") ///
	coordinates("$works/perxy.dta") ///
	genid(id) genc(c) replace
	
use "$works/perushp_dpto.dta", clear	
merge 1:1 NOMBDEP using "$works/basepbi.dta", nogen 

* Grafico de Mapa
spmap pbi2020 using "$works/perxy.dta", id(id) clmethod(q) cln(6) ///
	title("Mapa Cuantiles: PBI 2020") ///
	legend(size(medium) position(8)) fcolor(Blues2) ///
	note("Fuente: INEI - Perú") name(cuantiles, replace) 
