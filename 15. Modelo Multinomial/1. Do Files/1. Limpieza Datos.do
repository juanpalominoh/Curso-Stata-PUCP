
global main     "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/15. Modelo Multinomial"
global dta      "$main/2. Data"
global works 	"$main/3. Procesadas"
cd "$dta"

*==========================================
* Limpieza de Datos - ENAHO MODULO LABORAL
*==========================================

* Descargar datos
global inei  "http://iinei.inei.gob.pe/iinei/srienaho/descarga/STATA/"
copy "$inei/759-Modulo05.zip" "759-Modulo05.zip", replace
unzipfile "759-Modulo05", replace
erase "759-Modulo05.zip"

copy  "$dta/759-Modulo05/enaho01a-2021-500.dta" "$dta/enaho01a-2021-500.dta", replace
erase "$dta/759-Modulo05/enaho01a-2021-500.dta"



use "$dta/enaho01a-2021-500.dta", clear

*========================
* Variables Individuales
*========================

* Edad
rename p208a edad
label var edad "Edad (años)"


* Grupos etarios
recode edad (0/29=1 "Menor a 30 años") (30/44=2 "Entre 30 y 44 años") (45/59=3 "Entre 45 y 59 años") (60/max=4 "Mayor a 60 años"), gen(etario)
label variable etario "Grupo Etario"


* Sexo
recode p207 (2=1 "Mujer") (1=0 "Hombre"), gen(mujer)
label var mujer "Mujer"
	
	
* Estado Civil
recode p209 (1/2=1 "Casado/Conviviente") (3=2 "Viudo") (4/5=3 "Divorciado/Separado") (6=4 "Soltero"), gen(civil)
label var civil "Estado Civil"


* Nivel educativo
recode p301a (1/2=1 "Sin Nivel/Inicial") (3/4=2 "Primaria") (5/6 12=3 "Secundaria") (7/8=4 "Superior no universitaria") (9/10=5 "Superior universitaria") (11=6 "Maestria/Doctorado"), gen(educ)
label var educ "Nivel Educación"


* Raza
recode p558c (1/4 6 9=1 "Indigena") (5 7/8=0 "Otro"), gen(indigena)
label var indigena "Indígena"


* Jefe de hogar
recode p203 (1=1 "Jefe") (0 2/11=0 "Otro"), gen(jefe)
label var jefe "Jefe de Hogar"


* Residentes Habituales
gen residente=((p204==1 & p205==2) | (p204==2 & p206==1))
label var residente "Residente Habitual"


*=====================
* Variables Laborales
*=====================

* Pea
recode ocu500 (1/2=1 "PEA") (3/4=0 "NO PEA") (0=.), gen(pea)
label var pea "PEA"


* Pea Ocupada
label list ocu500
recode ocu500 (1=1 "Pea Ocupada") (2/4=0 "Otro"), gen(peao)
label var ocu500 "PEA ocupada"


* Empleo informal:
recode ocupinf (1=1 "Informal") (2=0 "Formal"), gen(informal)
label var informal "Empleo Informal"


* Actividades Sectoriales
recode p506r4 ///
	(0111/0322= 1 "Agricultura, ganadería, silvicultura y pesca") ///
	(0510/0990= 2 "Explotación de minas y canteras") ///
	(1010/3320= 3 "Industrias manufactureras") ///
	(3510/3530= 4 "Suministro de electricidad, gas, vapor y aire acondicionado") ///
	(3600/3900= 5 "Suministro de agua; evacuación de aguas residuales, gestión de desechos y descontaminación") ///
	(4100/4390= 6 "Construcción") ///
	(4510/4799= 7 "Comercio al por mayor y al por menor; reparación de vehículos automotores y motocicletas") ///
	(4911/5320= 8 "Transporte y almacenamiento") ///
	(5510/5630= 9 "Actividades de alojamiento y de servicio de comidas") ///
	(5811/6399= 10 "Información y comunicaciones") ///
	(6411/6630= 11 "Actividades financieras y de seguros") ///
	(6810/6820= 12 "Actividades inmobiliarias") ///
	(6910/7500= 13 "Actividades profesionales, científicas y técnicas") ///
	(7710/8299= 14 "Actividades de servicios administrativos y de apoyo") ///
	(8411/8430= 15 "Administración pública y defensa; planes de seguridad social de afiliación obligatoria") ///
	(8510/8550= 16 "Enseñanza") ///
	(8610/8890= 17 "Actividades de atención de la salud humana y de asistencia social") ///
	(9000/9329= 18 "Actividades artísticas, de entretenimiento y recreativas") ///
	(9411/9609= 19 "Otras actividades de servicios") ///
	(9700/9820= 20 "Actividades de los hogares como empleadores; actividades no diferenciadas de los hogares como productores de bienes y servicios para uso propio") ///
	(9900= 21 "Actividades de organizaciones y órganos extraterritoriales"), gen(act_sec)
label var act_sec "Actividades Sectoriales"

 
* Por sectores primarios, secundarios y terciarios
recode act_sec (1/2=1 "Sector Primario") (3/6=2 "Sector Secundario") (7/21=3 "Sector Terciario"), gen(sector)
label variable sector "Sector"


