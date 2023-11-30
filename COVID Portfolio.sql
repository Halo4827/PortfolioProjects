/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject3..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject3..CovidDeaths
ORDER BY 1,2

--Total Cases vs Total Deaths
--Shows possibility of dying if you contract COVID in specify country

SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM PortfolioProject3..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, total_cases, Population, (total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject3..CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population) * 100) AS PercentPopulationInfected
FROM PortfolioProject3..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Countries with Highest Death Count per Population

SELECT Location, SUM(CAST(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject3..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per Population

SELECT continent, SUM(CAST(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject3..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(New_Cases)*100) as DeathPercentage
FROM PortfolioProject3..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Total Population vs Vaccinations 

-- WITH USE CTE

WITH PopvsVAc (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVAccinated)
AS (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject3..CovidDeaths dea
	JOIN PortfolioProject3..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM PopvsVac

-- TEMP TABLE to perform Calculation on Partition By in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject3..CovidDeaths dea
	JOIN PortfolioProject3..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVacinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject3..CovidDeaths dea
	JOIN PortfolioProject3..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL


SELECT * FROM PercentPopulationVacinated