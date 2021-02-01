# single place for functions (for now)
cm_get = function(u = "https://www.eea.europa.eu/data-and-maps/data/co2-cars-emission-18/co2-emissions-cars-2017-final/co2_passengers_cars_v16_csv.zip/at_download/file", dir = tempdir()) {
  f = file.path(dir, "co2.zip")
  dd = file.path(dir, "co2")
if(!file.exists(f)) {
    download.file(u, f)
    dir.create(dd)
    unzip(f, exdir = dd)
  }
  f = list.files(dd, full.names = TRUE)
  print(f)
  # every single car type

  data <- read.csv(
    f, fileEncoding = "UTF-16", sep = "\t", header = TRUE
  )
  # fails:
  # readr::read_tsv(f, locale = readr::locale(encoding="UTF-16"))

  names <- c("ID",
             "Country",
             "Manufacturer_pooling",
             "Vehicle_family_identification_number",
             "Manufacturer_name_EU",
             "Manufacturer_name_OEM",
             "Manufacturer_name_MS",
             "Type_Approval_Number",
             "Type",
             "Variant",
             "Version",
             "Make",
             "Commercial_name",
             "Category_type_approved",
             "Category_vehicle_registered",
             "Mass_kg",
             "WLTP_Mass",
             "NEDC_CO2",
             "WLTP_CO2",
             "Wheelbase",
             "SteeringAxle",
             "OtherAxle",
             "Fuel_type",
             "Fuel_mode",
             "Engine_capacity",
             "Engine_power",
             "Electric_consumpt",
             "Innovative_tech",
             "NEDC_Emissions_tech",
             "WLTP_Emissions_tech",
             "Deviation_factor",
             "Verification_factor",
             "Total_new_registrations")
  colnames(data) <- names
  data$Manufacturer_pooling[data$Manufacturer_pooling == ""] <- NA
  data$Manufacturer_pooling <- as.factor(data$Manufacturer_pooling)
  data$Vehicle_family_identification_number[data$Vehicle_family_identification_number == ""] <- NA
  data$Manufacturer_name_EU <- toupper(data$Manufacturer_name_EU)
  data$Manufacturer_name_OEM[data$Manufacturer_name_OEM == ""] <- NA
  data$Manufacturer_name_OEM <- as.factor(toupper(base::trimws(data$Manufacturer_name_OEM, which = c("both"))))
  data$Manufacturer_name_MS[data$Manufacturer_name_MS == ""] <- NA
  data$Manufacturer_name_MS <- as.factor(toupper(base::trimws(data$Manufacturer_name_MS, which = c("both"))))
  data$Type_Approval_Number[data$Type_Approval_Number == ""] <- NA
  data$Make[data$Make == ""] <- NA
  data$Make <- as.factor(toupper(base::trimws(data$Make, which = c("both"))))
  data$Commercial_name[data$Commercial_name == ""] <- NA
  data$Commercial_name <- as.factor(toupper(base::trimws(data$Commercial_name, which = c("both"))))
  data$Category_type_approved[data$Category_type_approved == ""] <- NA
  data$Category_type_approved <- as.factor(toupper(base::trimws(data$Category_type_approved, which = c("both"))))
  data$Category_vehicle_registered <- NULL
  data$Fuel_type[data$Fuel_type == ""] <- NA
  data$Fuel_type <- as.factor(toupper(base::trimws(data$Fuel_type, which = c("both"))))
  data$Fuel_mode[data$Fuel_mode == ""] <- NA
  data$Fuel_mode <- toupper(base::trimws(data$Fuel_mode, which = c("both")))
  data$Innovative_tech[data$Innovative_tech == ""] <- NA
  data

}
d_raw = cm_get()
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
