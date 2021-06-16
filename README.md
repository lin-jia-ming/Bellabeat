# User Insights on Fitness Smart Device Usage

## Summary
This project is based on [Google Data Analytics Certification](https://www.coursera.org/learn/google-data-analytics-capstone) Capstone Project - Case Study 2 (Bellabeat)

## Tools
`SQL Server` is used for data cleaning  
`Tableau` is used for data analysis and visualisation  
`R` (tidyverse and ggplot2) is used as an alternate version for data cleaning, data analysis and visualisation  

## Business Case
Bellabeat's cofounder knows that an analysis of fitness smart device data would reveal more opportunities for growth. Obtain analysis insights and provide recommendations for Bellabeat marketing strategy.  

## Objectives
* Gain insights into how people are using fitness smart devices
* Provide marketing strategy recommendations for Bellabeat product

## Analysis
Refer to `Bellabeat`.pdf

## Conclusion
* 64% of users tracked their data for all days
* 8% of total records registered total steps of 0 for the entire day
* 9% of users tracked their sleep data for all days
* The user profile of fitness smart devices
    * Wide and normal distribution of inactive, active and very active users (by steps)
    * All users exercise less than 150 minutes weekly, with an average of 34 minutes
    * Have no sleep issues

## Recommendations
Recommendations for Bellabeat marketing strategy
#### Battery Life
* Bellabeat product has **stronger battery life** than those in the market
* Bellabeat product has the capability to **send user alerts** when the device is on low battery, fully charged, or not worn for 24 hours
#### Sleep Convenience
* Bellabeat product is able to **auto detect and track sleep**
* Bellabeat product is designed for **comfort** during sleep (“you can’t feel it”)
#### Fashion
* Bellabeat product is designed to **fashionably** appeal to specific demographic preference
#### Target User Profile
* Bellabeat product can be marketed to the **general population** (existing demand)
* There is possibly an untapped market of **people who exercise more than 150 minutes weekly**

## Limitations and Assumptions
* Unable to validate data with the original source
* Data is limited to 33 Fitbit users, and may not be representative of the population
* Data is limited to April and May,  and there might be seasonal trends
* Data provided is in 2016, and user behaviour might change over time
* Data is insufficient to decisively determine reasons for user behaviour
    * For example: why users stop tracking their fitness data, as well as sleep data
* Assume distance units to be in kilometers

## Further Investigations
* Why users stop tracking their fitness data?
    * Battery died? Privacy concerns? Discontinued product usage due to preferences?
* Why did users register total steps of 0 for the entire day?
    * User forgot to wear device? User is charging device?
* Why is there significantly lesser sleep data records?
    * Inconvenient/uncomfortable/unable to track sleep? User charge during sleep?
* Are "people who exercise more than 150 minutes weekly", an untapped market, or are they not interested in fitness smart devices?

## Opportunities
* Collect data from more fitness smart device users
* Collect data over several years
* Make sure data is current
* Collect more data points to determine user behaviour
    * Surveys, interviews etc
* Collect demographics data
* Analyze data by minute
    * Example: send alert when user is not moving and not sleeping, for the last hour

## File Structure
* `Bellabeat`.pdf, is the presentation for this portfolio project
* `Raw Data` folder, contains raw data from Kaggle that is used for this analysis
* `SQL` folder, contains SQL scripts for data cleaning
* `Clean Data` folder, contains cleaned data via SQL
* `Data Cleaning Checklist - Google DA Capstone - Case Study 2`.xlsx, is the checklist for data cleaning
* `Tableau` folder, contains Tableau visualizations
* `R` folder, contains R scripts for data cleaning, data analysis and visualizations (alternative to SQL + Tableau)

## Data Source
Kaggle dataset titled [FitBit Fitness Tracker Data](https://www.kaggle.com/arashnic/fitbit)  
