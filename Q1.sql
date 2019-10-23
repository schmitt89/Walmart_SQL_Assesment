----------------------------------------------QUESTION 1----------------------------------------------

--pull data for date range,get count of customers, and stage data for calculations
create table q1 as
WITH  
--first create cte 
        q1_1 (ugc_id, distinct_cust_2018, customers_35) as     
            (
                select distinct
                    ugc_id,
                --get distinct count of all customers who placed an order online for store pick up in 2018
                    count(distinct ugc_id)  over (),
                -- create binary flag for each customer who had an order over $35 
                --below line will return a 1 for any customer who had any purchase over $35 and 0 for all customers who did not
                    max(case when amount > 35 then 1 else 0 end) over(partition by ugc_id) 
                
                where 1=1
                --cast string as date for calculation
                --limits to all customers who had any online order with store pickup in 2018
                and cast(visit_date as DATE) between '2018-01-01' and '2018-12-31'
                and channel = 'DOTCOM'
                and service_id in (8, 11)
            ),
        q1_2 (distinct_cust_2018, purchase_count_35) as
        (
        select distinct
            --carry over count of unique customers in 2018 from first CTE
            distinct_cust_2018,
            --gets sum of unique customers who DID have a purchase (we can use this to calculate count and percent of thise who did not have a purchase)
            sum(customers_35) over()
        from q1_1
        )
select 
--subtract number of customers with $35 purchase from total customers 2018 to get count of those who have never placed a pick-up order of over $35
    distinct_cust_2018-purchase_count_35 as count_no35_order,
-- get %age of those who have never placed a pick-up order of over $35
    1-(purchase_count_35/distinct_cust_2018) as per_no35_order
from q1_2
;
