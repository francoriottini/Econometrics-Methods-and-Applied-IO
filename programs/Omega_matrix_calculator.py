"""
Este archivo calcula los precios post fusion para el promedio de las tiendas en el tiempo,
utilizando los shares de cada marca en todas las tiendas en todas las semanas y
utilizando precios promedio anuales a lo largo de las tiendas.
AdemÃ¡s, como para el proceso necesitamos estimar los costos marginales, este archivo tambiÃ©n lo realiza
calculando la matriz Omega, siguiendo los pasos de Knittel y Metaxoglou (2014).

Input: DATA_UDESA.xlsx ORDENADO POR SEMANA Y MARCA (SEMANA1:MARCA1, SEMANA1:MARCA2, ..., SEMANA48:MARCA11)

Demora: menos de 30 segundos

Requiere: Pandas y NumPy instalados.

Lucas Castellini y Franco Riottini
"""
import os
import pandas as pd                                               
import numpy as np


#Seteamos directorio donde se encuentra el Excel DATA_UDESA
os.chdir('C:\\Users\\Franco\\Desktop\\UDESA\\Metodos econométricos e IO aplicada\\Examen Final')


#Importamos los datos para crear un data frame de Pandas.
df1 = pd.read_excel("input/DATA_UDESA.xlsx")
df1 = df1.sort_values(by = ['semana','marca'])

#Armamos dos dataframe diferentes con los promedios de precio y shares, dim (11x1)
#Creamos un data frame con el precio promedio anual de cada marca
df2 = df1.groupby(by = ['marca']).agg({'precio':'mean'})
df2.reset_index(inplace = True)

#Creamos un data frame con el share promedio anual de cada marca (share 0 constante)
df3 = df1.groupby(by = ['marca']).agg({'share_jt':'mean'})
df3.reset_index(inplace = True)


#Armamos un diccionaron que indica que marca posee cada producto (11 productos, 4 marcas)
#Diccionario de propiedad, indica que firma produce cada marca PRE-fusion
dicc_pre_merge = {1:1, 2:1, 3:1, 4:2, 5:2, 6:2, 7:3, 8:3, 9:3, 10:4, 11:4}


#Utilizamos el alpha de la estimacion con FE marca-tienda
alpha = -0.3083324

#propias = alpha*precioj*(1-sharej)
#cross = -alpha*precioj*sharek


lista = []
#El siguiente loop calcula las derivadas
#Forloop doble que genera una lista con los elementos de la matriz de propiedad.
for ele in range(len(df2)):
    for i in range(len(df3)):

        if dicc_pre_merge[df2.iloc[ele]['marca']] != dicc_pre_merge[df3.iloc[i]['marca']]:

            lista.append(0)

        else:

            if df2.iloc[ele]['marca'] != df3.iloc[i]['marca']: #evalua si la marca es la misma en los dos dataframe y calcula
                                                               #la elasticidad propia

                elasticidad = (alpha*df2.iloc[ele]['precio']*df3.iloc[i]['share_jt'])
                derivada = elasticidad*(df3.iloc[i]['share_jt']/df2.iloc[ele]['precio'])
                lista.append(derivada)
            else:                                           #si no, calcula la elasticidad cruzada
                elasticidad = (-1)*(alpha*df2.iloc[ele]['precio']*(1-df3.iloc[i]['share_jt']))
                derivada = elasticidad*(df3.iloc[i]['share_jt']/df2.iloc[ele]['precio'])
                lista.append(derivada)

#Lista con los nombres de las marcas.
nombres = ['Marca 1 (25)','Marca 1 (50)','Marca 1 (100)','Marca 2 (25)','Marca 2 (50)',

            'Marca 2 (100)','Marca 3 (25)','Marca 3 (50)','Marca 3 (100)','Marca 4 (50)',

            'Marca 4 (100)']


omega_pre = df1.groupby(by = ['marca']).agg({'marca':'mean'})

i = 0
j = 0
for ele in range(11):

        
        omega_pre[nombres[i]] = lista[j:j+11]

        j +=11
        i += 1


omega_pre = omega_pre.drop(['marca'], axis = 1)

omega_pre.index = nombres




omega_pre.to_latex('output/preMatriz.tex', index = True,
                    caption = 'Matriz de propiedad previa a la fusión')


#Invertimos la matriz.
df_inv = pd.DataFrame(np.linalg.pinv(omega_pre.values), omega_pre.columns, omega_pre.index)



