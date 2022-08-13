
global main   "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/16. Análisis Series de Tiempo/"
global dta    "$main/2. Data"
global graphs "$main/3. Gráficos"
global works  "$main/4. Procesadas"


* II. Formatos del Tiempo
*========================

use "$dta/series_peru.dta", clear
list if _n<=10

* El valor de 1960 siempre va ser cero.
* Por lo tanto procedemos a generar la variable date, que empiece en el primer trimestre del año 1957.
gen fecha=_n
format fecha %tq

gen datevar= _n+159		
format datevar %tq

list if _n<=10

* Formato de datos en series de tiempo:
tsset datevar


* III. Operadores de series de tiempo
*====================================

* 3.1. Operador de rezagos
*-------------------------

* Primer rezago de la variable desempleo (unemployment):
br datevar taxes
gen taxesL1=L1.taxes
list datevar taxes taxesL1 if _n<=10

* Segundo rezago de la variable desempleo:
gen taxesL2=L2.taxes
list datevar taxes taxesL1 taxesL2 if _n<=10

* Operadores en estimaciones para especificar rezagos:
reg taxes gdp
reg taxes gdp L(1/5).taxes


* 3.2. Operador Forward
*-------------------------

* Operador F para adelantar datos, es decir, generar una variable con las observaciones en t+1:
gen taxesF1=F1.taxes
gen taxesF2=F2.taxes
list datevar taxes taxesF1 taxesF2 in 1/10

* Se puede usar también para estimaciones:
reg taxes gdp F(1/5).taxes


* 3.3. Operadores de Diferencias
*--------------------------------

* Podemos ocupar el operador D para calcular la primera y segunda diferencia:
gen taxesD1=D1.taxes    // D1= y_t - y_t-1 
gen taxesD2=D2.taxes    // D2= (y_t - y_t-1) - (y_t-1 - y_t-2) 
list datevar taxes taxesD1 taxesD2 in 1/10


* 3.4. Operadores Estacionales
*------------------------------

* Podemos ocupar el operador S para calcular la primera y segunda estación de la variable:
gen taxesS1=S1.taxes    // S1= y_t - y_t-1 
gen taxesS2=S2.taxes	// S2= y_t - y_t-2
list datevar taxes taxesS1 taxesS2 in 1/10


* IV. Autocorrelación
*=====================

* Breush-Godfrey y Durbin-Watson son usados para testear correlación serial. La hipótesis nula es que no hay autocorrelación serial.

* 4.1. Durbin Watson
*--------------------

* Toma valores de cero a 4, y hay autocorrelación cuando está cercano a ellos
reg gdp taxes exports imports
dwstat					
* Vemos que esta por 1 y no hay autocorrelación.

* Predecimos los residuos:
predict e, residual	
scatter e l.e			
graph export "autocorrelacion_dw_series_peru.png", as(png) replace


* 4.2. Breush-Godfrey
*---------------------
estat bgodfrey  
drop e
* No se rechaza la hipotesis nula y no hay autocorrelación serial


* 4.3. Ruido Blanco
*-------------------

* La hipotesis nula es que no hay autocorrelación serial.
wntestq taxes       

* Hay correlación serial
* Si tu variable no es ruido blanco, entonces ver correlogramas para ver el orden de autocorrelación


* V. Correlogramas (AC y PAC)
*==============================

corrgram taxes, lags(12)
ac taxes, ciopts(lcolor(black)) name(ac_taxes, replace) graphregion(color(white))
pac taxes, ciopts(lcolor(black)) name(pac_taxes, replace) graphregion(color(white))

* Combinamos ambos gráficos:
graph combine ac_taxes pac_taxes, graphregion(color(white))
graph export "ap_pac_taxes.png", as(png) replace


* VI. Lag Selection
*====================
varsoc gdp exports, maxlag(10)


* IX. Regresión Espúrea
*========================

reg taxes gdp if tin(2000q1, 2007q4)
reg taxes gdp if tin(2008q1, 2020q4)


* ¿Cómo podemos testear si una serie es estacionaria o no?
* ¿Cómo podemos hacer regresiones cuando tenemos series no estacionarias?

* X. Raiz unitaria
*===================

twoway (tsline gdp), graphregion(color(white)) ylabel(,nogrid)
line taxes fecha, name(taxes_root, replace) graphregion(color(white)) ylabel(,nogrid)
line taxesD1 datevar, name(d1taxes_root, replace) graphregion(color(white)) ylabel(,nogrid)
graph combine taxes_root d1taxes_root, graphregion(color(white))
graph export "$graphs/root_unemp.png", as(png) replace


* La hipotesis nula es que la serie es no estacionaria, es decir, tiene raiz unitaria. 

dfuller taxes
	
dfuller taxesD1 
* Encontramos que no hay raíz unitaria


* Test de raiz unitaria con tendencia:
dfuller taxes, trend reg	


* XI. Orden de integración
*==========================

* La siguiente serie ¿es estacionaria?
graph combine taxes_root d1taxes_root, graphregion(color(white))
graph export "$graphs/orden_integracion.png", as(png) replace

* Aplicando Dickey-Fuller 
dfuller taxesD1  
* No hay raíz unitaria y afirmamos que desempleo es una serie I(1), ya que no es estacionaria, pero su diferencia si lo es.


* XII.  Cointegración
*======================

* Testear cointegración es efectivamente testear la estacionariedad de los residuos. 

* Test de Cointegración
*------------------------

* Paso 1: Correr una regresión OLS y conseguir los residuos
reg taxes gdp
predict e, resid		

* Paso 2: Correr un test de raíz unitaria sobre los residuos
dfuller e, lags(10)

* Ambas variables no están cointegradas.    

