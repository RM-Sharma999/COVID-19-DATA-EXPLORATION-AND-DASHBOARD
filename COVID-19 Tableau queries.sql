/*

Queries used for Tableau Project

*/

-- 1. 
-- Almost Global Numbers, but perfect for use:
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases) * 1.0, 0) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent_norm is NOT NULL 
--Group By date
ORDER BY 1,2;


-- True Global Numbers, but not usable:

--SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
--SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases) * 1.0, 0) * 100 as DeathPercentage
--FROM PortfolioProject..CovidDeaths
----WHERE location = 'India'
--WHERE location = 'World'
----Group By date
--order by 1,2

-- 2.

SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent_norm is null 
and location not in ('World', 'European Union','High Income','Upper middle income','lower middle income','low income')
Group by location
order by TotalDeathCount desc

-- 3.
SELECT location, population, MAX(total_cases) as Highest_Infection_Count,
MAX((total_cases / (population * 1.0))) * 100 AS Highest_Infection_Rate
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
Group by location, population
order by Highest_Infection_Rate desc

-- 4. 
SELECT location, population, date, MAX(total_cases) as Highest_Infection_Count,
MAX((total_cases / (population * 1.0))) * 100 AS Highest_Infection_Rate
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
Group by location, population, date
order by Highest_Infection_Rate desc

-- 5.
-- Using CTE to calculate how many people are fully vaccinated:
WITH FullVacc (continent_norm, location, date, population, new_vaccinations, Full_Vaccination_Count)
AS
(
SELECT dea.continent_norm, dea.location, dea.date, dea.population, vac.new_vaccinations,
LEAST(SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date), 2 * dea.population) AS Full_Vaccination_Count
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent_norm is NOT NULL
-- ORDER BY 2,3;
)
SELECT *, (Full_Vaccination_Count/(population * 2.0)) * 100 AS Full_Vaccination_Percentage
FROM FullVacc;
-- ORDER BY Full_Vaccination_Percentage DESC;

--6.
-- Using CTE to calculate how many people are fully vaccinated, including first and second doses:
WITH FullVacc (continent_norm, location, date, population, new_vaccinations, Full_Vaccination_Count)
AS
(
SELECT dea.continent_norm, dea.location, dea.date, dea.population, vac.new_vaccinations,
LEAST(SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date), 2 * dea.population) AS Full_Vaccination_Count
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent_norm is NOT NULL
-- ORDER BY 2,3;
)
SELECT *, 
CASE WHEN Full_Vaccination_Count <= 1417173120 THEN Full_Vaccination_Count
ELSE 1417173120
END AS First_Dose_Administered, 
CASE WHEN Full_Vaccination_Count > 1417173120 THEN Full_Vaccination_Count - 1417173120
ELSE 0
END AS Second_Dose_Administered, 
(Full_Vaccination_Count/(population * 2.0)) * 100 AS Full_Vaccination_Percentage
FROM FullVacc
WHERE location = 'India';
-- ORDER BY Full_Vaccination_Percentage DESC;
