#Loading the necessary packages
library(dplyr)
library(readr)
library(tidyverse)

setwd("C:/Users/seung/OneDrive/Documents/GitHub/cyclistic-analysis/cyclistic-analysis/data")
#Creating the data frame from the csv files in the folder
origin_cyc_df <- list.files(path = "C:/Users/seung/OneDrive/Documents/GitHub/cyclistic-analysis/cyclistic-analysis/data") %>%
  lapply(read_csv) %>%
  bind_rows()

#Understanding the Data
colnames(origin_cyc_df)
glimpse(origin_cyc_df)

#CLEANING OF THE DATA
#Selecting columns required for analysis
cyc_df <- origin_cyc_df %>%
  select(ride_id, rideable_type, started_at, start_station_name, ended_at, end_station_name, member_casual)

#Check for duplicate ride ID's
cyc_df %>%
  n_distinct(cyc_df$ride_id)

#Check for incorrect ride ID's
cyc_df %>%
  filter(nchar(ride_id) != 16)

#Filtering blank row from the data frame
clean_cyc_df <- cyc_df %>%
  filter(!(is.na(ride_id)|
           is.na(start_station_name)|
           is.na(end_station_name)|
           is.na(rideable_type)|
           is.na(member_casual)|
           is.na(started_at)|
           is.na(ended_at)))
#DATA PREPARATION PHASE
#Determining the length of each ride
clean_cyc_df$ride_length <- difftime(clean_cyc_df$ended_at, clean_cyc_df$started_at, units = "mins")

#Removing trips that are less than a minute due to false starts
clean_cyc_df <- clean_cyc_df %>%
  filter(ride_length > 1)

no_rows_dropped <- nrow(cyc_df) - nrow(clean_cyc_df)
rows_analysis <- nrow(clean_cyc_df)
#Creating a column for the day of the week
clean_cyc_df$weekday <- wday(clean_cyc_df$started_at, label=TRUE, abbr=FALSE)

dim(clean_cyc_df)

#ANALYSIS PHASE
avg_ride_length <- round(as.numeric(mean(clean_cyc_df$ride_length)), digits = 2)

max_ride_length <- as.numeric(max(clean_cyc_df$ride_length))

#Number of rides per day of the week
ride_fq_dotw <- clean_cyc_df %>%
  group_by(weekday) %>%
  summarise(no_trips = n()) %>%
  arrange(desc(no_trips))

#Average ride length per member type
avg_ride_per_membertype <- clean_cyc_df %>%
  group_by(member_casual) %>%
  summarise(avg_no_trips = mean(ride_length))

#Average number of rides per day of the week
avg_ride_pdotw <- clean_cyc_df %>%
  group_by(weekday) %>%
  summarise(avg_no_trips = mean(ride_length))

#Number of trips per day per user type
no_trips_pday_puser <- clean_cyc_df %>%
  group_by(weekday, member_casual) %>%
  summarise(no_trips = n())

#Number of trips at every hour of the day
trips_p_tod <- clean_cyc_df %>%
  group_by(hr_of_day = hour(started_at), member_casual) %>%
  summarise(no_trips = n())

#Top five starting Stations for casual
top_5_start_stations_cas <- clean_cyc_df %>%
  filter(member_casual == "casual") %>%
  group_by(start_station_name) %>%
  summarise(no_trips = n()) %>%
  slice_max(order_by = no_trips, n = 5)

#Top five starting Stations for members
top_5_start_stations_mem <- clean_cyc_df %>%
  filter(member_casual == "member") %>%
  group_by(start_station_name) %>%
  summarise(no_trips = n()) %>%
  slice_max(order_by = no_trips, n = 5)

member_pref_bike_type <- clean_cyc_df %>%
  group_by(rideable_type, member_casual) %>%
  summarise(no_trips = n())

#Average ride length for each customer type and each bike type
avg_rl_bt_ct <- clean_cyc_df %>%
  group_by(rideable_type, member_casual) %>%
  summarise(avg_ride_length = mean(ride_length))

#Number of rides per month for different member types
month_ride_type <- clean_cyc_df %>%
  group_by(ride_month = month(started_at), member_casual) %>%
  summarise(no_trips = n())