#Generamos un "vector" (lista) fila de shares anuales. 
shares = []
for ele in range(len(df3)):
    shares.append(df3.iloc[ele]['share_jt'])


#Generamos un "vector" (dataframe columna) de precios.
precios_pre = pd.DataFrame([1])
i = 0
j = 0
for ele in range(11):

        
        precios_pre[nombres[i]] = df2.iloc[i]['precio']

        j +=11
        i += 1


#Tenemos dudas acerca del funcionamiento de la funcion .dot() de Pandas
#para multiplicar matrices y vectores.
#Alternativamente, se puede generar un "vector" columna de shares
#El siguiente código lo permite:
#df4 = pd.DataFrame([1])
#i = 0
#j = 0
#for ele in range(11):
#        df4[nombres[i]] = df3.iloc[i]['share_jt']
#        j +=11
#        i += 1
#df4 = df4.drop(0, axis=1)


resultado = df_inv.dot(shares)

#resultado = df4.dot(df_inv)

#Obtenemos los costos marginales.
costos_mg = precios_pre - resultado



#Generamos un diccionario que mapea marca con empresa POS fusion.
dicc_post_merge = {1:1, 2:1, 3:1, 4:1, 5:1, 6:1, 7:1, 8:1, 9:1, 10:2, 11:2}


lista2 = []
#Repetimos el mismo proceso que antes.

for ele in range(len(df2)):
    for i in range(len(df2)):

        if dicc_post_merge[df2.iloc[ele]['marca']] != dicc_post_merge[df3.iloc[i]['marca']]:

            lista2.append(0)

        else:

            if df2.iloc[ele]['marca'] != df3.iloc[i]['marca']:

                elasticidad = (alpha*df2.iloc[ele]['precio']*df3.iloc[i]['share_jt'])
                derivada = elasticidad*(df3.iloc[i]['share_jt']/df2.iloc[ele]['precio'])
                lista2.append(derivada)
            else:
                elasticidad = (-1)*(alpha*df2.iloc[ele]['precio']*(1-df3.iloc[i]['share_jt']))
                derivada = elasticidad*(df3.iloc[i]['share_jt']/df2.iloc[ele]['precio'])
                lista2.append(derivada)


omega_pos = df1.groupby(by = ['marca']).agg({'marca':'mean'})


i = 0
j = 0
for ele in range(11):

        
        omega_pos[nombres[i]] = lista2[j:j+11]

        j +=11
        i += 1


omega_pos = omega_pos.drop(['marca'], axis = 1)

omega_pos.index = nombres

#Exportamos la matriz pos fusion
omega_pos.to_latex('output/posMatriz.tex', index = False,
                        caption = 'Matriz de propiedad posterior a la fusión')

#Invertimos la matriz pos fusion (evaluada en los precios pre fusion)
df_inv2 = pd.DataFrame(np.linalg.pinv(omega_pos.values), omega_pos.columns, omega_pos.index)


#Mismo problema que antes
#Opcion 1

resultado2 = df_inv2.dot(shares)

#Opcion 2
#df4.dot(df_inv2)

#Obtenemos los precios predichos (aproximados como Knittel & Metaxoglou (2014))
precios_pos_pred = resultado2 + costos_mg


#Preparamos para exportar, ordeno
resultado_exp = pd.DataFrame(nombres)
resultado2_exp = pd.DataFrame(nombres)

costos_mg.index = ['Marca']
precios_pos_pred.index = ['Marca']

costos_mg.rename(columns = {0:'Marca'}, inplace = True)
precios_pos_pred.rename(columns = {0:'Marca'}, inplace = True)

resultado_exp = costos_mg.transpose()
resultado_exp = resultado_exp.drop(['Marca'], axis=0)
resultado_exp.reset_index(inplace = True)

resultado2_exp = precios_pos_pred.transpose()
resultado2_exp = resultado2_exp.drop(['Marca'], axis=0)
resultado2_exp.reset_index(inplace = True)

resultado_exp.columns = ['Marca','Costo marginal']
resultado2_exp.columns = ['Marca','Logit predict']

#Outputeo resultados en tablas tex
resultado_exp.to_latex('output/MCanual.tex', index = False,
                        caption = 'Costo marginal anual promedio')

resultado2_exp.to_latex('output/Logitanual.tex', index = False,
                        caption = 'Logit Prediction anual promedio')
