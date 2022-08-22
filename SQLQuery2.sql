select*
from portfolioproject..CovidDeath$
where continent is not null
order by 3,4

select*
from portfolioproject..CovidVaccinations$
where continent is not null
order by 3,4

select location,date,total_cases, new_cases, total_deaths, population
from portfolioproject..CovidDeath$
where continent is not null
order by 1,2

--looking at total cases vs total deaths, this show likelihood if you contract covid in Cnada
select location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
from portfolioproject..CovidDeath$
where location like '%Canada%'
order by 1,2

--looking at total cases vs population
select location, date, total_cases, Population,(total_cases/population)* 100 as DeathPercentage
from portfolioproject..CovidDeath$
where location like '%Canada%' and continent is not null
order by 1,2

--looking at countries with highest infection rate compared population
select location, population, Max(total_cases) as HighestInfectioncount, max(total_cases/population)*100 as 
percentage_population_infected
from portfolioproject..CovidDeath$
where continent is not null
group by location, population
order by percentage_population_infected desc

--showing the countries with highest death count per population
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeath$
where continent is not null
group by location
order by TotalDeathCount desc

--break things down by continent
select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeath$
where continent is not null
group by continent order by TotalDeathCount desc

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast
(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
from portfolioproject..CovidDeath$
where continent is not null
order by 1,2

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) OVER(partition by dea. location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
from portfolioproject..CovidDeath$ dea
join portfolioproject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) OVER(partition by dea. location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
from portfolioproject..CovidDeath$ dea
join portfolioproject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population) * 100 as percentage
from PopvsVac

--temp tale
create table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) OVER(partition by dea. location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
from portfolioproject..CovidDeath$ dea
join portfolioproject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100 as percentage
from #percentagepopulationvaccinated

create view percentagepopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) OVER(partition by dea. location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
from portfolioproject..CovidDeath$ dea
join portfolioproject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null



--Temp table