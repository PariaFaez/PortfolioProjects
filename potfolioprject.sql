select*
from CovidDeath
where continent is not null
order by 3,4



select location, date,total_cases,new_cases,total_deaths,population
from CovidDeath
order by 1,2


--Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage

--From CovidDeath

--order by 1,2
--Select location, date, total_cases, total_deaths, (cast(total_deaths as int)/cast(total_cases as int))*100 as DeathPercentage

--From CovidDeath
--order by 1,2
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage

From CovidDeath
where location like '%can%'
order by 1,2

Select location, date,population, total_cases,  (cast(total_cases as float)/cast(population as float))*100 as InfectionRate

From CovidDeath
--where location like '%germ%'
order by 1,2

Select location,population,MAX(total_cases),max((cast(total_cases as float)/cast(population as float)))*100 as InfectionRate

From CovidDeath
group by location,population

order by InfectionRate desc


--Select location,MAX(total_deaths )as totaldeathcount
--From CovidDeath
--group by location

--order by  totaldeathcount desc

Select location,MAX(cast(total_deaths as float))as totaldeathcount
From CovidDeath
where continent is not null
group by location         
order by  totaldeathcount desc  



 --BRACK THINGS DOWN BY CONTINENT

Select continent,MAX(cast(total_deaths as float))as totaldeathcount
From CovidDeath
where continent is not null
group by continent        
order by  totaldeathcount desc


Select location,MAX(cast(total_deaths as float))as totaldeathcount
From CovidDeath
where continent is null
group by location    
order by  totaldeathcount desc
 


 
 --death percentage of world populition
select sum(new_cases )AS totalcase,sum(cast(new_deaths as int))as totaldeath,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from CovidDeath
where continent is not null
--group by date  
order by 1,2





--looking to total population vs vac
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations ))over(partition by dea.location order by dea.location,dea.date)as totalpopulationvaccinated
from CovidDeath dea
join CovidVaccinations vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3



--- USE CTE
with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated) 
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations ))over(partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
from CovidDeath dea
join CovidVaccinations vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null
)
select*,(rollingpeoplevaccinated/population)*100 as PercentPopulationVaccinated

from popvsvac




-- Using Temp Table to perform Calculation on Partition By in previous query 
drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(
continent nvarchar(250),
location nvarchar(250),
Date datetime,
population numeric, 
new_vaccinations  numeric,
rollingpeoplevaccinated numeric
)
insert into #PercentPopulationVaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations ))over(partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
from CovidDeath dea
join CovidVaccinations vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null
select*,(rollingpeoplevaccinated/population)*100 as PercentPopulationVaccinated

from #PercentPopulationVaccinated 


-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations ))over(partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
from CovidDeath dea
join CovidVaccinations vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null