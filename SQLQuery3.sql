select * 
From [Portifolio project]..['coviddeaths']
order by 3,4


--select * 
--From [Portifolio project]..['covidvaccinations']
--order by 3,4

select * from sys.all_columns;
select Location, date, total_cases, new_cases, total_deaths, population
From [Portifolio project]..['coviddeaths']
order by 1,2

-- looking at total cases vs total deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)
From [Portifolio project]..['coviddeaths']
order by 1,2

-- total cases vs population in africa
select Location, date, total_cases, population, (total_deaths/population) * 100 as populationpercentage
From [Portifolio project]..['coviddeaths']
where location like 'africa'
order by 1,2


-- in states
select Location, date, total_cases, population, (total_deaths/population) * 100 as populationpercentage
From [Portifolio project]..['coviddeaths']
where location like '%states%'
order by 1,2

--highest numbers in infected areas 
select Location, population, MAX(total_cases) as Highest_Infected,  MAX((total_deaths/population)) * 100 as Infected_percentage
From [Portifolio project]..['coviddeaths']
--where location like '%states%'
group by location, population
order by Infected_percentage desc



--countries with the highest death count per population
select Location, MAX(cast(total_deaths as int)) as Total_death_count
From [Portifolio project]..['coviddeaths']
--where location like '%states%'
where continent is not null
group by location
order by Total_death_count desc



--continents with highest deaths
select continent, MAX(cast(total_deaths as int)) as Total_death_count
From [Portifolio project]..['coviddeaths']
--where location like '%states%'
where continent is not null
group by continent
order by Total_death_count desc

----Global numbers
--select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(new_cases as int)) * 100 as death_percentage
--From [Portifolio project]..['coviddeaths']
----where location like '%states%'
--where continent is not null
--group by date
--order by 1,2

-- looking at total population vs new vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date ) as Rolling_people_vaccination
from [Portifolio project]..['coviddeaths'] dea
Join [Portifolio project]..['vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3;

--USING CTE
With PopvsVac(continent, date, location, population, new_vaccinations, Rolling_people_vaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date ) as Rolling_people_vaccination
from [Portifolio project]..['coviddeaths'] dea
Join [Portifolio project]..['vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select * , (Rolling_people_vaccination/population) * 100
from PopvsVac

--TEMP TABLE
drop table if exists  #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacccinations numeric,
Rolling_people_vaccination numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as numeric)) OVER (partition by dea.location order by dea.location, dea.date ) as Rolling_people_vaccination
from [Portifolio project]..['coviddeaths'] dea
Join [Portifolio project]..['vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select * , (Rolling_people_vaccination/population) * 100
from #PercentPopulationVaccinated


-- creating views for future data visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as numeric)) OVER (partition by dea.location order by dea.location, dea.date ) as Rolling_people_vaccination
from [Portifolio project]..['coviddeaths'] dea
Join [Portifolio project]..['vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
