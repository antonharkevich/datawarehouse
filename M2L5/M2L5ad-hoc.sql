VARIABLE n_all_data NUMBER;
VARIABLE n_customer NUMBER;
VARIABLE n_company NUMBER;
VARIABLE n_summary NUMBER;

BEGIN
 -- set values to 0 to disable
 :n_all_data := 0; -- 1 to enable
 :n_customer := 2; -- 2 to enable
 :n_company  := 0; -- 3 to enable
 :n_summary  := 4; -- 4 to enable
END;
/

 SELECT /*+ gather_plan_statistics */
          g.game_desc game
        , countries.country_desc country
        , decode(GROUPING(C.company_desc),1,'ALL ÑOMPANIES',C.company_desc) company
        , decode(GROUPING(cus.customer_desc),1,'ALL CUSTOMERS',cus.customer_desc) customer
        , d.month_number_of_yr month
        , gen.sales_cat_desc category_of_success
        , SUM(S.fct_sales_amount) sales_amount
   FROM ts_dw_data_user.dw_sales s
        , ts_dw_data_user.dw_date d
        , ts_dw_data_user.dw_companies c
        , ts_dw_data_user.dw_customers cus
        , ts_dw_data_user.dw_games_scd g
        , ts_dw_data_user.dw_geo_locations countries
        , ts_dw_data_user.dw_gen_periods gen
  WHERE s.date_id = d.date_id 
    AND s.company_id = c.company_id 
    AND s.game_surr_id = g.game_surr_id 
    AND s.customer_id = cus.customer_id 
    AND d.year_id IN (2019) 
    AND d.month_number_of_yr BETWEEN 1 AND 13
    AND s.country_id = countries.country_id
    AND s.sales_cat_id = gen.sales_cat_id
  GROUP BY d.month_number_of_yr
           , g.game_desc
           , gen.sales_cat_desc
           , countries.country_desc
           , ROLLUP(c.company_desc, cus.customer_desc)
 HAVING GROUPING_ID(c.company_desc,cus.customer_desc)+1 IN(:n_all_data,:n_customer,:n_company,:n_summary)
  ORDER BY 5, 1, 2, 3, 4, 6;
  
  

create or replace view dw_cl_user.mmmain as 
SELECT
        s.sales_id  id
        ,g.game_desc game
        , countries.country_desc country
        , C.company_desc company
        , cus.customer_desc customer
        , d.month_number_of_yr month
        , gen.sales_cat_desc category_of_success
        , S.fct_sales_amount sales_amount
   FROM   ts_dw_data_user.dw_sales s
        , ts_dw_data_user.dw_date d
        , ts_dw_data_user.dw_companies c
        , ts_dw_data_user.dw_customers cus
        , ts_dw_data_user.dw_games_scd g
        , ts_dw_data_user.dw_geo_locations countries
        , ts_dw_data_user.dw_gen_periods gen
  WHERE s.date_id = d.date_id 
    AND s.company_id = c.company_id 
    AND s.game_surr_id = g.game_surr_id 
    AND s.customer_id = cus.customer_id 
    AND d.year_id IN (2018) 
    AND d.month_number_of_yr BETWEEN 1 AND 13
    AND s.country_id = countries.country_id
    AND s.sales_cat_id = gen.sales_cat_id;

SET AUTOTRACE ON;
--set timing on;
   SELECT /*+ gather_plan_statistics */ *
     FROM dw_cl_user.mmmain
    GROUP BY  month, company, customer, country, category_of_success
    MODEL
DIMENSION BY (SUM(id) AS ID)
 MEASURES (company
           , SUM(sales_amount) sales_amount
           , category_of_success
           , customer
           , country
           , MONTH
           ,0 AS income)
    RULES (income[ANY] = sales_amount[cv()]);
