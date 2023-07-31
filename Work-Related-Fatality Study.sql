select * 
from fatalities_cleaned 

SELECT COUNT(*) AS total_incidents FROM fatalities_cleaned;

-- Calculate the year-to-year percentage changes in the number of fatalities
SELECT YEAR(incident_date) AS Year, 
       COUNT(*) AS Incidents,
       ROUND((COUNT(*) - LAG(COUNT(*), 1) OVER(ORDER BY YEAR(incident_date))) / LAG(COUNT(*), 1) OVER(ORDER BY YEAR(incident_date)) * 100) AS Yearly_Change_Percentage
FROM fatalities_cleaned
WHERE YEAR(incident_date) <> 2022
GROUP BY Year;

--Calculate the year-to-year percentage changes in the number of fatalities
-------------------------------------------------------------
WITH t1 AS (
	SELECT EXTRACT(year from incident_date) AS incident_year, 
		 
		count(*) AS n_fatalities
	FROM 
		fatalities_cleaned
	GROUP BY 
		incident_year
	ORDER BY incident_year
)

SELECT
	incident_year,
	n_fatalities,
	lag(n_fatalities) OVER () AS previous_year,
	round(((n_fatalities / lag(n_fatalities) OVER ()) - 1) * 100) AS year_to_year
FROM t1
WHERE incident_year != '2022';

----------------------------------------------------------------------------------

-- Calculate the total number of fatalities that received a citation
SELECT COUNT(*) AS citation_received FROM fatalities_cleaned WHERE citation IS NOT NULL;

-- Calculate day of the week with most fatalities
SELECT day_of_week, 
       COUNT(*) AS fatalities_count, 
       ROUND((COUNT(*) / (SELECT COUNT(*) FROM fatalities_cleaned)) * 100, 2) AS Percentage 
FROM fatalities_cleaned 
GROUP BY day_of_week 
ORDER BY fatalities_count DESC LIMIT 1;

-------------------------------
-- Calculate day of the week with most fatalities
SELECT
	day_of_week, 
	n_fatalities,
	round(n_fatalities / sum(sum(n_fatalities)) OVER () * 100, 2) AS percentage
from
	(SELECT
		day_of_week,
		count(*) AS n_fatalities
	FROM 
		fatalities_cleaned
	GROUP BY 
		day_of_week) AS tmp
GROUP BY
	day_of_week,
	n_fatalities
ORDER BY 
	n_fatalities desc;
------------------------------------

-- Calculate the total number of fatalities during welding
SELECT COUNT(*) AS welding_fatalities FROM fatalities_cleaned WHERE description LIKE '%welding%';

-- Fetch the last 5 fatalities during welding
SELECT * FROM fatalities_cleaned WHERE description LIKE '%welding%' ORDER BY incident_date DESC LIMIT 5;

-- Top 5 states with most fatal incidents
SELECT state, COUNT(*) AS fatal_incidents FROM fatalities_cleaned GROUP BY state ORDER BY fatal_incidents DESC LIMIT 5;

-- Top 5 states with most fatal incidents from stabbings
SELECT state, COUNT(*) AS stabbing_fatalities FROM fatalities_cleaned WHERE description LIKE '%stabbing%' GROUP BY state ORDER BY stabbing_fatalities DESC LIMIT 5;

-- Top 10 states with most fatal incidents from shootings
SELECT state, COUNT(*) AS shooting_fatalities FROM fatalities_cleaned WHERE description LIKE '%shooting%' GROUP BY state ORDER BY shooting_fatalities DESC LIMIT 10;

-- Total number of shooting deaths per year
SELECT YEAR(incident_date) AS Year, COUNT(*) AS shooting_deaths FROM fatalities_cleaned WHERE description LIKE '%shooting%' GROUP BY YEAR(incident_date) ORDER BY shooting_deaths DESC;


--Note: Download the 'fatalities_cleaned.csv' datasets and ensure that the database connection details are updated in the "db.py" file before executing the SQL queries.