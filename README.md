
<!-- README.md is generated from README.Rmd. Please edit that file -->

# carmatch

<!-- badges: start -->
<!-- badges: end -->

``` r
# devtools::load_all()
source("https://github.com/ITSLeeds/carmatch/raw/main/R/carmatch.R")

d_raw = cm_get()
names(d_raw)
summary(d_raw$SteeringAxle)
system.time(saveRDS(d_raw, "d_raw_euco2.Rds"))
# 35s on fast computer! 40 MB

library(readxl)
sheet1 <- read_excel("veh0160.xlsx", sheet = 1)
rownumber <- which(sheet1$`Department for Transport statistics` == "Make")
headers <- as.list(sheet1[rownumber,])
sheet1 <- sheet1[-c(1:(rownumber)),]
colnames(sheet1) <- headers
rm(headers)
rownumber <- which(sheet1$Make == "1. Entries containing \"MISSING\" or \"UNKNOWN MODEL\" are either for vehicles that have never been allocated a model code (most likely older vehicles manufactured before 1972) or new vehicles when the code lookup has not yet been published.")
sheet1 <- sheet1[-c(rownumber:nrow(sheet1)),]
sheet1 <- subset(sheet1, !(is.na(sheet1$Make)))

sheet1$UK2017 <- as.numeric(sheet1$`2017 Q1 UK`) +
                 as.numeric(sheet1$`2017 Q2 UK`) +
                 as.numeric(sheet1$`2017 Q3 UK`) +
                 as.numeric(sheet1$`2017 Q4 UK`)

UK2017 <- as.data.frame(cbind(sheet1$Make, sheet1$`Model 1`, sheet1$UK2017))
colnames(UK2017) <- c("Make", "DVLAModel", "2017 Registrations")
UK2017 <- subset(UK2017, !is.na(UK2017$`2017 Registrations`))

EU_GB <- subset(d_raw, d_raw$Country == "GB")

library(tidyverse)
EU_data_summary <- EU_GB %>% group_by(Manufacturer_name_MS,Commercial_name, NEDC_CO2, Mass_kg, Wheelbase, SteeringAxle, OtherAxle, Fuel_type, Engine_capacity) %>% dplyr::summarise("freq in EU data for UK" = n())

EU_data_summary$Commercial_name_in_VEH0160_2017 <- NA
EU_data_summary$Commercial_name_in_VEH0160 <- NA
UK2017$MakeModel <- paste0(UK2017$Make, " ", UK2017$DVLAModel)
EU_data_summary$MakeModel <- paste0(EU_data_summary$Manufacturer_name_MS, " ", EU_data_summary$Commercial_name)
sheet1$MakeModel <- paste0(sheet1$Make, " ", sheet1$`Model 1`)

EU_data_summary$Commercial_name_in_VEH0160_2017[EU_data_summary$MakeModel %in% UK2017$MakeModel] <- TRUE
EU_data_summary$Commercial_name_in_VEH0160[EU_data_summary$MakeModel %in% sheet1$MakeModel] <- TRUE
```
