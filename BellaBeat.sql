/*
This is to see if there are any null data with the data sets we will be examining
*/
SELECT
	*
FROM
	dailyActivity_merged
WHERE
	Id IS NULL OR
	TotalSteps IS NULL OR
	ActivityDate IS NULL OR
	Calories IS NULL OR
	SedentaryMinutes IS NULL OR
	LightActiveDistance IS NULL OR
	FairlyActiveMinutes IS NULL OR
	VeryActiveMinutes IS NULL;

SELECT
	*
FROM 
	sleepDay_merged
WHERE
	Id IS NULL OR
	SleepDay IS NULL OR
	TotalSleepRecords IS NULL OR
	TotalMinutesAsleep IS NULL OR
	TotalTimeInBed IS NULL;
	
SELECT
	* 
FROM 
	weightLogInfo_merged
WHERE
	Id IS NULL OR
	WHERE
	Id IS NULL OR
	Date IS NULL OR
	WeightKg IS NULL OR
	WeightPounds IS NULL OR
	Fat IS NULL OR
	BMI IS NULL OR
	IsManualReport IS NULL OR
	LogId IS NULL;

/*
This is to see how many users are participating. There are 33 users within the daily activity table.
*/
SELECT
	COUNT(DISTINCT ID) AS total_users
FROM
	dailyActivity_merged;

/*
This is to see the timeframe of the project. It goes on for a month
*/
SELECT
	MIN(ActivityDate) AS beginning_date,
	MAX(ActivityDate) AS ending_date
FROM
	dailyActivity_merged;

/*
These next few are to see how many are in the sleep day and weight log files. The amount of users in both files is both lower
than the original file, with the sleep day file only having 24 and the weight log only having 8. Because the weight log is substantially
lower, we will be voiding it for this analysis.
*/
SELECT
	COUNT(DISTINCT Id) AS total_users
FROM
	sleepDay_merged;

SELECT
	COUNT(DISTINCT Id) AS total_users
FROM
	weightLogInfo_merged;

/*
This is to see the total recorded times a user has slept or inputted their weight. The results are mixed, less than 50% of users recorded their
sleep over 20 times and only one user manually inputted their weight consistently. 
*/
SELECT
	Id,
	COUNT(TotalSleepRecords) AS total_sleep_counted
FROM
	sleepDay_merged
GROUP BY
	Id

SELECT
	Id,
	COUNT(IsManualReport) AS manual_input_count
FROM 
	weightLogInfo_merged
WHERE
	IsManualReport = 1
GROUP BY 
	Id;

/*
This is to see how many times a user has logged their steps. Most range within the 20-30 range with the exception
of few users, one of which only has 4 records. The other 2 are fairly close with 18 and 19 records.
*/
SELECT
	Id,
	COUNT(ActivityDate) AS total_records
FROM	
	dailyActivity_merged
GROUP BY
	Id;

/*
This is to see the overall average minutes among each user
*/
SELECT
	AVG(act.VeryActiveMinutes) AS avg_very_active_minutes,
	AVG(act.FairlyActiveMinutes) AS avg_moderate_minutes,
	AVG(act.LightlyActiveMinutes) AS avg_light_minutes,
	AVG(act.SedentaryMinutes) AS avg_sedentary_minutes,
	AVG(act.SedentaryMinutes + act.LightlyActiveMinutes + act.FairlyActiveMinutes + act.VeryActiveMinutes) AS avg_total_minutes
FROM 
	dailyActivity_merged act

/*
This is to see the day-by-day trends users have with intensity
*/
SELECT
	ActivityDate,
	AVG(VeryActiveMinutes) AS avg_very_active_minutes,
	AVG(FairlyActiveMinutes) AS avg_moderate_minutes,
	AVG(LightlyActiveMinutes) AS avg_light_minutes,
	AVG(SedentaryMinutes) AS avg_sedentary_minutes
FROM
	dailyActivity_merged
GROUP BY
	ActivityDate
/*
The purpose of this table is to see if there is a correlation between how active the user is and their time in bed or their time spent sleeping.
To do this, we will get the average for each variable for the respective user. 
*/
SELECT
	act.Id,
	AVG(act.TotalSteps) AS avg_total_steps,
	AVG(act.VeryActiveMinutes) AS avg_very_active_minutes,
	AVG(act.FairlyActiveMinutes) AS avg_moderate_minutes,
	AVG(act.LightlyActiveMinutes) AS avg_light_minutes,
	AVG(act.SedentaryMinutes) AS avg_sedentary_minutes,
	AVG(act.SedentaryMinutes + act.LightlyActiveMinutes + act.FairlyActiveMinutes + act.VeryActiveMinutes) AS avg_total_minutes,
	AVG(act.Calories) AS avg_calories_burned,
	AVG(sleep.TotalMinutesAsleep) AS avg_sleep_time,
	AVG(sleep.TotalTimeInBed) AS avg_time_in_bed
FROM
	sleepDay_merged sleep
	JOIN dailyActivity_merged act
	ON sleep.Id = act.Id
WHERE
	Calories > 100 AND
	TotalSteps > 100
GROUP BY act.Id;

/*
Creating two temporary tables to see the average amount users sleep and were active on different weekdays, starting with the activity table.
We will group them by weekday to make the analysis easier.
*/
SELECT 
	DATENAME(Weekday,ActivityDate) AS Weekday,
	AVG(TotalSteps) AS avg_total_steps,
	AVG(VeryActiveMinutes) AS avg_very_active_minutes,
	AVG(FairlyActiveMinutes) AS avg_moderate_minutes,
	AVG(LightlyActiveMinutes) AS avg_light_minutes,
	AVG(SedentaryMinutes) AS avg_sedentary_minutes,
	AVG(Calories) AS avg_calories_burned
INTO
	Avg_Activity
FROM
	dailyActivity_merged
GROUP BY
	DATENAME(Weekday,ActivityDate);

/*
Now we will do the sleep table, getting the average sleep times and times in bed.
*/
SELECT
	DATENAME(Weekday, SleepDay) AS Weekday,
	AVG(TotalMinutesAsleep) AS avg_minutes_asleep,
	AVG(TotalTimeInBed) AS avg_minutes_in_bed
INTO
	Avg_Sleeptime
FROM 
	sleepDay_merged
GROUP BY
	DATENAME(Weekday,SleepDay);

/*
Now we will merge the two temporary tables together to see the variables for each weekday.
*/
SELECT
	a.Weekday,
	a.avg_total_steps,
	a.avg_very_active_minutes,
	a.avg_moderate_minutes,
	a.avg_light_minutes,
	a.avg_sedentary_minutes,
	a.avg_calories_burned,
	b.avg_minutes_asleep,
	b.avg_minutes_in_bed
FROM
	Avg_Activity a
	JOIN Avg_Sleeptime b
	ON a.Weekday = b.Weekday
ORDER BY
	Weekday DESC

DROP TABLE Avg_Activity
DROP TABLE Avg_Sleeptime;
