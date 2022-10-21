

--SELECT *
--FROM SQLPORTFOLIOPROJECT..CovidDeaths
--order by 3,4

--SELECT location, date, total_cases, new_cases, total_deaths, population 
--FROM SQLPORTFOLIOPROJECT..CovidDeaths
--where continent is not null 
--order by 1,2


--LOOKING AT TOTAL CASES VS TOTAL DEATHS (IN NIGERIA)

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM SQLPORTFOLIOPROJECT..CovidDeaths
where location like '%nigeria%'
order by 1,2
 

 --LOOKING AT TOTAL CASES VS POPULATION (shows what percentage has got covid)[IN NIGERIA]

select location, date, total_cases, population, (total_cases/population)*100 as PercentageofPopulationInfected
FROM SQLPORTFOLIOPROJECT..CovidDeaths
where location like '%nigeria%'
order by 1,2
 

 -- LOOKING FOR COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
 
 SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageofPopulationInfected
FROM SQLPORTFOLIOPROJECT..CovidDeaths
-- where location like '%nigeria%'
group by Location, population
order by PercentageofPopulationInfected desc

--SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT BY POPULATION

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLPORTFOLIOPROJECT..CovidDeaths
-- where location like '%nigeria%'
where continent is not null 
group by Location
order by TotalDeathCount desc


--BREAKING DETAILS DOWN BY CONTINENT 

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLPORTFOLIOPROJECT..CovidDeaths
-- where location like '%nigeria%'
where continent is not null 
group by continent
order by TotalDeathCount desc



-- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLPORTFOLIOPROJECT..CovidDeaths
-- where location like '%nigeria%'
where continent is not null 
group by Location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercantage
FROM SQLPORTFOLIOPROJECT..CovidDeaths
where continent is not null 
Group by date
order by 1,2 


-- JOINING THE TWO TABLES TOGETHER [COVIDDEATHS AND COVIDVACCINATION]

select *
from SQLPORTFOLIOPROJECT..CovidDeaths dea
join SQLPORTFOLIOPROJECT..CovidVaccinations vac
    on dea.location = vac.location


-- LOOKING AT TOTAL POPULATION VS VACCINATION 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from SQLPORTFOLIOPROJECT..CovidDeaths dea
join SQLPORTFOLIOPROJECT..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	order by 2,3




 -- DOING A ROLLING COUNT ON NEW_VACCINATION 

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccinatedPeople

from SQLPORTFOLIOPROJECT..CovidDeaths dea
join SQLPORTFOLIOPROJECT..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	order by 2,3


-- USING CTE

with POPvsVAC (Continent, location, date, population, New_vaccinations, RollingCountOfVaccinatedPeople)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccinatedPeople

from SQLPORTFOLIOPROJECT..CovidDeaths dea
join SQLPORTFOLIOPROJECT..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingCountOfVaccinatedPeople/Population)*100
from POPvsVAC 


-- TEMP TABLE

DROP Table if exists #PercentagePopulationVaccinated 
Create table #PercentagePopulationVaccinated  
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinaton numeric,
RollingCountOfVaccinatedPeople numeric,
)

Insert into #PercentagePopulationVaccinated 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccinatedPeople

from SQLPORTFOLIOPROJECT..CovidDeaths dea
join SQLPORTFOLIOPROJECT..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingCountOfVaccinatedPeople/population)*100
from #PercentagePopulationVaccinated 




-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZARION

Create View PercentageOfVaccinatedPopulation as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccinatedPeople
from SQLPORTFOLIOPROJECT..CovidDeaths dea
join SQLPORTFOLIOPROJECT..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentageOfVaccinatedPopulation 
