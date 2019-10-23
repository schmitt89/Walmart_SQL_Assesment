

WITH 
    CTE1 AS 
    (
            -- create idex that will be required for join (assigns a row number to YQ which is a identifier for year and quarter)
    	SELECT 
            ugc_id,
            DENSE_RANK() OVER (ORDER BY YQ) AS Indexed_Q,
            YQ
    	FROM 
    	    (
    	    
    		--Create table that has distinct customer with purchase made for each quarter   
    		SELECT 
    		    ugc_id
    		-- Combine year and quarter fields to create a unique identifier key
    			,CONCAT (YEAR(to_date(visit_date, 'YYYYMMDD')),QUARTER(to_date(visit_date, 'YYYYMMDD'))) AS YQ 
    		FROM TABLE
    		WHERE 1=1
    		--set date restriction to limit scope of query (cast dates)
    		    AND cast(visit_date as DATE) BETWEEN  '2017-01-01' and '2018-12-31'
    			AND channel = 'DOTCOM'
    		GROUP BY 
    		    ugc_id, CONCAT (YEAR(to_date(visit_date, 'YYYYMMDD')),Quarter(to_date(visit_date, 'YYYYMMDD')))
		    )
	    )

    	
--use CTE to calculate the rate at which customermers will repeat a purchase for a consecutive quarter. Data at quarter level
SELECT
--place data at the quarter level 
    YQ
    ,count(distinct ugc_id) AS customer_count
    ,count(distinct repeat) AS customer_repeat_count
    ,count(distinct repeat) / count(distinct ugc_id) AS repeat_percent
FROM (
	SELECT 
	    a.YQ,
		a.ugc_id,
		-- create flag for repeat purchase in consecutive quarter
		b.ugc_id AS repeat 
    --self join	
	FROM CTE1 a
	LEFT JOIN CTE1 b 
    	ON a.ugc_id = b.ugc_id
    	-- below filter is to ensure we look at customers who made a purchase in the consecutive quarter (the row index applied in the CTE will allow for q4/q1 comparison accross years)
	    AND a.Indexed_Q = (b.Indexed_Q - 1) 
	)
GROUP BY 1
ORDER BY 1;