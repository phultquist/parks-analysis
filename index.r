library(readr)
require(ggplot2)
library(dplyr)
library(MASS)
library(pbkrtest)
library(sjPlot)

merged <- read_csv("merged.csv")
attach(merged)
#View(merged)

nrow(merged)
summary(merged~numParks)
nrow(merged)

merged$parksPerPerson <- numParks / totalPopulation
merged$parksPerTenThousand <- (numParks / totalPopulation) * 10000

detach(merged)
attach(merged)

merged$percentBlack <- (merged$race.black / merged$totalPopulation) * 100
merged$percentWhite <- (merged$race.white / merged$totalPopulation) * 100

detach(merged)
attach(merged)

zipCodesWithParks <- filter(merged, numParks > 0)
zipCodesWithParksNotRural <- filter(zipCodesWithParks, zipCodesWithParks$populationDensity > 50)
zipCodesSuburbsParks <- filter(zipCodesWithParksNotRural, zipCodesWithParksNotRural$populationDensity < 5000)

detach(merged)
attach(zipCodesSuburbsParks)

nrow(zipCodesSuburbsParks)

numParksByRace <- function() {
  par(mfrow=c(2,1))
  plot(numParks~percentBlack, col="#142755", main="Number of Parks by Percent Black", xlab="Percent Black", ylab="Number of Parks")
  parksByBlack <- lm(numParks~percentBlack)
  summary(parksByBlack)
  
  plot(numParks~percentWhite, col="#142755", main="Number of Parks by Percent White", xlab="Percent White", ylab="Number of Parks")
  parksByWhite <- lm(numParks~percentWhite)
  summary(parksByWhite) 
}

#parksPerPersonByRace <- function() {
#  par(mfrow=c(2,1))
#  plot(parksPerPerson~percentBlack)
#  parksByBlack <- lm(parksPerPerson~percentBlack)
#  summary(parksByBlack)
#  
#  plot(parksPerPerson~percentWhite)
#  parksByWhite <- lm(parksPerPerson~percentWhite)
#  summary(parksByWhite) 
#}

parksPerTenThousandByRace <- function() {
  par(mfrow=c(1,2))
  plot(parksPerTenThousand~percentBlack, pch=1, col="#142755", main="Parks Per Ten Thousand by Percent Black", xlab="Percent Black", ylab="Parks Per Ten Thousand People")
  parksByBlack <- lm(parksPerTenThousand~percentBlack)
  summary(parksByBlack)
  
  plot(parksPerTenThousand~percentWhite, pch=1, col="#142755", main="Parks Per Ten Thousand by Percent White", xlab="Percent White", ylab="Parks Per Ten Thousand People")
  parksByWhite <- lm(parksPerTenThousand~percentWhite)
  summary(parksByWhite) 
}

parksPerTenThousandByIncome <- function() {
  par(mfrow=c(1,1))
  plot(parksPerTenThousand~meanHouseholdIncome, pch=1, col="#142755", main="Parks Per Ten Thousand by Mean Household Income", xlab="Mean Household Income ($)", ylab="Parks Per Ten Thousand People")
  parksByIncome <- lm(parksPerTenThousand~meanHouseholdIncome)
  summary(parksByIncome)
}

parksTotalPopulation <- function() {
  par(mfrow=c(1,1))
  plot(numParks~totalPopulation, pch=1, col="#142755", main="Number of Parks by Total Population", xlab="Total Population", ylab="Number of Parks")
}

parksPerTenThousandByTotalPopulation <- function() {
  par(mfrow=c(1,1))
  plot(parksPerTenThousand~totalPopulation, pch=1, col="#142755", main="Parks Per Ten Thousand by Total Population", xlab="Total Population", ylab="Parks Per Ten Thousand")
  model <- lm(parksPerTenThousand~totalPopulation)
  tab_model(model, 
            p.style = "stars", #this sets the table up so that stars will appear next to variables that are statistically significant.  A caption on the bottom of the table explaining the stars will also appear.
            show.se = TRUE, #This tells R to include the standard error along with the model estimate
            show.ci = FALSE, #this turns off the command wanting to also print confidence intervals
            collapse.se = TRUE, #This pusts the standard error in parentheses below the estimate rather than next to it in its own column
            title = "Regression Results: Maternal Mortality", #This is the title for the table.  You can type whatever you'd like here, but I have simply written the name of the dependent (y) variable
            string.est = "Estimate <br> (S.E.)", #This is what will appear above the estimate/coefficient.  The <br> cretes a new line (it's html).  Here I just wrote estimate and S.E. for standard error.
            pred.labels = c("Intercept", "Pct. Attended Births"), #this is a list of what you want you readers to see listed for your x-variables.  The table always lists the intercept first so you MUST include that first.  Then, you should include common sense, short explanations of each variable (here, Pct. Attended Births instead of v89 (which would make no sense to the audience))
            dv.labels = c("Model 1"))
}


# political affiliation by parks

parksPerTenThousandByIncome()

model1 <- lm(numParks~meanHouseholdIncome)
summary(model1)
plot(numParks~meanHouseholdIncome)

model2 <- lm(numParks~meanHouseholdIncome+totalPopulation)
summary(model2)

summary(meanHouseholdIncome)

model3 <- lm(numParks~meanHouseholdIncome+totalPopulation)
summary(model3)

model4 <- lm(numParks~meanHouseholdIncome+race.black)
summary(model4)

model5 <- lm(numParks~meanHouseholdIncome+race.white)
summary(model5)

nb1 <- glm.nb(numParks~totalPopulation+meanHouseholdIncome+race.black+race.white, data = merged)
summary(nb1)

nbRace <- glm.nb(numParks~race.black, data = merged)
summary(nbRace)

plot(numParks~race.black)
plot(numParks~race.white)

plot(numParks~meanHouseholdIncome)

# TODO: Percentage of race, instead of total

# the negative binomial model is the right variable for count variables
# count variables bring skewed distribution

# to do: % population white?

# negative binomial models or 