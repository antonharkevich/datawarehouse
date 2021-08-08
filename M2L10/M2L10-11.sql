--grant all privileges on ts_dw_data_user.dw_sales to sal_dw_cl_user; 
--grant unlimited tablespace to sal_dw_cl_user;
--grant all  privileges on sal_dw_cl_user.temp_sales to TS_SAL_DATA_USER;
--grant unlimited tablespace to TS_SAL_DATA_USER;
--
--
--create global temporary table sal_dw_cl_user.temp_sales
--ON COMMIT DELETE ROWS
--as (select * from ts_dw_data_user.dw_sales);

insert into sal_dw_cl_user.temp_sales
(select * from ts_dw_data_user.dw_sales);

select * from sal_dw_cl_user.temp_sales;

delete from sal_dw_cl_user.temp_sales s
WHERE NOT EXISTS (SELECT 1 FROM ts_dw_data_user.dw_customers c WHERE c.customer_id=s.customer_id);

delete from sal_dw_cl_user.temp_sales s
WHERE NOT EXISTS (SELECT 1 FROM ts_dw_data_user.dw_companies c WHERE c.company_id=s.company_id);

delete from sal_dw_cl_user.temp_sales s
WHERE NOT EXISTS (SELECT 1 FROM ts_dw_data_user.dw_geo_locations g WHERE g.country_id=s.country_id);

delete from sal_dw_cl_user.temp_sales s
WHERE NOT EXISTS (SELECT 1 FROM ts_dw_data_user.dw_date d WHERE d.date_id=s.date_id);

delete from sal_dw_cl_user.temp_sales s
WHERE NOT EXISTS (SELECT 1 FROM ts_dw_data_user.dw_gen_periods g WHERE g.sales_cat_id=s.sales_cat_id);

delete from sal_dw_cl_user.temp_sales s
WHERE NOT EXISTS (SELECT 1 FROM ts_dw_data_user.dw_games_scd g WHERE g.game_surr_id=s.game_surr_id);



 MERGE INTO TS_SAL_DATA_USER.FCT_SALES_DD target
           USING (SELECT * FROM  sal_dw_cl_user.temp_sales) source
              ON ( target.sales_id = source.sales_id)
      WHEN NOT MATCHED THEN
         INSERT (sales_id, customer_id, game_surr_id, company_id, country_id, date_id, sales_cat_id, fct_sales_amount, fct_sales_dollars, fct_profit_margin, insert_dt, event_dt)
             VALUES (source.sales_id, source.customer_id, source.game_surr_id, source.company_id, source.country_id, source.date_id, source.sales_cat_id, source.fct_sales_amount, 
                    source.fct_sales_dollars, source.fct_profit_margin 
                    , source.insert_dt
                    , source.event_dt)
      WHEN MATCHED THEN
         UPDATE SET target.customer_id=source.customer_id, target.game_surr_id=source.game_surr_id, target.company_id=source.company_id
         , target.country_id=source.country_id, target.date_id=source.date_id, target.sales_cat_id=source.sales_cat_id
         , target.fct_sales_amount=source.fct_sales_amount, target.fct_profit_margin=source.fct_profit_margin, target.fct_sales_dollars=source.fct_sales_dollars
         , target.insert_dt= source.insert_dt, target.event_dt= source.event_dt;
commit;



--create global temporary table sal_dw_cl_user.temp_customers
--ON COMMIT DELETE ROWS
--as (select * from ts_dw_data_user.dw_customers cus where cus.customer_id in (select customer_id from TS_SAL_DATA_USER.FCT_SALES_DD));

insert into sal_dw_cl_user.temp_customers
(select * from ts_dw_data_user.dw_customers cus where cus.customer_id in (select customer_id from TS_SAL_DATA_USER.FCT_SALES_DD));

select * from sal_dw_cl_user.temp_customers;

MERGE INTO TS_SAL_DATA_USER.DIM_CUSTOMERS target
           USING (SELECT * FROM  sal_dw_cl_user.temp_customers) source
              ON ( target.customer_id = source.customer_id)
      WHEN NOT MATCHED THEN
         INSERT (customer_id, customer_desc, customer_age, customer_gender, insert_dt, update_dt)
             VALUES (source.customer_id, source.customer_desc, source.customer_age, source.customer_gender, source.insert_dt, source.update_dt)
      WHEN MATCHED THEN
         UPDATE SET target.customer_desc=source.customer_desc, target.customer_gender=source.customer_gender
         , target.customer_age=source.customer_age, target.insert_dt=source.insert_dt, target.update_dt=source.update_dt;
