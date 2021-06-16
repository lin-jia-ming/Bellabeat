/*
Project: Google Data Analytics Capstone Project, Case Study 2
Activity: Data Cleaning
Dataset: FitBit Fitness Tracker Data (Kaggle)
Table: sleepDay_merged.csv
Analyst: Lin Jiaming
Date: 30 May 2021
*/


--------------------------
--  Create Backup Copy  --
--------------------------

SELECT *
INTO sleepDay_Backup
FROM sleepDay;


---------------------------
--  Column Header Check  --
---------------------------

SELECT *
FROM Project_Bellabeat..sleepDay;


-----------------------
--  Data Type Check  --
-----------------------

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sleepDay';


-- Convert ActivityDate data type from datetime to date

ALTER TABLE sleepDay
ALTER COLUMN SleepDay date;


-- Convert TotalSleepRecords data type from int to character

ALTER TABLE sleepDay
ALTER COLUMN TotalSleepRecords nvarchar(255);


----------------------------
--  Missing Values Check  --
----------------------------

-- Checked using skim_without_charts() in R
-- No missing values found

SELECT *
FROM Project_Bellabeat..sleepDay
WHERE Id IS NULL
  OR SleepDay IS NULL
  OR TotalSleepRecords IS NULL
  OR TotalMinutesAsleep IS NULL
  OR TotalTimeInBed IS NULL;
  
  
------------------------
--  Duplicates Check  --
------------------------

-- Removed 3 duplicates

SELECT *
FROM Project_Bellabeat..sleepDay AS Orig
JOIN (
  SELECT Id, SleepDay, COUNT(*) AS row_num
  FROM Project_Bellabeat..sleepDay
  GROUP BY Id, SleepDay
  HAVING COUNT(*) > 1) AS Dup
ON Orig.Id = Dup.Id AND Orig.SleepDay = Dup.SleepDay;


-- Inspect duplicates fields before deletion
-- Duplicates are exactly the same in all fields

WITH DupCheck AS (
  SELECT
    Id,
	SleepDay,
	ROW_NUMBER() OVER(PARTITION BY Id, SleepDay ORDER BY Id ASC) AS row_num
  FROM Project_Bellabeat..sleepDay
)

DELETE
FROM DupCheck
WHERE row_num > 1;


--------------------------
--  Extra Spaces Check  --
--------------------------

-- Not applicable
-- No character data type


---------------------------------------
--  Inconsistent Field Length Check  --
---------------------------------------

-- Not applicable


------------------------
--  Date Range Check  --
------------------------

-- Start-date = 2016-04-12
-- End-date = 2016-05-12

SELECT MIN(SleepDay) AS earliest_date, MAX(SleepDay) AS lastest_date
FROM Project_Bellabeat..sleepDay;


----------------------------
--  Categorization Check  --
----------------------------

-- 3 categories for TotalSleepRecords

SELECT TotalSleepRecords, COUNT(*) AS sleep_record_count
FROM Project_Bellabeat..sleepDay
GROUP BY TotalSleepRecords;


------------------------
--  Data Count Check  --
------------------------

-- 24 unique users, and 31 unique dates
-- Not all users participated in tracking sleep
-- 410 total records, not all participating users track everyday [further data exploration]

SELECT
  COUNT(*) AS total_records,
  COUNT(DISTINCT Id) AS total_unique_id,
  COUNT(DISTINCT SleepDay) AS total_unique_date
FROM Project_Bellabeat..sleepDay;


-- Only 3 users tracked their sleep data for all 31 days

WITH Users AS (
  SELECT Id, COUNT(SleepDay) AS days_tracked
  FROM Project_Bellabeat..sleepDay
  GROUP BY Id
  --ORDER BY Id
)

SELECT days_tracked, COUNT(*) AS user_count
FROM Users
GROUP BY days_tracked
ORDER BY days_tracked DESC;


-- 19 out of 24 users did not track their data in running days
-- For older fitbits and most “pocket” models, you have to press a button.
-- https://www.quora.com/How-does-Fitbit-figure-out-that-Im-sleeping

WITH RunningDate AS (
  SELECT
    Id,
    SleepDay,
    LAG(SleepDay, 1) OVER(PARTITION BY Id ORDER BY Id ASC) AS SleepDayLag
  FROM Project_Bellabeat..sleepDay
)

--SELECT date_diff, COUNT(*) AS num
SELECT COUNT(DISTINCT Id) AS user_count
FROM (
  SELECT *, DATEDIFF(day, SleepDayLag, SleepDay) AS date_diff
  FROM RunningDate
  ) AS DateDiffCheck
WHERE date_diff <> 1;
--GROUP BY date_diff;


------------------------
--  Data Range Check  --
------------------------

-- Checked using summary() in R

-- Steps and Distance
-- Observation: total_sleep_minutes_max = 796min = 13.3 hours
-- Observation: total_sleep_minutes_min = 58min = 0.97 hours
-- Observation: total_bed_minutes_max = 961mins = 16 hours
-- Observation: total_bed_minutes_min = 61mins = 1.02 hours

SELECT
  MAX(TotalMinutesAsleep) AS total_sleep_minutes_max,
  MIN(TotalMinutesAsleep) AS total_sleep_minutes_min,
  MAX(TotalTimeInBed) AS total_bed_minutes_max,
  MIN(TotalTimeInBed) AS total_bed_minutes_min
FROM Project_Bellabeat..sleepDay;


-------------------
--  Export Data  --
-------------------

-- Export table with all records and fields

SELECT *
FROM Project_Bellabeat..sleepDay;