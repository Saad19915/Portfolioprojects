


SELECT *
FROM PortfolioProject..CovidDeaths
WHERE Continent is not Null
ORDER BY 3,4



SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

---Select data that we are going to be using 

SELECT Location, date, total_cases, new_Cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE Continent is not Null
ORDER BY 1 ,2

---Looking at total Cases VS Total Death 
---Showing likelihood of dying if you contract Covid in your Country

SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location IN ('Germany', 'United States')
and Continent is not Null
ORDER BY 1, 2

---Looking at Total Cases VS Population 
---Showing what percentage of population got Covid

SELECT Location, date, total_cases,population,(total_cases/Population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location IN ('United States','Germany')
ORDER BY 1 DESC,2

---Showing the Countries with highest infection Rate compared to Population 

SELECT location,population,MAX (total_cases)AS HighestInfectionCount,(MAX(total_cases)/Population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
--HAVING location IN ('United States','Germany')
ORDER BY PercentPopulationInfected DESC


---Showing Continent with highest death count Perīpopulation

SELECT Continent, MAX(cast(total_deaths as int))AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
GROUP BY Continent
ORDER BY 2 DESC


----Showing Total cases, total death and percentag of death from infected cases per date

SELECT date, SUM(new_cases)as TotalCases,SUM(cast(new_deaths as int))as TotalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent is not Null
GROUP BY date
ORDER BY 1,2

---- showing total cases, total death and percentage of death globaly in general 

SELECT SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int))as TotalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent is not Null
--GROUP BY date
ORDER BY 1,2

----Looking at total population vs Vaccination

SELECT dea.Continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.date, dea.location) as RollingPeopleVaccinated
From PortfolioProject. .CovidDeaths dea
join PortfolioProject. .CovidVaccinations vac
on dea.Location = vac.Location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

---USE CTE

WITH PopvsVac as(
SELECT dea.Continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.date, dea.location) as RollingPeopleVaccinated
From PortfolioProject. .CovidDeaths dea
join PortfolioProject. .CovidVaccinations vac
on dea.Location = vac.Location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


---TEMP TABLE 


DROP TABLE if exists #Percentpopulationvaccinated
CREATE TABLE #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric, 
new_Vaccination numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #Percentpopulationvaccinated
SELECT dea.Continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject. .CovidDeaths dea
join PortfolioProject. .CovidVaccinations vac
	on dea.Location = vac.Location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #Percentpopulationvaccinated


---Creating View to store data for later visualisation


CREATE View Percentpopulationvaccinated 
as

SELECT dea.Continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,

SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject. .CovidDeaths dea
join PortfolioProject. .CovidVaccinations vac
	on dea.Location = vac.Location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
from Percentpopulationvaccinated