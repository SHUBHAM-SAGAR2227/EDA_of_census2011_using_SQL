select * from project_census.dataset1;

select * from project_census.dataset2;

-- number of rows into our dataset

select count(*) from project_census.dataset1;
select count(*) from project_census.dataset2;

-- extrating the dataset from jharkhand and bihar

select * from project_census.dataset1
where state in ('Jharkhand', 'Bihar')

-- population of India
select sum(population) as Population from project_census.dataset2

-- average  growth  rate of India
select avg(growth) as avg_growth from project_census.dataset1;

-- average growth rate of individual states

select state , avg(growth) as state_growth from project_census.dataset1
 group by state;

-- avg sex ratio per state
select state, round(avg(sex_ratio),0) as avg_sex_ratio from project_census.dataset1 
group by state order   by avg_sex_ratio desc;
 # round(_,_) is used to round off the no. to desire decimal place

-- states having literacy rate greater than 90
select state, round(avg(literacy),0) as avg_literacy_rate from project_census.dataset1 
group by state having round(avg(literacy),0) > 90 order   by avg_literacy_rate desc ;

-- top 3 state showing highest growth ratio
select state , round(avg(growth),3) as state_growth from project_census.dataset1 
group by state order  by state_growth desc limit 3

-- Bottom 3 state showing the lowest sex ratio
select state, round(avg(sex_ratio),0) as  avg_sexratio from project_census.dataset1
group by state order by avg_sexratio asc  limit 3


--  top and bottom  3 states in literacy state in same table (one column)

drop table if exists topstates # deleting the tempory table so we avoid table already exits ERROR
create table topstates(state varchar(255),topstates float);

insert into topstates
select state, round(avg(literacy),0) as avg_literacy from
project_census.dataset1 group by state order by avg_literacy desc limit 3 ;

select * from topstates #1



drop table if exists bottomstates; # deleting the tempory table so we avoid table already exits ERROR
create table bottomstates(state varchar(255),bottomstates float);

insert into bottomstates
select state, round(avg(literacy),0) as avg_literacy from
project_census.dataset1 group by state order by avg_literacy asc limit 3 ;

select * from bottomstates   #2



  -- union The UNION operator is used to combine the result-set of two or more SELECT statements. #1+#2
select * from topstates union select * from bottomstates



-- states starting with letter a
select distinct state from project_census.dataset1 
where lower(state) like 'a%'   #The LIKE operator is used in a WHERE clause to search for a specified pattern in a column.


-- states starting with letter a or b

select distinct state from project_census.dataset1
where lower(state) like 'a%' or lower(state) like 'b%'

-- states starting with letter a and ending 'm'
select distinct state from project_census.dataset1
where lower(state) like 'a%'  and lower(state) like '%m'


-- joining both the tables i.e dataset1 and dataset2

select a.district,a.state,a.sex_ratio,b.population from project_census.dataset1 a 
inner join project_census.dataset2 b on a.district = b.district

# finding the total number of male and females  district wise

  /* Math used :
  f/m = sex_ratio
  f= sex_ratio *m  .......... 1
  f + m = Population
  f = Poulation - m ..........2 
  from 1 and 2
   Population - m = sex_ratio*m
   Population = m(sex_ratio +1)
   m = Population /(sex_ratio +1) 
   f = Population - (population/(sex_ratio +1))
   f = Popullation(1-1(sex_ratio +1)
   f = (population * sex_rati0)/(sex_ratio +1)
      */
   
select c.district,c.state, round(c.population /(c.sex_ratio +1),0) males , round((c.population*c.sex_ratio)/(c.sex_ratio +1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from project_census.dataset1 a 
inner join project_census.dataset2 b on a.district = b.district) c
   
   
# Total males and females state wise
select d.state, sum( d.males) Total_males , sum(d.females) Total_females from
(select c.district,c.state, round(c.population /(c.sex_ratio +1),0) males , round((c.population*c.sex_ratio)/(c.sex_ratio +1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from project_census.dataset1 a 
inner join project_census.dataset2 b on a.district = b.district) c ) d
group by d.state;

-- total literate peolple into state

  /* Formula used
  Total literate people/population = Literacy_ratio
  Total literate people = Literacy_ratio * population
  Total illiterate people = (1- literacy_ratio)*population */


select c.state, sum(c.literate_people) Total_literate_people, sum(c.illiterate_people) Total_illilterate_people from
(select d.district,d.state, round(d.literacy_ratio*d.population,0) literate_people,round((1 - d.literacy_ratio)*d.population,0) illiterate_people from
(select a.district, a.state, a.literacy/100 literacy_ratio, b.population from project_census.dataset1 a inner join project_census.dataset2 b on a.District = b.District) d) c

group by c.state


-- population in previous census vs population in current census
/*Math used
 prev_census + growth*perv_census = population
 prev_census = population /( 1+ growth) 
 */
 
 
select sum(c.Previous_census_population) , sum(Current_population) from (
select e.state, sum(e.previous_census_population) Previous_census_population , sum(e.current_census_population ) Current_population     from
(select d.district,d.state,round( d.population/ (1+d.growth),0) previous_census_population, d.population current_census_population from
(select a.district, a.state, a.growth/100 growth, b.population from project_census.dataset1 a inner join project_census.dataset2 b on a.district = b.district) d) e

group by e.state) c

-- Population/ vs area

select (g.total_area/g.Previous_census_population)_vs_area , (g.total_area/Current_population) Current_population_vs_area from
(select q.* , r.total_area from(

select  "1"as num, n.* from  # adding the common key so we can join the table
(select sum(c.Previous_census_population) Previous_census_population , sum(Current_population) Current_population from (
select e.state, sum(e.previous_census_population) Previous_census_population , sum(e.current_census_population ) Current_population     from
(select d.district,d.state,round( d.population/ (1+d.growth),0) previous_census_population, d.population current_census_population from
(select a.district, a.state, a.growth/100 growth, b.population from project_census.dataset1 a inner join project_census.dataset2 b on a.district = b.district) d) e

group by e.state) c)n) q inner join (

select  "1"as num, m.* from ## adding the common key so we can join the table
(select sum(Area_km2) total_area from Project_census.dataset2) m) r on q.num = r.num) g


-- Window function
# output top 3 district from each state with highest literacy rate
select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) 
rnk from project_census.dataset1 ) a
where a.rnk in (1,2,3)









  
  
  
  







