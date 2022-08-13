
global main   "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/16. Análisis Series de Tiempo/"
global dta    "$main/2. Data"
global graphs "$main/3. Gráficos"
global works  "$main/4. Procesadas"


* II. Formatos del Tiempo
*========================

use "$dta/tseries.dta", clear
list if _n<=10

* El valor de 1960 siempre va ser cero.
* Por lo tanto procedemos a generar la variable date, que empiece en el primer trimestre del año 1957.
gen fecha=_n
format fecha %tq

display (1960-1957)*4+1
gen datevar= _n-13		
format datevar %tq

list if _n<=10

* Formato de datos en series de tiempo:
tsset datevar


* III. Operadores de series de tiempo
*====================================

* 3.1. Operador de rezagos
*-------------------------

* Primer rezago de la variable desempleo (unemployment):
br datevar unemp
gen unempL1=L1.unemp
list datevar unemp unempL1 if _n<=10

* Segundo rezago de la variable desempleo:
gen unempL2=L2.unemp
list datevar unemp unempL1 unempL2 if _n<=10

* Operadores en estimaciones para especificar rezagos:
reg unemp gdp
reg unemp gdp L(1/5).unemp


* 3.2. Operador Forward
*-------------------------

* Operador F para adelantar datos, es decir, generar una variable con las observaciones en t+1:
gen unempF1=F1.unemp
gen unempF2=F2.unemp
list datevar unemp unempF1 unempF2 in 1/10

* Se puede usar también para estimaciones:
reg unemp gdp F(1/5).unemp


* 3.3. Operadores de Diferencias
*--------------------------------

* Podemos ocupar el operador D para calcular la primera y segunda diferencia:
gen unempD1=D1.unemp    // D1= y_t - y_t-1 
gen unempD2=D2.unemp    // D2= (y_t - y_t-1) - (y_t-1 - y_t-2) 
list datevar unemp unempD1 unempD2 in 1/10


* 3.4. Operadores Estacionales
*------------------------------

* Podemos ocupar el operador S para calcular la primera y segunda estación de la variable:
gen unempS1=S1.unemp    // S1= y_t - y_t-1 
gen unempS2=S2.unemp	// S2= y_t - y_t-2
list datevar unemp unempS1 unempS2 in 1/10


* IV. Autocorrelación
*=====================

* Breush-Godfrey y Durbin-Watson son usados para testear correlación serial. La hipótesis nula es que no hay autocorrelación serial.

* 4.1. Durbin Watson
*--------------------

* Toma valores de cero a 4, y hay autocorrelación cuando está cercano a ellos
reg gdp unemp cpi interest
dwstat					
* Vemos que esta por 2 y no hay autocorrelación.

* Predecimos los residuos:
predict e, residual	
scatter e l.e			
graph export "$graphs/autocorrelacion_dw.png", as(png) replace


* 4.2. Breush-Godfrey
*---------------------
estat bgodfrey  
drop e
* No se rechaza la hipotesis nula y no hay autocorrelación serial


* 4.3. Ruido Blanco
*-------------------

* La hipotesis nula es que no hay autocorrelación serial.
wntestq unemp       

* Hay correlación serial
* Si tu variable no es ruido blanco, entonces ver correlogramas para ver el orden de autocorrelación


* V. Correlogramas (AC y PAC)
*==============================

corrgram unemp, lags(12)
ac unemp, ciopts(lcolor(black)) name(ac_unemp, replace) graphregion(color(white))
pac unemp, ciopts(lcolor(black)) name(pac_unemp, replace) graphregion(color(white))

* Combinamos ambos gráficos:
graph combine ac_unemp pac_unemp, graphregion(color(white))
graph export "$graphs/ap_pac_unemp.png", as(png) replace


* VI. Lag Selection
*====================
varsoc gdp cpi, maxlag(10)


* IX. Regresión Espúrea
*========================

reg unemp gdp if tin(1965q1, 1981q4)
reg unemp gdp if tin(1982q1, 2000q4)


* ¿Cómo podemos testear si una serie es estacionaria o no?
* ¿Cómo podemos hacer regresiones cuando tenemos series no estacionarias?

* X. Raiz unitaria
*===================

twoway (tsline unemp), graphregion(color(white)) ylabel(,nogrid)
line unemp datevar, name(unemp_root, replace) graphregion(color(white)) ylabel(,nogrid)
line unempD1 datevar, name(d1unemp_root, replace) graphregion(color(white)) ylabel(,nogrid)
graph combine unemp_root d1unemp_root, graphregion(color(white))
graph export "$graphs/root_unemp.png", as(png) replace


* La hipotesis nula es que la serie es no estacionaria, es decir, tiene raiz unitaria. 

dfuller unemp
	
dfuller unempD1 
* Encontramos que no hay raíz unitaria


* Test de raiz unitaria con tendencia:
dfuller unemp, trend reg	



* XI. Orden de integración
*==========================

* La siguiente serie ¿es estacionaria?
graph combine unemp_root d1unemp_root, graphregion(color(white))
graph export "$graphs/orden_integracion.png", as(png) replace

* Aplicando Dickey-Fuller 
dfuller unempD1  
* No hay raíz unitaria y afirmamos que desempleo es una serie I(1), ya que no es estacionaria, pero su diferencia si lo es.


* XII.  Cointegración
*======================

* Testear cointegración es efectivamente testear la estacionariedad de los residuos. 

* Test de Cointegración
*------------------------

* Paso 1: Correr una regresión OLS y conseguir los residuos
reg unemp gdp
predict e, resid		

* Paso 2: Correr un test de raíz unitaria sobre los residuos
dfuller e, lags(10)

* Ambas variables no están cointegradas.    


