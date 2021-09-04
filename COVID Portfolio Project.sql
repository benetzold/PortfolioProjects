SELECT *
FROM PortfolioProject..covid_deaths_tutorial
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..covid_vax_tutorial
--ORDER BY 3,4

-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..covid_deaths_tutorial
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the chances of dying if you get covid in your country 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..covid_deaths_tutorial
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what % of population got Covid

SELECT Location, date,Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..covid_deaths_tutorial
Where location like '%states%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..covid_deaths_tutorial
GROUP by Location, Population
ORDER BY PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covid_deaths_tutorial
WHERE continent is not null
Group by Location
order by TotalDeathCount desc


-- BREAKING DOWN BY CONTINENTS 

-- Showing continents with the highest death count 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covid_deaths_tutorial
WHERE continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS DAILY

SELECT date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..covid_deaths_tutorial
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBERS TOTAL

SELECT SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..covid_deaths_tutorial
WHERE continent is not null
ORDER BY 1,2

--JOINING DEATHS + VAX

SELECT *
FROM PortfolioProject..covid_deaths_tutorial dea
Join PortfolioProject..covid_vax_tutorial vac
	ON dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccintations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVax
FROM PortfolioProject..covid_deaths_tutorial dea
Join PortfolioProject..covid_vax_tutorial vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

	-- USE CTE

With PopVsVac (Continent, location, date, population ,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVax
FROM PortfolioProject..covid_deaths_tutorial dea
Join PortfolioProject..covid_vax_tutorial vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	)
	SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM PopvsVac

	--TEMP TABLE

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
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVax
FROM PortfolioProject..covid_deaths_tutorial dea
Join PortfolioProject..covid_vax_tutorial vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

	SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM #PercentPopulationVaccinated

	-- Creating View to store data for later visualizations

	CREATE VIEW PercentPopulationVaccinated as
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVax
FROM PortfolioProject..covid_deaths_tutorial dea
Join PortfolioProject..covid_vax_tutorial vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null


	
