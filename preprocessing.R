#Importing
crime_data <- read.csv("D:/R Project/Crime.csv")
View(crime_data)
#delete unnecessary columns and rows
library("dplyr")
crime_data <- crime_data %>% select(-Mocodes,-Weapon.Used.Cd,-Weapon.Desc,-Crm.Cd.1, -Crm.Cd.2, -Crm.Cd.3, -Crm.Cd.4, -Cross.Street)
library(stringr)
crime_data$Premis.Desc <- str_trim(crime_data$Premis.Desc)
crime_data$LOCATION <- str_trim(crime_data$LOCATION)
crime_data <- crime_data %>% filter(!is.na(Vict.Sex) & Vict.Sex != '' & Vict.Sex != 'H' & Vict.Sex != 'X')
crime_data <- crime_data %>% filter(!is.na(Vict.Descent) & Vict.Descent != '' & Vict.Descent != '-')
crime_data <- crime_data %>% filter(!is.na(Premis.Cd) & Premis.Cd != '' ) 
crime_data <- crime_data %>% filter(!is.na(Premis.Desc) & Premis.Desc != '' ) 
#Handling Victim Age column
crime_data <- crime_data %>% filter(Vict.Age > 0 ) 
Q1 <- quantile(crime_data$Vict.Age, 0.25)
Q3 <- quantile(crime_data$Vict.Age, 0.75)
IQR <- Q3 - Q1
lower <- Q1 -1.5*IQR
upper <- Q3 +1.5 * IQR
crime_data <- crime_data %>% filter(Vict.Age <= upper & Vict.Age >= lower)
#Converting data type
crime_data$Date.Rptd <- as.POSIXct(crime_data$Date.Rptd, format = "%m/%d/%Y %I:%M:%S %p")
crime_data$DATE.OCC <- as.POSIXct(crime_data$DATE.OCC, format = "%m/%d/%Y %I:%M:%S %p")

#Checking any columns remain missing value?
temp_crime_data <- data.frame(lapply(crime_data, as.character), stringsAsFactors = FALSE)
empty_cells_per_column <- colSums(temp_crime_data == "")
empty_cells_per_column
#Take only 9,999 rows
crime_desc_counts <- crime_data %>% group_by(Crm.Cd.Desc) %>% summarise(count = n()) %>% arrange(desc(count))
top_3_crimes_type <- crime_desc_counts %>% top_n(3,count)
top_3_crimes_type
crime_data <- crime_data %>% filter(Crm.Cd.Desc == top_3_crimes_type$Crm.Cd.Desc)
crime_data <- crime_data %>% group_by(Crm.Cd.Desc) %>% slice_sample(n = 3333) %>% ungroup()
#Count time_to_report
crime_data$Time.to.reports<- as.numeric(round(difftime(crime_data$Date.Rptd,
                                                       crime_data$DATE.OCC, 
                                                             units = "days")))
#Check if Delayed_Report
crime_data$Delayed_Report <- factor(with(crime_data, ifelse((Time.to.reports > 1), 1, 0)))
#Convert Time Occur to Time_Slot
crime_data$Time_Slots_Happening <- factor(with(crime_data, ifelse(TIME.OCC >= 0 & TIME.OCC < 400, "Midnight",
                                                         ifelse(TIME.OCC >=400 & TIME.OCC < 1200, "Morning",
                                                                ifelse(TIME.OCC >= 1200 & TIME.OCC < 1900, "Afternoon", "Evening")))))
#Convert Date Occur to Weekdays
crime_data$Weekdays_of_DateOcc <- weekdays(crime_data$DATE.OCC)                                    
#Exporting
write.csv(crime_data, "new_crime_data.csv", row.names = FALSE)
getwd()

