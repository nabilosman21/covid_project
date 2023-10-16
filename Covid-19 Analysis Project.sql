Select *
From PortfolioProject..CovidDeaths$
order by 3,4


Select *
From PortfolioProject..CovidVaccinations$
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths$
order by 1,2

--Total Cases vs Total Deaths 

Select location, date, total_cases, total_deaths, CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths$
Where location like '%somalia%'
order by 1,2


-- Total Cases vs Population 

Select location, date, population, total_cases, (total_cases/population)*100 as AffectedPeople
From PortfolioProject..CovidDeaths$
Where location like '%united kingdom%'
order by 1,2


--Highest Infection Rate compared to Population

Select Location, MAX(Population) as HighestPopulation, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/MAX(population))*100 as AffectedPeople
From PortfolioProject..CovidDeaths$
Group by Location, Population
order by AffectedPeople desc

-- Highest Death Count Rate 


Select Location, MAX(Population) as HighestPopulation, MAX(total_deaths) as HighestDeaths, (MAX(total_deaths)/MAX(population))*100 as DeathRate
From PortfolioProject..CovidDeaths$
Group by Location, Population
order by DeathRate desc

-- Highest Death Count per Continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global Statistics --- Death Percentage in the world
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null 
order by 1,2 

-- Total Population vs Vaccinations
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER  (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/Population)*100 as PVPC
From PopvsVac


-- Temp Table
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER  (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

Select *, (RollingPeopleVaccinated/Population)*100 as PVPC
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER  (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
