/*
Project: Google Data Analytics Capstone Project, Case Study 2
Activity: Data Cleaning
Dataset: FitBit Fitness Tracker Data (Kaggle)
Table: dailyActivity_merged.csv
Analyst: Lin Jiaming
Date: 30 May 2021
*/


--------------------------
--  Create Backup Copy  --
--------------------------

SELECT *
INTO dailyActivity_Backup
FROM dailyActivity;


---------------------------
--  Column Header Check  --
---------------------------

SELECT *
FROM Project_Bellabeat..dailyActivity;


-----------------------
--  Data Type Check  --
-----------------------

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dailyActivity';


-- Convert ActivityDate data type from datetime to date

ALTER TABLE dailyActivity
ALTER COLUMN ActivityDate date;


----------------------------
--  Missing Values Check  --
----------------------------

-- Checked using skim_without_charts() in R
-- No missing values found
-- Inefficient to check multiple columns in SQL

SELECT *
FROM Project_Bellabeat..dailyActivity
WHERE Id IS NULL
  OR ActivityDate IS NULL
  OR TotalSteps IS NULL;


------------------------
--  Duplicates Check  --
------------------------

-- No duplicates found

WITH DupCheck AS (
  SELECT
    Id,
	ActivityDate,
	ROW_NUMBER() OVER(PARTITION BY Id, ActivityDate ORDER BY Id ASC) AS row_num
  FROM Project_Bellabeat..dailyActivity
)

SELECT row_num, COUNT(*) AS num
FROM DupCheck
GROUP BY row_num;


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

SELECT MIN(ActivityDate) AS earliest_date, MAX(ActivityDate) AS lastest_date
FROM Project_Bellabeat..dailyActivity;


----------------------------
--  Categorization Check  --
----------------------------

-- Not applicable


------------------------
--  Data Count Check  --
------------------------

-- 33 unique users, and 31 unique dates
-- 940 total records, not all users track everyday [further data exploration]

SELECT
  COUNT(*) AS total_records,
  COUNT(DISTINCT Id) AS total_unique_id,
  COUNT(DISTINCT ActivityDate) AS total_unique_date
FROM Project_Bellabeat..dailyActivity;


-- Only 21 users tracked their data for all 31 days

WITH Users AS (
  SELECT Id, COUNT(ActivityDate) AS days_tracked
  FROM Project_Bellabeat..dailyActivity
  GROUP BY Id
  --ORDER BY Id
)

SELECT days_tracked, COUNT(*) AS user_count
FROM Users
GROUP BY days_tracked
ORDER BY days_tracked DESC;


-- All users track their data in running days

WITH RunningDate AS (
  SELECT
    Id,
    ActivityDate,
    LAG(ActivityDate, 1) OVER(PARTITION BY Id ORDER BY Id ASC) AS ActivityDateLag
  FROM Project_Bellabeat..dailyActivity
)

SELECT date_diff, COUNT(*) AS num
FROM (
  SELECT *, DATEDIFF(day, ActivityDateLag, ActivityDate) AS date_diff
  FROM RunningDate
  ) AS DateDiffCheck
GROUP BY date_diff;


------------------------
--  Data Range Check  --
------------------------

-- Checked using summary() in R

-- Steps and Distance
-- Observation: total_steps_min = 0, total_distance_min = 0
-- Observation: total_distance_max = 28.03

SELECT
  MAX(TotalSteps) AS total_steps_max,
  MIN(TotalSteps) AS total_steps_min,
  MAX(TotalDistance) AS total_distance_max,
  MIN(TotalDistance) AS total_distance_min,
  MAX(TrackerDistance) AS tracker_distance_max,
  MIN(TrackerDistance) AS tracker_distance_min,
  MAX(LoggedActivitiesDistance) AS logged_activities_distance_max,
  MIN(LoggedActivitiesDistance) AS logged_activities_distance_min,
  MAX(Calories) AS calories_max,
  MIN(Calories) AS calories_min
FROM Project_Bellabeat..dailyActivity;


-- Observation: There are 77 records where TotalSteps = 0
-- Observation: There are 73 records where TotalSteps = 0, but Calories <> 0
-- Exclude these records for specific analysis

