--select location, date, new_cases, total_cases, new_deaths from CovidDeaths
--order by 1, 2

-- Looking at total cases vs Total deaths
--Shows the likelihood of dying from Covid-19 in the selected country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from CovidDeaths
where location = 'Serbia'
order by location, date

--Looking at the Total Cases vs The Population
--Shows the percentage of people who have Covid-19 in the selected country
select location, date, population, total_cases, (total_cases/population)*100 from CovidDeaths
where location = 'Serbia'
order by date

-- Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as MaxTotalCases, (max(total_cases)/population)*100 as PercentPeopleInfected 
from CovidDeaths
group by location, population
order by PercentPeopleInfected desc -- Cyprus is the country with the highest infection percentage

-- Countries with Highest Death Count per Population
select location, population, max(cast(total_deaths as int)) as HighestTotalDeaths, (max(total_deaths)/population)*100 as PercentageOfDeaths
from CovidDeaths
where continent is not NULL
group by location, population
order by PercentageOfDeaths desc --Bosnia and Herzegovina is the country with the highest pecentage of Covid-19 deaths

--Continents with the highest death count per population
--select location, max(cast(total_deaths as int)) as TotalDeaths from CovidDeaths
--where continent is null
--group by location
--order by TotalDeaths desc

--Continents with the most number of deaths
select continent, max(cast(total_deaths as int)) as TotalDeaths from CovidDeaths
where continent is not null
group by continent
order by TotalDeaths desc

--Global numbers
select date, sum(new_cases) DailyWorldCases, sum(cast(new_deaths as int)) as DailyWorldDeaths
from CovidDeaths
where continent is not null
group by date
order by date

--Looking at total population vs total vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by dea.location, dea.date


--USE CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by dea.location, dea.date
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Creating view to store data for later visualizations
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by dea.location, dea.date

select * from PercentPopulationVaccinated