* Grupo Ocupacional
* https://www.inei.gob.pe/media/Clasificador_Nacional_de_Ocupaciones_9_de_febrero.pdf
gen ciuo=int(p505r4)
recode ciuo (1111/1499=1 "Miembros del Poder Ejecutivo, Legislativo, Judicial y personal directivo de la administración pública y privada") ///
			(2111/2656=2 "Profesionales científicos e intelectuales") ///
			(3111/3523=3 "Profesionales técnicos") ///
			(4110/4419=4 "Jefes y empleados administrativos") ///
			(5111/5419=5 "Trabajadores de los servicios y vendedores de comercios y mercados") ///
			(6111/6340=6 "Agricultores y trabajadores calificados agropecuarios, forestales y pesqueros") ///
			(7111/7519=7 "Trabajadores de la construcción, edificación, productos artesanales, electricidad y las telecomunicaciones") ///
			(8111/8352=8 "Operadores de maquinaria industrial, ensambladores y conductores de transporte") ///
			(9111/9629=9 "Ocupaciones elementales") ///
			(111/131 211/231 311/331=0 "Ocupaciones militares y policiales"), gen(gruocu)
label variable gruocu "Grupo Ocupacional"


* Habilidad Ocupacional
* https://www.ilo.org/ilostat-files/Documents/description_OCU_EN.pdf
recode gruocu (1/3=1 "High Skill Occupation") (4/8=2 "Medium Skill Occupation") (9=3 "Low Skill Occupation") (0=0 "Ocupaciones Fuerzas Armadas"), gen(skill_ocu)
label variable skill_ocu "Skill Occupation"


* Ingreso Mensual
egen ing_ocu_pri=rowtotal(i524a1 d529t i530a d536)						
egen ing_ocu_sec=rowtotal(i538a1 d540t i541a d543)						
rename d544t ing_extra
egen ing_total = rowtotal(ing_ocu_pri ing_ocu_sec ing_extra) 
gen ingreso=ing_total/12
label var ingreso "Ingreso Total Mensual"


* Logaritmo Ingreso Mensual
gen lnwage=ln(ingreso)
label var lnwage "Logaritmo Ingreso Mensual"


* Categoria de afiliados a sistema de pensiones
d p558a*
br p558a*
recode p558a1 (1=1 "AFP") (0=0 "No afiliado"), gen(afp)
recode p558a2 (2=1 "SNP 19990") (0=0 "No afiliado"), gen(snp19)
recode p558a3 (3=1 "SNP 20530") (0=0 "No afiliado"), gen(snp20)
recode p558a4 (4=1 "Otra afiliación") (0=0 "No afiliado"), gen(sis_otro)  // Caja de Pensiones del Pescador/Estibador, Caja de Pensiones Militar Policial, etc
recode p558a5 (0=1 "Afiliado") (5=0 "No afiliado"), gen(afil_pens)
label var afil_pens "Afiliado a un Sistema de Pensiones"

* ONP
gen onp=(snp19==1 | snp20==1)
replace onp=. if snp19==. | snp20==.
label define lab_onp 1 "ONP" 0 "No Afiliado"
label values onp lab_onp

* Tipo de Pensiones
gen cat_pens=1 if afil_pens==0
replace cat_pens=2 if afp==1
replace cat_pens=3 if onp==1
replace cat_pens=4 if sis_otro==1
replace cat_pens=. if afp==. | onp==. | sis_otro==.
label define cat_pens 1 "No afiliado" 2 "AFP" 3 "ONP" 4 "Otro"
label values cat_pens cat_pens

* Hay casos de individuos que estan afiliados en dos sistemas a la vez (es raro). 
* Aquí la categorización depende del investigador o una investigación más profunda para cada caso.
* br afp snp19 snp20 sis_otro afil_pens cat_pens if afp==1 & snp19==1
replace cat_pens=2 if afp==1 & snp19==1
replace cat_pens=2 if afp==1 & snp20==1
replace cat_pens=2 if afp==1 & sis_otro==1
replace cat_pens=4 if snp19==1 & sis_otro==1
replace cat_pens=4 if snp20==1 & sis_otro==1


*=======================
* Variables Geográficas
*=======================

* Pais
gen pais="Perú"
label var pais "País"


* Departamento
gen dpto=substr(ubigeo,1,2)
destring dpto, replace
label var dpto "Departamento"
label define lab_dpto 1 "Amazonas" 2 "Ancash" 3 "Apurímac" 4 "Arequipa" ///
		5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" ///
		11 "Ica" 12 "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 	16 "Loreto" ///
		17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" ///
		23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values dpto lab_dpto


* Area
recode estrato (1/5=1 "Urbano") (6/8=0 "Rural"), gen(area) 
label var area "Área Geográfica"


* Zona
recode dominio (1/3=1 "Costa") (4/6=2 "Sierra") (7=3 "Selva") (8=4 "Lima Metropolitana"), gen(zona)
label var zona "Zona Geográfica"


* Zona Geográfica
gen zona_geo=1 if zona==1 & area==1
replace zona_geo=2 if zona==1 & area==0
replace zona_geo=3 if zona==2 & area==1
replace zona_geo=4 if zona==2 & area==0
replace zona_geo=5 if zona==3 & area==1
replace zona_geo=6 if zona==3 & area==0
replace zona_geo=7 if zona==4
label var zona_geo "Zona geográfica"
label define zona_geo 1 "Costa Urbano" 2 "Costa Rural" 3 "Sierra Urbano" 4 "Sierra Rural" 5 "Selva Urbano" 6 "Selva rural" 7 "Lima Metropolitana"
label values zona_geo zona_geo


keep conglome-codperso pais dpto area zona zona_geo edad etario mujer civil educ indigena jefe residente pea peao act_sec sector gruocu skill_ocu ingreso lnwage afil_pens afp snp19 snp20 onp sis_otro cat_pens informal fac500a

order pais dpto zona area zona_geo conglome-codperso mujer edad etario civil educ jefe residente indigena
order fac500a, last 

save "$works/enaho_laboral.dta", replace
