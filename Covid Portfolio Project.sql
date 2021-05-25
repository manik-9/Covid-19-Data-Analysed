Select * FROM [Portfolio].[dbo].[CovidDeaths]
Where continent is not null
Order by 3,4

Select * FROM [Portfolio].[dbo].[CovidVaccinations]
Order by 3,4

--Select the data that we will be using

Select Location,date,total_cases,new_cases,total_deaths,population
FROM [Portfolio].[dbo].[CovidDeaths]
Where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying due to Covid if in India
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio].[dbo].[CovidDeaths]
Where Location like '%India'
and continent is not null
Order by 1,2


--Looking at Total Cases vs Population

Select Location,date,population,total_cases,(total_cases/population)*100 as InfectedPopulation
FROM [Portfolio].[dbo].[CovidDeaths]
--Where Location like '%India'
Order by 1,2

--Looking at Countries having highest infection rate to population

Select Location,population,MAX(total_cases)as HighestInfectionCount,MAX((total_cases/population))*100 as InfectedPopulation
FROM [Portfolio].[dbo].[CovidDeaths]
--Where Location like '%India'
Group by Location,population
Order by InfectedPopulation desc

--Showing Countries with the highest Death count per Population

Select continent, MAX(cast(total_deaths as int))as HighestDeathCount
FROM [CovidDeaths]
Where continent is not null
Group by continent
Order by HighestDeathCount desc


--Let's break thing down by continent

Select location, MAX(cast(total_deaths as int))as HighestDeathCount
FROM [CovidDeaths]
Where continent is  null
Group by location
Order by HighestDeathCount desc

--Showing the continents with highest deathcounts per population

 Select continent, MAX(cast(total_deaths as int))as HighestDeathCount
FROM [CovidDeaths]
Where continent is not null
Group by continent
Order by HighestDeathCount desc

--Global Numbers

Select date, SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
FROM [Portfolio].[dbo].[CovidDeaths]
--Where Location like '%India'
Where continent is not null
group by date
order by 1,2

--Global Death percentage

Select  SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
FROM [Portfolio].[dbo].[CovidDeaths]
--Where Location like '%India'
Where continent is not null
order by 1,2

--CovidVaccinations & Covid Deaths 

Select * 
from Portfolio.dbo.CovidDeaths dea
join Portfolio.dbo.CovidVaccinations vac
 on dea.Location=vac.location 
 and vac.date=dea.date

 --Looking at total polulation vs total vaccinations
 Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated,
 (RollingPeopleVaccinated/population)*100
 from Portfolio.dbo.CovidDeaths dea
join Portfolio.dbo.CovidVaccinations vac
 on dea.Location=vac.location 
 and vac.date=dea.date
 where dea.continent is not null
order by 2,3

--USE CTE
 With PopvsVac (Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
 as
 (
  Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
 from Portfolio.dbo.CovidDeaths dea
join Portfolio.dbo.CovidVaccinations vac
 on dea.Location=vac.location 
 and vac.date=dea.date
 where dea.continent is not null
--order by 2,3
)
Select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP Table

Drop table if exists #PercentPopulatinVaccinated
Create Table #PercentPopulatinVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulatinVaccinated
  Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
 from Portfolio.dbo.CovidDeaths dea
join Portfolio.dbo.CovidVaccinations vac
 on dea.Location=vac.location 
 and vac.date=dea.date
 where dea.continent is not null
--order by 2,3

Select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulatinVaccinated

--Creating view to store data for later visulation
 
Create View PercentPopulatinVaccinated as
  Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
 from Portfolio.dbo.CovidDeaths dea
join Portfolio.dbo.CovidVaccinations vac
 on dea.Location=vac.location 
 and vac.date=dea.date
 where dea.continent is not null
--order by 2,3

Select * from PercentPopulatinVaccinated