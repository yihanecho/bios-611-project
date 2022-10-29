.PHONY: clean

SHELL: /bin/bash

clean:
	rm -f $(wildcard derived_data/*.csv)
	rm -f $(wildcard figures/*.png)

report.pdf:\
  report.Rmd\
  figures/*.png\
  source_data/fetal_health.csv 
	Rscript -e "rmarkdown::render('report.Rmd',output_format='pdf_document')"

figures/figure1.png\
figures/figure2.png:\
 analysis_section1.R\
 source_data/fetal_health.csv\
	Rscript analysis_section1.R

figures/figure3.png\
figures/figure4.png:\
 analysis_section2.R\
 source_data/fetal_health.csv\
 source_data/US_State/*
	Rscript analysis_section2.R
