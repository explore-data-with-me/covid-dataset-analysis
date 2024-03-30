SELECT * 
from [portfolio databases]..CovidDeaths
--where continent is not null
order by 3,4

----SELECT * 
----from [portfolio databases]..CovidVaccinations
----order by 3,4

--select data that we are going to be using
-- shows likelihood of dying if someone contract covid in their country

SELECT Location, date, total_cases, new_cases,total_deaths, population 
from [portfolio databases]..CovidDeaths
order by 1,2


-- looking at total cases vs total deaths

SELECT Location, date, total_cases,total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
from [portfolio databases]..CovidDeaths
order by 1,2


SELECT Location, date, total_cases,total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
from [portfolio databases]..CovidDeaths
where location like '%china%'
AND continent is not null
order by 1,2

-- looking at total cases vs total population

SELECT Location, date, total_cases,population,
(total_cases/population)*100 as PercentPopulationInfected
from [portfolio databases]..CovidDeaths
where location like '%India%'
order by 1,2

SELECT Location, population, MAX(total_cases)AS HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
from [portfolio databases]..CovidDeaths
Group by Location, population
order by 3 desc;

-- showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int))AS Total_death_counts
from [portfolio databases]..CovidDeaths
where continent is not null
Group by Location
order by Total_death_counts desc;


SELECT location, MAX(cast(total_deaths as int))AS Total_death_counts
from [portfolio databases]..CovidDeaths
where continent is null
Group by location
order by Total_death_counts desc;


---- BREAKING THINGS BY CONTINENT

-- showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int))AS Total_death_counts
from [portfolio databases]..CovidDeaths
where continent is not null
Group by continent
order by Total_death_counts desc;


-- GLOBAL NUMBERS

SELECT date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths ,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from [portfolio databases]..CovidDeaths
--where location like '%china%'
where continent is not null
group by date
order by 1,2

SELECT  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths ,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from [portfolio databases]..CovidDeaths
where continent is not null
order by 1,2

-- NOW LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT *
FROM [portfolio databases]..CovidVaccinations dea
join [portfolio databases]..CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM [portfolio databases]..CovidVaccinations vac
join [portfolio databases]..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USING CTE

WITH PopVSVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM [portfolio databases]..CovidVaccinations vac
join [portfolio databases]..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select * , (RollingPeopleVaccinated/Population)*100
from PopVSVac


-- TEMP TABLE

CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
 insert into #PERCENTPOPULATIONVACCINATED
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM [portfolio databases]..CovidVaccinations vac
join [portfolio databases]..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * , (RollingPeopleVaccinated/Population)*100
from #PERCENTPOPULATIONVACCINATED


--- BUT NOW I DON'T WANT TO USE WHERE DEA.CONTINENT IS NOT NULL SO I HAVE TO DROP THE OLD TABLE FIRST THEN CREATE IT AGAIN 

drop table if exists #PERCENTPOPULATIONVACCINATED 

CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
 insert into #PERCENTPOPULATIONVACCINATED
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM [portfolio databases]..CovidVaccinations vac
join [portfolio databases]..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * , (RollingPeopleVaccinated/Population)*100
from #PERCENTPOPULATIONVACCINATED



-- CREATE VIEWS TO STORE DATA FOR LATER VISUALIZATIONS

CREATE view percentpopulationvaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM [portfolio databases]..CovidVaccinations vac
join [portfolio databases]..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from dbo.percentpopulationvaccinated