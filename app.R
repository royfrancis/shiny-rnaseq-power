## shiny-rnaseq-power
## R shinyapp to run power analysis for rna-seq experiments
## 2023 Roy Francis

library(shiny)
library(shinyBS)
library(bslib)
library(RNASeqPower)

choices_pa <- list(
  `Number of samples in each group` = c("n" = "n"),
  `Biological coefficient of variation within group` = c("cv" = "cv"),
  `Relative expression effect (like fold-change)` = c("effect" = "effect"),
  `False positive rate (like p-value)` = c("alpha" = "alpha"),
  `Fraction of true positives` = c("power" = "power")
)

## version
fn_version <- function() {
  return("v1.1.0")
}

## returns a message if condition is true
fn_validate <- function(input, message) if (input) print(message)

shinyApp(
  ui = page_fixed(
    class="app-container",
    tags$head(tags$style(HTML("
    .app-container {
      margin-top: 1em;
    }
    .app-container h2 {
      color: #A7C947;
    }
    .help-note {
      font-size: 0.9em;
      color: #C0C0C0;
      padding-top: 10px;
      padding-bottom: 10px;
    }
    "))),
    title = "RNASeq Power",
    theme = bs_theme(primary = "#A7C947"),
    h2("RNASeq Power"),
    div("Power Analysis for RNA-Seq"),
    div(class = "help-note", style = "padding-top:0;", "Assumes comparison of two groups with equal number of samples. Multiple values can be entered using comma separation. Sequencing depth is input only and cannot be estimated."),
    layout_sidebar(
      sidebar(
        selectInput("in_pa_est", "Variable to estimate", choices = choices_pa, selected = 1),
        uiOutput("ui_pa")
      ),
      div(style="margin-bottom:0.5rem;;", htmlOutput("out_pa_label")),
      verbatimTextOutput("out_pa")
    ),
    div(class = "help-note",
      HTML(paste0("Built on ", a(href="https://bioconductor.org/packages/release/bioc/html/RNASeqPower.html","RNASeqPower"),". Version ", a(fn_version(), href = "https://github.com/royfrancis/shiny-rnaseq-power")))
    )
  ),
  server = function(session, input, output) {
    # UI: ui_pa ---------------------------------------------------------------
    # conditional ui for power analysis

    output$ui_pa <- renderUI({
      div(
        textInput("in_pa_depth", "Sequencing depth", value = "4"),
        shinyBS::bsTooltip("in_pa_depth", title = "Number of reads mapped to a feature. Usually a value between 5-20. Generally, sequencing depths of more than 5/CV^2 will lead to only minor gains. ", placement = "top", trigger = "hover"),
        if (input$in_pa_est != "n") {
          div(
            textInput("in_pa_n", "Number of samples", value = "3"),
            shinyBS::bsTooltip("in_pa_n", title = "The number of samples per group.", placement = "top", trigger = "hover")
          )
        },
        if (input$in_pa_est != "cv") {
          div(
            textInput("in_pa_cv", "Coefficient of variation", value = "0.4"),
            shinyBS::bsTooltip("in_pa_cv", title = "Biological coefficient of variation between replicates within a group. A value between 0-1.", placement = "top", trigger = "hover")
          )
        },
        if (input$in_pa_est != "effect") {
          div(
            textInput("in_pa_effect", "Effect", value = "1.25,1.5,1.75,2"),
            shinyBS::bsTooltip("in_pa_effect", title = "Target effect size. Like fold-change. Usually values like 0.25, 0.5, 1, 1.25, 2 etc.", placement = "top", trigger = "hover")
          )
        },
        if (input$in_pa_est != "alpha") {
          div(
            textInput("in_pa_alpha", "Alpha", value = "0.05"),
            shinyBS::bsTooltip("in_pa_alpha", title = "The false positive rate. A value between 0 and 1.", placement = "top", trigger = "hover")
          )
        },
        if (input$in_pa_est != "power") {
          div(
            textInput("in_pa_power", "Power", value = "0.8,0.9"),
            shinyBS::bsTooltip("in_pa_power", title = "The fraction of true positives to be detected. A value between 0 and 1.", placement = "top", trigger = "hover")
          )
        }
      )
    })

    # OUT: out_pa_label ----------------------------------------------------------
    # label for power analysis

    output$out_pa_label <- renderText({
      shiny::req(input$in_pa_est)

      labeller <- function(type) {
        switch(type,
          n = "Number of Samples",
          cv = "Coefficient of Variation",
          effect = "Relative Expression Effect",
          alpha = "False Positive Rate",
          power = "Power"
        )
      }

      txt <- labeller(input$in_pa_est)
      paste0("Estimated: <b>", txt, "</b>")
    })

    # OUT: out_pa ----------------------------------------------------------------
    # print output for power analysis

    output$out_pa <- renderPrint({
      # shiny::req(input$in_pa_est)

      tryCatch(
        {
          depth <- as.numeric(unlist(strsplit(gsub(" ", "", input$in_pa_depth), ",")))
          validate(fn_validate(any(is.na(depth)), "Sequencing depth must be a numeric."))

          if (input$in_pa_est != "n") {
            n <- as.numeric(unlist(strsplit(gsub(" ", "", input$in_pa_n), ",")))
            validate(fn_validate(any(is.na(n)), "Sample size must be a numeric."))
          }

          if (input$in_pa_est != "cv") {
            cv <- as.numeric(unlist(strsplit(gsub(" ", "", input$in_pa_cv), ",")))
            validate(fn_validate(any(is.na(cv)), "Effect must be a numeric."))
          }

          if (input$in_pa_est != "effect") {
            effect <- as.numeric(unlist(strsplit(gsub(" ", "", input$in_pa_effect), ",")))
            validate(fn_validate(any(is.na(effect)), "Effect must be a numeric."))
          }

          if (input$in_pa_est != "alpha") {
            alpha <- as.numeric(unlist(strsplit(gsub(" ", "", input$in_pa_alpha), ",")))
            validate(fn_validate(any(is.na(alpha)), "Alpha must be a numeric."))
            validate(fn_validate(any(alpha >= 1 | alpha <= 0), "Alpha must be a numeric between 0 and 1."))
          }

          if (input$in_pa_est != "power") {
            power <- as.numeric(unlist(strsplit(gsub(" ", "", input$in_pa_power), ",")))
            validate(fn_validate(any(is.na(power)), "Power must be a numeric."))
            validate(fn_validate(any(power >= 1 | power <= 0), "Power must be a numeric between 0 and 1."))
          }

          switch(input$in_pa_est,
            "n" = RNASeqPower::rnapower(depth = depth, cv = cv, effect = effect, alpha = alpha, power = power),
            "cv" = RNASeqPower::rnapower(depth = depth, n = n, effect = effect, alpha = alpha, power = power),
            "effect" = RNASeqPower::rnapower(depth = depth, cv = cv, n = n, alpha = alpha, power = power),
            "alpha" = RNASeqPower::rnapower(depth = depth, cv = cv, effect = effect, n = n, power = power),
            "power" = RNASeqPower::rnapower(depth = depth, cv = cv, effect = effect, alpha = alpha, n = n)
          )
        },
        error = function(e) {
          shiny:::reactiveStop(conditionMessage(e))
          #validate(fn_validate(T, "Power analysis error. Check if input values and/or delimiters are correct. All input must be numeric. Coefficient of variation, Alpha and Power must be values between 0 and 1. If error persists, submit an issue on the GitHub repo."))
        }
      )
    })
  }
)