commit;


--create global temporary table sal_dw_cl_user.temp_companies
--ON COMMIT DELETE ROWS
--as (select * from ts_dw_data_user.dw_companies cus where cus.company_id in (select company_id from TS_SAL_DATA_USER.FCT_SALES_DD));

insert into sal_dw_cl_user.temp_companies
(select * from ts_dw_data_user.dw_companies cus where cus.company_id in (select company_id from TS_SAL_DATA_USER.FCT_SALES_DD));

select * from sal_dw_cl_user.temp_companies;

MERGE INTO TS_SAL_DATA_USER.DIM_COMPANIES target
           USING (SELECT * FROM  sal_dw_cl_user.temp_companies) source
              ON ( target.company_id = source.company_id)
      WHEN NOT MATCHED THEN
         INSERT (company_id, company_name, company_desc, insert_dt, update_dt)
             VALUES (source.company_id, source.company_name, source.company_desc, source.insert_dt, source.update_dt)
      WHEN MATCHED THEN
         UPDATE SET target.company_name=source.company_name, target.company_desc=source.company_desc,
         target.insert_dt=source.insert_dt, target.update_dt=source.update_dt;
commit;


--create global temporary table sal_dw_cl_user.temp_geo_locations
--ON COMMIT DELETE ROWS
--as (select * from ts_dw_data_user.dw_geo_locations cus where cus.country_id in (select country_id from TS_SAL_DATA_USER.FCT_SALES_DD));

insert into sal_dw_cl_user.temp_geo_locations
(select * from ts_dw_data_user.dw_geo_locations cus where cus.country_id in (select country_id from TS_SAL_DATA_USER.FCT_SALES_DD));

select * from sal_dw_cl_user.temp_geo_locations;

MERGE INTO TS_SAL_DATA_USER.DIM_GEO_LOCATIONS target
           USING (SELECT * FROM  sal_dw_cl_user.temp_geo_locations) source
              ON ( target.country_id = source.country_id)
      WHEN NOT MATCHED THEN
         INSERT (country_id, country_desc, region_id, region_desc, part_id, part_desc, geo_systems_id, geo_systems_code, geo_systems_desc, insert_dt, update_dt)
             VALUES (source.country_id, source.country_desc, source.region_id, source.region_desc, source.part_id,
             source.part_desc, source.geo_systems_id, source.geo_systems_code, source.geo_systems_desc, source.insert_dt, source.update_dt)
      WHEN MATCHED THEN
         UPDATE SET target.country_desc=source.country_desc, target.region_id=source.region_id,
         target.region_desc=source.region_desc, target.part_id=source.part_id,
         target.part_desc=source.part_desc, target.geo_systems_id=source.geo_systems_id,
         target.geo_systems_code=source.geo_systems_code, target.geo_systems_desc=source.geo_systems_desc,
         target.insert_dt=source.insert_dt, target.update_dt=source.update_dt;
commit;

--create global temporary table sal_dw_cl_user.temp_gen_periods
--ON COMMIT DELETE ROWS
--as (select * from ts_dw_data_user.dw_gen_periods cus where cus.sales_cat_id in (select sales_cat_id from TS_SAL_DATA_USER.FCT_SALES_DD));

insert into sal_dw_cl_user.temp_gen_periods
(select * from ts_dw_data_user.dw_gen_periods cus where cus.sales_cat_id in (select sales_cat_id from TS_SAL_DATA_USER.FCT_SALES_DD));

select * from sal_dw_cl_user.temp_gen_periods;

MERGE INTO TS_SAL_DATA_USER.DIM_GEN_PERIODS target
           USING (SELECT * FROM  sal_dw_cl_user.temp_gen_periods) source
              ON ( target.sales_cat_id = source.sales_cat_id)
      WHEN NOT MATCHED THEN
         INSERT (sales_cat_id, sales_cat_desc, start_amount, end_amount, insert_dt, update_dt)
             VALUES (source.sales_cat_id, source.sales_cat_desc, source.start_amount, source.end_amount, source.insert_dt, source.update_dt)
      WHEN MATCHED THEN
         UPDATE SET target.sales_cat_desc=source.sales_cat_desc, target.start_amount=source.start_amount,
         target.end_amount=source.end_amount, target.insert_dt=source.insert_dt, target.update_dt=source.update_dt;
