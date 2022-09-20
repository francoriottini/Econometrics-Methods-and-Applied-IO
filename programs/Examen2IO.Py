"""
Created on Tue Sep 20 12:38:13 2022

Este documento calcula el precio promedio de las otras marcas en las otras tiendas en la misma semana, 
es decir, el llamado Instrumento de Hausman.

input: DATA_UDESA.xlsx
output: hausman_instrument.xlsx

"""
import os
import pandas as pd 
import xlsxwriter as xls

#Seteamos directorio
os.chdir('C:\\Users\\Franco\\Desktop\\UDESA\\Metodos econométricos e IO aplicada\\Examen Final')

#Creamos libro

libro = xls.Workbook('output\hausman_instrument.xlsx')
hoja = libro.add_worksheet()

col = 0 
row = 0
df0 = pd.read_excel("input\DATA_UDESA.xlsx")

df00 = df0.sort_values(by = ['semana', 'marca', 'tienda'])

lista_df = []

for i in range(1, 49):

    w_i = df00[(df00['semana'] == i)]
    w_i.reset_index(inplace = True)
    lista_df.append(w_i)


for i in range(len(lista_df)):
   
    for x in range(len(lista_df[i])):
        suma = 0
        cuanto_divido = 0

        for ele in range(len(lista_df[i])):

            if lista_df[i].iloc[x]['marca'] != lista_df[i].iloc[ele]['marca']:

                if lista_df[i].iloc[x]['tienda'] != lista_df[i].iloc[ele]['tienda']:

                    suma += lista_df[i].iloc[ele]['precio']
                    cuanto_divido += 1

        hoja.write(row, col, suma/cuanto_divido) # 730 es porque miro las otras 10 marcas en las otras 73 tiendas
        row += 1
    
libro.close()

