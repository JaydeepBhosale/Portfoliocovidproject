Select * 
from deaths
order by 3,4

Select * 
from [dbo].[Vaccination]
order by 3,4



Select location,date, total_cases,new_cases, total_deaths
from [dbo].[Deaths]
order by 1,2

--death percentage country wise
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [dbo].[Deaths]
order by 1,2

--total cases vs population percentage

Select location, date, population ,total_cases,total_deaths, (total_cases/population)*100 as covid_percentage
from [dbo].[Deaths]
where location= 'India'
order by 1,2 Desc


--infection rate as per population & country wise
Select location, population , max(total_cases) as highestinfectioncount, max((total_cases/population)*100) as covid_percentage
from [dbo].[Deaths]
group by location,population
order by 4 Desc

--Death rate as per population & country wise
Select location, population , max(total_deaths) as totaldeathcount, max((total_deaths/population)*100) as death_percentage
from [dbo].[Deaths]
group by location,population
order by 4 Desc

-Country wise death count

select location, max (cast(total_deaths as int)) as highestdeaths
from Deaths
where continent is not null
group by location 
order by highestdeaths DESC

--Continent wise death count

select continent, max (cast(total_deaths as int)) as highestdeaths
from Deaths
where continent is not null
group by continent
order by highestdeaths DESC

--global numbers

select date, sum(cast(new_cases as int)) as totalcases,sum (cast(new_deaths as int)) as totaldeaths
from deaths 
where continent is not null
group by date
order by totalcases Desc, totaldeaths Desc

-- Total Population Vs Total Vaccination	

Select dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations
from [dbo].[Deaths] dea
join [dbo].[Vaccination] vac
on dea.location= vac.location and dea.date  = vac.date
where dea.continent is not null 
order by 1,2,3


-- Total Population Vs Total Vaccination (rolling vaccination detail)

Select dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as rollingvaccinations
from [dbo].[Deaths] dea
join [dbo].[Vaccination] vac
on dea.location= vac.location and dea.date  = vac.date
where dea.continent is not null
order by 1,2,3

--cte
 with popvsvac ( continent, location, date, population, new_vaccination,rollingvaccinations)
  as 
  (
Select dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as rollingvaccinations
from [dbo].[Deaths] dea
join [dbo].[Vaccination] vac
on dea.location= vac.location and dea.date  = vac.date
where dea.continent is not null
)
select * , (rollingvaccinations/population)*100 as percentage
from popvsvac
order by 1,2


--create temp table

Drop table if exists #percentagevaccination

create table #percentagevaccination
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccinations numeric
)
insert into #percentagevaccination
Select dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as rollingvaccinations
from [dbo].[Deaths] dea
join [dbo].[Vaccination] vac
on dea.location= vac.location and dea.date  = vac.date


select * , (rollingvaccinations/population)*100 as percentage
from #percentagevaccination
order by 1,2


--create view

create view percentagevaccination as
Select dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as rollingvaccinations
from [dbo].[Deaths] dea
join [dbo].[Vaccination] vac
on dea.location= vac.location and dea.date  = vac.date
where dea.continent is not null

