SET SESSION sql_mode = '';



select continent,location,total_cases,total_deaths
from coviddeaths;


select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from coviddeaths
order by 1,2;



select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where location='India'
order by 1,2;


select location,date,total_cases,population,(total_cases/population)*100 as infected_percentage
from coviddeaths
where location='India'
order by 1,2;



select location,population,max(total_cases) as highest_infected_count, max((total_cases/population))*100 as infected_percentage
from coviddeaths
group by location,population
order by infected_percentage desc;



select location,max(cast(total_deaths as signed)) as total_death_count
from coviddeaths
where continent != ""
group by location
order by total_death_count desc;



select location,max(cast(total_deaths as signed)) as total_death_count
from coviddeaths
where continent = ""
group by location
order by total_death_count desc;



select date,sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, (sum(cast(new_deaths as signed))/sum(new_cases))*100 as death_percentage
from coviddeaths
where continent!=""
group by date
order by date;



select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, (sum(cast(new_deaths as signed))/sum(new_cases))*100 as death_percentage
from coviddeaths
where continent!=""
order by date;



select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rolling_vaccination_count
from coviddeaths dea join covidvaccinations vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent !=""
order by 2,3;


-- CTE
with pop_vs_vac(Continent,Location,Date,Population,New_vaccinations,Rolling_vaccination_count)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rolling_vaccination_count
from coviddeaths dea join covidvaccinations vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent !=""
)

select *,(Rolling_vaccination_count/population)*100 as percentage_vaccinated from pop_vs_vac;


-- temp table
drop table if exists percent_pop_vac_temp_table;
create table percent_pop_vac_temp_table(
Continent char(255),
Location char(255),
Date datetime,
Population numeric,
New_vaccinations numeric null,
Rolling_vaccination_count numeric
);

Insert into percent_pop_vac_temp_table
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rolling_vaccination_count
from coviddeaths dea join covidvaccinations vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent !="";

select *,(Rolling_vaccination_count/population)*100 as percentage_vaccinated from percent_pop_vac_temp_table;


--  creating view

create view percentage_infected_view as 
select location,population,max(total_cases) as highest_infected_count, max((total_cases/population))*100 as infected_percentage
from coviddeaths
group by location
order by infected_percentage desc;