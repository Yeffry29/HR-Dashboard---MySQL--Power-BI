create database projects;
use projects;
select * from hr;

alter table hr
change column ï»¿id emp_id varchar (20) null;

describe  hr;

set sql_safe_updates=0;

#darle formato a las fechas birthdate / hire_date
update hr 
set birthdate = case 
	when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'), '%Y-%m-%d')
    when birthdate like '%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'), '%Y-%m-%d')
    else null
end;

#cambiar el tipo de datos de text a date 
alter table hr
modify column birthdate date ;

select hire_date from hr;


update hr
set hire_date = case 
	when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'), '%Y/%m/%d')
	when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'), '%Y-%m-%d')
    else null
end;

alter table hr
modify column hire_date date;
----------------------------------


-----
#recuperar info 

select hr.emp_id, hrb.termdate, hr.termdate
from hr
join `human resources` as hrb  on hr.emp_id = hrb.ï»¿id;
    
UPDATE hr
JOIN `human resources` hrb
    ON hr.emp_id = hrb.ï»¿id
SET hr.termdate = hrb.termdate;  

UPDATE hr h
JOIN `human resources` hrb
    ON h.emp_id = hrb.`ï»¿id`
SET h.termdate = hrb.termdate
WHERE h.emp_id LIKE '00-%';


SELECT h.emp_id, hrb.termdate
FROM hr h
JOIN `human resources` hrb
    ON h.emp_id = hrb.`ï»¿id`
LIMIT 10;




#modyfing termdate 
select termdate from hr;

update hr
set termdate=date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC')) 
where termdate is not null and termdate != '';

alter table hr
modify column termdate date;

select termdate,date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
from hr
where termdate is not null and termdate != '';

SELECT 
    termdate,
    CASE
        WHEN termdate IS NULL OR termdate = ''
        THEN '00-00-00'
        ELSE termdate
    END AS termdate
FROM hr;


UPDATE hr
SET termdate = '00-00-00'
WHERE termdate IS NULL
   OR termdate = '';
   
UPDATE hr
SET termdate = NULL
WHERE termdate = '00-00-00';

describe hr;

alter table hr
modify column hire_date date;




--------------------------
#add age data
alter table hr
add column age int;

select *from hr ;


select *
,timestampdiff(year,birthdate,curdate())
from hr;

update hr
set age= timestampdiff(year,birthdate,curdate());

select min(age) as youngest, max(age) as oldest
from hr;

select count(age) from hr where age < 18;


----------------

#questions 

#1 what is the gender breakdown of employees in the company ?
select gender, count(*) as count
from hr
where age >=18 and termdate is null
group by gender;


select * from hr;

--------------------
#2 What is the race /ethnicity/breakdown of employees in the company?

select race, count(*) as count
from hr
where age >= 18  and termdate is null
group by race
order by count desc;

---------------

#3 what is the age distribution of employees in the company 
select 
	min(age) as youngest,
	max(age) as oldest
from hr
where age >=18 and termdate is null ;

select 
	case
		when age >=18 and age <=24 then '18-24'
		when age >=25 and age <=34 then '25-34'
		when age >=35 and age <=44 then '35-44'
		when age >=45 and age <=54 then '45-54'
		when age >=55 and age <=64 then '55-64'
		else '65+'
	end as age_group,gender,
    count(*) as count
from hr
where age >=18 and termdate is null
group by age_group,gender
order by age_group,gender desc;
------------------

#How many employees work at site vs remote?
select location, count(*) as count
from hr
where age >=18 and termdate is null
group by location ;

#what is the avg of employees who have been terminated

select round(avg(datediff(termdate, hire_date)))/365 as avg_length_employment
from hr
where termdate <= curdate() and age >=18  ;

#How does the gender dirtribution vary across department and job tittle?
select department, gender,count(*) as count
from hr
where age >=18 and termdate is null
group by department, gender
order by department;


#what is the distribution of job tittles across the company ?
select jobtitle, count(*) as count
from hr
where age >= 18 and termdate is null
group by jobtitle
order by jobtitle desc;

#8 which department has the higghest turnover rate

select department, total_count, terminated_count, terminated_count/total_count as termination_rate
from (
	select department,count(*) as total_count,
    sum(case when termdate <> 000 and termdate <=curdate() then 1 else 0 end) as terminated_count
    from hr
    where age >=18
    group by department
    ) as subquery
    
    order by termination_rate desc;
    
    # what is the distirbution employees across location by city and state
    
    select location_state, count(*)  as count
    from hr
    where age >=18 and termdate is null
    group by location_state
    order by count desc;
    
    
    #how has the company employee count changed over time based on hire and term date
    
    select year, hires, terminations, hires - terminations as net_change , round((hires - terminations) / hires * 100,2) as net_change_percent
    
    from (select year (hire_date) as year,
		count(*) as hires,
        sum(case when termdate <> 0 and termdate <=curdate() then 1 else 0 end) as terminations 
        from hr 
        where age >=18
        group by year(hire_date) 
    
    
    ) as subquery
    
    order by year asc;
    
    
    # What is the tenue distribution of  each department 
    
    select department, round(avg(datediff(termdate,hire_date)/365),0) as Avg_tenure
    from hr
    where termdate <= curdate() and termdate <> 000  and age >=18 
    group by department;