SELECT *
FROM Project_Bellabeat..dailyActivity
WHERE TotalSteps = (SELECT MIN(TotalSteps) FROM Project_Bellabeat..dailyActivity)
  AND Calories <> 0;


-- Observation: There are 78 records where TotalDistance = 0
-- Observation: There are 74 records where TotalDistance = 0, but Calories <> 0
-- Exclude these records for specific analysis

SELECT *
FROM Project_Bellabeat..dailyActivity
WHERE TotalDistance = (SELECT MIN(TotalDistance) FROM Project_Bellabeat..dailyActivity)
  AND Calories <> 0;


-- There are 77 records where TotalDistance = 0 and TotalSteps = 0

(SELECT *
FROM Project_Bellabeat..dailyActivity
WHERE TotalDistance = (SELECT MIN(TotalDistance) FROM Project_Bellabeat..dailyActivity)
)
INTERSECT
(SELECT *
FROM Project_Bellabeat..dailyActivity
WHERE TotalSteps = (SELECT MIN(TotalSteps) FROM Project_Bellabeat..dailyActivity)
);


-- There are 1 records where TotalDistance = 0 and TotalSteps <> 0

(SELECT *
FROM Project_Bellabeat..dailyActivity
WHERE TotalDistance = (SELECT MIN(TotalDistance) FROM Project_Bellabeat..dailyActivity)
)
EXCEPT
(SELECT *
FROM Project_Bellabeat..dailyActivity
WHERE TotalSteps = (SELECT MIN(TotalSteps) FROM Project_Bellabeat..dailyActivity)
);


-- Investigate if max of TotalDistance make sense
-- Calculate speed to determine if TotalDistance make sense
--
-- Assume units of distance to be in km, instead of miles
-- https://dev.fitbit.com/build/reference/web-api/basics/
--
-- Fitbit definition for minutes:
--  >> SedentaryMinutes, less than 1.5 METs
--  >> LightlyActiveMinutes, between 1.5-3.0 METs
--  >> FairlyActiveMinutes, between 3.0-6.0 METs
--  >> VeryActiveMinutes, greater than 6.0 METs
-- https://community.fitbit.com/t5/Web-API-Development/Daily-Activity-Summary-Data-Definition-Questions/td-p/3087077
--
-- Wikipedia definition for MET
--  >> 1.5 METs: writing, deskwork, using computer
--  >> 2.0 METs: walking slowly
-- https://en.wikipedia.org/wiki/Metabolic_equivalent_of_task
-- Therefore, to calculate speed, one must exclude SedentaryMinutes
--
-- Speed comparison:
--  >> Average marathon runner speed (male) = 60/6.43 = 9.33 km/h
--  >> Average marathon runner speed (female) = 60/7.26 = 8.26 km/h
-- https://www.runnersworld.com/uk/training/marathon/a27787958/average-marathon-finish-time
--  >> Speed of fastest human = 37.58 km/h
-- https://www.britannica.com/story/how-fast-is-the-worlds-fastest-human
--
-- The data's max speed (VeryActive) of 10.48 km/h is reasonable
-- The data's max speed (TotalDistance) of 8.31km/h is reasonable, therefore TotalDistance is reasonable too

SELECT
  MAX(ROUND(TotalDistance / (VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) * 60,2)) AS speed_total,
  MAX(ROUND(VeryActiveDistance / IIF(VeryActiveMinutes=0,99999,VeryActiveMinutes) * 60,2)) AS speed_veryactive,
  MAX(ROUND(ModeratelyActiveDistance / IIF(FairlyActiveMinutes=0,99999,FairlyActiveMinutes) * 60,2)) AS speed_fairlyactive,
  MAX(ROUND(LightActiveDistance / IIF(LightlyActiveMinutes=0,99999,LightlyActiveMinutes) * 60,2)) AS speed_lightlyactive
FROM Project_Bellabeat..dailyActivity
WHERE VeryActiveMinutes <> 0
  OR FairlyActiveMinutes <> 0
  OR LightlyActiveMinutes <> 0;


-------------------------
--  Cross Field Check  --
-------------------------

