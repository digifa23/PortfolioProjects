SELECT 
  continent,
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM 
  `eighth-gamma-371719.Porfolio.CDeath`
WHERE continent IS NOT NULL
ORDER BY 1,2

--SHOWING TOTAL CASES VERSUS TOTAL DEATHS AND LIKELYHOOD OF DYING IF COVID IS CONTRACTED TODAY
SELECT 
  continent,
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases)*100 AS DeathPercentage
FROM 
  `eighth-gamma-371719.Porfolio.CDeath`
WHERE location LIKE '%Nigeria' AND continent IS NOT NULL
--ORDER BY 1,2


--LOOKING AT TOTAL CASES VERSUS POPULATION
--WHAT PERCENTAGE OF POPULATION GOT COVID
SELECT 
  location,
  continent,
  date,
  total_cases,
  population,
  (total_cases/population)*100 AS PercentageOfPopulation

FROM 
  `eighth-gamma-371719.Porfolio.CDeath`
WHERE location LIKE '%Nigeria' AND continent IS NOT NULL
ORDER BY 1,2


--LOOKING AT COUNTRIES WITH THE HIGHEST INFECTION RATES
SELECT
  location,
  continent,
  population,
  MAX(total_cases) AS HighestInfectionCount,
  MAX((total_cases/population))*100 AS PercentageOfPopulation

FROM 
  `eighth-gamma-371719.Porfolio.CDeath`
WHERE continent IS NOT NULL
GROUP BY location,population,continent
ORDER BY HighestInfectionCount DESC


--COUNTRIES WITH THE GIGHEST DEATH COUNT PER POPULATION
SELECT
  location,
  continent,
  MAX(CAST(total_deaths AS INT64)) AS HighestDeathCount
FROM 
  `eighth-gamma-371719.Porfolio.CDeath`
WHERE continent IS NOT NULL
GROUP BY location,population,continent
ORDER BY HighestDeathCount DESC

--BREAKING THINGS DOWN BY CONTINENT 
--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT
SELECT
  continent,
  MAX(CAST(total_deaths AS INT64)) AS HighestDeathCount
FROM 
  `eighth-gamma-371719.Porfolio.CDeath`
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

--GLOBAL CASES
SELECT 
  date,
  SUM(new_cases) AS ToatlConfirmedCases,
  SUM(new_deaths) AS TotalConfirmedDeaths,
  SUM(new_deaths)/ SUM(new_cases) AS GlobalDeathsPercentage
FROM 
  `eighth-gamma-371719.Porfolio.CDeath`
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--JOINING THE TABLES
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM 
  `eighth-gamma-371719.Porfolio.CDeath` dea 
JOIN 
  `eighth-gamma-371719.Porfolio.CVaccinations` vac
ON 
  dea.location = vac.location 
AND 
  dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USING A CTE
WITH PopvsVac AS-- (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated) 
(
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM 
  `eighth-gamma-371719.Porfolio.CDeath` dea 
JOIN 
  `eighth-gamma-371719.Porfolio.CVaccinations` vac
ON 
  dea.location = vac.location 
AND 
  dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,(RollingPeopleVaccinated/population)*100 AS VaccinationRate
FROM  PopvsVac




--TEMPORARY TABLE
--DROP ASSIGNMENT IF EXISTS PercentagePopulationVaccinated
CREATE TEMP TABLE PercentagePopulationVaccinated AS
(
  Continent STRING(255),
  Location  STRING(255),
  Date Datetime,
  Population INT64,
  New_Vaccination INT64,
  RollingPeopleVaccinated INT64
)

INSERT INTO PercentagePopulationVaccinated(
  SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM 
  `eighth-gamma-371719.Porfolio.CDeath` dea 
JOIN 
  `eighth-gamma-371719.Porfolio.CVaccinations` vac
ON 
  dea.location = vac.location 
AND 
  dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/population)*100 AS VaccinationRate
FROM  PercentagePopulationVaccinated


--CREATING VIEW FOR LATER
CREATE VIEW `eighth-gamma-371719.Porfolio.PercentagePopulationVaccinated`
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM 
  `eighth-gamma-371719.Porfolio.CDeath` dea 
JOIN 
  `eighth-gamma-371719.Porfolio.CVaccinations` vac
ON 
  dea.location = vac.location 
AND 
  dea.date = vac.date
WHERE dea.continent IS NOT NULL
