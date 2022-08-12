

global main 	"/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/9. Gráficos Mapas"
global dta      "$main/2. Data"
global graphs 	"$main/4. Gráficos"
global works 	"$main/5. Procesadas"
global maps     "$main/3. Shapefiles"
global inei  	"http://iinei.inei.gob.pe/iinei/srienaho/descarga/DocumentosZIP/2018-150/"


* Base Pobreza
*---------------
use "$works/base_sumaria_2021.dta", clear
gen CCDD=dpto
tostring CCDD, replace
replace CCDD="0"+CCDD if length(CCDD)==1
order CCDD, b(dpto)
tab poverty [iw=facpob07]
collapse (mean) poverty [iw=facpob07], by(CCDD)
replace poverty=poverty*100
format poverty %5.1f
save "$works/pobreza.dta", replace


*=================
* MAPAS EN STATA
*=================

cd "$maps"
* Descargar Shapefiles
copy "$inei/5_Informacion_Cartografica-Shape.zip" "5_Informacion_Cartografica-Shape.zip", replace
unzipfile "5_Informacion_Cartografica-Shape", replace
erase "$maps/5_Informacion_Cartografica-Shape.zip"

*ssc install shp2dta, replace
*ssc install spmap, replace   // Si no funciona spmap, usar grmap


* Creando archivos de mapas
shp2dta using "$maps/5_Informacion_Cartografica-Shape/LIMITE_DEPARTAMENTO/LIMITE_DEP.shp", ///
	database("$works/perushp_dpto.dta") ///
	coordinates("$works/perxy.dta") ///
	genid(id) genc(c) replace

* Unir la variable pobreza a la base de mapas
use "$works/perushp_dpto.dta", clear
merge 1:1 CCDD using "$works/pobreza.dta", nogen
save "$works/base_pobreza.dta", replace


* Mapa sin información
*----------------------
spmap using "$works/perxy.dta", id(id)
graph export "$graphs/mapa_sininfo.png", as(png) replace 

use "$works/base_pobreza.dta", clear

* Creando base de etiquetas: 
preserve
generate label = NOMBDEP
keep id x_c y_c label
gen length = length(label)
save "$works/Labels.dta", replace
restore


* Mapa con nombres
*------------------
spmap using "$works/perxy.dta", id(id) ///
	  label(data("$works/Labels.dta") x(x_c) y(y_c) ///
		    label(label) size(*0.7 ..) position(0 6) length(21))
graph export "$graphs/mapa_nombre_regiones.png", as(png) replace 


* Mapa de cuantiles
*-------------------
spmap poverty using "$works/perxy.dta", id(id) clmethod(q) cln(6) ///
	title("Mapa Cuantiles: Pobreza 2021") ///
	legend(size(medium) position(8)) fcolor(Blues2) ///
	note("Fuente: INEI - Perú") name(cuantiles, replace) ///
	label(data("$works/Labels.dta") x(x_c) y(y_c) ///
		  label(label) size(*0.5 ..) position(0 6) length(21))
graph export "$graphs/mapa_cuantiles.png", as(png) replace 


* Mapa de intervalos iguales
*----------------------------
spmap poverty using "$works/perxy.dta", id(id) clmethod(e) cln(6) ///
	title("Mapa Intervalos: Pobreza 2021") ///
	legend(size(medium) position(8)) fcolor(Reds2) ///
	note("Fuente: INEI - Perú") name(intervalos, replace) ///
    label(data("$works/Labels.dta") x(x_c) y(y_c) ///
		label(label) size(*0.5 ..) position(0 6) length(21))
graph export "$graphs/mapa_intervalos_iguales.png", as(png) replace 


* Mapa de diagrama de cajas
*----------------------------
spmap poverty using "$works/perxy.dta", id(id) clmethod(boxplot) ///
	title("Mapa Boxplot: Pobreza 2021") ///
	legend(size(medium) position(8)) fcolor(Heat) ///
	note("Fuente: INEI - Perú") name(boxplot, replace) ///
    label(data("$works/Labels.dta") x(x_c) y(y_c) ///
		label(label) size(*0.5 ..) position(0 6) length(21))   
graph export "$graphs/mapa_cajas.png", as(png) replace 


* Mapa de desviaciones estandar
*-------------------------------
spmap poverty using "$works/perxy.dta", id(id) clmethod(s) ///
	title("Mapa Desviaciones Estándar: Pobreza 2021") ///
	legend(size(medium) position(8)) fcolor(Greens2) ///
	note("Fuente: INEI - Perú") name(desvios, replace) ///
    label(data("$works/Labels.dta") x(x_c) y(y_c) ///
		label(label) size(*0.5 ..) position(0 6) length(21))           
graph export "$graphs/mapa_desvios.png", as(png) replace 


