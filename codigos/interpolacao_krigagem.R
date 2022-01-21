# Script para realizar a interpolação por Krigagem

#Instalado pacotes
#install.packages("maptools")

#Importando bibliotecas
library(sp)       
library(maptools) 
library(raster)   
library(gstat)  
library(graphics)
library(lattice)


# Selecionando área de trabalho
setwd("D:\\krigagem")

#Lendo arquivo de dados de determinada característica
dados <- read.csv('dados/dados_caracteristica/ba/ph_kcl.csv')
coordinates(dados) <- ~x+y
head(dados)

# plot densidade
d <- density(dados$ph_kcl) 
plot(d) 

#Lendo contorno do estado 
coords <- read.csv('dados/contornos/contorno_ba.csv')
coordinates(coords) = ~x+y 
contorno = SpatialPolygons( list(Polygons(list(Polygon(coords)), 1)))
plot(contorno)


#Inicio da Análise dos semivariogramas
variograma <- variogram(ph_kcl~1, dados)

#Plotando o Variografico 
plot(variograma,pch=16,col=1, xlab="Distância",ylab="Semivariância",
     main =" Semivariograma")  #pch: Formato - Col: Cores


# Modelo esférico
modelo.sph <- fit.variogram(object = variograma, model=vgm(psill = 20000, nugget = 5000, range = 290000, model = "Sph"))
modelo.sph
(sqr.E<-attr(modelo.sph, "SSErr"))

#Plotando semivariograma esférico
plot(variograma,model=modelo.sph, col=1,pl=F,pch=16,xlab="Distância",ylab="Semivariância",
     main =" Semivariograma - Modelo Esférico ")

# Modelo Gaussiano
modelo.gau <- fit.variogram(object = variograma, model=vgm(psill = 20000, nugget = 5000, range = 290000, model = "Gau"))
modelo.gau
(sqr.E<-attr(modelo.gau, "SSErr"))

#Plotando semivariograma Gaussiano
plot(variograma,model=modelo.gau, col=1,pl=F,pch=16,xlab="Distância",ylab="Semivariância",
     main =" Semivariograma - Modelo Gaussiano")

# Modelo Exponencial
modelo.exp <- fit.variogram(object = variograma, model=vgm(psill = 20000, nugget = 20000, range = 290000, model = "Exp"))
modelo.exp
(sqr.E<-attr(modelo.exp, "SSErr"))

#Plotando semivariograma exponencial
plot(variograma,model=modelo.exp, col=1,pl=F,pch=16,xlab="Distância",ylab="Semivariância",
     main =" Semivariograma - Modelo Exponencial ")


#Auto variogram para testes
library(automap)
variogram = autofitVariogram(argila_dis~1,dados)
plot(variogram)


#Criando o grid 
x<-coords$x
y<-coords$y
dis <- 5000 #Distância entre pontos
grid <- expand.grid(X=seq(min(x),max(x),dis), Y=seq(min(y),max(y),dis))
gridded(grid) = ~ X + Y
plot(grid)


#Realizando a Krigagem 
ko <- krige(ph_kcl~1, dados, grid,modelo.gau)
ko <- as.data.frame(ko)
coordinates(ko)=~X+Y 
gridded(ko)=TRUE 
ko <- raster(ko) 
plot(ko)

#Recortando com o contorno
ko <- mask(ko, contorno, inverse=FALSE)
#x11()
plot(ko, xlab="X (UTM)",ylab="Y (UTM)", main =" PH_KCL - Bahia ")
plot(contorno, add=T)
contour(ko, add=T, nlevels = 3)

