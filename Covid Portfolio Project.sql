SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order By 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order By 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Demonstarates the liklihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentageWithCovid
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionRate, Max((total_cases/population)*100) as PopulationPercentageWithCovid
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Group by location, population
order by PopulationPercentageWithCovid DESC

-- Showing Countries with the highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
Group by location
order by TotalDeathCount DESC

-- Let's break things down by Continent
-- Showing the continents with the highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
Group by continent
order by TotalDeathCount DESC


-- Global numbers
SELECT  SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vacinations
-- Use CTE
With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, CumlativeNewVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER By dea.location,
dea.date) as CumlativeNewVaccinations

FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (CumlativeNewVaccinations/Population)*100
FROM PopvsVac

--Temp Table
DROP TABLE if exists #PercentPopulationVacinated
CREATE TABLE #PercentPopulationVacinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumlativeNewVaccinations numeric
)

INSERT INTO #PercentPopulationVacinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER By dea.location,
dea.date) as CumlativeNewVaccinations

FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (CumlativeNewVaccinations/Population)*100
FROM #PercentPopulationVacinated



-- Creating to store data for later visualizations

CREATE VIEW PercentPopulationVacinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER By dea.location,
dea.date) as CumlativeNewVaccinations

FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *
From PercentPopulationVacinated