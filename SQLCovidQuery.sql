Use Covid19Project

Select *
From Covid19Project..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From Covid19Project..CovidVaccinations
--order by 3,4

--Selecting Data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From Covid19Project..CovidDeaths
order by 1,2

--Looking at the Total Cases Vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From Covid19Project..CovidDeaths
Where location like '%states%'
AND continent is not null
order by 1,2

--Looking at the Total Cases vs Population
Select Location, date, population, total_cases, (total_cases/population)*100 AS PopulationInfectedPercentage
From Covid19Project..CovidDeaths
order by 1,2

--Looking at Countries with high infection rate compared to population
Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationInfectedPercentage
From Covid19Project..CovidDeaths
Group by Location, Population
order by PopulationInfectedPercentage DESC

--Countries with high death counts per population
Select Location, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
From Covid19Project..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount DESC

--Breaking down by continent
Select location, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
From Covid19Project..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount DESC

-- Showing continents with highest death count per population
Select continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
From Covid19Project..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(New_deaths as int))/SUM(New_cases) * 100 as DeathPercentage
From Covid19Project..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Population Vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date
where dea.continent is not null
Order by 2,3

--CTE
With PopVSVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVSVac

--Temp Table
Drop table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated

--Create View
Drop View if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date
where dea.continent is not null

Select * 
From PercentPopulationVaccinated

--Queries for Tableau
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
as DeathPercentage
From Covid19Project..CovidDeaths
where continent is not null
order by 1,2

Select location, SUM(CAST(new_deaths as int)) as TotalDeathCount
From Covid19Project..CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc

Select location, Population, MAX(total_cases) as HighInfectedCount, MAX((total_cases/population))*100 as PercentPopInfected
From Covid19Project..CovidDeaths
Group by Location, Population
Order by PercentPopInfected

Select Location, Population, date, MAX(total_cases) as HighInfectedCount, MAX((total_cases/population)) * 100 as PercentPopInfected
From Covid19Project..CovidDeaths
Group by Location, Population, date
order by PercentPopInfected