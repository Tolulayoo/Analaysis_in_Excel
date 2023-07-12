--selecting data 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM SQLPROJECT.. coviddeath
WHERE continent is not null
order by 1,2

-- SELECT *
--FROM SQLPROJECT.. coviddeath
--order by 1,2

--calculating total cases vs total deaths 
SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS float))*100 as deathpercentage
FROM SQLPROJECT.. coviddeath
WHERE location like 'africa' 
order by 1,2 


--calculating total cases vs population

SELECT Location, date, total_cases, population, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS float))*100 as percentage_infected
FROM SQLPROJECT.. coviddeath
WHERE location LIKE 'nigeria' and  continent is not null
order by 1,2

--calculating the highest infection rate per location
SELECT Location,  MAX(total_cases) AS highest_cases_per_country, population, MAX((CAST(total_cases AS FLOAT)/CAST(population AS float))*100) as percentage_infected
FROM SQLPROJECT.. coviddeath
WHERE continent is not null
GROUP BY location, population
order by percentage_infected DESC


-- total deaths per location
SELECT Location,  Max(cast(total_deaths as int)) as totaldeathcount
FROM SQLPROJECT.. coviddeath
WHERE continent is not null
Group by location
order by totaldeathcount desc

-- group by continent 
-- continents with highest death count
SELECT continent,  Max(cast(total_deaths as int)) as totaldeathcount
FROM SQLPROJECT.. coviddeath
WHERE continent is not null
Group by continent
order by totaldeathcount desc

-- Global counts
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as float))/ SUM(cast(new_cases as float))*100 as DeathPercentage
FROM SQLPROJECT.. coviddeath
WHERE continent is not null
Group by date
order by 1,2

Select  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as float))/ SUM(cast(new_cases as float))*100 as DeathPercentage
FROM SQLPROJECT.. coviddeath
WHERE continent is not null
--Group by date
order by 1,2
-- converting date from varchar to datetime
ALTER TABLE SQLPROJECT..covidvaccination
ADD vacdate DATETIME
UPDATE SQLPROJECT.. covidvaccination 
SET vacdate = CONVERT(DATETIME, date, 103);
-- ALTER TABLE SQLPROJECT..covidvaccination
--DROP COLUMN date;


-- joining both tables
Select *
FROM SQLPROJECT.. covidvaccination vac
 join SQLPROJECT.. coviddeath death
 on death.location = vac.location
 and death.date = vac.vacdate

 Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
 FROM SQLPROJECT.. covidvaccination vac
 join SQLPROJECT.. coviddeathsss death
	on death.location = vac.location
	and death.date = vac.vacdate
WHERE death.continent is not null
order by 2,3

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER  (Partition by death.location
order by death.location, death.Date) as RollingPeopleVaccinated 
 FROM SQLPROJECT.. coviddeath death
 join SQLPROJECT..  covidvaccination vac
	on death.location = vac.location
	and death.date = vac.vacdate
WHERE death.continent is not null
order by 2,3
 
-- USING CTE to get the percentage of rolling vaccination

WITH PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER  (Partition by death.location
order by death.location, death.Date) as RollingPeopleVaccinated 
 FROM SQLPROJECT.. coviddeath death
 join SQLPROJECT..  covidvaccination vac
	on death.location = vac.location
	and death.date = vac.vacdate
WHERE death.continent is not null
)
Select * , (cast(RollingPeopleVaccinated as float) / cast(Population as float))*100 as vaccinatedpercentage
From PopvsVac



--CREATE VIEW
USE SQLPROJECT
GO
create view PopvsVac as WITH PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER  (Partition by death.location
order by death.location, death.Date) as RollingPeopleVaccinated 
 FROM SQLPROJECT.. coviddeath death
 join SQLPROJECT..  covidvaccination vac
	on death.location = vac.location
	and death.date = vac.vacdate
WHERE death.continent is not null
)
Select * , (cast(RollingPeopleVaccinated as float) / cast(Population as float))*100 as vaccinatedpercentage
From PopvsVac
-- deathpercentage in Africa
USE SQLPROJECT
GO
create view deathpercentage as 
SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS float))*100 as deathpercentage
FROM SQLPROJECT.. coviddeath
WHERE location like 'africa' 
-- death percentage global
USE SQLPROJECT
GO
create view globaldeathpercentage as 
SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS float))*100 as deathpercentage
FROM SQLPROJECT.. coviddeath
WHERE continent is not null 

-- deathpercontinent
USE SQLPROJECT
GO
Create View  deathcountpercontinent as SELECT continent,  Max(cast(total_deaths as int)) as totaldeathcount
FROM SQLPROJECT.. coviddeath
WHERE continent is not null
Group by continent
--order by totaldeathcount desc
