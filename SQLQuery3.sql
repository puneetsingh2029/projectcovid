
--display all tables
select * 
from CovidDeaths8;

select * 
from CovidVaccinations8;

--primary data that we would be using 
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths8
order by location, date;

--total cases vs total deaths – death percentage
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from CovidDeaths8
order by location, date;


--likelihood(in percentage) of dying if you contact covid in india
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from covidDeaths8
where location like '%india%'
order by location, date

--total cases vs population(chances of contacting covid in india)
select location, date, total_cases, population, (total_cases/population)*100 as contactingcovidpercentage
from covidDeaths8
where location like '%india%'
order by location, date

--countries with highest infection rate
select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as populationaffected
from CovidDeaths8
group by location, population
order by populationaffected desc

-- countries with highest death count
select location, max(total_deaths)
from CovidDeaths8
where continent is not null
group by location
order by max(total_deaths) desc

-- continents with highest death count
select continent, max(total_deaths) as totaldeaths
from CovidDeaths8
where continent is not null
group by continent
order by max(total_deaths) desc

--
select date, sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(cast(new_cases as int))
from covidDeaths8
where continent is not null
group by date
order by 1,2


--total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths8 dea
join CovidVaccinations8 vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by location


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinations
from CovidDeaths8 dea
join CovidVaccinations8 vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by location


--CTE
with populationvsVaccination (continent, location, date, population, new_vaccinations, rollingpeoplevaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinations
from CovidDeaths8 dea
join CovidVaccinations8 vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)

select *, (rollingpeoplevaccinations/population)*100
from populationvsVaccination

--Temp Table

DROP table if exist #percentpopulationvaccinated

create table #percentpopulationvaccinated(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated values(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinations
from CovidDeaths8 dea
join CovidVaccinations8 vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)


select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated



--creating view to store data for later visualization

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinations
from CovidDeaths8 dea
join CovidVaccinations8 vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select * from percentpopulationvaccinated

