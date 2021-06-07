FROM rocker/shiny:4.0.5
LABEL authors="Roy Francis"
ARG REPO="royfrancis/shiny-rnaseq-power"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

RUN Rscript -e 'install.packages(c("BiocManager","shinyBS","shinythemes"),repo="https://cloud.r-project.org/");BiocManager::install("RNASeqPower")'

RUN cd /srv/shiny-server/ && \
    git clone https://github.com/${REPO}.git app && \
    sudo chown -R shiny:shiny /srv/shiny-server/app

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/app/', host = '0.0.0.0', port = 8787)"]
