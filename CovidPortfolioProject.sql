--select * from portfolioproject..CovidVaccinations

--Select Only Limited Columns
select location,date,total_cases,new_cases,total_deaths, population 
from portfolioproject..CovidDeaths
order by 1,2


--Total cases VS Total Deaths

select location,Date,(total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
where location like '%Iran%'
order by DeathPercentage DESC


--Total Cases VS Population InfectedCasesPercentage


select location,population,total_cases,(total_cases/population)*100 as InfectedCasesPercentage
from portfolioproject..CovidDeaths
order by InfectedCasesPercentage DESC


--Higgest Cases Group By location

select location,max(cast(total_deaths as int)) as HighestCase
from portfolioproject..CovidDeaths
where continent is not null
group by location
order by HighestCase DESC

--Count by continent     

select max(cast(total_deaths as int)) as SumDeath,continent 
from portfolioproject..CovidDeaths
where continent is not null
group by continent
order by SumDeath DESC


-- Sum of New Cases, Sum of New Death and DeathPercentage Group By month of the Date column. 

select month(date) as Month ,sum(new_cases) as New_Cases,sum(cast(new_deaths as int)) as New_Death,((sum(cast(new_deaths as int)) / sum(new_cases))*100) as DeathPercentage
from portfolioproject..CovidDeaths
where continent is not null
group by month(date)
order by month(date) asc

---------------------Table Vaccination-------------------

--Total Vaccination Vs population
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,dea.total_cases,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location)
from portfolioproject..CovidDeaths dea join portfolioproject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3


--Create View to store data for further Data Visualisation

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,dea.total_cases,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths dea join portfolioproject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated 
order by 1,2


