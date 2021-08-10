DECLARE
--    TYPE date_curs IS REF CURSOR; 
--    curs date_curs;
    TYPE curs IS REF CURSOR; 
    first_curs curs; 
    second_curs curs;
BEGIN   

DW_CL_USER.pkg_etl_dim_locations_dw_v2.load_locations;
     
END;


--    DW_CL_USER.pkg_etl_dim_gen_periods_dw.load_gen_periods(first_curs, second_curs);
--    DW_CL_USER.pkg_etl_dim_locations_dw.load_locations;
--    DW_CL_USER.pkg_etl_dim_date_dw.load_date(curs);
--    DW_CL_USER.pkg_etl_dim_companies_dw.load_companies;
--    DW_CL_USER.pkg_etl_dim_customers_dw.load_customers;
--    DW_CL_USER.pkg_etl_dim_sales_dw.load_sales; 
--    DW_CL_USER.pkg_etl_dim_locations_dw_v2.load_locations;
--    DW_CL_USER.pkg_etl_dim_sales_dw.load_sales; 
--    DW_CL_USER.pkg_etl_dim_companies_dw.load_companies;
--    DW_CL_USER.pkg_etl_dim_gen_periods_dw.load_gen_periods(first_curs, second_curs);
--    DW_CL_USER.pkg_etl_dim_locations_dw.load_locations;
--    DW_CL_USER.pkg_etl_dim_date_dw.load_date(curs);
--    DW_CL_USER.pkg_etl_dim_customers_dw.load_customers;
--    DW_CL_USER.pkg_etl_dim_companies_dw.load_companies;
--    DW_CL_USER.pkg_etl_dim_games_dw.load_games;
