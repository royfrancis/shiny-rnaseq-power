# shiny-rnaseq-power  
# functions

library(shiny)
library(shinyBS)
library(shinythemes)
library(RNASeqPower)

# fn_version
fn_version <- function() {
  return("v1.0.0")
}

choices_pa <- list(`Number of samples in each group`=c("n"="n"),
                   `Biological coefficient of variation within group`=c("cv"="cv"),
                   `Relative expression effect (like fold-change)`=c("effect"="effect"),
                   `False positive rate (like p-value)`=c("alpha"="alpha"),
                   `Fraction of true positives`=c("power"="power"))

# returns a message if condition is true
fn_validate <- function(input,message) if(input) print(message)
