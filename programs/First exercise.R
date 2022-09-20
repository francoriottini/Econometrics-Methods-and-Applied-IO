#install.packages("MASS")
#install.packages("faux")
#install.packages("ivreg", dependencies = TRUE)

library(MASS)
library(dplyr)
library(tidyr)
library(faux)
library("ivreg")

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

data <- data %>% mutate (y = x**2 + u)

#-------------Control------
cor.test(u, v)

#----OLS

OLS <- lm(y ~ x**2 -1, data = data)

OLS2 <- lm(y ~ xsq -1, data = data)

summary(OLS2)

# Los resultados están sesgados ya que la variable dependiente (x) tiene un error (v)
# en su DGP que se encuentra altamente correlacionado con el error no observable (u).
#--------------
# Vamos a utilizar "Non-Linear 2 Stage Least Squares (NL2SLS)"

# Generamos la variable z = 1

data <- data %>% mutate(z = 1)

data <- data %>% mutate(xsq = x**2)

FirstStage <- lm(x**2 ~ z -1, data = data)

FirstStage2 <- lm(xsq ~ z -1, data = data)

data$xsqhat <- FirstStage$fitted.values

data$xsqhat2 <- FirstStage2$fitted.values

#Dado que z = 1 los xsqhat son todos iguales

nl2sls <- lm(y ~ xsqhat -1, data = data)

nl2sls2 <- lm(y ~ xsqhat2 -1, data = data)

# Este método es consistente


#------------------TwoStage(IV)

IVfirst_stage <- lm(x ~ z -1, data = data)

data$ivx <- IVfirst_stage$fitted.values

data <- data %>% mutate(ivxsq = ivx**2)

IVsecond_stage <- lm(y ~ ivxsq -1, data = data)

# Este metodo es inconsistente
#----------------------------






