#Loading the necessary packages
library(dplyr)
library(readr)
library(tidyverse)
library(plotly)
library(ggplot2)
options(scipen = 999)

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

#Member type distribution
no_trip_pmem <- clean_cyc_df %>%
  group_by(member_casual) %>%
  summarise(no_trips = n())

color_pie <- c("#2596BE", "#2b2d42")
fig_pi_chart <- plot_ly(no_trip_pmem, labels=~member_casual,values =~no_trips, text =~member_casual,
marker = list(colors = color_pie)) %>%
  add_pie(hole = 0.42) %>%
  layout(title = "Ride Distribution: Member Type", annotations=list(text=paste("Over 4M Rides"),"showarrow" =F))
fig_pi_chart
?paste
#Number of rides per day of the week
ride_fq_dotw <- clean_cyc_df %>%
  group_by(weekday) %>%
  summarise(no_trips = n()) %>%
  arrange(desc(no_trips))

fig_ride_pq <- plot_ly(ride_fq_dotw, x=~weekday, y=~no_trips, type = "bar", colors = "blue")
fig_ride_pq <- fig_ride_pq %>%
  layout(title = "Weekday Ride Distribution", yaxis = list(title = "Number of Trips"))

fig_ride_pq

#Average ride length per member type
avg_ride_per_membertype <- clean_cyc_df %>%
  group_by(member_casual) %>%
  summarise(avg_no_trips = mean(ride_length))

fig_avg_ride_p_mem <- plot_ly(avg_ride_per_membertype,
  x=~member_casual, y=~avg_no_trips, type = "bar")
fig_avg_ride_p_mem <- fig_avg_ride_p_mem %>%
  layout(title = "Average Ride Length by Membership",
    xaxis = list(title = "Type of Membership"),
  yaxis = list(title = "Average Ride Length (Mins)"))

fig_avg_ride_p_mem

#Average length of rides per day of the week
avg_ride_pdotw <- clean_cyc_df %>%
  group_by(weekday) %>%
  summarise(avg_no_trips = mean(ride_length))

fig_avg_pdotw <- plot_ly(avg_ride_pdotw, x=~weekday, y=~avg_no_trips, type = "bar")
fig_avg_pdotw <- fig_avg_pdotw %>%
  layout(title = "Average Ride Length Across Weekdays",
  yaxis = list(title = "Average Ride Length (Mins)"))

fig_avg_pdotw

#Number of trips per day per user type
no_trips_pday_puser <- clean_cyc_df %>%
  group_by(weekday, member_casual) %>%
  summarise(no_trips = n())

fig_no_trips_pday <- ggplotly(
ggplot(no_trips_pday_puser, mapping = aes(x=weekday, y=no_trips, fill=member_casual)) +
  geom_bar(position = "dodge", stat = "identity") +
  labs(title = "Trips Per Day: User Type Comparison", y = "Number of Trips") +
  guides(fill=guide_legend(title="User Type")) +
  scale_fill_manual(values = c("#2596BE", "#2b2d42")) +
  theme_minimal()
)

fig_no_trips_pday

#Number of trips at every hour of the day
trips_p_tod <- clean_cyc_df %>%
  group_by(hr_of_day = hour(started_at), member_casual) %>%
  summarise(no_trips = n())

fig_trips_p_tod <- ggplotly(
  ggplot(trips_p_tod, mapping = aes(x=hr_of_day, y=no_trips, colour = member_casual)) +
  geom_line(stat = "identity") +
  geom_point(stat = "identity") +
  labs(title = "Hourly Trip Volume Analysis: User Type Basis", x = "Hour of the Day", y = "Number of Trips") +
  guides(color=guide_legend(title = "User Type")) +
  scale_color_manual(values = c("#2596BE", "#2b2d42")) +
  scale_x_continuous(breaks =seq(0,23,2)) +
  scale_y_continuous(breaks = seq(0,300000,50000)) +
  theme_minimal()
)
fig_trips_p_tod


#Top five starting Stations for casual
top_5_start_stations_cas <- clean_cyc_df %>%
  filter(member_casual == "casual") %>%
  group_by(start_station_name) %>%
  summarise(no_trips = n()) %>%
  slice_max(order_by = no_trips, n = 5)

