
global main  "/Users/juanpalomino/Google Drive/Cursos/Laboratorio de Stata/Capitulo 2"
global dos   "$main/1. Do Files"
global dta   "$main/2. Data"
global works "$main/3. Procesadas"

cd "$works"

use "$works/base_laboral_2021.dta", clear

* Solo miembros del hogar (Establecer a los residentes habituales)
gen residente=((p204==1 & p205==2) | (p204==2 & p206==1))

keep if (p204==1 & p205==2) | (p204==2 & p206==1) 
drop p204 p205 p206


*==============================
* I. Estadísticos Descriptivos
*==============================

* El comando summarize
*----------------------
summarize 
sum ingreso, detail

* El comando count
*-------------------
count 
count if dpto==15


*=========================
* II. Tabulando Variables
*=========================

* El comando tabulate
*---------------------
tab pea
tab pea [iw=fac500a]
tab pea if area==1
tab pea if area==0


* El comando tab1
*-----------------
tab1 zona area dpto


* El comando tab2
*-----------------
tab2 zona area
tab2 zona area mujer

tab zona area, nofreq row


* El comando table
*------------------
tab zona
table zona, c(mean ingreso) format(%10.0fc)
table pais if pea==1 & ingreso>0 [iw=fac500a], c(mean ingreso) // Ingreso promedio mensual proveniente del trabajo
table zona if pea==1 & ingreso>0 [iw=fac500a], c(sum pea mean ingreso) format(%9.0fc)


*======================
* III. Exportar Tablas
*====================== 

* El comando estpost
*--------------------
* search st0085_2  // instalarlo
estpost summarize
esttab using "$works/ejemplo.csv", cells("count mean sd min max") noobs replace


* El comando asdoc
*------------------
*ssc install asdoc
asdoc sum, save(ejemplo.doc)


* Exportar tabulados a excel:
*-----------------------------
* Ver putexcel, tab2xl, 
help tab2xl // instalarlo
tab2xl dpto zona using "$works/tabla.xlsx", col(1) row(1)


* Exportar tabulados a word:
*-----------------------------
help tab2docx // instalarlo

* Primero crean documento
putdocx begin
tab2docx dpto
putdocx save "$works/tabla.docx"
