
-- Looking at Total Cases vs Total Deaths

select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..covid_deaths
where location = 'India'
order by location,date

-- Looking at Total Cases vs Population

select location, date,total_cases, population, (total_cases/population)*100 as casesPercentage
from PortfolioProject1..covid_deaths
where continent is not null
and location = 'India'
order by location,date


-- Looking countries with Highest Infection Rate compared to Population
select location, population,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject1..covid_deaths
where continent is not null
group by location,population
order by PercentPopulationInfected desc


-- Showing countries with highest death count per population
select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..covid_deaths
where continent is not null
group by location
order by TotalDeathCount desc 


-- Global numbers 
select sum(new_cases) as total_cases, sum(cast(new_deaths as int )) as total_deaths, (sum(cast(new_deaths as int ))/sum(new_cases))*100 as PercentPopulationDeaths
from PortfolioProject1..covid_deaths
where continent is not null

-- Looking at Total population vs Vaccinations

select d.continent, d.location,d.date, d.population, v.new_vaccinations, 
sum(convert(float,v.new_vaccinations)) OVER (partition by d.location order by d.location , d.date) as RollingPeopleVaccinated,
from PortfolioProject1..covid_deaths as d 
inner join PortfolioProject1..covid_vaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null and d.population is not null
order by location,date

-- Temp table
DROP table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into PercentPopulationVaccinated
select d.continent, d.location,d.date, d.population, v.new_vaccinations, 
sum(convert(float,v.new_vaccinations)) OVER (partition by d.location order by d.location , d.date) as RollingPeopleVaccinated
from PortfolioProject1..covid_deaths as d 
inner join PortfolioProject1..covid_vaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null and d.population is not null
order by location,date

select*,(RollingPeopleVaccinated/Population)*100 as RollingPeoplePercentage
from PercentPopulationVaccinated

-- We take these out as they are not in the above queries and want to stay consistent
-- European Union is part of Europe
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..covid_deaths
where continent is not null and location not in ('World','European Union', 'International')
group by continent
order by TotalDeathCount desc

select location, population,date,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject1..covid_deaths
where continent is not null
group by location,population,date
order by PercentPopulationInfected desc
