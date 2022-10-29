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
figures/figure2.png:\
 analysis_section1.R\
 derived_data/fetal_health.csv
	Rscript analysis_section1.R

derived_data/fetal_health_new.csv\
 load_data.R\
 source_data/fetal_health.csv
	Rscript load_data.R
