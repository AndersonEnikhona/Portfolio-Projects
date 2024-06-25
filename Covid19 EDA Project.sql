SELECT *
FROM CovidDeath
ORDER BY 3,4


--SELECT *
--FROM CovidVaccination
--ORDER BY 3,4

--looking for total cases vs total death

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeath
WHERE location like 'nigeria'
order by 1,2

--total cases vs population
--shows population that got covid

SELECT location, date, population, total_cases,  (population/total_cases)*100 as PercentPopulationInfected
FROM CovidDeath
WHERE location like 'nigeria'
order by 1,2

--looking at country with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectonCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM CovidDeath
GROUP BY location, population
order by 4 desc

--looking at country with highest death cases

SELECT location, MAX(cast(total_deaths as int)) as TotalDeath
FROM CovidDeath
WHERE continent is not null
GROUP BY location
order by TotalDeath desc

--breaking things down by continents
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeath
FROM CovidDeath
WHERE continent is not null
GROUP BY continent
order by TotalDeath desc


--Global Numbers


SELECT  Date, SUM(New_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM CovidDeath
WHERE continent is not null
group by date
order by 1,2

select *
from CovidDeath
join CovidVaccination
on CovidDeath.location = CovidVaccination.location 
and CovidDeath.date = CovidVaccination.date


--total vaccination vs population 

--group by

select CovidDeath.continent, CovidDeath.location, CovidDeath.date, population, CovidVaccination.new_vaccinations, 
SUM(cast(covidVaccination.new_vaccinations as int)) as SumNewVacination
from CovidDeath
join CovidVaccination
on CovidDeath.location = CovidVaccination.location 
and CovidDeath.date = CovidVaccination.date
where CovidDeath.continent is not null
group by CovidDeath.continent, CovidDeath.location, CovidDeath.date, population, CovidVaccination.new_vaccinations
order by 2,3

--partition by

select CovidDeath.continent, CovidDeath.location, CovidDeath.date, population, CovidVaccination.new_vaccinations, 
SUM(cast(covidVaccination.new_vaccinations as int)) OVER (PARTITION BY CovidDeath.location order by CovidDeath.date, CovidDeath.location) as SumNewVaccination
from CovidDeath
join CovidVaccination
on CovidDeath.location = CovidVaccination.location 
and CovidDeath.date = CovidVaccination.date
where CovidDeath.continent is not null
order by 2,3




--with CTES

WITH PopVsVal (Continent, Location, Date, Population, New_Vaccination, SumNewVaccination)
as
(select CovidDeath.continent, CovidDeath.location, CovidDeath.date, population, CovidVaccination.new_vaccinations, 
SUM(cast(covidVaccination.new_vaccinations as int)) OVER (PARTITION BY CovidDeath.location order by CovidDeath.date, CovidDeath.location) as SumNewVaccination
from CovidDeath
join CovidVaccination
on CovidDeath.location = CovidVaccination.location 
and CovidDeath.date = CovidVaccination.date
where CovidDeath.continent is not null
--order by 2,3
)

select *, (SumNewVaccination/Population)*100 
from PopVsVal


--TEMP TABLE

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
SumNewVaccination numeric
)

insert into #PercentPopulationVaccinated
select CovidDeath.continent, CovidDeath.location, CovidDeath.date, population, CovidVaccination.new_vaccinations, 
SUM(cast(covidVaccination.new_vaccinations as int)) OVER (PARTITION BY CovidDeath.location order by CovidDeath.date, CovidDeath.location) as SumNewVaccination
from CovidDeath
join CovidVaccination
on CovidDeath.location = CovidVaccination.location 
and CovidDeath.date = CovidVaccination.date
where CovidDeath.continent is not null
--order by 2,3

select*, (SumNewVaccination/Population)*100 
from #PercentPopulationVaccinated




--Creating Views to store data for later visualization

Create view PercentPopulationVaccinated as
select CovidDeath.continent, CovidDeath.location, CovidDeath.date, population, CovidVaccination.new_vaccinations, 
SUM(cast(covidVaccination.new_vaccinations as int)) OVER (PARTITION BY CovidDeath.location order by CovidDeath.date, CovidDeath.location) as SumNewVaccination
from CovidDeath
join CovidVaccination
on CovidDeath.location = CovidVaccination.location 
and CovidDeath.date = CovidVaccination.date
where CovidDeath.continent is not null
--order by 2,3