--Covid-19

--SELECT *
--FROM CovidDeaths
--WHERE continent_norm is NOT NULL
--ORDER BY 3, 4;

--SELECT * 
--FROM CovidVaccinations
--ORDER BY 3,4;

--ALTER TABLE CovidVaccinations
--ALTER COLUMN new_vaccinations bigint;


-- Column Selection:
SELECT continent_norm, location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
WHERE continent_norm is NOT NULL
ORDER BY location, date;

-- Total Cases vs Total Deaths:
--SELECT location, date, total_cases, total_deaths,
--    CASE 
--        WHEN total_cases = 0 THEN NULL -- Avoid's zero division error
--        ELSE (total_deaths * 1.0 / total_cases) * 100 -- Calculate death rate
--    END AS death_rate
--FROM CovidDeaths
--WHERE continent_norm is NOT NULL

(-- OR--)
--Also the likelihood of dying in your specific country
SELECT location, date, total_cases, total_deaths,
(total_deaths / NULLIF(total_cases * 1.0, 0)) * 100 AS death_rate
FROM CovidDeaths
WHERE location = 'India' AND continent_norm is NOT NULL
ORDER BY location, date;

--Total_cases vs the Population
--Percentage of Population that got covid:
SELECT location, date, total_cases, population, 
(total_cases / (population * 1.0)) * 100 AS Population_Infected_Percentage
FROM CovidDeaths
WHERE location = 'India' AND continent_norm is NOT NULL
ORDER BY location, date;

--Countries with Highest Infection Rate compared to Population:
SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, 
MAX((total_cases / (population * 1.0))) * 100 AS Highest_Infection_Rate
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent_norm is NOT NULL
GROUP BY location, population
ORDER BY Highest_Infection_Rate DESC;

--Countries with Highest Death count per Population:
SELECT location, population, MAX(total_deaths) AS Highest_Death_count
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent_norm is NOT NULL
GROUP BY location, population
ORDER BY Highest_Death_count DESC;

--Highest Death count by Continents:
SELECT continent_norm, MAX(total_deaths) AS Highest_Death_count
FROM CovidDeaths
WHERE continent_norm is NOT NULL
GROUP BY continent_norm
ORDER BY Highest_Death_count DESC;

--[Maybe correct continent records but mixed with inncorect rows of location]:
--SELECT location, MAX(total_deaths) AS Highest_Death_count
--FROM CovidDeaths
--WHERE continent_norm is NULL
--GROUP BY location
--ORDER BY Highest_Death_count DESC;

-------------------------------------------------------------------------------------

--Global Numbers:
SELECT date, location, SUM(new_cases) AS Global_Cases, SUM(new_deaths) AS Global_Deaths,
SUM(new_deaths)/NULLIF(SUM(new_cases) * 1.0, 0) * 100 AS Global_Death_Percentage
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent_norm is NOT NULL
GROUP BY date, location
ORDER BY date, location;

--Total Global Cases, Deaths and Death Percentage
SELECT SUM(new_cases) AS Tot_Global_Cases, SUM(new_deaths) AS Tot_Global_Deaths,
SUM(new_deaths)/NULLIF(SUM(new_cases) * 1.0, 0) * 100 AS Global_Death_Percentage_Tot
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent_norm is NOT NULL


--Looking at Total Population vs Vaccinations:

SELECT dea.continent_norm, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Vaccination_Count
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent_norm is NOT NULL
ORDER BY 2,3;

--Using CTE to calculate how many people are vaccinated:
WITH PopVacc (continent_norm, location, date, population, new_vaccinations, Rolling_Vaccination_Count)
AS
(
SELECT dea.continent_norm, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Vaccination_Count
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent_norm is NOT NULL
--ORDER BY 2,3;
)
SELECT *, (Rolling_Vaccination_Count/(population * 1.0)) * 100 AS People_Vaccinated_Percentage
FROM PopVacc
WHERE location like 'Alban%'

--via Temp table:

--DROP TABLE if exists #Percent_Population_vaccinated 
--CREATE TABLE #Percent_Population_vaccinated
--(
--continent_norm nvarchar(255),
--location nvarchar(255),
--date datetime,
--population numeric, 
--new_vaccinations numeric, 
--Rolling_Vaccination_Count numeric
)

--INSERT INTO #Percent_Population_vaccinated
--SELECT dea.continent_norm, dea.location, dea.date, dea.population, vac.new_vaccinations,
--SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Vaccination_Count
--FROM CovidDeaths AS dea
--JOIN CovidVaccinations AS vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent_norm is NOT NULL
----ORDER BY 2,3;

SELECT *, (Rolling_Vaccination_Count/(population * 1.0)) * 100 AS People_Vaccinated_Percentage
FROM #Percent_Population_vaccinated

--Creating a view for later visulizations:
CREATE VIEW Percent_Population_vaccinated AS 
SELECT dea.continent_norm, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Vaccination_Count
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent_norm is NOT NULL
--ORDER BY 2,3;

SELECT * FROM Percent_Population_vaccinated