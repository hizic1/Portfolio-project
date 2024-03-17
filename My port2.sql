--select *
--from coviddeath
--order by 3,4

--select *
--from covidvaccine
--order by 3,4


--select location, date, total_cases, new_cases ,total_deaths, population
--from coviddeath
--order by 1,2

-- looking at total cases vs total deaths

select continent, location, date, total_cases, total_deaths, cast(total_deaths as decimal) / total_cases*100 as deathpercent
from coviddeath
where location = 'china'
order by 1,2


--looking at the total cases vs population

select continent, location, date, population, total_cases, cast(total_cases as decimal) / population*100 as percentpopulationinfected
from coviddeath
where location = 'china'
order by 1,2


--looking at countries with the highest infection rate compared to population

select continent, location, population, max(total_cases) as highestinfectioncount, max(cast(total_cases as decimal)) / population*100 as 
percentpopulationinfected
from coviddeath
--where location = 'china'
where continent is not null
group by continent, location, population
order by 3 desc


-- countries with highest death count per population

select continent, location, max(cast(total_deaths as decimal)) as totaldeathcount
from coviddeath
--where location = 'china'
where continent is not null
group by continent, location
order by totaldeathcount desc


-- continent with the highest death count per population

select continent, max(cast(total_deaths as decimal)) as totaldeathcount
from coviddeath
--where location = 'china'
where continent is not null
group by continent
order by totaldeathcount desc


-- global numbers

select date, sum(new_cases) as totalcases , sum(new_deaths) as totaldeaths, sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from coviddeath
where new_deaths > 0 and continent is not null
group by date
order by 1,2

-- global total new cases, total new deaths, and death percentage


select sum(new_cases) as totalcases , sum(new_deaths) as totaldeaths, sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from coviddeath
where new_deaths > 0 and continent is not null
order by 1,2


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeath as dea
join covidvaccine as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3




-- using cte

with popsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeath as dea
join covidvaccine as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popsvac



-- temp table

drop table if exists percentpopulationvaccinated
create table percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeath as dea
join covidvaccine as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from percentpopulationvaccinated



-- creating view

create view percentpopulationvaccinate as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeath as dea
join covidvaccine as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

create view popsvac1 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeath as dea
join covidvaccine as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


create view globalnums as
select sum(new_cases) as totalcases , sum(new_deaths) as totaldeaths, sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from coviddeath
where new_deaths > 0 and continent is not null
--order by 1,2