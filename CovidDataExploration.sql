--select * from portfolioproject..covid_deaths$
--order by 3,4


----select * from portfolioproject..covid_vaccinations$
----order by 3,4
----select data that we are going to be using 

select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..covid_deaths$
order by 1,2

--Looking at Total Cases vs Total Deaths


--Shows the likelihood of dying if you contract covid in the US
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..covid_deaths$
where location like '%states%'
AND Continent IS NOT NULL
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population has contracted Covid19
select location,date,total_cases,total_deaths, (total_cases/population)*100 as Percentage
from portfolioproject..covid_deaths$
where location like '%states%'
AND continent IS NOT Null
order by 1,2

--Looking at Countries with highest infection rate vs population

select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentageOfPopulationInfected
from portfolioproject..covid_deaths$
group by location, population
order by PercentageOfPopulationInfected DESC

--Showing Countries with Highest Death Count per Population

select location,population, max(cast(total_deaths as int)) as MaxTotalDeaths
from portfolioproject..covid_deaths$
where continent is not null
group by location, population
order by MaxTotalDeaths DESC

--Let's break things down by Continent


-- Showing continents with Highest Death Count
select continent, MAX(cast(total_deaths as int)) as MAXDeathCount
from portfolioproject..covid_deaths$
where continent is not null
group by continent
order by MAXDeathCount DESC

--  *****GO BACKdrill down effect repeat above queries by continent,location

--GLOBAL NUMBERS


select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int)) / sum(new_cases) *100 as DeathPercentage
from portfolioproject..covid_deaths$
--where location like '%states%'
WHERE Continent IS NOT NULL
--GROUP by Date
order by 1,2


--Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from portfolioproject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.Continent is not null
AND dea.date is not null
order by 2,3

--USE CTE
;
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from portfolioproject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.Continent is not null
AND dea.date is not null
--order by 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100 as PercentVaccinated from PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated 
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from portfolioproject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.Continent is not null
AND dea.date is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100 as PercentVaccinated from #PercentPopulationVaccinated
order by 2,3


-- Creating View to store data for later visualizations

Create View PerceptPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from portfolioproject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.Continent is not null
--order by 2,3

select * from PerceptPopulationVaccinated
