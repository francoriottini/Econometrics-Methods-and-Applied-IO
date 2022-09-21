"""

Este documento calcula los share de venta de cada marca en cada semana, es decir,
los s_{jt}. La fusión posterior de ambos archivos se hizo mediante la función
BUSCARV() de Excel.

input: DATA_UDESA.xlsx
output: Shares.xlsx


"""
import os
import pandas as pd

#Seteamos directorio
os.chdir('C:\\Users\\Franco\\Desktop\\UDESA\\Metodos econométricos e IO aplicada\\Examen Final')

#Input
df = pd.read_excel("input\DATA_UDESA.xlsx")                        


#Calculamos las ventas de cada marca por semana (sin distinción de tienda) en un nuevo data frame
df2 = df.groupby(by = ['semana', 'marca']).agg({'ventas':'sum'})
                                                                 
df2.reset_index(inplace = True)
                           
#Calculamos las ventas totales por semana
df3 = df2.groupby(by = ['semana']).agg({'ventas':'sum'})

df3.reset_index(inplace = True)
                                                   
cuenta = 0
lista_totales=[]
for i in range(48):                                     #Este for loop calcula el share semanal de cada marca
    for ele in range(cuenta, cuenta + 11):
            lista_totales.append((df2.iloc[ele]['ventas']/df3.iloc[i]['ventas'])*0.62)
    cuenta = cuenta + 11

df2['shares unidades vendidas'] = lista_totales

#Agregamos los share semanales de cada marca al lado del monto de ventas semanales de c/marca

#Output
df2.to_excel('output\Shares.xlsx')




