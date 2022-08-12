

*=================
* PRIMERA SESIÓN
*=================

* Nuestro primer do-file

* Todo lo que vaya después del asterico es considerado una nota y el Stata no lo ejecuta
sysuse auto, clear			 // podemos escribir una nota en la misma línea de comando usando "//"
describe price weight		
help regress

/*
para escribir una nota que ocupa de varias lineas
la enmarcamos entre "/*" y "*/" o escribimos "*" en cada linea
*/

"nuestra primera línea de texto" //para definir una cadena de texto la enmarcamos entre comillas

exit