-- Check TotalDistance vs TrackerDistance
-- Observation: There are 15 records where TotalDistance <> TrackerDistance
-- It is unclear what does TrackerDistance represents

SELECT
  Id,
  ActivityDate,
  TotalDistance,
  TrackerDistance,
  ROUND(TotalDistance - TrackerDistance,2) AS dist_diff,
  ROUND((TotalDistance - TrackerDistance)/TotalDistance*100,1) AS dist_diff_percent
FROM Project_Bellabeat..dailyActivity
WHERE TotalDistance - TrackerDistance <> 0
ORDER BY dist_diff_percent DESC;


-- Check TotalDistance vs sum of Distance
-- Observation: There are 41 records where difference between TotalDistance and sum of distance > 1%

SELECT
  *,
  ROUND(TotalDistance - dist_sum,2) AS dist_diff,
  ROUND((TotalDistance - dist_sum)/TotalDistance*100,2) AS dist_diff_percent
FROM (
  SELECT
    Id,
    ActivityDate,
    TotalDistance,
    VeryActiveDistance + ModeratelyActiveDistance + LightActiveDistance + SedentaryActiveDistance AS dist_sum
  FROM Project_Bellabeat..dailyActivity
  ) AS DistSum
WHERE TotalDistance - dist_sum <> 0
  AND ABS(ROUND((TotalDistance - dist_sum)/TotalDistance*100,2)) > 1
ORDER BY dist_diff_percent DESC, dist_diff DESC;


-- Check sum of Minutes = 1440 (24 hours * 60 minutes)
-- Observation: There are 478 records where sum of minutes = 1440
-- Observation: There are 462 records where sum of minutes <> 1440

--WITH RecordsNum AS (
  SELECT minutes_total, COUNT(*) AS num
  FROM (
    SELECT
      Id,
      ActivityDate,
      VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes AS minutes_total
    FROM Project_Bellabeat..dailyActivity
    ) AS MinutesTotal
  GROUP BY minutes_total
  ORDER BY minutes_total DESC;
--)

--SELECT SUM(num) AS records_num
--FROM RecordsNum
--WHERE minutes_total <> 1440;


-- Check sum of [Minutes in dailyActivity Table] and [TotalTimeInBed in sleepDay Table] = 1440 (24 hours * 60 minutes)
-- Observation: There are 604 records where sum of minutes = 1440
-- Observation: There are 155 records where sum of minutes > 1440
-- Observation: There are 181 records where sum of minutes < 1440
-- Investigation is needed with regards to how Fitbit measure their statistics

--WITH RecordsNum AS (
  SELECT minutes_total, COUNT(*) AS num
  FROM (
    SELECT
      act.Id,
      act.ActivityDate,
      VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes + ISNULL(TotalTimeInBed,0) AS minutes_total
    FROM Project_Bellabeat..dailyActivity AS act
    LEFT JOIN sleepDay AS slp
      ON act.Id = slp.Id AND act.ActivityDate = slp.SleepDay
    ) AS MinutesTotal
  GROUP BY minutes_total
  ORDER BY minutes_total DESC;
--)

--SELECT SUM(num) AS records_num
--FROM RecordsNum
--WHERE minutes_total > 1440;


-------------------------
--  Cross Table Check  --
-------------------------

-- Observation: All 410 keys (id and date) in sleepDay.csv, are in dailyActivity.csv

SELECT
  (SELECT COUNT(*) FROM Project_Bellabeat..dailyActivity) AS activity_cnt,
  (SELECT COUNT(*) FROM Project_Bellabeat..sleepDay) AS sleep_cnt,
  (SELECT COUNT(*)
  FROM Project_Bellabeat..dailyActivity act
  JOIN Project_Bellabeat..sleepDay slp
    ON act.Id = slp.Id AND act.ActivityDate = slp.SleepDay) AS same_records_cnt;


-------------------
--  Export Data  --
-------------------

-- Export table with all records and fields
-- Data where TotalDistance = 0 and TotalSteps = 0 will be filtered in Tableau for specific analysis

SELECT *
FROM Project_Bellabeat..dailyActivity;