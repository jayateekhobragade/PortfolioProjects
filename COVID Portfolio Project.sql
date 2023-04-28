Select * 
from PortfolioProject..['Covid Deaths$']
where continent is not null
order by 3,4

--Select * 
--from PortfolioProject..['Covid Vaccination$']
--order by 3,4

-- Data for use

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['Covid Deaths$']
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 as DeathPercentage
from PortfolioProject..['Covid Deaths$']
where location like '%india%'
and continent is not null
order by 1,2


-- Total Cases vs Population
-- What percentage of population got covid
Select location, date, population, total_cases, (CAST(total_deaths AS float)/CAST(population AS float))*100 as PersentPopulationInfected
from PortfolioProject..['Covid Deaths$']
--where location like '%india%'
order by 1,2


--Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((CAST(total_deaths AS float)/CAST(population AS float)))*100 as PersentPopulationInfected
from PortfolioProject..['Covid Deaths$']
--where location like '%india%'
Group by location, Population
order by PersentPopulationInfected desc


-- The Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['Covid Deaths$']
--where location like '%india%'
where continent is not null
Group by location
order by TotalDeathCount desc


-- BREAK THINGS DOWN BY CONTINENT

-- The Continents with the Highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['Covid Deaths$']
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..['Covid Deaths$']
where continent is not null
order by 1,2


-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp Table

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
DATE datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visvualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
from PercentPopulationVaccinated