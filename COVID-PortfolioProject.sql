--select *
--from SQLPortfolioProject..covidDeaths
--order by 3,4

--To Have a view of the COVID situation in Nigeria
select Location, date, total_cases,new_cases, total_deaths, population
from SQLPortfolioProject.dbo.coviddeaths
where location like '%Nigeria%'
order by total_deaths desc

--To show the percentage of the Total deaths vs Total cases in Nigeria
select location, sum(convert(int,total_cases)) totalcases,sum(convert(int, total_deaths)) totaldeaths, max(total_deaths/total_cases)*100 as deathpercentage
from SQLPortfolioProject.dbo.coviddeaths
where location like '%Nigeria%'
group by location

----To show the percentage of total population in nigeria who had covid
Select Location,sum(Population) totalpop, sum(total_cases) totalcase,  (sum(total_cases)/sum(population))*100 as PercentPopulationInfected
From SQLPortfolioProject..CovidDeaths
Where location like 'Nigeria'
group by location

--To show the percentage of total population and total deaths in Nigeria
Select Location,sum(Population) totalpop, sum(total_cases) totalcase,sum(convert(int,total_deaths)) totaldeaths,(sum(convert(int, total_cases))/sum(population))*100 as PercentPopofdeath
From SQLPortfolioProject..CovidDeaths
Where location like 'Nigeria'
group by location


----To show the percentage of the Total deaths vs Total cases in Africa
select location, sum(convert(int,total_cases)) totalcases,sum(convert(int, total_deaths)) totaldeaths, max(total_deaths/total_cases)*100 as deathpercentage
from SQLPortfolioProject.dbo.coviddeaths
where continent like'Africa'
group by location
order by deathpercentage desc

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From SQLPortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Showing countries in Africa and their total death counts
Select location,population, MAX(convert(int, Total_deaths)) as TotalDeathCount
From SQLPortfolioProject..CovidDeaths
Where continent like 'Africa'
Group by location,population
order by TotalDeathCount desc

-- Total Population vs Vaccinations
-- Shows Percentage of the worlds Population that has recieved at least one Covid Vaccine

Select death.continent, death.location,death.date,death.population,vaccine.new_vaccinations,max(death.total_deaths), SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPortfolioProject..CovidDeaths death
Join SQLPortfolioProject..CovidVaccination vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.location is not null 
order by 2,3



--To show the number of people infected that were vaccinated in Nigeria
-- Shows Population in Nigeria that has recieved at least one Covid Vaccine

Select death.continent, death.location, death.date, death.population, vaccine.total_vaccinations,death.total_deaths,death.total_cases
, SUM(CONVERT(int,vaccine.total_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From SQLPortfolioProject..CovidDeaths death
Join SQLPortfolioProject..CovidVaccination vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.location like 'Nigeria' 
order by total_deaths desc

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.continent) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPortfolioProject..CovidDeaths death
Join SQLPortfolioProject..CovidVaccination vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
--order by 1,2
)
Select *, (RollingPeopleVaccinated/Population)*100 RollingpeoplePercentage
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

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

--Inserting values into Temp table
Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPortfolioProject..CovidDeaths death
Join SQLPortfolioProject..CovidVaccination vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 Rollpeoplepercentage
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPortfolioProject..CovidDeaths death
Join SQLPortfolioProject..CovidVaccination vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 

--creating temp table for visualizations

drop table if exists #TotalDeath_TotalCaseinAfrica
create table #TotalDeath_TotalCaseinAfrica
(
location nvarchar(255),
total_cases numeric,
total_deaths numeric,
deathpercentage numeric
)
 --Inserting values into temp table
insert into #TotalDeath_TotalCaseinAfrica
select location, sum(convert(int,total_cases)) totalcases,sum(convert(int, total_deaths)) totaldeaths, max(total_deaths/total_cases)*100 as deathpercentage
from SQLPortfolioProject.dbo.coviddeaths
where continent like'Africa'
group by location
order by deathpercentage desc

--Creating view for later visualization
create view TotalDeath_TotalCaseinAfrica as 
select location, sum(convert(int,total_cases)) totalcases,sum(convert(int, total_deaths)) totaldeaths, max(total_deaths/total_cases)*100 as deathpercentage
from SQLPortfolioProject.dbo.coviddeaths
where continent like'Africa'
group by location

select *
from TotalDeath_TotalCaseinAfrica