report.html: Report.Rmd code/render_report.R descriptive_analysis regression_analysis
	Rscript code/render_report.R

output/table_1.rds: code/make_table.R data/global_sports_footwear_sales_2018_2026.csv
	Rscript code/make_table.R
	
output/boxplot1.png output/boxplot2.png&: code/make_boxplots.R data/global_sports_footwear_sales_2018_2026.csv
	Rscript code/make_boxplots.R

output/model_coeffs.rds output/model1_summ.rds&: code/model.R data/global_sports_footwear_sales_2018_2026.csv
	Rscript code/model.R
	
.PHONY: regression_analysis
regression_analysis: output/model_coeffs.rds output/model1_summ.rds

.PHONY: descriptive_analysis
descriptive_analysis:	output/table_1.rds output/boxplot1.png output/boxplot2.png

.PHONY: clean
clean:
	rm -f output/*.rds && rm -f output/*.png && rm -f report.html

.PHONY: install
install:
	Rscript -e "renv::restore(prompt = FALSE)"
	
# Docker associated rules:
#PROJECTFILES = Report.Rmd code/make_table.R code/make_boxplots.R code/model.R code/render_report.R Makefile
#RENVFILES = renv.lock renv/activate.R renv/settings.json

# rule to build image
#project_image: Dockerfile $(PROJECTFILES) $(RENVFILES)
	#docker build -t project_image .
	#touch $@
	
# rule to run container on Mac
report/report_mac.html:
	docker run -v "$$(pwd)/report":/home/rstudio/project/report helenc358/final_project

# rule to run container on Windows
report/report_windows.html:
	docker run -v "/$$(pwd)/report":/home/rstudio/project/report helenc358/final_project
	