GRANT CREATE MATERIALIZED VIEW TO ts_dw_data_user;

CREATE MATERIALIZED VIEW ts_dw_data_user.sales_month_report
TABLESPACE ts_dw_data
BUILD IMMEDIATE
REFRESH ON DEMAND
AS SELECT
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
  ORDER BY 5, 1, 2, 3, 4, 6;
  
CREATE OR REPLACE 
PROCEDURE ts_dw_data_user.MAT_VIEW_SALES_MONTH_REPORT_REFRESH
IS
BEGIN
   DBMS_MVIEW.REFRESH(LIST=>'ts_dw_data_user.sales_month_report');
END;

BEGIN
   ts_dw_data_user.MAT_VIEW_SALES_MONTH_REPORT_REFRESH;
END;

select * from ts_dw_data_user.sales_month_report;

update ts_dw_data_user.dw_sales
set sales_cat_id = 3
where game_surr_id = 1000 and company_id = 217667 and fct_sales_amount = 866697 and customer_id = 3084829; 