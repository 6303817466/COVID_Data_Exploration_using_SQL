--SELECT * FROM 
--PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT * FROM 
PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

-- SELECT DATA THAT WE ARE GOING TO BE USING 

SELECT Location, date , total_cases , new_cases , total_deaths , population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total cases vd Total Deaths

-- Shows likelihood of dying if you contract covid in your country

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases FLOAT

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths FLOAT

SELECT Location, date , total_cases , total_deaths , (total_deaths/total_cases)*100 AS DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%india%'
AND continent is not null
ORDER BY 1,2

--Looking at total cases vs Population
-- Shows what  percentage of population got covid

SELECT Location , date , total_cases , population , (total_cases / population) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%india%'
WHERE continent is not null
ORDER BY 1,2

-- Looking at countries with highest Infection Rate compared to population

SELECT Location , population , MAX(total_cases) AS HighestInfectionCount , MAX((total_cases / population) )* 100 AS PercentPopulationInfect
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%india%'
WHERE continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationInfect DESC

--Showing the countries with the higest death count per percentage

SELECT Location , MAx(total_deaths) AS Total_deaths
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%india%'
WHERE continent is not null
GROUP BY Location
ORDER BY Total_deaths DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing th continents with the highest count per population

SELECT continent , MAx(total_deaths) AS Total_deaths
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%india%'
WHERE continent is not null
GROUP BY continent
ORDER BY Total_deaths DESC


-- Global NUmbers 

SELECT   SUM(new_cases) , SUM(new_deaths),
(CASE WHEN SUM(new_cases) > 0 THEN SUM(new_deaths) / SUM(new_cases) ELSE SUM(new_deaths) /1 END) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%india%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Lokking at Total Population vs Vaccinations

SELECT dea.continent,dea.location,dea.date, dea.population , vac.new_vaccinations , 
SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
AS RollingPeopleVaccinated
-- RollingPeopleVaccinated/population * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.Location = vac.Location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY  1,2,3

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date, dea.population , vac.new_vaccinations , 
SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
AS RollingPeopleVaccinated
-- RollingPeopleVaccinated/population * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.Location = vac.Location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  1,2,3

)
SELECT * , (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date, dea.population , vac.new_vaccinations , 
SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
AS RollingPeopleVaccinated
-- RollingPeopleVaccinated/population * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.Location = vac.Location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  1,2,3

SELECT * , (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visulization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date, dea.population , vac.new_vaccinations , 
SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
AS RollingPeopleVaccinated
-- RollingPeopleVaccinated/population * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.Location = vac.Location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  1,2,3

SELECT * 
FROM PercentPopulationVaccinated
