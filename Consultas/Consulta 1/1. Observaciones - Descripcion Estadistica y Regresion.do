
global works "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/2. Manejo de Base de Datos/3. Procesadas"
use "$works/base_laboral_2021.dta", clear

* Solo miembros del hogar (Establecer a los residentes habituales)
gen residente=((p204==1 & p205==2) | (p204==2 & p206==1))
keep if residente==1
drop p204 p205 p206

* Estandarizar observaciones de Estimación con tabla de descripción estadística
*===============================================================================
br ingreso lnwage
sum
gen lnwage2=ln(ingreso+1)

* Paso 1: Estimar la regresión
regress lnwage2 edad i.educ i.informal

* Paso 2: Hallar el predicho
predict double yhat2 if e(sample), xb
predict double uhat if e(sample), residuals

* Paso 3: Borrar los missing del predicho (no es lo mismo que borrar missing de
* la dependiente e independientes)
drop if yhat2==.

* Paso 4: Hacer el resumen estadístico 
sum lnwage2 edad educ informal


