-- view all tables in database

select *
from COVIDDeaths$

select *
from COVIDVaccination$;

-- select columns that will be used for analysis

select continent, location, population, date, total_cases, total_deaths
from COVIDDeaths$
order by 1,2;

-- find death percentage

select continent, location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from COVIDDeaths$;

-- find percentage of total population infected by COVID

select continent, location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from COVIDDeaths$;

-- find DeathPercentage and PercentagePopulationInfected for a particular country

select continent, location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from COVIDDeaths$
where location like 'india'
Order by date

-- countries with highest infection rate (Table 3 for Tableau Visualization)

select Location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentagePopulationInfected
from COVIDDeaths$
where continent is not null -- to exclude aggregate continents from location
group by location, population
order by PercentagePopulationInfected desc;

-- countries with highest infection rate date wise (Table 4 for Tableau Visualization)

select Location, Population, date, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentagePopulationInfected
from COVIDDeaths$
where continent is not null -- to exclude aggregate continents from location
group by location, population, date
order by PercentagePopulationInfected desc;

-- countries with highest death count

select location, max(cast(total_deaths as int)) as TotalDeathCount
from COVIDDeaths$
where continent is not null 
group by location
order by TotalDeathCount desc;

-- continents with highest death count (Table 2 for Tableau Visualization)

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from COVIDDeaths$ 
where continent is null
and location not in ('world','high income', 'upper middle income', 'lower middle income', 'european union','low income','international')
group by location
order by TotalDeathCount desc;

-- total cases and deaths across the world 

select date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from COVIDDeaths$
where location like 'world'
Order by date

-- total deaths and cases (Table 1 for tableau visualization)

select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percenatge
from COVIDDeaths$
where location like 'world'

-- total populaton vaccinated

select COVIDDeaths$.location, COVIDDeaths$.population, COVIDDeaths$.date, COVIDVaccination$.new_vaccinations, sum(cast(COVIDVaccination$.new_vaccinations as bigint)) over (partition by COVIDDeaths$.location order by COVIDDeaths$.location, COVIDDeaths$.date) as Total_Vaccinations
from COVIDDeaths$
join COVIDVaccination$
on COVIDDeaths$.location = COVIDVaccination$.location
and COVIDDeaths$.date = COVIDVaccination$.date
where COVIDDeaths$.continent is not null and COVIDVaccination$.new_vaccinations is not null
order by 1,3;

-- Percenatage of people vaccinated

with PopvsVac (location, population, date, new_vaccinations, Total_Vaccinations)
as
(
select COVIDDeaths$.location, COVIDDeaths$.population, COVIDDeaths$.date, COVIDVaccination$.new_vaccinations, sum(cast(COVIDVaccination$.new_vaccinations as bigint)) over (partition by COVIDDeaths$.location order by COVIDDeaths$.location, COVIDDeaths$.date) as Total_Vaccinations
from COVIDDeaths$
join COVIDVaccination$
on COVIDDeaths$.location = COVIDVaccination$.location
and COVIDDeaths$.date = COVIDVaccination$.date
where COVIDDeaths$.continent is not null and COVIDVaccination$.new_vaccinations is not null
)
select *,(Total_Vaccinations/population)*100 as  PercentagePopulationVaccinated
from PopvsVac;

