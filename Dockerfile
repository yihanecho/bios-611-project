FROM rocker/verse
MAINTAINER yihant <yihant@ad.unc.edu>

WORKDIR /
RUN R -e "install.packages(c('readr','stringr','tidyr','dplyr'))"
RUN R -e "install.packages(c('carnet','scales','randomForest'))"
RUN R -e "install.packages(c('ggplot2','ggrepel','forcats'))"
RUN R -e "install.packages(c('treemapify','sf','tmap'))"
RUN R -e "install.packages(c('gridExtra','grid'))"
RUN R -e "install.packages('tinytex'); tinytex::install_tinytex(dir='/opt/tinytex')"
