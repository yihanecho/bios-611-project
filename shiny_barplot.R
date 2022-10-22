library(stringr)
library(dplyr)
library(gridExtra)
library(grid)
library(ggplot2)
library(shiny)
select <- dplyr::select

d.state <- read_csv("./derived_data/Salary_State.csv")
d.major <- d.state %>% filter(O_GROUP == "major") %>% mutate(SOC = str_sub(OCC_CODE, 1, 2))


# Define Barplot function==================================================
