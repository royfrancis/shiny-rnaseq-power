FROM rocker/shiny:4.2.3
LABEL authors="Roy Francis"
LABEL org.opencontainers.image.source https://github.com/royfrancis/shiny-rnaseq-power

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN Rscript -e 'install.packages(c("BiocManager","shinyBS","pak"),repo="https://cloud.r-project.org/");pak::pkg_install("rstudio/bslib");BiocManager::install("RNASeqPower");'

RUN mkdir /srv/shiny-server/app
COPY . /srv/shiny-server/app
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
RUN sudo chown -R shiny:shiny /srv/shiny-server/app

EXPOSE 3838

CMD ["/usr/bin/shiny-server"]