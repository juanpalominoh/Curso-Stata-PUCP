
global main    "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/13. Modelos Logit y Probit Binomial"
global works   "$main/3. Procesadas"
global graphs  "$main/4. Gráficos"


* I. Modelos Binarios
*======================

use "$works/base_anemia.dta", clear

sort HHID HVIDX HWIDX
global var_niño  "i.sexo edadmeses pesoalnacer"
global var_madre "edadmadre i.educmadre ib1.lengmaterna i.anemiamadre"
global var_geog  "i.area"
global var_socio "i.wealth_index"

* Probit
eststo m1: probit d_anemia $var_niño $var_madre $var_geog $var_socio

* Logit
eststo m2: logit d_anemia $var_niño $var_madre $var_geog $var_socio

* Resumen de los resultados de los modelos Logit y Probit
esttab m1 m2, replace label title("Probit y Logit Binomial") ///
					   b(3) se(3) stats(N r2_p aic bic, fmt(0 3 0 0) ///
					   labels("Observations" "Pseudo R2" "AIC" "BIC")) ///
					   drop(0.sexo 0.educmadre 0.area 1.lengmaterna 1.wealth_index 0.anemiamadre) ///
					   coeflabels(pesoalnacer "Peso al nacer/1000" ///
								  edadmadre "Edad madre" anemiamadre "Anemia madre") ///
					   star(* 0.10 ** 0.05 *** 0.01) ///
					   mtitle("Probit" "Logit") ///
		               note("Standard errors in parentheses")	


* 1. Test estadísticos
*-----------------------

* Test de Wald
*---------------
logit d_anemia i.sexo edadniño1335 edadniño3659 pesoalnacer $var_madre $var_geog $var_socio
test edadniño1335

* Test conjunto
test edadniño1335 edadniño3659

* Test de igualdad
test edadniño1335=edadniño3659


* Test de ratio de verosimilitud 
*----------------------------------
* Modelo irrestricto
logit d_anemia sexo edadmeses pesoalnacer $var_madre $var_geog $var_socio, nolog
estimates store fmodel		// fmodel: full model

* Modelo restringido: omite ciertas variables del modelo irrestricto
logit d_anemia sexo pesoalnacer $var_madre $var_geog $var_socio, nolog
estimates store nmodel

lrtest fmodel nmodel		
* Se prefiere el modelo irrestricto
					   
					   
* 2. Medidas de ajuste
*----------------------

* Usamos el paquete fitstat para ver que modelo se ajusta más. Este comando no está instalado en el Stata, por lo que debemos instalarlo:
findit fitstat
* Damos click en spost9_ado y spost13_ado

* Creamos la variable edad al cuadrado
gen edad_sq=(edadmeses^2)

* Modelo 1
logit d_anemia $var_niño $var_madre $var_geog $var_socio, nolog
fitstat, saving(mod1)		

* Modelo 2: incluimos la variable edad al cuadrado dentro de los controles del modelo
logit d_anemia $var_niño edad_sq $var_madre $var_geog $var_socio, nolog
fitstat, using(mod1)		

* El modelo que tiene mayor verosimilitud es mucho mejor
* Con el menor BIC y AIC es el que se prefiere


* 3. Predicción del modelo
*----------------------------
logit d_anemia $var_niño $var_madre $var_geog $var_socio, nolog

* Con el comando predict predecimos la probabilidad de un niño(a) promedio pueda tener anemia
predict prlogit		   
summarize prlogit		
* 0.31 es la probabilidad de que un niño(a) tenga anemia

* Usando una gráfica de puntos observamos la distribución de la probabilidad de que un niño(a) tenga anemia
dotplot prlogit, ylabel(0(.2)1)		
graph export "$graphs/dotpredict.png", as(png) replace


* Comparando las probabilidades del modelo logit y probit
probit d_anemia $var_niño $var_madre $var_geog $var_socio, nolog
predict prprobit
label var prprobit "Probit: Pr(lfp)"


* Correlacion de variables
corr prlogit prprobit		
* En 99.96% de los casos, si hubiesemos estimados probit y logit de la misma manera para hallar la probabilidad de que un niño(a) tenga anemia, hubiera dado un mismo resultado.


* 4. Predicción individual
*--------------------------
logit d_anemia sexo edadmeses pesoalnacer edadmadre sch_madre anemiamadre area riqueza, nolog

* Forzar instalación al paquete spost9_ado 

* Niño, con madre anemica, de area urbana
prvalue, x(sexo=0 anemiamadre=1 area=1) rest(mean) 
* La probabilidad de que tenga anemia es 43.96%

* Niña, con madre anemica, de area urbana
prvalue, x(sexo=1 anemiamadre=1 area=1) rest(mean) 
* La probabilidad de que tenga anemia es 37.28%

* Población promedio
prvalue
* La probabilidad de que tenga anemia es 28.75%

* Tabla de predicción (ejemplo)
logit d_anemia sexo edadmeses pesoalnacer edadmadre sch_madre anemiamadre area riqueza, nolog
prtab anemiamadre area, rest(mean)		
* prtab sirve para hacer tablas de probabilidad. 


* 5. Graficando las probabilidades
*----------------------------------------

* Efecto de la riqueza sobre la probabilidad de tener anemia por edad (meses)

sum riqueza
* Predicción para edad=12
prgen riqueza, from(-2.1) to(2.2) generate(p12) x(edadmeses=12) rest(mean) n(11)
label var p12p1 "12 meses"

* Predicción para edad=24
prgen riqueza, from(-2.1) to(2.2) generate(p24) x(edadmeses=24) rest(mean) n(11)
label var p24p1 "24 meses"

* Predicción para edad=36
prgen riqueza, from(-2.1) to(2.2) generate(p36) x(edadmeses=36) rest(mean) n(11)
label var p36p1 "36 meses"

* Predicción para edad=48
prgen riqueza, from(-2.1) to(2.2) generate(p48) x(edadmeses=48) rest(mean) n(11)
label var p48p1 "48 meses"

* Predicción para edad=59
prgen riqueza, from(-2.1) to(2.2) generate(p59) x(edadmeses=59) rest(mean) n(11)
label var p59p1 "59 meses"

list p12p1 p24p1 p36p1 p48p1 p59p1 p59x in 1/11

#delimit ;
graph twoway connected p12p1 p24p1 p36p1 p48p1 p59p1 p59x, 
    ytitle("Pr(Anemia)") ylabel(0(.25)1) xtitle("Riqueza") graphregion(color(white));
graph export "$graphs/pred_logit.png", as(png) replace;
#delimit cr

	
* 6. Efectos Marginales
*-----------------------

probit d_anemia $var_niño $var_madre $var_geog $var_socio
margins, dydx(*) atmeans 

logit d_anemia $var_niño $var_madre $var_geog $var_socio
margins, dydx(*) atmeans 

	
* Graficando los efectos marginales
logit d_anemia sexo edadmeses pesoalnacer edadmadre sch_madre anemiamadre area riqueza, nolog
margins, at(riqueza=(-2.1(0.4)2.2) edadmeses=(4(10)59))
marginsplot, noci legend(cols(3)) ytitle("Pr(Anemia)") scheme(s2mono) ylabel(0(0.1)1) graphregion(color(white))
graph export "$graphs/margin_binario.png", as(png) replace


* Cambio en las probabilidades predichas
prchange edadmeses, x(sexo=1 edadmeses=40) 
mfx, at(sexo=1 edadmeses=40)
