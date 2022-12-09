.PHONY: clean

SHELL: /bin/bash

clean:
	rm -f $(wildcard derived_data/*.csv)
	rm -f $(wildcard figures/*.png)

report.pdf:\
  report.Rmd\
  figures/*.png\
  derived_data/fetal_health_new.csv 
	Rscript -e "rmarkdown::render('report.Rmd',output_format='pdf_document')"


figures/figure1.png\
figures/figure12.png\
figures/figure13.png:\
 analysis_section1.R\
source_data/fetal_health.csv\
 derived_data/fetal_health_new.csv
	Rscript analysis_section1.R

figures/figure23.png\
figures/figure22.png:\
 analysis_section2.R\
source_data/fetal_health.csv
	Rscript analysis_section2.R

derived_data/fetal_health_new.csv:\
 load_data.R\
 source_data/fetal_health.csv
	Rscript load_data.R
