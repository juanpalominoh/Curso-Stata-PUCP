

*=========================
* Limpieza de Datos ENDES
*=========================

global main      "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/13. Modelos Logit y Probit Binomial"
global endes     "$main/2. ENDES"
global dta_hogar "$endes/Modulo Hogar"
global dta_ind 	 "$endes/Modulo Individual"
global dta_ps    "$endes/Modulo PS"
global dta_salud "$endes/Modulo Salud"
global works     "$main/3. Procesadas"


*=============================
* Modulo Datos Basicos de MEF
*=============================

* REC0111
*---------
use "$dta_ind/REC0111.dta", clear

* ID
count // 38,635
split CASEID
order HHID CASEID CASEID1 CASEID2, a(ID1)
drop HHID CASEID
rename (CASEID1 CASEID2) (HHID HVIDX)
destring HVIDX, replace
duplicates list HHID HVIDX

keep HHID HVIDX V001 V002 V005 V012 V015 V106 V131 V133 V190 V191 V022 V024 V025 V040
rename (V001 V002 V191 V025 V040 V012 V024 V022 V190) (conglome hogar riqueza urbano altitud edadmadre region estrato wealth_index)

recode V133 (97=.), gen(sch_madre)
recode urbano (1=1 "Urbano") (2=0 "Rural"), gen(area)
recode V131 (1/9=0 "Lengua Indígena") (10=1 "Castellano") (11 12=2 "Lengua extranjera"), gen(lengmaterna) 
recode V106 (0/1=0 "Primaria  o menos") (2=1 "Secundaria") (3=2 "Superior"), gen(educmadre) 
drop urbano V106 V131 V133

*Reescalamos variable ponderacion
format V005 %8.0f
gen peso=V005/1000000 

order V015 edadmadre sch_madre educmadre lengmaterna wealth_index riqueza region area altitud estrato V005 peso, a(hogar)
sort HHID HVIDX

count

save "$works/datos_madre.dta", replace     // 38,635



*=================================================================
* Modulo Historia de Nacimiento - Tabla de Conocimiento de Metodo
*=================================================================

* REC21
*----------
use "$dta_ind/REC21.dta", clear

count   // 66,258
split CASEID
order CASEID CASEID1 CASEID2, a(ID1)
rename (CASEID1 CASEID2) (HHID HVIDX)
destring HVIDX, replace
duplicates list HHID HVIDX BIDX
mdesc

* Sexo
recode B4 (1=0 "Hombre") (2=1 "Mujer"), g(sexo)
lab var sexo "Sexo del niño"

* Rename
rename BIDX HWIDX

keep HHID HVIDX BORD HWIDX sexo B5

save "$works/sexo_niño.dta", replace // 66,258


*===============================================
* Modulo Embarazo, Parto, Puerperio y Lactancia
*===============================================

* REC41
*-------
use "$dta_ind/REC41.dta", clear

count // 22,100
split CASEID
order CASEID CASEID1 CASEID2, a(ID1)
rename (CASEID1 CASEID2) (HHID HVIDX)
destring HVIDX, replace
drop CASEID
duplicates list HHID HVIDX MIDX

keep HHID HVIDX MIDX M19
rename MIDX HWIDX

* Peso al nacer
sum
label list M19
gen pesoalnacer=M19
replace pesoalnacer=. if pesoalnacer==9996 | pesoalnacer==9998
replace pesoalnacer=pesoalnacer/1000
drop M19 

sum

save "$works/peso_nacer.dta", replace   // 22,100


*=============================
* Modulo Inmunización y Salud
*=============================

* REC42
*-------
use "$dta_ind/REC42.dta", clear

count // 36,714
split CASEID
order CASEID CASEID1 CASEID2, a(ID1)
rename (CASEID1 CASEID2) (HHID HVIDX)
destring HVIDX, replace
drop CASEID
duplicates list HHID HVIDX

* Anemia Madre
label list V457
recode V457 (1/3=1 "Madre Tiene anemia") (4=0 "Madre No tiene anemia") (9=.), gen(anemiamadre)
label var anemiamadre "Madre tiene anemia"

keep HHID HVIDX anemiamadre
duplicates list HHID HVIDX

save "$works/anemia_madre.dta", replace   // 36,714


*==============================
* Modulo Peso y Talla - Anemia
*==============================

* REC44 
*-------
use "$dta_ind/REC44.dta", clear

count  // 22,100
split CASEID
order CASEID CASEID1 CASEID2, a(ID1)
rename (CASEID1 CASEID2) (HHID HVIDX)
destring HVIDX, replace
drop CASEID
duplicates list HHID HVIDX HWIDX

keep HHID HVIDX HWIDX HW1 HW13 HW55 HW57 

* Renombrando
rename HW1 edadmeses

* Edad Grupos
gen edadniño012=1 if edadmeses>=0 & edadmeses<=12
replace edadniño012=0 if edadmeses>=13 & edadmeses<=59

gen edadniño1335=1 if edadmeses>=13 & edadmeses<=35
replace edadniño1335=0 if (edadmeses>=0 & edadmeses<=12) | (edadmeses>=36 & edadmeses<=59)

gen edadniño3659=1 if edadmeses>=36 & edadmeses<=59
replace edadniño3659=0 if edadmeses>=0 & edadmeses<=35


* Tiene Anemia Niño
tab HW57
label list HW57
recode HW57 (1/3=1 "Tiene Anemia") (4=0 "No tiene anemia") (9=.), gen(d_anemia)

* Categorías de Anemia
recode HW57 (4=1 "Sin Anemia") (3=2 "Leve") (2=3 "Moderado") (1=4 "Grave") (9=.), gen(anemia)
tab1 anemia d_anemia
drop HW57

save "$works/anemia_niño.dta", replace   // 22,100



*=============
* Union Bases
*=============

* Union base niños
use "$works/sexo_niño.dta", clear
merge 1:1 HHID HVIDX HWIDX using "$works/peso_nacer.dta", nogen
merge 1:1 HHID HVIDX HWIDX using "$works/anemia_niño.dta", nogen
sort HHID HVIDX HWIDX 
save "$works/base_niños.dta", replace  // 66,258

* Union base madres
use "$works/datos_madre.dta", clear    // 38,635
merge 1:1 HHID HVIDX using "$works/anemia_madre.dta", nogen
tab V015
keep if V015==1  // Encuestas completas
drop V015
count
save "$works/base_madre.dta", replace   // 36,714

* Union base niños - madres
use "$works/base_niños.dta", clear
duplicates list HHID HVIDX
merge m:1 HHID HVIDX using "$works/base_madre.dta"

* Filtros
drop if B5==0       // Eliminar niños muertos
keep if HW13==0     // Solo medidos
keep if HW55==0     // Solo los que aceptaron consentimiento
drop _merge B5 HW13 HW55


* sort edadmeses
*drop if edadmeses<6 // | edadmeses>35
sort HHID HVIDX HWIDX
count
mdesc
sum

save "$works/base_anemia.dta", replace // 20,466