* Combinar los mapas y exportar
*-------------------------------
graph combine cuantiles intervalos, saving(mapa_combinar, replace) graphregion(color(white)) 
graph export "$graphs/mapa_combinar.png", as(png) replace 


*=================
* Mapa con cifras
*=================

* Creo una variable que tenga etiqueta nombre y de valores
use "$works/base_pobreza.dta", clear
gen labtype =1
append using "$works/base_pobreza.dta"
replace labtype = 2 if labtype==.
replace NOMBDEP = string(poverty, "%4.1f") if labtype == 2
keep x_c y_c NOMBDEP labtype poverty
save "$works/maplabels.dta", replace


* Primer Mapa con cifras 
*-----------------------------
use "$works/base_pobreza.dta", clear

spmap poverty using "$works/perxy.dta", id(id) ///
	label(data("$works/maplabels.dta") xcoord(x_c) ycoord(y_c) ///
		  label(NOMBDEP) by(labtype) size(*0.7 ..) pos(12 0)) ///
	legend(size(medium) position(8)) fcolor(Reds2) ocolor(white ..) ///
	title("Pobreza 2021") name(figura1, replace)  
graph export "$graphs/mapa_cifras_sincirculos.png", as(png) replace 
	

* Segundo Mapa con cifras (circulos)
*------------------------------------
spmap poverty using "$works/perxy.dta", id(id) clnumber(5) ///
	fcolor(Blues) osize(thin ...) ocolor(black ...) legend(size(medium) position(8)) ///
	point(data("$works/maplabels.dta") ///
			xcoord(x_c) ycoord(y_c) fcolor(white) ocolor(white) size(*2.5)) ///
	label(data("$works/maplabels.dta") ///
			xcoord(x_c) ycoord(y_c) label(poverty) color(blak) size(*0.7)) ///
	title("Pobreza 2021") name(figura2, replace) 
graph export "$graphs/mapa_cifras_concirculos.png", as(png) replace 





*================
* Mapa Distrital
*================

* Creando archivos de mapas
shp2dta using "$maps/5_Informacion_Cartografica-Shape/LIMITE_DISTRITO/LIMITE_DIST.shp", ///
	database("$works/perushp_dist.dta") ///
	coordinates("$works/perxy_dist.dta") ///
	genid(id) genc(c) replace

* Base pobreza a nivel distrital	
use "$works/perushp_dist.dta", clear
merge 1:1 UBIGEO using "$dta/pobreza_distrital_2018.dta", nogen
replace pobreza2018=pobreza2018*100
format pobreza2018 %4.1f
save "$works/base_pobreza_distrital.dta", replace


* Mapa distrital clásico
*------------------------
spmap pobreza2018 using "$works/perxy_dist.dta", ///
 id(id) cln(5) fcolor(Heat) ///
 ocolor(gs6 ..) osize(0.03 ..) ///
 ndfcolor(gs14) ndocolor(gs6 ..) ndsize(0.03 ..) ndlabel("No data") ///
 legend(pos(8) size(3.5) title("% Pobreza", size(medium))) legstyle(2)
graph export "$graphs/mapa_distrital.png", as(png) replace 

 
* Mapa distrital con bordes departamentales
*--------------------------------------------
spmap pobreza2018 using "$works/perxy_dist.dta", ///
 id(id) cln(5) fcolor(Heat) ///
 ocolor(gs6 ..) osize(0.03 ..) ///
 ndfcolor(gs14) ndocolor(gs6 ..) ndsize(0.03 ..) ndlabel("No data") ///
 polygon(data("$works/perxy.dta") ocolor(black) osize(0.2) legenda(off) legl("Departamentos")) ///
 legend(pos(8) size(3.5) title("% Pobreza", size(medium))) legstyle(2) ///
 label(data("$works/Labels.dta") x(x_c) y(y_c) label(label) length(21) color(black) size(1.3))
graph export "$graphs/mapa_distrital_bordes.png", as(png) replace 
	

* Otras paletas
*----------------
*ssc install palettes, replace
*ssc install colorpalette	
colorpalette plasma, n(10) nograph reverse   // plasma, cividis
local colors `r(p)'
spmap pobreza2018 using "$works/perxy_dist.dta", ///
 id(id) cln(10)  fcolor("`colors'") ///
 ocolor(gs6 ..) osize(0.03 ..) ///
 ndfcolor(gs14) ndocolor(gs6 ..) ndsize(0.03 ..) ndlabel("No data") ///
 polygon(data("$works/perxy.dta") ocolor(black) osize(0.2) legenda(on) legl("Departamentos")) ///
 legend(pos(8) size(3.5) title("% Pobreza", size(medium)))  legstyle(2) ///
 label(data("$works/Labels.dta") x(x_c) y(y_c) label(label) length(21) color(black) size(1.3))	
graph export "$graphs/mapa_distrital_colors.png", as(png) replace 

	
