SET AUTOTRACE ON;
SET TIMING ON;
SELECT /*+ gather_plan_statistics */ g.game_desc game
       , decode(GROUPING(c.company_desc),1,'ALL COMPANIES',c.company_desc) company
       , decode(GROUPING(cus.customer_desc),1,'ALL CUSTOMERS',cus.customer_desc) customer
       , d.month_number_of_yr month
       , gen.sales_cat_id sales_category
       , geo.country_id country
       , SUM(S.fct_sales_amount) sales_amount
  FROM ts_sal_data_user.fct_sales_dd s
       INNER JOIN ts_sal_data_user.dim_date d
               ON s.date_id      = d.date_id
       INNER JOIN ts_sal_data_user.dim_companies c
               ON s.company_id   = c.company_id
       INNER JOIN ts_sal_data_user.dim_customers cus
               ON s.customer_id  = cus.customer_id
       INNER JOIN ts_sal_data_user.dim_games_scd g
               ON s.game_surr_id = g.game_surr_id
       INNER JOIN ts_sal_data_user.dim_geo_locations geo 
               ON s.country_id   = geo.country_id
       INNER JOIN ts_sal_data_user.dim_gen_periods gen
               ON s.sales_cat_id = gen.sales_cat_id
 WHERE d.year_id IN (2018) 
   AND d.month_number_of_yr BETWEEN 1 AND 13
   AND s.is_deleted = 0
 GROUP BY d.month_number_of_yr
          , g.game_desc
          , CUBE(c.company_desc, cus.customer_desc)
          , gen.sales_cat_id
          , geo.country_id
 ORDER BY 4, 1, 2, 3;