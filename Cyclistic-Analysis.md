Cyclistic Analysis - Google Data Analytics Capstone Project
================

**Author**: Gisanrin Oluwaseun  
**Date Updated**: 20th February, 2024

**Notice**  
This publication was completed as a part of the Google Data Analytics
course on Coursera. You may get in touch with me via email at
[seungisanrin@gmail.com](mailto:www.seungisanrin@gmail.com).

## Background

Cyclistic, a bike-share program launched in 2016 in Chicago, has grown
significantly, boasting a fleet of 5,824 bicycles across 692 stations,
offering geotracked and flexible rental options for customers. While its
marketing strategy initially targeted broad consumer segments, recent
financial analysis indicates that annual members generate higher profits
compared to casual riders. Recognizing this, Moreno, Cyclistic’s
strategist, aims to shift focus towards converting casual riders into
annual members. To achieve this, her team plans to delve into
Cyclistic’s historical bike trip data to discern trends and understand
the differing behaviors of casual riders and annual members, ultimately
informing targeted marketing strategies that leverage digital media
effectively.

### Business Task

How do annual members and casual riders use Cyclistic bikes differently?

## Analysis Process

This details the procedure by which this analysis was completed.

### Data Preparation and Pre-processing

The dataset utilised for the completion of this task covered the span of
one year from February 2023 to January 2024, the dataset can be
downloaded [here](https://divvy-tripdata.s3.amazonaws.com/index.html).
The data has been made available by Motivate International Inc. under
this [license](https://ride.divvybikes.com/data-license-agreement). It
is a public dataset, and it can be used in exploring the differences in
the customer types for Cyclistic. The data is hosted on the Amazon Web
Server (AWS), and is first-party data owned by Cyclistic.

#### Preparation

The language used in the preparation and cleaning of the dataset to be
used for analysis is R. R is a dynamic programming language that can be
used in data preparation, analysis, visualisations, as well as for
creating reports.  
The 12 datasets (monthly) used for this analysis, each with 13 columns
and between 100,000 and 700,000+ rows. The datasets were combined into
`origin_cyc_df` dataframe in R.

The combined dataframe has **5674449 rows** and **13 columns**.

``` r
glimpse(origin_cyc_df)
```

    ## Rows: 5,674,449
    ## Columns: 13
    ## $ ride_id            <chr> "CBCD0D7777F0E45F", "F3EC5FCE5FF39DE9", "E54C1F27FA…
    ## $ rideable_type      <chr> "classic_bike", "electric_bike", "classic_bike", "e…
    ## $ started_at         <dttm> 2023-02-14 11:59:42, 2023-02-15 13:53:48, 2023-02-…
    ## $ ended_at           <dttm> 2023-02-14 12:13:38, 2023-02-15 13:59:08, 2023-02-…
    ## $ start_station_name <chr> "Southport Ave & Clybourn Ave", "Clarendon Ave & Go…
    ## $ start_station_id   <chr> "TA1309000030", "13379", "TA1309000030", "TA1309000…
    ## $ end_station_name   <chr> "Clark St & Schiller St", "Sheridan Rd & Lawrence A…
    ## $ end_station_id     <chr> "TA1309000024", "TA1309000041", "13156", "TA1309000…
    ## $ start_lat          <dbl> 41.92077, 41.95788, 41.92077, 41.92087, 41.79483, 4…
    ## $ start_lng          <dbl> -87.66371, -87.64958, -87.66371, -87.66373, -87.618…
    ## $ end_lat            <dbl> 41.90799, 41.96952, 41.88042, 41.87943, 41.78053, 4…
    ## $ end_lng            <dbl> -87.63150, -87.65469, -87.65552, -87.63550, -87.605…
    ## $ member_casual      <chr> "casual", "casual", "member", "member", "member", "…

#### Cleaning and Manipulation

A brief outline providing details on the steps taken to clean the
dataset for analysis.  
+ The columns relevant for the analysis were selected, this includes
(ride_id, rideable_type, started_at, start_station_name, ended_at,
end_station_name, member_casual).  
+ Duplicates in the `ride_id` columns were checked for, and the column
was determined to be unique.  
+ Checked the `ride_id` column for nonconforming observations, all
observations are made up of 16 character strings. All observations of
the `ride_id` variable were valid.  
+ Filtered through all columns to remove ride observations that had any
of its variables blank.  
+ Created column `ride_length` to determine the length of each ride
observation in minutes.  
+ Dropped observations with less `ride_length` less than 1 minute, which
are potentially false starts or attempts at re-docking bikes. As well as
observations with negative values for `ride_length`.  
+ Created column `weekday` to denote the day of the week a ride was
embarked on.

The cleaning of the dataset led to the removal of **1464313** ride
observations.  
The dataset for analysis is composed of **4210136** rows and **9**
columns.

#### Analysis
For this step, summary statistics were performed in R to determine differences between members and casuals
riders. Number of valid rides were computed, the average length ride between the period of Feb-2023 and
Jan-2024, also the maximum ride length for the time period.  
Member-type analyses were conducted to determine the ride distribution among the 4 million rides, the 
frequency of trips on each day of the week, the average ride length, also the bike preferences for each
type of member.  
The detailed analysis can be seen [here](https://github.com/seungisanrin/cyclistic-analysis/blob/main/cyclistic_analysis.r).  
  
#### Data Visualisation
In creating this visualisation, the flexdashboard package in R was used. The package allows for the creation of dashboards
using rmarkdown, the link to the dashboard is [here](https://rpubs.com/seungisanrin/cyclistic-analysis).
![image](https://github.com/seungisanrin/cyclistic-analysis/assets/159424518/7a526398-251d-47f8-a91a-33a7483becc6)

#### Recommendations
1. **Weekend Promotions**: Casual riders seem to use our bikes more on weekends. We could target promotions for ride memberships specifically on weekends to encourage them to convert to annual members.  
2. **Targeted Ads**: Casual riders mostly prefer the Classic Bike. We could create targeted advertisements for casual riders, highlighting the benefits of becoming annual members, with a focus on the Classic Bike.  
3. **Daily Transportation Incentives**: Both casual and member riders frequently use our bikes at 8 AM and 5 PM, indicating a daily transportation routine, likely for office workers. Offering promotions tailored for daily transportation needs could motivate casual riders to become members.  
4. **Station-Specific Promotions**: We could target promotions to the top 5 most visited start stations for casual riders. This could help create awareness among casual riders about the benefits of membership.  
5. **Seasonal Usage Insights**: During winter, casual riders prefer the Classic or Electric Bike, while in summer, there's an increase in usage of all bike types, especially the Classic Bike. We could adjust our marketing strategies seasonally to highlight the benefits of membership based on bike preferences.
6. **Long Ride Promotions**: Casual riders tend to embark on longer trips than members on average. Offering promotions for subscriptions with benefits for long rides could incentivize casual riders to sign up for annual memberships.