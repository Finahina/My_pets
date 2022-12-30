----It's a litle check of data
SELECT *
FROM My_Pet..CovidDeth
ORDER BY 3,4 

SELECT *
FROM My_Pet..CovidVactinations
ORDER BY 3,4 


----Selecting needed data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM My_Pet..CovidDeth
ORDER BY 1, 2


----Total cases vs Total Deat
----Cinversion of deaths
SELECT location, date, total_cases, total_deaths, cast(total_deaths as float)/cast(total_cases as float)*100 as DethPercentage
FROM My_Pet..CovidDeth
WHERE location like '%Bermuda%'
ORDER BY 1, 2


----Percent of ill of Covid people
SELECT location, date, total_cases, population, cast(total_cases as float)/cast(population as float)*100 as PercentageOfInfected
FROM My_Pet..CovidDeth
WHERE location like '%Bermuda%'
ORDER BY 1, 2


----Loking for a Countries with higest infection rate compared to Population
SELECT location, MAX(cast(total_cases as float)) as MaxTotalCases, population, MAX(cast(total_cases as float)/cast(population as float))*100 as InfectedPercentage
FROM My_Pet..CovidDeth
WHERE continent is not Null
GROUP BY location, population
ORDER BY InfectedPercentage desc


----Showing location with higest Deth count per population
SELECT location, MAX(cast(total_deaths as float)) as MaxTotalDeaths
FROM My_Pet..CovidDeth
WHERE continent is not Null
GROUP BY location
ORDER BY MaxTotalDeaths desc

----Break things down by continent
----Showing continent with higest deaths count per population
SELECT continent, MAX(cast(total_deaths as float)) as MaxTotalDeaths
FROM My_Pet..CovidDeth
WHERE continent is not Null
GROUP BY continent
ORDER BY MaxTotalDeaths desc

----GLOBAL Numbers 

SELECT date, SUM(cast(new_cases as float)) as all_new_cases, SUM(cast(new_deaths as float)) as all_new_deaths,(SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 as DeathPercentage
FROM My_Pet..CovidDeth
WHERE continent is not Null
GROUP BY date
ORDER BY 1, 2

----population vs vactination
---- total vactination by loction

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.date) as rolling_vac_by_loc
FROM My_Pet..CovidDeth as dea
JOIN My_Pet..CovidVactinations as vac
	ON dea.location = vac.location
	AND  dea.date = vac.date
WHERE dea.continent is not null
ORDER by 1,2,3


----percentage of vactinated people using rolling count
WITH PopVsVac(continent, location, date, population, new_vaccinations, rolling_vac_by_loc)
as(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY vac.Location ORDER BY vac.date) as rolling_vac_by_loc
FROM My_Pet..CovidDeth as dea
JOIN My_Pet..CovidVactinations as vac
	ON dea.location = vac.location
	AND  dea.date = vac.date
WHERE dea.continent is not null ) 


SELECT *, (rolling_vac_by_loc/population)*100 as vactinated_people_pecentage
FROM PopVsVac
ORDER BY location


---- temp table
DROP TABLE IF exists #VactinatedPeoplePercentage

CREATE TABLE #VactinatedPeoplePercentage
(
continent nvarchar(255),
location nvarchar(255),
date nvarchar(255),
population numeric,
new_vaccinations numeric,
rolling_vac_by_loc numeric
)


INSERT INTO #VactinatedPeoplePercentage
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY vac.Location ORDER BY vac.date) as rolling_vac_by_loc
FROM My_Pet..CovidDeth as dea
JOIN My_Pet..CovidVactinations as vac
	ON dea.location = vac.location
	AND  dea.date = vac.date
WHERE dea.continent is not null 

SELECT *, (rolling_vac_by_loc/population)*100 as vactinated_people_pecentage
FROM #VactinatedPeoplePercentage
ORDER BY location

--Creating View to store data for later visualisations

CREATE VIEW VactinatedPercentage as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY vac.Location ORDER BY vac.date) as rolling_vac_by_loc
FROM My_Pet..CovidDeth as dea
JOIN My_Pet..CovidVactinations as vac
	ON dea.location = vac.location
	AND  dea.date = vac.date
WHERE dea.continent is not null 

SELECT *, (rolling_vac_by_loc/population)*100 as vactinated_people_pecentage
FROM VactinatedPercentage
ORDER BY location
