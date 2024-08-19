

select location, date ,total_cases, new_cases,total_deaths,population
from Portfolio..CovidDeaths
WHERE continent is not null
order by 1,2

--Looking at total cases vs total deaths

select location,date ,total_cases,total_deaths,(total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage
from Portfolio..CovidDeaths 
WHERE continent is not null
order by 1,2

--Looking at total cases vs population 
select location , date , total_cases , population , (total_cases/NULLIF(population,0))*100 as ContractedPrecentage
from Portfolio..CovidDeaths
WHERE continent is not null
--Looking at countries with highest infection Rate compared to population

select location , date, population ,MAX(population) as HighestDensity, MAX(NULLIF(total_cases,0)) as HighestInfectionCount
from Portfolio..CovidDeaths
WHERE continent is not null
Group by location , population , date
order by HighestInfectionCount desc

--Showing countries with highest death count per population 
 SELECT location ,  MAX(total_deaths) AS HighestDeaths 
 FROM Portfolio..CovidDeaths
 WHERE continent is not null
 GROUP BY location  
 ORDER BY HighestDeaths DESC

 --Showing highest death counts by continetns

 SELECT continent , MAX(total_deaths) AS HighestDeaths
 FROM Portfolio..CovidDeaths
 WHERE continent is not null 
 GROUP BY continent
 ORDER BY HighestDeaths DESC

--Join two tables and looking at total population vs new vaccination 
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
 FROM Portfolio..CovidDeaths dea
 JOIN Portfolio..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
   WHERE dea.continent is not null 
   AND vac.new_vaccinations is not null
   ORDER BY 1,2

 --Sum Total vaccination by location
 --CTE
 With popvsvac (location,continent,date,population,new_vaccinations,vaccinatedpeople)
 as
 (
 SELECT 
 dea.location,
 dea.continent, 
 dea.date, 
 dea.population,
 vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS BIGINT)) 
   OVER (PARTITION BY dea.location ORDER BY dea.date,dea.location) AS vaccinatedpeople
 FROM 
  Portfolio..CovidDeaths dea 
 JOIN 
  Portfolio..CovidVaccinations vac 
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE 
  vac.new_vaccinations is not null
  AND dea.continent is not null
 )

 SELECT * ,(vaccinatedpeople/NULLIF(population,0))*100
 FROM popvsvac



 --TEMP Table
 DROP TABLE IF EXISTS #percentpopulationvaccinated
 CREATE TABLE #percentpopulationvaccinated
 (
 location nvarchar(255),
 continent nvarchar(255),
 date datetime,
 population numeric,
 new_vaccination numeric,
 vaccinatedpeople numeric
 )

 INSERT INTO #percentpopulationvaccinated
  SELECT 
 dea.location,
 dea.continent, 
 dea.date, 
 dea.population,
 vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS BIGINT)) 
   OVER (PARTITION BY dea.location ORDER BY dea.date,dea.location) AS vaccinatedpeople
 FROM 
  Portfolio..CovidDeaths dea 
 JOIN 
  Portfolio..CovidVaccinations vac 
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE 
  vac.new_vaccinations is not null
  AND dea.continent is not null
 

 SELECT * ,(vaccinatedpeople/NULLIF(population,0))*100
 FROM #percentpopulationvaccinated


 --Create view #percentpopulationvaccinated
 CREATE VIEW percentpopulationvaccinated
 as 
SELECT 
 dea.location,
 dea.continent, 
 dea.date, 
 dea.population,
 vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS BIGINT)) 
   OVER (PARTITION BY dea.location ORDER BY dea.date,dea.location) AS vaccinatedpeople
 FROM 
  Portfolio..CovidDeaths dea 
 JOIN 
  Portfolio..CovidVaccinations vac 
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE 
  vac.new_vaccinations is not null
  AND dea.continent is not null
 

 SELECT * 
 FROM percentpopulationvaccinated