commit;


--create global temporary table sal_dw_cl_user.temp_games
--ON COMMIT DELETE ROWS
--as (select * from ts_dw_data_user.dw_games_scd cus where cus.game_id in (select game_surr_id from TS_SAL_DATA_USER.FCT_SALES_DD));

insert into sal_dw_cl_user.temp_games
(select * from ts_dw_data_user.dw_games_scd cus where cus.game_id in (select game_surr_id from TS_SAL_DATA_USER.FCT_SALES_DD));

select * from sal_dw_cl_user.temp_games;

MERGE INTO TS_SAL_DATA_USER.DIM_GAMES_SCD target
           USING (SELECT * FROM  sal_dw_cl_user.temp_games) source
              ON ( target.game_surr_id = source.game_surr_id)
      WHEN NOT MATCHED THEN
         INSERT (game_surr_id, game_id, game_desc, game_cost, valid_from, valid_to, is_active, category_id, category_desc, platform_id, platform_desc, insert_dt, update_dt)
             VALUES (source.game_surr_id, source.game_id, source.game_desc, source.game_cost, source.valid_from, source.valid_to,
                    source.is_active, source.category_id, source.category_desc, source.platform_id, source.platform_desc, source.insert_dt, source.update_dt)
      WHEN MATCHED THEN
         UPDATE SET target.game_desc=source.game_desc, target.game_cost=source.game_cost,
         target.valid_from=source.valid_from, target.valid_to=source.valid_to, target.is_active=source.is_active,
         target.category_id=source.category_id, target.category_desc=source.category_desc, target.platform_id=source.platform_id,
         target.platform_desc=source.platform_desc, target.insert_dt=source.insert_dt, target.update_dt=source.update_dt;
commit;



--create global temporary table sal_dw_cl_user.temp_date
--ON COMMIT DELETE ROWS
--as (select * from ts_dw_data_user.dw_date cus where cus.date_id in (select date_id from TS_SAL_DATA_USER.FCT_SALES_DD));

insert into sal_dw_cl_user.temp_date
(select * from ts_dw_data_user.dw_date cus where cus.date_id in (select date_id from TS_SAL_DATA_USER.FCT_SALES_DD));

select * from sal_dw_cl_user.temp_date;

