FROM rocker/verse
MAINTAINER yihant <yihant@ad.unc.edu>

WORKDIR /
RUN R -e "install.packages(c('readr','stringr','tidyr','dplyr','kableExtra'))"
RUN R -e "install.packages(c('carnet','scales','randomForest','h2o'))"
RUN R -e "install.packages(c('ggplot2','ggrepel','forcats'))"
RUN R -e "install.packages(c('treemapify','sf','tmap'))"
RUN R -e "install.packages(c('gridExtra','grid'))"

