FROM rocker/tidyverse:4.5.1 as base

#RUN apt-get update && apt-get install -y pandoc

RUN mkdir /home/rstudio/project
WORKDIR /home/rstudio/project

RUN mkdir -p renv
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

RUN mkdir renv/.cache
ENV RENV_PATHS_CACHE=renv/.cache

RUN Rscript -e "renv::restore(prompt = FALSE)"

###### DO NOT EDIT STAGE 1 BUILD LINES ABOVE ######

FROM rocker/tidyverse:4.5.1

RUN mkdir /home/rstudio/project

WORKDIR /home/rstudio/project
COPY --from=base /home/rstudio/project .

ENV WHICH_CONFIG="default"
COPY Makefile .
COPY Report.Rmd .
RUN mkdir code
RUN mkdir output
RUN mkdir data
RUN mkdir report
COPY data/global_sports_footwear_sales_2018_2026.csv data

COPY code code
CMD make && cp Report.html report/

