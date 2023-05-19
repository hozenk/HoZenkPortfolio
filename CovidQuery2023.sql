--Total cases vs. Total deaths connection
--(Shows the likelihood of dying if you contract Covid-19 in the US)
Select location,date,cast(total_cases as float) as total_cases,cast(total_deaths as float) as total_deaths, 
Round((cast(total_deaths as float)/cast(total_cases as float))*100,4) as Death_Percentage
From [Portfolio Project]..CovidDeaths2023
Where location = 'United States'
Order by Death_Percentage desc;

--Total cases vs Population
--(Shows what percent of a population contracted Covid-19)
Select location,date,population, cast(total_cases as float) as total_cases, Round(total_cases/population*100,4) as Infection_Percentage
From [Portfolio Project]..CovidDeaths2023
--Where location = 'United States'
Order by Infection_Percentage desc;

--Determining countries with highest infection rate compared to population
Select location,population,MAX(total_cases) as HighestInfectionCount, MAX(ROUND((total_cases/population)*100,4)) as Infection_Percentage
From [Portfolio Project]..CovidDeaths2023
Group By population,location
Order by Infection_Percentage Desc;

--Determining countries with highest death rate compared to population
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths2023
Where continent != 'Null'
Group By population,location
Order by TotalDeathCount Desc;

--Determining continents with highest death rate compared to population
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths2023
Where continent is not Null
Group By continent
Order by TotalDeathCount Desc;

--Global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/nullif(SUM(new_cases),0)*100 as Death_Percentage
From [Portfolio Project]..CovidDeaths2023
Where continent is not null
Group by date
Order by 1,2;

--Looking at total population vs. vaccination


Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
nullif(SUM(cast(vax.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date),0) as RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths2023 as dea
Join [Portfolio Project]..CovidVax2023 as vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
order by 2,3;

--Use CTE
With PopVsVax (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
nullif(SUM(cast(vax.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date),0) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths2023 as dea
Join [Portfolio Project]..CovidVax2023 as vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3;
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVax



--Temp Table
Drop table if exists #PercentPopVaxxed
Create table #PercentPopVaxxed
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopVaxxed
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
nullif(SUM(cast(vax.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date),0) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths2023 as dea
Join [Portfolio Project]..CovidVax2023 as vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopVaxxed

--Creating view to store data for later visualizations
use [Portfolio Project]

Create View PercentPopVaxxed as 
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
nullif(SUM(cast(vax.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date),0) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths2023 as dea
Join [Portfolio Project]..CovidVax2023 as vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3;