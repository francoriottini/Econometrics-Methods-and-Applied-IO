################################################################################
#EJERCICIO GMM DEL EXAMEN DE METODOS ECONOMETRICOS Y IO APLICADA 2022 - UDESA

#Alumnos: Lucas Castellini y Franco Riottini

################################################################################
#PAQUETES NECESARIOS:
#install.packages("stargazer")
#install.packages("MASS")
#install.packages("faux")
#install.packages("ivreg", dependencies = TRUE)
#install.packages("texreg")
library(MASS)
library(dplyr)
library(texreg)
library(tidyr)
library(faux)
library("ivreg")
library("stargazer")

#---------------------#Generamos la base de datos con las mil observaciones------

samples = 1000
r = 0.8

set.seed(1234)

data = mvrnorm(n=samples, mu=c(0, 0), Sigma=matrix(c(1, r, r, 1), nrow=2), empirical=FALSE)

u = data[, 1]  # standard normal (mu=0, sd=1)

v = data[, 2]  # standard normal (mu=0, sd=1)

data <- as.data.frame(data) 

#-------------Remame------
data <- rename(data, u = V1)

data <- rename(data, v = V2)

data <- data %>% mutate (x = 1 + v)

data <- data %>% mutate (xsq = x**2)

data <- data %>% mutate (y = xsq + u)

stargazer(data, type = "latex", title = "Data head")

#-------------Control------
control <- cor.test(u, v)

#----OLS

OLS <- lm(y ~ xsq -1, data = data)

summary(OLS)

stargazer(OLS, type = "latex", title = "OLS Regression")

# Los resultados están sesgados ya que la variable dependiente (x) tiene un error (v)
# en su DGP que se encuentra altamente correlacionado con el error no observable (u).
#--------------
# Vamos a utilizar "Non-Linear 2 Stage Least Squares (NL2SLS)"

# Generamos la variable z = 1

data <- data %>% mutate(z = 1)

data <- data %>% mutate(xsq = x**2)

#Primera etapa de NL2SLS
FirstStage <- lm(xsq ~ z -1, data = data)

summary(FirstStage)

data$x2hat <- FirstStage$fitted.values

#Dado que z = 1 los x2hat son todos iguales

#Segunda etapa de NL2SLS

nl2sls <- lm(y ~ x2hat -1, data = data)

summary(nl2sls)

# Este método es consistente

stargazer(OLS, nl2sls, type = "latex", title = "OLS Regression")

#También con x**2 se llega exactamente a los mismos resultados

FirstStage2 <- lm(x**2 ~ z -1, data = data)

summary(FirstStage2)

data$x2hat2 <- FirstStage2$fitted.values

nl2sls2 <- lm(y ~ x2hat2 -1, data = data)
summary(nl2sls2)

#NL2SLS si es consistente

#------------------TwoStage(IV)

#Primera etapa de 2S
IVFirstStage <- lm(x ~ z -1, data = data)
summary(IVFirstStage)
data$ivx <- IVFirstStage$fitted.values

#Generamos el instrumento ivx2

data <- data %>% mutate(ivx2 = ivx**2)

#Segunda etapa

IVSecondStage <- lm(y ~ ivx2 -1, data = data)

summary(IVSecondStage)

#Usar ivx2 en la segunda etapa resulta en inconsistencia.

# Este metodo es inconsistente
#----------------------------
stargazer(OLS, nl2sls, IVSecondStage, type = "latex", title = "OLS Regression")





