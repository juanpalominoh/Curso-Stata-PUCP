

*================================
* Limpieza de datos: MODULO 500
*================================

use "$dta_5/enaho01a-2016-2020-500-panel01.dta", clear

* Me quedo con los individuos que persisten entre 2016 y 2020
keep if perpanel1620==1 // 4,664
keep if hpanel1620==1 // 4,636

* Creando id de persona
egen id_codperso=concat(conglome vivienda hogar_16 codperso_16)
duplicates list id_codperso


foreach i in 16 17 18 19 20 {
	
* Variables Individuales
*------------------------

* Jefe de hogar
recode p203_`i' (1=1 "Jefe") (0 2/11=0 "Otro"), gen(jefe_`i')
label var jefe_`i' "Jefe de Hogar `i'"


* Residentes Habituales
gen residente_`i'=((p204_`i'==1 & p205_`i'==2) | (p204_`i'==2 & p206_`i'==1))
label var residente_`i' "Residente Habitual `i'"


* Edad (años)
rename p208a_`i' edad_`i'
label variable edad_`i' "Edad `i'"


* Edad al cuadrado
gen sq_edad_`i'=edad_`i'*edad_`i'
label var sq_edad_`i' "Edad^{2}"


* Sexo
recode p207_`i' (2=1 "Mujer") (1=0 "Hombre"), gen(mujer_`i')
label variable mujer_`i' "Mujer `i'"


* Estado Civil
recode p209_`i' (1/2=1 "Casada/Conviviente") (3=2 "Viuda") (4/5=3 "Divorciada/Separada") (6=4 "Soltera"), gen(civil_`i')
label var civil_`i' "Civil Status `i'"


* Raza
recode p558c_`i' (1/4 6 9=1 "Indigenous") (5 7/8=0 "Other"), gen(indigenous_`i')
label var indigenous_`i' "Indigenous `i'"


* Nivel educativo
recode p301a_`i' (1/2=1 "Sin Nivel/Inicial") (3/4=2 "Primaria") (5/6 12=3 "Secundaria") (7/8=4 "Superior no universitaria") (9/10=5 "Superior universitaria") (11=6 "Maestria/Doctorado"), gen(educ_`i')
label var educ_`i' "Nivel Educación `i'"


*----------------------
* Variables Laborales
*----------------------

* PEA ocupada
label list ocu500
recode ocu500_`i' (1=1 "Empleado") (2/4=0 "Desempleado"), gen(peao_`i')
label variable peao_`i' "PEA `i'"


* Empleo informal:
recode ocupinf_`i' (1=1 "Informal") (2=0 "Formal"), gen(informal_`i')
label var informal_`i' "Empleo Informal `i'"


* Permanencia
gen per_`i' = p513a1_`i' if p513a1_`i'!=.
label var per_`i' "Años de permanencia en el trabajo actual `i'"


*-----------------------
* Variables Geográficas
*-----------------------

* Departamento
gen dpto_`i'=substr(ubigeo_`i',1,2)
destring dpto_`i', replace
label var dpto_`i' "Departamento `i'"
label define lab_dpto 1 "Amazonas" 2 "Ancash" 3 "Apurímac" 4 "Arequipa" ///
		5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" ///
		11 "Ica" 12 "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 	16 "Loreto" ///
		17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" ///
		23 "Tacna" 24 "Tumbes" 25 "Ucayali", replace
label values dpto_`i' lab_dpto


* Area
recode estrato_`i' (1/5=1 "urbana") (6/8=0 "rural"), gen(area_`i') 
label variable area_`i' "Urbano `i'"


}

keep conglome vivienda hogar_16 codperso_16 id_codperso jefe_* residente_* edad* mujer* civil* indigenous* educ* ocu500* peao* informal* per_* dpto_* area_* facpanel1620 fac500*

order conglome vivienda hogar_16 codperso_16 id_codperso jefe_* residente_* edad* mujer* civil* indigenous* educ* ocu500* peao* informal* per_* dpto_* area_* facpanel1620 fac500*

save "$works/base_empleo1.dta", replace // 4,636


*========================
* Modulo 500 - Panel 02
*========================

use "$dta_5/enaho01a-2016-2020-500-panel02.dta", clear

* Me quedo con los individuos que persisten entre 2016 y 2020
keep if perpanel1620==1 // 4,664
keep if hpanel1620==1 // 4,636

* Creando id de persona
egen id_codperso=concat(conglome vivienda hogar_16 codperso_16)
duplicates list id_codperso

foreach i in 16 17 18 19 20 {

* Ingreso principal + secundario + ingresos extraordinarios
*-----------------------------------------------------------
egen ingreso_pri_`i'=rowtotal(i524a1_`i' d529t_`i' i530a_`i' d536_`i')
egen ingreso_sec_`i'=rowtotal(i538a1_`i' d540t_`i' i541a_`i' d543_`i') 
egen ingreso_tot_`i'=rowtotal(i524a1_`i' d529t_`i' i530a_`i' d536_`i' i538a1_`i' d540t_`i' i541a_`i' d543_`i' d544t_`i')

gen y_`i'=ingreso_tot_`i'/12
gen lnwage_`i'=ln(y_`i')

label variable y_`i' "Ingreso mensual `i'"
label variable lnwage_`i' "Ln(Ingreso mensual) `i'"

* Zona
*------
recode dominio_`i' (1/3=1 "Costa") (4/6=2 "Sierra") (7=3 "Selva") (8=4 "Lima Metropolitana"), gen(zona_`i')
label var zona_`i' "Zona `i'"

}

keep conglome vivienda hogar_16 codperso_16 id_codperso ingreso_pri* ingreso_sec* ingreso_tot* y_* lnwage_* zona_* facpanel1620 

order conglome vivienda hogar_16 codperso_16 id_codperso ingreso_pri* ingreso_sec* ingreso_tot* y_* lnwage_* zona_* facpanel1620 

save "$works/base_empleo2.dta", replace // 4,636



use "$works/base_empleo1.dta", clear
merge 1:1 conglome vivienda hogar_16 codperso_16 using "$works/base_empleo2.dta", keepusing(ingreso_pri* ingreso_sec* ingreso_tot* y_* lnwage_* zona_*) nogen

order conglome vivienda hogar_16 codperso_16 id_codperso jefe_* residente_* edad* mujer* civil* indigenous* educ* ocu500* peao* informal* per_* ingreso_pri* ingreso_sec* ingreso_tot* y_* lnwage_* zona_* dpto_* area_* facpanel1620 fac500*

* Codigo id de individuo
sort id_codperso
gen id=_n

* Elimino algunas variables
drop id_codperso conglome vivienda hogar_16 codperso_16 fac500_p_20
order id

* Reemplazar observaciones
replace mujer_20=0 if id==2784
replace mujer_16=1 if id==2791
replace mujer_20=1 if id==2791
replace mujer_16=1 if id==2688
replace mujer_17=1 if id==3202
replace mujer_20=1 if id==45

* Reshape a long data
reshape long jefe_ residente_ edad_ mujer_ civil_ indigenous_ educ_ ocu500_ peao_ informal_ per_ ingreso_pri_ ingreso_sec_ ingreso_tot_ y_ lnwage_ zona_ dpto_ area_ fac500a_ , i(id facpanel1620) j(year)

* Rename a las variables que terminan en "_"
rename (*_) (*)

* Reemplazo a años
replace year=2016 if year==16
replace year=2017 if year==17
replace year=2018 if year==18
replace year=2019 if year==19
replace year=2020 if year==20

order facpanel1620, last

save "$works/base_panel_enaho.dta", replace
