select * from CovidDeaths
order by 3,4 
select * from CovidVaccinations
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

select location,date,total_cases,total_deaths,(convert(float,total_deaths)/convert(float,total_cases))*100 as DeathPercentage
from CovidDeaths where location like '%states%'
order by 1,2

select location,date,total_cases,population,(convert(float,total_cases)/convert(float,population))*100 as PercentPopulationInfected
from CovidDeaths --where location like '%states%'
order by 1,2

select location,population,max(convert(float,total_cases)) as HighestInfectionCount,
max(convert(float,total_cases)/convert(float,population))*100 
as PercentPopulationInfected
from CovidDeaths --where location like ''
group by location,population
order by PercentPopulationInfected 
desc

select location,max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths where continent is not null
group by location
order by totaldeathcount desc

select continent,max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths where continent is not null
group by continent
order by totaldeathcount desc

select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,
(sum(new_deaths)/sum(new_cases))*100 as deathpercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2

select d.continent,d.location,d.date,population,new_vaccinations,
sum(CONVERT(bigint,new_vaccinations)) over (partition by d.location order by d.location,d.date)
as rollingpeoplevaccinated
from CovidDeaths d 
join CovidVaccinations v 
on d.location=v.location 
and d.date=v.date
where d.continent is not null
order by 2,3

with PopvsVac (continent,location,date,population,new_vaccinations,people_vaccinated,rollingpeoplevaccinated)
as
(
select d.continent,d.location,d.date,population,new_vaccinations,people_vaccinated,
sum(CONVERT(bigint,new_vaccinations)) over (partition by d.location order by d.location,d.date)
as rollingpeoplevaccinated
from CovidDeaths d 
join CovidVaccinations v 
on d.location=v.location 
and d.date=v.date
where d.continent is not null
--order by 2,3
)
select *,(people_vaccinated/population)*100
from PopvsVac
where location='India'
order by 2,3


drop table if exists #percentpopvac
create table #percentpopvac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopvac
select d.continent,d.location,d.date,population,new_vaccinations,
sum(CONVERT(bigint,new_vaccinations)) over (partition by d.location order by d.location,d.date)
as rollingpeoplevaccinated
from CovidDeaths d 
join CovidVaccinations v 
on d.location=v.location 
and d.date=v.date
where d.continent is not null
order by 2,3

select *,(rollingpeoplevaccinated/population)*100
from #percentpopvac
where location='India'