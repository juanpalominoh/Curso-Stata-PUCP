
global main  "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/18. Modelo Gravitacional Migración/"
global dta   "$main/2. Data"
global works "$main/3. Procesadas"
global maps  "$main/4. Shapefiles"
cd "$maps"

*================================
* Modelo Gravitacional Migración
*================================

use "$dta/migracion_dpto.dta", clear
merge m:1 ccdd_orig using "$dta/poblacion_origen_dpto.dta", nogen keep(3)
merge m:1 ccdd_dest using "$dta/poblacion_destino_dpto.dta", nogen keep(3)
order d_migro, last
rename d_migro migracion
save "$works/base_migracion.dta", replace


* Descargar Shapefiles
copy "$inei/5_Informacion_Cartografica-Shape.zip" "5_Informacion_Cartografica-Shape.zip", replace
unzipfile "5_Informacion_Cartografica-Shape", replace
erase "$maps/5_Informacion_Cartografica-Shape.zip"

* Creando archivos de mapas
shp2dta using "$maps/5_Informacion_Cartografica-Shape/LIMITE_DEPARTAMENTO/LIMITE_DEP.shp", ///
	database("$works/perushp_dpto.dta") ///
	coordinates("$works/perxy.dta") ///
	genid(id) genc(c) replace

	
* Unir la variable pobreza a la base de mapas
use "$works/perushp_dpto.dta", clear
drop OBJECTID id Shape*
gen ccdd_orig=CCDD
rename CCDD ccdd_dest
save "$works/base_latitud_dpto.dta", replace

use "$works/base_migracion.dta", clear
merge m:1 ccdd_orig using "$works/base_latitud_dpto.dta", nogen
rename (x_c y_c NOMBDEP) (long_orig lat_orig DPTO_ORIG)

merge m:1 ccdd_dest using "$works/base_latitud_dpto.dta", nogen
rename (x_c y_c NOMBDEP) (long_dest lat_dest DPTO_DEST)

sort ccdd_orig ccdd_dest 
order ccdd_orig DPTO_ORIG long_orig lat_orig pob_orig ccdd_dest DPTO_DEST long_dest lat_dest pob_dest

* Crear distancia
geodist lat_orig long_orig lat_dest long_dest, gen(dist)

* Logaritmos
gen ln_migro=ln(migracion)
gen ln_poborig=ln(pob_orig)
gen ln_pobdest=ln(pob_dest)
gen ln_dist=ln(dist+1)

* Estimación
regress ln_migro ln_poborig ln_pobdest ln_dist, robust

* Horizontal
coefplot, drop(_cons) xline(0)
coefplot, drop(_cons) xline(0) keep(*:) omitted baselevels

* Vertical
coefplot, vertical drop(_cons) yline(0)