MERGE INTO TS_SAL_DATA_USER.DIM_DATE target
           USING (SELECT * FROM  sal_dw_cl_user.temp_date) source
              ON ( target.date_id = source.date_id)
      WHEN NOT MATCHED THEN
         INSERT (date_id, DATE_DESC, DATE_FULL_NUMBER, DATE_FULL_STRING, WEEKDAY_FL, US_CIVIL_HOLIDAY_FL, LAST_DAY_OF_WEEK_FL, LAST_DAY_OF_MONTH_FL, LAST_DAY_OF_QTR_FL, LAST_DAY_OF_YR_FL, DAY_ID, DAY_DESC, DAY_OF_WEEK_NAME,
         DAY_OF_WEEK_ABBR, DAY_NUMBER_OF_WEEK, DAY_NUMBER_OF_MONTH, DAY_NUMBER_OF_QTR, DAY_NUMBER_OF_YR, WEEK_ID, WEEK_DESC, WEEK_NUMBER_OF_MONTH, WEEK_NUMBER_OF_QTR, WEEK_NUMBER_OF_YR,
         WEEK_BEGIN_DT, WEEK_END_DT, MONTH_ID, MONTH_DESC, MONTH_NAME, MONTH_NAME_ABBR, MONTH_NUMBER_OF_YR, MONTH_BEGIN_DT, MONTH_END_DT, QUARTER_ID, QUARTER_DESC, QTR_NUMBER_OF_YR,
         QTR_BEGIN_DT, QTR_END_DT, YEAR_ID, YEAR_DESC, YR_BEGIN_DT, YR_END_DT, INSERT_DT, UPDATE_DT)
             VALUES (source.date_id, source.DATE_DESC, source.DATE_FULL_NUMBER, source.DATE_FULL_STRING, source.WEEKDAY_FL, source.US_CIVIL_HOLIDAY_FL,
                    source.LAST_DAY_OF_WEEK_FL, source.LAST_DAY_OF_MONTH_FL, source.LAST_DAY_OF_QTR_FL, source.LAST_DAY_OF_YR_FL, source.DAY_ID, source.DAY_DESC, source.DAY_OF_WEEK_NAME,
                    source.DAY_OF_WEEK_ABBR, source.DAY_NUMBER_OF_WEEK, source.DAY_NUMBER_OF_MONTH, source.DAY_NUMBER_OF_QTR, source.DAY_NUMBER_OF_YR, source.WEEK_ID, source.WEEK_DESC,
                    source.WEEK_NUMBER_OF_MONTH, source.WEEK_NUMBER_OF_QTR, source.WEEK_NUMBER_OF_YR, source.WEEK_BEGIN_DT, source.WEEK_END_DT, source.MONTH_ID, source.MONTH_DESC,
                    source.MONTH_NAME, source.MONTH_NAME_ABBR, source.MONTH_NUMBER_OF_YR, source.MONTH_BEGIN_DT, source.MONTH_END_DT, source.QUARTER_ID, source.QUARTER_DESC,
                    source.QTR_NUMBER_OF_YR, source.QTR_BEGIN_DT, source.QTR_END_DT, source.YEAR_ID, source.YEAR_DESC, source.YR_BEGIN_DT, source.YR_END_DT, source.insert_dt, source.update_dt)
      WHEN MATCHED THEN
         UPDATE SET target.DATE_DESC=source.DATE_DESC, target.DATE_FULL_NUMBER=source.DATE_FULL_NUMBER,
         target.DATE_FULL_STRING=source.DATE_FULL_STRING, target.WEEKDAY_FL=source.WEEKDAY_FL, target.US_CIVIL_HOLIDAY_FL=source.US_CIVIL_HOLIDAY_FL,
         target.LAST_DAY_OF_WEEK_FL=source.LAST_DAY_OF_WEEK_FL, target.LAST_DAY_OF_MONTH_FL=source.LAST_DAY_OF_MONTH_FL, target.LAST_DAY_OF_QTR_FL=source.LAST_DAY_OF_QTR_FL,
         target.LAST_DAY_OF_YR_FL=source.LAST_DAY_OF_YR_FL, target.DAY_ID=source.DAY_ID, target.DAY_DESC=source.DAY_DESC,
         target.DAY_OF_WEEK_NAME=source.DAY_OF_WEEK_NAME, target.DAY_OF_WEEK_ABBR=source.DAY_OF_WEEK_ABBR, target.DAY_NUMBER_OF_WEEK=source.DAY_NUMBER_OF_WEEK,
         target.DAY_NUMBER_OF_MONTH=source.DAY_NUMBER_OF_MONTH, target.DAY_NUMBER_OF_QTR=source.DAY_NUMBER_OF_QTR, target.DAY_NUMBER_OF_YR=source.DAY_NUMBER_OF_YR,
         target.WEEK_ID=source.WEEK_ID, target.WEEK_DESC=source.WEEK_DESC, target.WEEK_NUMBER_OF_MONTH=source.WEEK_NUMBER_OF_MONTH,
         target.WEEK_NUMBER_OF_QTR=source.WEEK_NUMBER_OF_QTR, target.WEEK_NUMBER_OF_YR=source.WEEK_NUMBER_OF_YR, target.WEEK_BEGIN_DT=source.WEEK_BEGIN_DT,
         target.WEEK_END_DT=source.WEEK_END_DT, target.MONTH_ID=source.MONTH_ID, target.MONTH_DESC=source.MONTH_DESC,
         target.MONTH_NAME=source.MONTH_NAME, target.MONTH_NAME_ABBR=source.MONTH_NAME_ABBR, target.MONTH_NUMBER_OF_YR=source.MONTH_NUMBER_OF_YR,
         target.MONTH_BEGIN_DT=source.MONTH_BEGIN_DT, target.MONTH_END_DT=source.MONTH_END_DT, target.QUARTER_ID=source.QUARTER_ID,
         target.QUARTER_DESC=source.QUARTER_DESC, target.QTR_NUMBER_OF_YR=source.QTR_NUMBER_OF_YR, target.QTR_BEGIN_DT=source.QTR_BEGIN_DT,
         target.QTR_END_DT=source.QTR_END_DT, target.YEAR_ID=source.YEAR_ID, target.YEAR_DESC=source.YEAR_DESC,
         target.YR_BEGIN_DT=source.YR_BEGIN_DT, target.YR_END_DT=source.YR_END_DT, target.insert_dt=source.insert_dt,
         target.update_dt=source.update_dt;
commit;