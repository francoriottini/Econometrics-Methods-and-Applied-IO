library(MASS)
library(dplyr)
library(tidyr)
library(faux)
library(ivreg)
library(readxl)

#Cargo datos
datos<-read_xlsx("input/DATA_UDESA.xlsx")

#Generamos 30 precios random

instrumentos<-data.frame(matrix(NA, nrow = nrow(datos), ncol = 30))

#asigno nombres

colnames(instrumentos)<-paste0("p",seq(30))

#seed para replicabilidad
set.seed(30)
#loopeo
for (i in 1:nrow(instrumentos)) {
  datospivot<-datos%>%filter(marca==datos$marca[i] & semana==datos$semana[i] & tienda!=datos$tienda[i])
  instrumentos[i,1:30]<-sample(datospivot$precio,size=30,replace=TRUE)
}

#Incluyo todo en datos
datos2 <- merge(datos, instrumentos)
