select 
location, date, total_cases, new_cases, total_deaths,population
from CovidProject..CovidDeaths
order by 1,2
--where location = 'Grenada'

select sum(total_cases)
from CovidProject..CovidDeaths


select 
location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeaths
from CovidProject..CovidDeaths
where location = 'Africa'
order by date desc

--Looking at countries with highest infection rates compared to population
select 
location, population, MAX(total_cases) HighestInfectionCount, MAX(total_cases/population)*100 as HighestInfectionRate
from CovidProject..CovidDeaths
where continent is not null
group by location, population
order by HighestInfectionRate desc

--Looking at highest death counts per countries
select 
location, MAX(cast(total_deaths as int)) TotalDeathCount
from CovidProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Looking at highest death counts per continent
select 
location Continent, MAX(cast(total_deaths as int)) TotalDeathCount
from CovidProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Global daily cases recorded
select 
	date, 
	sum(new_cases) as NewCases, 
	sum(cast(new_deaths as int)) as NewDeaths, 
	sum(cast(new_deaths as int))/Sum(new_cases) * 100 as PercentageDeaths
from CovidDeaths
where continent is not null and new_cases is not null
group by date
order by date

--Looking at total population vsd vaccinations
select 
	deaths.continent, 
	deaths.location, 
	deaths.date, 
	deaths.population, 
	vacs.new_vaccinations, 
	sum(cast(new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date)
from CovidDeaths deaths
join CovidVaccinations vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date	
where deaths.continent is not null
--where deaths.location like '%Nigeria%'
order by location, deaths.date

select distinct location from CovidDeaths
--order by continent

--Looking at total population vsd vaccinations with rolling percentages
With PopulationVaccinated(Continent,Location,Date,Population,NewVaccinations,PercentageVaccinated)
as
(select 
	deaths.continent, 
	deaths.location, 
	deaths.date, 
	deaths.population, 
	vacs.new_vaccinations, 
	sum(cast(new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as PercentageVaccinated
from CovidDeaths deaths
join CovidVaccinations vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date	
where deaths.continent is not null
--where deaths.location like '%Nigeria%'
--order by location, deaths.date
)
select *, (PercentageVaccinated/Population) * 100 from PopulationVaccinated order by location


-- Temp table
drop table if exists #TmpPopulationVaccinated
create table #TmpPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	NewVaccinations numeric,
	PercentageVaccinated numeric
)

insert into #TmpPopulationVaccinated
select 
	deaths.continent, 
	deaths.location, 
	deaths.date, 
	deaths.population, 
	vacs.new_vaccinations, 
	sum(cast(new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as PercentageVaccinated
from CovidDeaths deaths
join CovidVaccinations vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date	
where deaths.continent is not null

select *, (PercentageVaccinated/Population) * 100 from #TmpPopulationVaccinated order by location

select Continent, Location,	Population from #TmpPopulationVaccinated order by location
--order by continent