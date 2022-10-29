


##Overview 
This dataset contains 2126 records of features extracted from cardiotocogram exams, which were then classified by three expert obstetricians into 3 classes: Normal, Suspect, Pathological. Among the data, we have 21 features including baseline fetal heart rate, uterine contractions and so on. I am willing to use this dataset to make do data visualization and detailed demographic plot to show the association between covariates and dependent outcomes.  Also, to demonstrate the information for each baseline covariates.  I can learn to use not only R such as ggplot, but also python and other software to do data visualization. Also, I am willing to do the predication and classification of fetal health by using different method like parametric model such as by fitting the proportional odds model or non-parametric model such as classification method. Then we can compare the performance of the parametric and non-parametric model. Also, I want to learn some method like machining learning such as decision tree, supervised machine learning classification and deep learning methods. Moreover, the ultimate goal is to improve the performance of the predictions for the fetal mortality by utilizing the diagnostic information and check the model performance and do validations such as k-fold validation. Besides, I want to learn how to use docker to reproduce the whole demographic report and classification model by using one line of code in docker. In this class, my goal is to learn some machine learning methods to do classification and how to organize my code and files so that I can share to other people, and they can easily repeat my analysis with less efforts. 


## Instruction:
#### Build Environment
 - Build the image for this project by typing: 
```
docker build . -t project
```
 - Then start RStudio in your web browser by typing:
```
docker run -e PASSWORD=<some_password> --rm -v $(pwd):/home/rstudio/ -p 8787:8787 -t project
```
 - Once the Rstudio is running connect to it by visiting
https://localhost:8787 in your browser. Log in with username `rstudio` and the password you entered after `PASSWORD=`.


#### Generate Results
 - Type `make report.pdf` in the terminal to create the final report.
 - Each R script generates the figures for a particular section. If interested in the analysis in a particular section, run load_data.R first, and then the R script for that section.


