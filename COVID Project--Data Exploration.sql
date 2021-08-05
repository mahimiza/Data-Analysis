SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at total cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population

SELECT Location, date, population, total_cases, total_deaths, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at Countries with Highest infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
--where location like '%states%'
Group By location, population
order by PercentagePopulationInfected desc


--Highest Death Count Per Populaton
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$ 
--where location like '%states%'
where continent is not null
Group By location
order by TotalDeathCount desc

--Breaking it down by continent

SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$ 
--where location like '%states%'
where continent is not null
Group By continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$ 
--where location like '%states%'
where continent is not null
Group By date
order by 1,2

--Across the World 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$ 
--where location like '%states%'
where continent is not null
--Group By date
order by 1,2



--Looking at Total Population vs Vaccinations

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;


--USE CTE
WITH PopvsVac(Continent, Location, Date, Population, New_Vaccations, RollingPeopleVaccinated) 
as 
(
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
FROM PopvsVac;

--Creating View 

--GO
--Create View PercentagePopulationVaccinated as
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
-- SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
-- dea.date) as RollingPeopleVaccinated
-- From PortfolioProject..CovidDeaths$ dea
-- Join PortfolioProject..CovidVaccinations$ vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null;


--SELECT *
--FROM PercentagePopulationVaccinated


--if exists (select * from sys.objects where object_id = object_id('PercentagePopulationVaccinated') and type = 'V')
--drop view PercentagePopulationVaccinated
--go

--CREATE VIEW sys.database_firewall_rules AS SELECT id, name, start_ip_address, end_ip_address, create_date, modify_date FROM sys.database_firewall_rules_table
