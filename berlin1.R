
library(MASS)
setwd("C:/Users/Hendrik Serruys/Documents/dev/NLOS")


#load data
#GT: Ground Truth

data = read.csv("data/berlin1_potsdamer_platz/RXM-RAWX.csv", header = TRUE, sep=";")

time <- data$GPSSecondsOfWeek..s.
GNSS_ID <- data$GNSS.identifier..gnssId....
SV_ID <- data$Satellite.identifier..svId....
C <- data$Pseudorange.measurement..prMes...m.
C_std <- data$Estimated.pseudorange.measurement.standard.deviation..prStdev...m.
L <- data$Carrier.phase.measurement..cpMes...cycles.
L_std <- data$Estimated.carrier.phase.measurement.standard.deviation..cpStdev...cycles.
D <- data$Doppler.measurement..doMes...Hz.
D_std <- data$Estimated.Doppler.measurement.standard.deviation..doStdev...Hz.
S <- data$Carrier.to.noise.density.ratio..cno...dbHz. #difference CNR to SNR?
NLOS <- data$NLOS..0....no..1....yes.......No.Information.

data2 <- data.frame(time, GNSS_ID, SV_ID, C, C_std, L,L_std,D,D_std,S,NLOS)
write.csv(data2,file = "data/berlin1_potsdamer_platz/RXM-RAWX_CLEANED.csv")


### Some plots for individual satellites
#GPS12
gps12 <- subset(data2,GNSS_ID=="GPS" & SV_ID == 12)
plot(gps12$time,gps12$C)
plot(gps12$time,gps12$S)
plot(gps12$NLOS,gps12$S)
pairs(gps12[,-c(2,3)])

#R2
R2 <- subset(data2,GNSS_ID=="Glonass" & SV_ID == 2)
plot(R2$time,R2$C)
plot(R2$time,R2$S)
plot(R2$NLOS,R2$S)
pairs(R2[,-c(2,3)])


### NLOS explorative
plot(data2$NLOS,data2$C, xlab = "NLOS", ylab="Pseudorange [m]")

#Remove Pseudorange outliers
ind_outliers = which(data2[, 4] > 35000000)
data3 <- data2[-ind_outliers,]
data4 <- data3
data4$NLOS <- factor(data4$NLOS, levels = c('0','1'), labels = c('0','1'))
head(data4)




plot(data4$NLOS,data4$C, xlab = "NLOS", ylab="Pseudorange [m]")
plot(data4$NLOS,data4$L, xlab = "NLOS", ylab="Carrier Phase [Cycles]")
plot(data4$NLOS,data4$D, xlab = "NLOS", ylab="Doppler [Hz]")
plot(data4$NLOS,data4$S, xlab = "NLOS", ylab="CNR [dB]")

#Check for multicollinearity
VIF <- diag(solve(cor(data3[, -c(1,2,3,11)])))
round(VIF, 2) # multicollinearity detected between Pseudorange and Carrier Phase.
cor(data3[, -c(1,2,3,11)])

#Logistic Regression
lm1 <- glm(NLOS ~ C + L + D + S, data = data4)
summary(lm1)

lm2 <- stepAIC(lm1, list(lower = ~ 1, upper = ~ .), direction = "both")
summary(lm2)

#Deviance of fit:
#The deviance of a fitted model compares
#the log-likelihood of the fitted model to the log-likelihood of a model with n parameters
#that fits the n observations perfectly.
#In the normal error linear regression model, the definition of the deviance is
#slightly modified and turns out to be the error sum of squares SSE.
# Residual deviance: 2894.4  on 21304  degrees of freedom
qchisq(0.95, 21304) # 21644.66 >> 2894.4 => do not reject this model

#Null deviance = 5320.1
#The null deviance shows how well the response variable is predicted 
#by a model that includes only the intercept (grand mean).
#Null dev. - Res dev. = 5320.1 - 2894.4 = 2425.7
#So adding our variables reduces the deviance with 2425.7.

#Odds Ratios (OR)
lm2.cint <- summary(lm2)$coef[-1, ]
lm2.cint
#95% confidence interval 
lm2.ci <- cbind(lm2.cint[, 1] - 1.96 * lm2.cint[, 2],
                lm2.cint[, 1] + 1.96 * lm2.cint[, 2])
lm2.ci
lm2.or <- exp(lm2.cint[, 1])
lm2.cior <- exp(lm2.ci)
cbind(lm2.or, lm2.cior)

#So what this says is that, as the CNR (S) increases with 1 dB, the odds P(NLOS)/P(LOS) decreases with 4%.
#Might not be very useful for C and L as of big scale

#plot
fitted.link <- predict(lm2, newdata = data3, type = "link")
summary(fitted.link)
fitted.probs <- predict(lm2, newdata = data3, type = "response") # = fitted(redmod)
summary(fitted.probs)

plot(fitted.link, data3$NLOS, xlab = "fitted", ylab = "NLOS",
     main = "logistic regression fit to berlin1 data")
points(fitted.link, fitted.probs, type = "p", col = "blue")

NLOS.index <- which(data3$NLOS == 1)
plot(fitted.probs, col = "blue")
points(NLOS.index, fitted.probs[NLOS.index], col = "red", pch = 19)

lm3 <- glm(NLOS ~ ., data = data3[,-c(1,2,3,4)])
lm4 <- stepAIC(lm3, list(lower = ~ 1, upper = ~ .), direction = "both")
summary(lm4)

fitted4.link <- predict(lm4, newdata = data3, type = "link")
fitted4.probs <- predict(lm4, newdata = data3, type = "response")
plot(fitted4.link, data3$NLOS, xlab = "fitted", ylab = "NLOS",
     main = "logistic regression fit to berlin1 data")
points(fitted4.link, fitted4.probs, type = "p", col = "blue")

#Plot residuals
plot(residuals(lm4, "deviance"))


#Establish a base line
nb_NLOS_samples = dim(data22[data3$NLOS == 1,])[1]
nb_LOS_samples = dim(data22[data3$NLOS == 0,])[1]
cut_off = nb_NLOS_samples / (nb_LOS_samples + nb_NLOS_samples)

pred.NLOS <- ifelse(fitted4.probs > cut_off, 1, 0)
table(data3$NLOS, pred.NLOS)
ptable <- prop.table(table(data3$NLOS, pred.NLOS))
# prop.table normalizes to a total of 1
ptable
APER <- 1 - sum(diag(ptable))
APER


