---------------------------------------------------------------QUESTION 2--------------------------------------------------
--pull all revenue by chanel for the year 2017 sum bu month to get revenue in each month
create table q2_data as
select 
--extract year and month from date to perform quicker calculation
    YEAR(cast(visit_date AS DATE)) as year,
    MONTH(cast(visit_date AS DATE)) as month,
    channel,
    sum(amount) as revenue,
--create rand field for months to be used in calculation below


from data_table
where 1=1
and cast(visit_date as DATE) between '2017-01-01' and '2017-12-31'
and channel in ('DOTCOM','OG')

group by 1,2,3
--must order my month
order by 2
;

--add revenue by month to create cumulative revenue report for 2017
--here i will create a Cartesian product to do the calculation quickly without having to explicitly type my sum conditions
create table q2_summary as
select 
    a.year,
    a.month,
    sum(b.revenue) As revenue_YTD

from q2_data a
    cross join q2_data b
--limit so that table b revenue is summed for months <= month value to get cumulative ytd rev for each month
        where b.month <= a.month
        and a.month <> month(getdate())
group by a.year,a.month
order by a.month 
;   

