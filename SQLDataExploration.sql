Select *
From PortfolioProject..CovidVaccination
Where continent is not null
order by 3,4;

Select Location, date, total_cases, New_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 1,2;

Alter Table PortfolioProject.dbo.CovidDeaths
	Alter Column total_deaths int;
	
-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location Like '%states'
Order by 1,2;


-- Looking at Total Cases vs Population 
--Shows what Percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 As PercentOfPopulation
From PortfolioProject.dbo.CovidDeaths
Where location Like '%states'
Order by 1,2;

--Lokking at countries with Highest Infection Rate Compared To Population

Select Location,  population, Max(total_cases) as infectionCount, Max(total_cases/population)*100 As PercentagePopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by   population,location
Order by PercentagePopulationInfected desc;

--Lokking at countries with Highest Death Count Per Population

Select Location, Max(total_deaths) as TotalDeath
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by  location
Order by TotalDeath desc;


-- LETS'S BREAK THINGS DOWN BY CONTINENT

Select continent, Max(total_deaths) as TotalDeath
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
group by continent
Order by TotalDeath desc;

-- Showing contintents with highest death count per population

Select continent, Max(total_deaths) as TotalDeath
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
group by continent
Order by TotalDeath desc;


-- Gloabl Numbers

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as TotalDeath, Sum(cast(new_deaths as int))/Sum(new_cases)*100 As DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location Like '%states'
--Group By  date
Order by 1,2;

--Looking at Total Popoluation Vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With popvscav ( Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated /population) *100
From popvscav


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac 
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