fig_top_5_sscas <- plot_ly(top_5_start_stations_cas, x=~no_trips, y=~start_station_name, type = "bar", colors = "#2596BE") %>%
  layout(title = "Top 5 Most Visited Starting Stations for Casual Riders",
    xaxis = list(title = "Number of Trips"),
    yaxis = list(title = "Station Name"))
fig_top_5_sscas

#Top five starting Stations for members
top_5_start_stations_mem <- clean_cyc_df %>%
  filter(member_casual == "member") %>%
  group_by(start_station_name) %>%
  summarise(no_trips = n()) %>%
  slice_max(order_by = no_trips, n = 5)

fig_top_5_ssmem <- plot_ly(top_5_start_stations_mem, x=~no_trips, y=~start_station_name, type = "bar", colors = "#2596BE") %>%
  layout(title = "Top 5 Most Visited Starting Stations for Member Riders",
    xaxis = list(title = "Number of Trips"),
    yaxis = list(title = "Station Name"))
fig_top_5_ssmem

#Preferred Bike Type for each Member Type
member_pref_bike_type <- clean_cyc_df %>%
  group_by(rideable_type, member_casual) %>%
  summarise(no_trips = n())

fig_mem_pref_bk <- ggplotly(
ggplot(member_pref_bike_type, mapping = aes(x=rideable_type, y=no_trips, fill=member_casual)) +
  geom_bar(position = "dodge", stat = "identity") +
  labs(title = "Bike Type Preference Analysis", y = "Number of Trips", x ="Bike Type") +
  guides(fill=guide_legend(title="User Type")) +
  scale_fill_manual(values = c("#2596BE", "#2b2d42")) +
  theme_minimal()
)
fig_mem_pref_bk

#Average ride length for each customer type and each bike type
avg_rl_bt_ct <- clean_cyc_df %>%
  group_by(rideable_type, member_casual) %>%
  summarise(avg_ride_length = mean(ride_length))

ggplotly(
ggplot(avg_rl_bt_ct, mapping = aes(x=rideable_type, y=avg_ride_length, fill=member_casual)) +
  geom_bar(position = "dodge", stat = "identity") +
  labs(title = "Average Ride Length: Customer-Bike Type Perspective", y = "Average Ride Length (Mins)", x ="Bike Type") +
  guides(fill=guide_legend(title="User Type")) +
  scale_fill_manual(values = c("#2596BE", "#2b2d42")) +
  theme_minimal()
)

#Number of rides per month for different member types
month_ride_type <- clean_cyc_df %>%
  group_by(ride_month = month(started_at, label=  TRUE, abbr = FALSE), member_casual) %>%
  summarise(no_trips = n())

ggplotly(
ggplot(month_ride_type, mapping = aes(x=ride_month, y=no_trips, fill=member_casual)) +
  geom_bar(position = "dodge", stat = "identity") +
  labs(title = "Average Ride Length: Customer-Bike Type Perspective", y = "Average Ride Length (Mins)", x ="Month") +
  guides(fill=guide_legend(title="User Type")) +
  scale_fill_manual(values = c("#2596BE", "#2b2d42")) +
  scale_y_continuous(breaks = seq(0,400000,50000)) +
  theme(panel.grid.major.x = element_blank()) +
  theme_minimal()
)

#Bike Preference per month for each member type
bp_p_month <- clean_cyc_df %>%
  group_by(ride_month = month(started_at, label =  TRUE, abbr = FALSE), rideable_type, member_casual) %>%
  summarise(no_trips = n())

fig_bp_pmnt <- ggplotly(
ggplot(bp_p_month, mapping = aes(x=no_trips, y=ride_month, fill=member_casual)) +
  geom_bar(position = "stack", stat = "identity") +
  labs(title = "Monthly Bike Preference: User Type Basis", y = "Month", x ="Number of Trips") +
  guides(fill=guide_legend(title="User Type")) +
  scale_fill_manual(values = c("#2596BE", "#2b2d42")) +
  theme(panel.grid.major.x = element_blank()) +
  theme_minimal() +
  facet_wrap(~rideable_type, nrow = 3)
)