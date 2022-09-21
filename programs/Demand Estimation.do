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
* 1.1) MCO
* 1.2) MCO w/FE
* 1.3) MCO w/FE and Interaction
* 1.4) IV (con costo)*
* 1.5) Hausman
* 1.6) Mean own elasticities

2) BLP

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
import excel "$input/DATA_UDESA.xlsx", sheet("DATA de Medicamentos") firstrow

*Generamos variables de interes 

gen delta = ln(share_jt) - ln(share_s0)

*gen salesdelta = ln(salesshare_good_j_t) - ln(share_good_0)

*Regresamos MCO

reg delta precio_jt descuento i.semana

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
xtreg delta precio_jt descuento i.semana, fe

est store ols2
*La segunda, que permite identificar las variables categóricas

regress delta precio_jt descuento i.marca i.semana

* 1.3) MCO
*==============================================================================*

regress delta precio_jt descuento i.marca#i.tienda i.semana

est store ols3

*Exportamos
esttab ols1 ols2 ols3 using "$output/OLS.tex", replace label keep(precio_jt descuento)

* 1.4) IV (con costo)*
*==============================================================================*
* Listamos los 3 modelos en el orden anterior

ivregress 2sls delta descuento i.semana (precio = costo)

est store ivc1

* Las dos formas del punto 1.2)*

xtset marca
xtivreg delta descuento i.semana (precio = costo), fe

est store ivc2

*distinta forma
ivregress 2sls delta descuento i.marca i.semana (precio = costo)

* Tercer modelo
ivregress 2sls delta descuento i.marca#i.tienda i.semana (precio = costo)

est store ivc3

esttab ivc1 ivc2 ivc3 using "$output/IVC.tex", replace label keep(precio descuento)

* 1.5) Hausman
*==============================================================================*
* Listamos los 3 modelos en el orden anterior

ivregress 2sls delta descuento i.semana (precio = Hausman)

est store ivh1

* Las dos formas del punto 1.2)*

xtset marca
xtivreg delta descuento i.semana (precio = Hausman), fe

est store ivh2

ivregress 2sls delta descuento i.marca i.semana (precio = Hausman)

* Tercer modelo
ivregress 2sls delta descuento i.marca#i.tienda i.semana (precio = Hausman)

est store ivh3

esttab ivh1 ivh2 ivh3 using "$output/IVH.tex", replace label keep(precio descuento)


* 1.6) Mean own elasticities
*==============================================================================*

* Generamos variables con los coeficientes de las primeras tres regresiones para el precio promedio

gen alpha1 = -.0494562

gen alpha2 = -.5666967

gen alpha3 = -.5664513

* Generamos las elasticidades con la formula de Nevo (2000)

gen elasticity1 = alpha1*precio_jt*(1-share_jt)

gen elasticity2 = alpha2*precio_jt*(1-share_jt)

gen elasticity3 = alpha3*precio_jt*(1-share_jt)

* Data clean

drop _est_ols1 _est_ols2 _est_ols3

drop alpha1 alpha2 alpha3

* Save

export excel using "$output/Demand_Estimation.xlsx", sheetmodify firstrow(variables) nolabel
