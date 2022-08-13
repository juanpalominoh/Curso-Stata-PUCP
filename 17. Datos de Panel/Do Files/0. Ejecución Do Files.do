
* Se debe descargar la encuesta de datos de panel
global main    "/Users/juanpalomino/Google Drive/ENAHO/Panel"
global dta_2   "$main/Modulo 2"
global dta_3   "$main/Modulo 3"
global dta_5   "$main/Modulo 5"
global dta_34  "$main/Sumaria"

* Rutas del directorio
global main2   "/Users/juanpalomino/Documents/GitHub/Curso-Stata-PUCP/17. Datos de Panel"
global dos     "$main2/Do Files"
global dta     "$main2/Bases"
global works   "$main2/Procesadas"
global results "$main2/Resultados"



* Ejecución de Do Files (ENAHO Panel)
do "$dos/1. ENAHO Panel - Translate.do"
do "$dos/2. ENAHO Panel - Limpieza.do"
do "$dos/3. ENAHO Panel - Estimaciones"


* Ejecución de Do Files (Convergencia Económica)
do "$dos/4. Panel - Crecimiento Económico.do"
