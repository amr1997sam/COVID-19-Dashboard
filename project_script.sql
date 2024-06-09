-- UPDATING SECTION
-- --
-- already update the date in covid_deaths table
UPDATE vaccination_data 
SET date = STR_TO_DATE(date, '%d/%m/%Y');

UPDATE covid_deaths
SET continent = NULL
WHERE continent = 'NULL';

UPDATE covid_deaths
SET 
    iso_code = CASE WHEN iso_code = 'NULL' THEN NULL ELSE iso_code END,
    continent = CASE WHEN continent = 'NULL' THEN NULL ELSE continent END,
    location = CASE WHEN location = 'NULL' THEN NULL ELSE location END,
    date = CASE WHEN date = 'NULL' THEN NULL ELSE date END,
    population = CASE WHEN population = 'NULL' THEN NULL ELSE population END,
    population_density = CASE WHEN population_density = 'NULL' THEN NULL ELSE population_density END,
    total_cases = CASE WHEN total_cases = 'NULL' THEN NULL ELSE total_cases END,
    new_cases = CASE WHEN new_cases = 'NULL' THEN NULL ELSE new_cases END,
    total_deaths = CASE WHEN total_deaths = 'NULL' THEN NULL ELSE total_deaths END,
    new_deaths = CASE WHEN new_deaths = 'NULL' THEN NULL ELSE new_deaths END,
    reproduction_rate = CASE WHEN reproduction_rate = 'NULL' THEN NULL ELSE reproduction_rate END,
    gdp_per_capita = CASE WHEN gdp_per_capita = 'NULL' THEN NULL ELSE gdp_per_capita END,
    life_expectancy = CASE WHEN life_expectancy = 'NULL' THEN NULL ELSE life_expectancy END,
    human_development_index = CASE WHEN human_development_index = 'NULL' THEN NULL ELSE human_development_index END;

ALTER TABLE covid_deaths
MODIFY total_cases INT;

ALTER TABLE covid_deaths ADD COLUMN date_backup VARCHAR(255);
UPDATE covid_deaths SET date_backup = date;

ALTER TABLE covid_deaths 
MODIFY date DATE;

ALTER TABLE covid_deaths 
MODIFY date_backup VARCHAR(255) AFTER date;

ALTER TABLE covid_deaths 
DROP date_backup;



-- MONITORING SECTION
-- --
SELECT * FROM coronavirus_covid_19_deaths_db.covid_deaths
ORDER BY 3,4;


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as tot_death_rate
FROM coronavirus_covid_19_deaths_db.covid_deaths
WHERE location LIKE '%egypt%'
ORDER BY 2;

SELECT location, MAX(cast(total_deaths as double)) as tot_deaths, MAX(CAST(total_cases AS DOUBLE))/MAX(CAST(population AS DOUBLE))*100 as infection_rate
FROM coronavirus_covid_19_deaths_db.covid_deaths
GROUP BY location
-- WHERE location LIKE '%egypt%'
ORDER BY infection_rate DESC;

SELECT location, population, MAX(CAST(total_cases AS DOUBLE)) AS max_infection, MAX(CAST(total_cases AS DOUBLE))/MAX(CAST(population AS DOUBLE))*100 as infection_percentage,
MAX(CAST(total_deaths AS DOUBLE))/MAX(CAST(population AS DOUBLE))*100 AS death_percentage
FROM coronavirus_covid_19_deaths_db.covid_deaths
GROUP BY location, population
ORDER BY death_percentage DESC, infection_percentage DESC;


-- compare total cases vs total deaths vs total vacination for each country
SELECT dth.location, sum(cast(new_cases as double)) as tot_cases, sum(cast(new_deaths as double)) as tot_deaths, sum(cast(people_vaccinated as double)) as tot_vaccinated
FROM coronavirus_covid_19_deaths_db.covid_deaths as dth
JOIN coronavirus_covid_19_deaths_db.vaccination_data as vacc
	ON dth.location = vacc.location
	AND dth.date = vacc.date
WHERE dth.continent !="NULL"
GROUP BY dth.location
ORDER BY tot_deaths DESC, tot_vaccinated DESC;    

SELECT dth.location, sum(cast(new_cases as double)) as tot_cases, sum(cast(new_deaths as double)) as tot_deaths, sum(cast(people_vaccinated as double)) as tot_vaccinated
FROM coronavirus_covid_19_deaths_db.covid_deaths as dth
JOIN coronavirus_covid_19_deaths_db.vaccination_data as vacc
	ON dth.location = vacc.location
	AND dth.date = vacc.date
WHERE dth.continent !="NULL" AND dth.location LIKE '%egypt%'
GROUP BY dth.location;

SELECT *
FROM covid_deaths;

-- checking if there is some values which cannot be integer 
SELECT total_cases
FROM covid_deaths
WHERE CAST(total_cases AS SIGNED) IS NULL AND total_cases IS NOT NULL;

SELECT DAY(date) AS day_part
FROM covid_deaths;

SELECT location, life_expectancy, MAX(total_deaths)/ MAX(total_cases) as death_percentage
FROM covid_deaths
WHERE continent is NOT NULL AND life_expectancy IS NOT NULL
GROUP BY location, life_expectancy
ORDER BY 2;