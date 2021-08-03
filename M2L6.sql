SELECT DISTINCT company_id, country_id, date_id, FIRST_VALUE(fct_sales_amount)
 OVER (PARTITION BY company_id, country_id, date_id ORDER BY fct_sales_amount DESC
       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
       AS "HIGHEST_SALES_AMOUNT",
     FIRST_VALUE(fct_sales_dollars)
 OVER (PARTITION BY company_id, country_id, date_id ORDER BY fct_sales_dollars DESC
       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
       AS "HIGHEST_SALES_DOLLARS"
FROM ts_dw_data_user.dw_sales
ORDER BY company_id, country_id, date_id;



SELECT DISTINCT game_surr_id, LAST_VALUE(fct_sales_amount)
 OVER (PARTITION BY game_surr_id ORDER BY fct_sales_amount DESC
       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
       AS "LOW_SALES_AMOUNT",
    LAST_VALUE(fct_sales_dollars)
 OVER (PARTITION BY game_surr_id ORDER BY fct_sales_dollars DESC
       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
       AS "LOW_SALES_DOLLARS"
FROM ts_dw_data_user.dw_sales
ORDER BY game_surr_id;

select * from (
select company_id, 
       fct_sales_amount,
       RANK() OVER (PARTITION BY sales_cat_id ORDER BY fct_sales_amount)sales_rank
  from ts_dw_data_user.dw_sales
 where sales_cat_id between 1 and 3
)   where sales_rank<=10;


select * from (
select company_id, 
       fct_sales_amount,
       DENSE_RANK() OVER (PARTITION BY sales_cat_id ORDER BY fct_sales_amount)sales_rank
  from ts_dw_data_user.dw_sales
 where sales_cat_id between 1 and 3
)   where sales_rank<=10; 
 

select * from (
select company_id, 
       fct_sales_amount,
       RANK() OVER (PARTITION BY sales_cat_id ORDER BY fct_sales_amount)sales_rank,
       DENSE_RANK() OVER (PARTITION BY sales_cat_id ORDER BY fct_sales_amount)sales_dense_rank,
       ROW_NUMBER() OVER (PARTITION BY sales_cat_id ORDER BY fct_sales_amount)sales_rn
  from ts_dw_data_user.dw_sales
 where sales_cat_id between 1 and 3
)   where sales_rank<=10;


SELECT DISTINCT country_id, MAX(fct_sales_amount)
 OVER (PARTITION BY  country_id ORDER BY fct_sales_amount DESC
       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
       AS "MAX_SALES_AMOUNT",
     MAX(fct_sales_dollars)
 OVER (PARTITION BY  country_id ORDER BY fct_sales_dollars DESC
       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
       AS "MAX_SALES_DOLLARS",
MIN(fct_sales_amount)
 OVER (PARTITION BY country_id ORDER BY fct_sales_amount DESC
       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
       AS "MIN_SALES_AMOUNT",
     MIN(fct_sales_dollars)
 OVER (PARTITION BY country_id ORDER BY fct_sales_dollars DESC
       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
       AS "MIN_SALES_DOLLARS",
       ROUND(AVG(fct_sales_amount)
 OVER (PARTITION BY country_id ORDER BY fct_sales_amount DESC
       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING), 0)
       AS "AVG_SALES_AMOUNT",
     ROUND(AVG(fct_sales_dollars)
 OVER (PARTITION BY country_id ORDER BY fct_sales_dollars DESC
       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),0)
       AS "AVG_SALES_DOLLARS"
FROM ts_dw_data_user.dw_sales
ORDER BY country_id;