 CREATE MATERIALIZED VIEW ts_dw_data_user.sales_storage_report 
  BUILD IMMEDIATE
REFRESH ON COMMIT AS SELECT
        s.sales_id  id
        ,g.game_desc game
        , countries.country_desc country
        , C.company_desc company
        , cus.customer_desc customer
        , d.month_number_of_yr month
        , gen.sales_cat_desc category_of_success
        , S.fct_sales_amount sales_amount
   FROM ts_dw_data_user.dw_sales s
        , ts_dw_data_user.dw_date d
        , ts_dw_data_user.dw_companies c
        , ts_dw_data_user.dw_customers cus
        , ts_dw_data_user.dw_games_scd g
        , ts_dw_data_user.dw_geo_locations countries
        , ts_dw_data_user.dw_gen_periods gen
  WHERE s.date_id      = d.date_id 
    AND s.company_id   = c.company_id 
    AND s.game_surr_id = g.game_surr_id 
    AND s.customer_id  = cus.customer_id 
    AND d.year_id IN (2019) 
    AND d.month_number_of_yr BETWEEN 1 AND 13
    AND s.country_id   = countries.country_id
    AND s.sales_cat_id = gen.sales_cat_id;

SELECT * FROM ts_dw_data_user.sales_storage_report;


UPDATE ts_dw_data_user.dw_sales 
   SET sales_cat_id = 1
 WHERE game_surr_id = 16496 
   AND company_id = 271481 
   AND fct_sales_amount = 33894 
   AND customer_id = 3502573; 
COMMIT;