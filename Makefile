.PHONY: clean

SHELL: /bin/bash

clean:
	rm -f $(wildcard derived_data/*.csv)
	rm -f $(wildcard figures/*.png)

report.pdf:\
  report.Rmd\
  figures/*.png\
  derived_data/DS_broad_group.csv 
	Rscript -e "rmarkdown::render('report.Rmd',output_format='pdf_document')"

figures/figure41.png\
figures/figure42.png:\
 analysis_section4.R\
 source_data/Automation_by_state.csv\
 derived_data/Salary_US_major_group.csv
	Rscript analysis_section4.R

figures/figure31.png\
figures/figure32.png:\
 analysis_section3.R\
 derived_data/Salary_State.csv\
 source_data/US_State/*
	Rscript analysis_section3.R

figures/figure21-22.png\
figures/figure23.png:\
 analysis_section2.R\
 derived_data/Salary_US_major_group.csv\
 derived_data/DS_broad_group.csv
	Rscript analysis_section2.R

figures/figure11-12.png\
figures/figure13.png:\
 analysis_section1.R\
 derived_data/Salary_US_major_group.csv
	Rscript analysis_section1.R

derived_data/Salary_US.csv\
derived_data/Salary_State.csv\
derived_data/Salary_US_major_group.csv\
derived_data/DS_broad_group.csv:\
 load_data.R\
 source_data/all_data_M_2020.csv
	Rscript load_data.R
