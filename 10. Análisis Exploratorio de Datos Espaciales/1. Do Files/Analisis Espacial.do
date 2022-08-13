
clear all
global main     "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/10. Análisis Exploratorio de Datos Espaciales/"
global dos      "$main/1. Do Files"
global dta      "$main/2. Data"
global works    "$main/3. Procesadas"
global maps     "$main/4. Shapefiles"
global graphs   "$main/5. Gráficos"
global inei  	"http://iinei.inei.gob.pe/iinei/srienaho/descarga/DocumentosZIP/2018-150/"


* Descargar Shapefiles
cd "$maps"
copy "$inei/5_Informacion_Cartografica-Shape.zip" "5_Informacion_Cartografica-Shape.zip", replace
unzipfile "5_Informacion_Cartografica-Shape", replace
erase "$maps/5_Informacion_Cartografica-Shape.zip"


*====================
* CLUSTER DE POBREZA
*====================

* Primer Paso
*--------------
* Creando bases de datos de polígonos y coordenadas
shp2dta using "$maps/5_Informacion_Cartografica-Shape/LIMITE_PROVINCIA/LIMITE_PROV.shp", ///
				database("$works/datoprov.dta") ///
				coordinates("$works/coorprov.dta") /// 
				genid(id) genc(c) replace


* Unimos bases de datos (indicadores de gini y pobreza con base de provincias)
use "$works/datoprov.dta", clear
duplicates drop IDPROV, force
merge 1:1 IDPROV using "$dta/basepr_gini_fgt0.dta", nogen
save "$works/base_pobreza.dta", replace


* Segundo Paso 
*--------------

* Visualizar en un mapa la data espacial
format pobr %12.3f
spmap pobr using "$works/coorprov.dta", id(id) clmethod(s) title("% de Pobreza Total de las provincias 2017") ///
legend(size(medium) position(8)) fcolor(Reds2) note("Fuente: INEI - Perú") name(poverty, replace)



* Tercer Paso
*---------------

* Creación de Matrices Espaciales a partir de la base de datos del shapefile
spmat contiguity idmat_c using "$works/coorprov.dta", id(id) replace
spmat getmatrix idmat_c W
getmata (x*)=W
spmat dta W_queen x1-x196, id(id) norm(row) replace
keep x1-x196
save "$works/W_queen_b.dta", replace

* Creación de Matriz Espacial Estandarizada
spatwmat using "$works/W_queen_b.dta", name(Ws) standardize
matrix list Ws

* Creación de Matriz Espacial No Estandarizada
spatwmat using "$works/W_queen_b.dta", name(W)
matrix list W




* Cuarto Paso
*---------------

* Indices Globales de Autocorrelación Espacial
use "$works/base_pobreza.dta", clear

* I de Moran
spatgsa pobr, w(Ws) moran two

* c de Geary
spatgsa pobr, w(Ws) geary two

* G de Getis y Ord
spatgsa pobr, w(W) go two


* Quinto Paso
*---------------

* Indicadores Locales de Autocorrelación espacial
spatlsa pobr, w(Ws) moran id(NOMBPROV) sort twotail 

* Diagramas de Dispersión de Moran
splagvar pobr, wname(Ws) wfrom(Stata) ind(pobr) order(1) plot(pobr) moran(pobr)

* Diagramas de Dispersión de Moran
do "$dos/program_genmsp.do"
genmsp pobr, w(Ws)

graph twoway (scatter Wstd_pobr std_pobr if pval_pobr>=0.05, ///
					  msymbol(i) mlabel(NOMBPROV) mlabsize(*0.4) mlabpos(c)) ///
			 (scatter Wstd_pobr std_pobr if pval_pobr<0.05, ///
			          msymbol(i) mlabel(NOMBPROV) mlabsize(*0.4) mlabpos(c) mlabcol(red)) ///
			 (lfit Wstd_pobr std_pobr), ///
			 yline(0, lpattern(--)) xline(0, lpattern(--)) ///
			 xlabel(-2.5(1)2.5, labsize(*0.8)) xtitle("{it:x}") ///
			 ylabel(-2.5(1)2.5, angle(0) labsize(*0.8)) ///
			 ytitle("{it:Wx}") legend(off) scheme(s1color)
graph export "$graphs/scatterplot_moran.png", replace
			 
* Mapa de cluster			 
spmap msp_pobr using "$works/coorprov.dta", ///
		id(id) clmethod(unique) fcolor(blue blue*0.2 red) ///
		label(x(x_c) y(y_c) label(NOMBPROV) color(white)  ///
			  size(*0.4) select(keep if msp_pobr!=.))
graph export "$graphs/plot_lisa.png", replace
			  
