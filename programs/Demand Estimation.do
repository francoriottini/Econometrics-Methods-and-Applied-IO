/*******************************************************************************
*                   Metodos Econometricos y de IO aplicada 

*                          Universidad de San Andrés
*                              
*	    		                      2022							           
*******************************************************************************/
*      Franco Riottini Depetris                     Lucas Castellini
/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Configurar el entorno

1) Modelo Logit de elección discreta (Berry, 1994)*

2) 

*******************************************************************************/


* 0) Configurar el entorno
*==============================================================================*

global main "C:/Users/Franco/Desktop/UDESA/Metodos econométricos e IO aplicada/Examen Final"
global input "$main/input"
global output "$main/output"

cd "$main"

* 1) Modelo Logit de elección discreta
* 1.1) MCO
*==============================================================================*
import excel "$input/DATA_UDESA (1).xlsx", sheet("DATA de Medicamentos") firstrow

*Generamos variables de interes 

gen delta = ln(share_good_j_t) - ln(share_good_0)

*gen salesdelta = ln(salesshare_good_j_t) - ln(share_good_0)

*Regresamos MCO

reg delta precio descuento i.semana

*guardamos en la memoria
est store ols1

*reg difsalesdelta precio descuento i.semana

/*
Dado que la regresión con los share calculados a partir del monto de ventas totales (ventas * precio) da resultados muy extraños, a partir de aquí utlizaremos solo la variable "difshare" que da resultados coherentes con la teoría. Da resultados muy extraños porque incluimos en la variable dependiente a una variable que incluye al precio y en las independientes también lo incluimos. Esto genera problemas.
*/


* 1.2) MCO
*==============================================================================*
*Dos formas de hacerlo.
*La primera

xtset marca
xtreg delta precio descuento i.semana, fe

est store ols2
*La segunda, que permite identificar las variables categóricas

regress delta precio descuento i.marca i.semana

* 1.3) MCO
*==============================================================================*

regress delta precio descuento i.marca#i.tienda i.semana

est store ols3

*Exportamos
esttab ols1 ols2 ols3 using "$output/OLS.tex", replace label keep(precio descuento)

* 1.4) IV (con costo)*
*==============================================================================*
* Listamos los 3 modelos en el orden anterior

ivregress 2sls delta descuento i.semana (precio = costo)

* Las dos formas del punto 1.2)*

xtset marca
xtivreg delta descuento i.semana (precio = costo), fe

ivregress 2sls delta descuento i.marca i.semana (precio = costo)

* Tercer modelo
ivregress 2sls delta descuento i.marca#i.tienda i.semana (precio = costo)

* 1.5) Hausman
*==============================================================================*
* Listamos los 3 modelos en el orden anterior

ivregress 2sls delta descuento i.semana (precio = Hausman)

* Las dos formas del punto 1.2)*

xtset marca
xtivreg delta descuento i.semana (precio = Hausman), fe

ivregress 2sls delta descuento i.marca i.semana (precio = Hausman)

* Tercer modelo
ivregress 2sls delta descuento i.marca#i.tienda i.semana (precio = Hausman)





