library(readr)
library(tidyr)
library(dplyr)
library(stringr)
library(forcats)
select <- dplyr::select

# Clean & Format Raw Data==================================================

d <- read_csv("./source_data/all_data_M_2020.csv",
              col_types = cols(.default = "c")) %>%
  filter(!is.na(AREA_TYPE) & AREA_TYPE %in% c("1","2")) %>%
  select(PRIM_STATE, AREA_TYPE, NAICS, NAICS_TITLE,
         OCC_CODE, OCC_TITLE, O_GROUP,
         TOT_EMP, EMP_PRSE, H_MEAN, A_MEAN, MEAN_PRSE)
print(paste0(nrow(d), " rows are read in from source data"))

## Convert coded value to their correspondence
d <- d %>% mutate(TOT_EMP = replace(TOT_EMP, TOT_EMP=="**", NA),
                  EMP_PRSE = replace(EMP_PRSE, EMP_PRSE=="**", NA),
                  H_MEAN = {
                    v <- H_MEAN; v[v == "*"] <- NA; v[v == "#"] <- 100; v
                  },
                  A_MEAN = {
                    v <- A_MEAN; v[v == "*"] <- NA; v[v == "#"] <- 208000; v
                  },
                  MEAN_PRSE = replace(MEAN_PRSE, MEAN_PRSE=="*", NA))

## Remove rows containing NAs and convert formated data to numeric
to_numeric <- function(s){
  s %>%
    str_to_lower() %>%
    str_trim() %>%
    str_replace_all(",","") %>%
    as.numeric();
}

d.nona <- d %>% na.omit() %>%
  mutate(across(c(TOT_EMP, EMP_PRSE, H_MEAN, A_MEAN, MEAN_PRSE), to_numeric))
print(paste0(nrow(d) - nrow(d.nona), " rows are removed after removing rows that contain NAs"))

# Create & Apply Label=============================================================
create.OCC.Label <- function(s){
  s %>% str_trim() %>%
    str_replace_all(" Occupations","") %>%
    str_replace_all("Arts, Design, Entertainment, Sports, and Media", "Arts") %>%
    str_replace_all("Building and Grounds Cleaning and Maintenance", "Building") %>%
    str_replace_all("Business and Financial Operations", "Finance") %>%
    str_replace_all("Community and Social Service", "Social Service") %>%
    str_replace_all("Computer and Mathematical", "CS and Math") %>%
    str_replace_all("Construction and Extraction", "Install") %>%
    str_replace_all("Educational Instruction and Library", "Education") %>%
    str_replace_all("Farming, Fishing, and Forestry", "Farming") %>%
    str_replace_all("Food Preparation and Serving Related", "Food") %>%
    str_replace_all("Healthcare Practitioners and Technical", "Healthcare Practitioners") %>%
    str_replace_all("Installation, Maintenance, and Repair", "Maintenance ") %>%
    str_replace_all("Life, Physical, and Social Science", "Science") %>%
    str_replace_all("Office and Administrative Support", "Administry") %>%
    str_replace_all("Personal Care and Service", "Personal Care") %>%
    str_replace_all("Sales and Related", "Sales") %>%
    str_replace_all("Transportation and Material Moving", "Transportation") %>%
    str_trim();
}

create.NAICS.Label <- function(s){
  s %>% str_trim() %>%
    str_replace_all("Federal(.?)+", "Government") %>%
    str_replace_all("Agriculture, Forestry, Fishing and Hunting","Agriculture") %>%
    str_replace_all("Mining, Quarrying, and Oil and Gas Extraction", "Traditional Energy") %>%
    str_replace_all("Finance and Insurance", "Finance") %>%
    str_replace_all("Real Estate and Rental and Leasing", "Real Estate") %>%
    str_replace_all("Professional, Scientific, and Technical Services", "Scientific and Techincal") %>%
    str_replace_all("Management of Companies and Enterprises", "Enterprise Management") %>%
    str_replace_all("Administrative and Support and Waste Management and Remediation Services","Support") %>%
    str_replace_all("Health Care and Social Assistance", "Health and Social Care") %>%
    str_replace_all("Services", "") %>%
    str_replace_all("Educational", "Education") %>%
    str_replace_all("Manufacturing", "Manufacture")  %>%
    str_replace_all("Other(.?)+", "Other") %>%
    str_replace_all("Arts, Entertainment, and Recreation", "Arts") %>%
    str_replace_all("Accommodation and Food", "Food") %>%
    str_replace_all("Transportation and Warehousing", "Transport") %>%
    str_trim();
}

d.nona <- d.nona %>%
  mutate(across(NAICS_TITLE, create.NAICS.Label)) %>%
  mutate(across(OCC_TITLE, create.OCC.Label))

# Select Data of Interest ========================================================
d.us <- d.nona %>% filter(AREA_TYPE == "1")
d.state <- d.nona %>% filter(AREA_TYPE == "2")

OCC.of.interest <- c("15-1210", "15-1220", "15-1230", "15-1240",
                     "15-1250", "15-2020", "15-2030", "15-2040",
                     "15-2050", "17-2060", "19-1040")

d.broad.selected <- d.nona %>% filter(OCC_CODE %in% OCC.of.interest) %>%
  group_by(OCC_TITLE) %>% summarise(TOT_EMP = sum(TOT_EMP),
                                    H_MEAN = mean(H_MEAN),
                                    A_MEAN = mean(A_MEAN)) %>%
  arrange(desc(H_MEAN))

# Check Completeness of data ======================================================
# Check the 23 SOC major groups (https://www.bls.gov/soc/)
OCC.d <- d.us %>% filter(O_GROUP == "major") %>%
  group_by(OCC_CODE, OCC_TITLE) %>% tally() %>% arrange(OCC_CODE)
# the o_group structure is major - minor - broad - detailed,
# each latter one is a more detailed categorization of the former one
# All data is included expect data for military specific occupation.

# Check the 20 NAICS sectors (https://siccode.com/page/structure-of-naics-codes)
NAICS.d <- d.us %>%
  filter(nchar(NAICS) == 2 | NAICS %in% c("31-33", "44-45", "48-49")) %>%
  group_by(NAICS, NAICS_TITLE) %>% tally() %>% arrange(NAICS)

OCC.NAICS <- d.us %>%
  filter(OCC_CODE %in% (OCC.d %>% pull(OCC_CODE)) & NAICS %in% (NAICS.d %>% pull(NAICS)))


# Output derived dataset =========================================================
write.csv(d.us, "./derived_data/Salary_US.csv")
print(paste0("./derived_data/Salary_US.csv saved.", " #row: ", nrow(d.us)))

write.csv(d.state, "./derived_data/Salary_State.csv")
print(paste0("./derived_data/Salary_State.csv saved.", " #row: ", nrow(d.state)))

write.csv(OCC.NAICS, "./derived_data/Salary_US_major_group.csv")
print(paste0("./derived_data/Salary_US_major_group.csv saved.", " #row: ", nrow(OCC.NAICS)))

write.csv(d.broad.selected, "./derived_data/DS_broad_group.csv")
print(paste0("./derived_data/DS_broad_group.csv saved.", " #row: ", nrow(d.broad.selected)))