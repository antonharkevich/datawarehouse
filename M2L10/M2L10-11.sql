GRANT ALL PRIVILEGES ON ts_dw_data_user.dw_sales TO sal_dw_cl_user; 
GRANT ALL PRIVILEGES ON ts_dw_data_user.dw_customers TO sal_dw_cl_user; 
GRANT ALL PRIVILEGES ON ts_dw_data_user.dw_companies TO sal_dw_cl_user; 
GRANT ALL PRIVILEGES ON ts_dw_data_user.dw_geo_locations TO sal_dw_cl_user; 
GRANT ALL PRIVILEGES ON ts_dw_data_user.dw_date TO sal_dw_cl_user; 
GRANT ALL PRIVILEGES ON ts_dw_data_user.dw_gen_periods TO sal_dw_cl_user; 
GRANT ALL PRIVILEGES ON ts_dw_data_user.dw_games_scd TO sal_dw_cl_user; 
GRANT ALL PRIVILEGES ON ts_sal_data_user.fct_sales_dd TO sal_dw_cl_user; 
GRANT ALL PRIVILEGES ON ts_sal_data_user.dim_customers TO sal_dw_cl_user; 
GRANT ALL PRIVILEGES ON ts_sal_data_user.dim_companies TO sal_dw_cl_user; 
GRANT ALL PRIVILEGES ON ts_sal_data_user.dim_games_scd TO sal_dw_cl_user; 
GRANT ALL PRIVILEGES ON ts_sal_data_user.dim_date TO sal_dw_cl_user; 
GRANT ALL PRIVILEGES ON ts_sal_data_user.dim_geo_locations TO sal_dw_cl_user; 
GRANT ALL PRIVILEGES ON ts_sal_data_user.dim_gen_periods TO sal_dw_cl_user; 
GRANT UNLIMITED TABLESPACE TO sal_dw_cl_user;
GRANT ALL  PRIVILEGES ON sal_dw_cl_user.temp_sales TO ts_sal_data_user;
GRANT UNLIMITED TABLESPACE TO ts_sal_data_user;


--create global temporary table sal_dw_cl_user.temp_sales
--ON COMMIT DELETE ROWS
--as (select * from ts_dw_data_user.dw_sales);

--create global temporary table sal_dw_cl_user.temp_customers
--ON COMMIT DELETE ROWS
--as (select * from ts_dw_data_user.dw_customers cus where cus.customer_id in (select customer_id from TS_SAL_DATA_USER.FCT_SALES_DD));

--create global temporary table sal_dw_cl_user.temp_companies
--ON COMMIT DELETE ROWS
--as (select * from ts_dw_data_user.dw_companies cus where cus.company_id in (select company_id from TS_SAL_DATA_USER.FCT_SALES_DD));


--create global temporary table sal_dw_cl_user.temp_geo_locations
--ON COMMIT DELETE ROWS
--as (select * from ts_dw_data_user.dw_geo_locations cus where cus.country_id in (select country_id from TS_SAL_DATA_USER.FCT_SALES_DD));

--create global temporary table sal_dw_cl_user.temp_games
--ON COMMIT DELETE ROWS
--as (select * from ts_dw_data_user.dw_games_scd cus where cus.game_id in (select game_surr_id from TS_SAL_DATA_USER.FCT_SALES_DD));

--create global temporary table sal_dw_cl_user.temp_date
--ON COMMIT DELETE ROWS
--as (select * from ts_dw_data_user.dw_date cus where cus.date_id in (select date_id from TS_SAL_DATA_USER.FCT_SALES_DD));

--create global temporary table sal_dw_cl_user.temp_gen_periods
--ON COMMIT DELETE ROWS
--as (select * from ts_dw_data_user.dw_gen_periods cus where cus.sales_cat_id in (select sales_cat_id from TS_SAL_DATA_USER.FCT_SALES_DD));


CREATE OR REPLACE PROCEDURE sal_dw_cl_user.etl_dw_sales 
AS
BEGIN
 INSERT INTO sal_dw_cl_user.temp_sales
(SELECT * FROM ts_dw_data_user.dw_sales);

 DELETE FROM sal_dw_cl_user.temp_sales S
  WHERE  NOT EXISTS (SELECT 1 FROM ts_dw_data_user.dw_customers C WHERE C.customer_id=S.customer_id);

DELETE FROM sal_dw_cl_user.temp_sales S
 WHERE  NOT EXISTS (SELECT 1 FROM ts_dw_data_user.dw_companies C WHERE C.company_id=S.company_id);

DELETE FROM sal_dw_cl_user.temp_sales S
 WHERE  NOT EXISTS (SELECT 1 FROM ts_dw_data_user.dw_geo_locations G WHERE G.country_id=S.country_id);

DELETE FROM sal_dw_cl_user.temp_sales S
 WHERE  NOT EXISTS (SELECT 1 FROM ts_dw_data_user.dw_date D WHERE D.date_id=S.date_id);

DELETE FROM sal_dw_cl_user.temp_sales S
 WHERE  NOT EXISTS (SELECT 1 FROM ts_dw_data_user.dw_gen_periods G WHERE G.sales_cat_id=S.sales_cat_id);

DELETE FROM sal_dw_cl_user.temp_sales S
 WHERE  NOT EXISTS (SELECT 1 FROM ts_dw_data_user.dw_games_scd G WHERE G.game_surr_id=S.game_surr_id);

UPDATE ts_sal_data_user.fct_sales_dd target
   SET is_deleted = 1
  WHERE target.sales_id NOT IN (SELECT sales_id FROM sal_dw_cl_user.temp_sales);


 MERGE INTO ts_sal_data_user.fct_sales_dd TARGET
      USING (SELECT * FROM  sal_dw_cl_user.temp_sales) SOURCE
         ON ( TARGET.sales_id = SOURCE.sales_id)
       WHEN NOT MATCHED THEN
         INSERT (sales_id
                 , customer_id
                 , game_surr_id
                 , company_id
                 , country_id
                 , date_id
                 , sales_cat_id
                 , fct_sales_amount
                 , fct_sales_dollars
                 , fct_profit_margin
                 , insert_dt
                 , event_dt
                 , is_deleted)
         VALUES (SOURCE.sales_id
                , SOURCE.customer_id
                , SOURCE.game_surr_id
                , SOURCE.company_id
                , SOURCE.country_id
                , SOURCE.date_id
                , SOURCE.sales_cat_id
                , SOURCE.fct_sales_amount
                , SOURCE.fct_sales_dollars
                , SOURCE.fct_profit_margin 
                , SOURCE.insert_dt
                , SOURCE.event_dt
                , 0)
       WHEN MATCHED THEN
         UPDATE SET TARGET.customer_id          = SOURCE.customer_id
                    , TARGET.game_surr_id       = SOURCE.game_surr_id
                    , TARGET.company_id         = SOURCE.company_id
                    , TARGET.country_id         = SOURCE.country_id
                    , TARGET.date_id            = SOURCE.date_id
                    , TARGET.sales_cat_id       = SOURCE.sales_cat_id
                    , TARGET.fct_sales_amount   = SOURCE.fct_sales_amount
                    , TARGET.fct_profit_margin  = SOURCE.fct_profit_margin
                    , TARGET.fct_sales_dollars  = SOURCE.fct_sales_dollars
                    , TARGET.insert_dt          = SOURCE.insert_dt
                    , TARGET.event_dt           = SOURCE.event_dt
                    , TARGET.is_deleted         = 0;
COMMIT;

END;





CREATE OR REPLACE PROCEDURE sal_dw_cl_user.etl_dw_customers
AS
BEGIN
 INSERT INTO sal_dw_cl_user.temp_customers
(SELECT * FROM ts_dw_data_user.dw_customers cus WHERE cus.customer_id IN (SELECT customer_id FROM ts_sal_data_user.fct_sales_dd));


MERGE INTO ts_sal_data_user.dim_customers TARGET
     USING (SELECT * FROM  sal_dw_cl_user.temp_customers) SOURCE
        ON ( TARGET.customer_id = SOURCE.customer_id)
      WHEN NOT MATCHED THEN
        INSERT (customer_id
                , customer_desc
                , customer_age
                , customer_gender
                , insert_dt
                , update_dt)
        VALUES (SOURCE.customer_id
                , SOURCE.customer_desc
                , SOURCE.customer_age
                , SOURCE.customer_gender
                , SOURCE.insert_dt
                , SOURCE.update_dt)
      WHEN MATCHED THEN
        UPDATE SET TARGET.customer_desc      =  SOURCE.customer_desc
                    , TARGET.customer_gender =  SOURCE.customer_gender
                    , TARGET.customer_age    =  SOURCE.customer_age
                    , TARGET.insert_dt       =  SOURCE.insert_dt
                    , TARGET.update_dt       =  SOURCE.update_dt;
COMMIT;

END;


CREATE OR REPLACE PROCEDURE sal_dw_cl_user.etl_dw_companies
AS
BEGIN
 INSERT INTO sal_dw_cl_user.temp_companies
(SELECT * FROM ts_dw_data_user.dw_companies cus WHERE cus.company_id IN (SELECT company_id FROM ts_sal_data_user.fct_sales_dd));



MERGE INTO ts_sal_data_user.dim_companies TARGET
     USING (SELECT * FROM  sal_dw_cl_user.temp_companies) SOURCE
        ON ( TARGET.company_id = SOURCE.company_id)
      WHEN NOT MATCHED THEN
       INSERT (company_id
               , company_name
               , company_desc
               , insert_dt
               , update_dt)
       VALUES (SOURCE.company_id
               , SOURCE.company_name
               , SOURCE.company_desc
               , SOURCE.insert_dt
               , SOURCE.update_dt)
      WHEN MATCHED THEN
       UPDATE SET TARGET.company_name   = SOURCE.company_name
                  , TARGET.company_desc = SOURCE.company_desc
                  , TARGET.insert_dt    = SOURCE.insert_dt
                  , TARGET.update_dt    = SOURCE.update_dt;
COMMIT;

END;


CREATE OR REPLACE PROCEDURE sal_dw_cl_user.etl_geo_locations
AS
BEGIN
 INSERT INTO sal_dw_cl_user.temp_geo_locations
(SELECT * FROM ts_dw_data_user.dw_geo_locations cus WHERE cus.country_id IN (SELECT country_id FROM ts_sal_data_user.fct_sales_dd));



MERGE INTO ts_sal_data_user.dim_geo_locations TARGET
     USING (SELECT * FROM  sal_dw_cl_user.temp_geo_locations) SOURCE
        ON (TARGET.country_id = SOURCE.country_id)
      WHEN NOT MATCHED THEN
      INSERT (country_id
              , country_desc
              , region_id
              , region_desc
              , part_id
              , part_desc
              , geo_systems_id
              , geo_systems_code
              , geo_systems_desc
              , insert_dt
              , update_dt)
       VALUES (SOURCE.country_id
               , SOURCE.country_desc
               , SOURCE.region_id
               , SOURCE.region_desc
               , SOURCE.part_id
               , SOURCE.part_desc
               , SOURCE.geo_systems_id
               , SOURCE.geo_systems_code
               , SOURCE.geo_systems_desc
               , SOURCE.insert_dt
               , SOURCE.update_dt)
      WHEN MATCHED THEN
       UPDATE SET TARGET.country_desc         = SOURCE.country_desc
                  , TARGET.region_id          = SOURCE.region_id
                  , TARGET.region_desc        = SOURCE.region_desc
                  , TARGET.part_id            = SOURCE.part_id
                  , TARGET.part_desc          = SOURCE.part_desc
                  , TARGET.geo_systems_id     = SOURCE.geo_systems_id
                  , TARGET.geo_systems_code   = SOURCE.geo_systems_code
                  , TARGET.geo_systems_desc   = SOURCE.geo_systems_desc
                  , TARGET.insert_dt          = SOURCE.insert_dt
                  , TARGET.update_dt          = SOURCE.update_dt;
COMMIT;
END;


CREATE OR REPLACE PROCEDURE sal_dw_cl_user.etl_gen_periods
AS
BEGIN
 INSERT INTO sal_dw_cl_user.temp_gen_periods
(SELECT * FROM ts_dw_data_user.dw_gen_periods cus WHERE cus.sales_cat_id IN (SELECT sales_cat_id FROM ts_sal_data_user.fct_sales_dd));


MERGE INTO ts_sal_data_user.dim_gen_periods TARGET
     USING (SELECT * FROM  sal_dw_cl_user.temp_gen_periods) SOURCE
        ON ( TARGET.sales_cat_id = SOURCE.sales_cat_id)
      WHEN NOT MATCHED THEN
        INSERT (sales_cat_id
                , sales_cat_desc
                , start_amount
                , end_amount
                , insert_dt
                , update_dt)
        VALUES (SOURCE.sales_cat_id
                , SOURCE.sales_cat_desc
                , SOURCE.start_amount
                , SOURCE.end_amount
                , SOURCE.insert_dt
                , SOURCE.update_dt)
      WHEN MATCHED THEN
        UPDATE SET TARGET.sales_cat_desc  = SOURCE.sales_cat_desc
                   , TARGET.start_amount  = SOURCE.start_amount
                   , TARGET.end_amount    = SOURCE.end_amount
                   , TARGET.insert_dt     = SOURCE.insert_dt
                   , TARGET.update_dt     = SOURCE.update_dt;
COMMIT;
END;



CREATE OR REPLACE PROCEDURE sal_dw_cl_user.etl_dw_games
AS
BEGIN
 INSERT INTO sal_dw_cl_user.temp_games
(SELECT * FROM ts_dw_data_user.dw_games_scd cus WHERE cus.game_id IN (SELECT game_surr_id FROM ts_sal_data_user.fct_sales_dd));


MERGE INTO ts_sal_data_user.dim_games_scd TARGET
     USING (SELECT * FROM  sal_dw_cl_user.temp_games) SOURCE
        ON (TARGET.game_surr_id = SOURCE.game_surr_id)
      WHEN NOT MATCHED THEN
    INSERT (game_surr_id
            , game_id
            , game_desc
            , game_cost
            , valid_from
            , valid_to
            , is_active
            , category_id
            , category_desc
            , platform_id
            , platform_desc
            , insert_dt
            , update_dt)
    VALUES (SOURCE.game_surr_id
            , SOURCE.game_id
            , SOURCE.game_desc
            , SOURCE.game_cost
            , SOURCE.valid_from
            , SOURCE.valid_to
            , SOURCE.is_active
            , SOURCE.category_id
            , SOURCE.category_desc
            , SOURCE.platform_id
            , SOURCE.platform_desc
            , SOURCE.insert_dt
            , SOURCE.update_dt)
      WHEN MATCHED THEN
    UPDATE SET TARGET.game_desc       = SOURCE.game_desc
               , TARGET.game_cost     = SOURCE.game_cost
               , TARGET.valid_from    = SOURCE.valid_from
               , TARGET.valid_to      = SOURCE.valid_to
               , TARGET.is_active     = SOURCE.is_active
               , TARGET.category_id   = SOURCE.category_id
               , TARGET.category_desc = SOURCE.category_desc
               , TARGET.platform_id   = SOURCE.platform_id
               , TARGET.platform_desc = SOURCE.platform_desc
               , TARGET.insert_dt     = SOURCE.insert_dt
               , TARGET.update_dt     = SOURCE.update_dt;
COMMIT;
END;



CREATE OR REPLACE PROCEDURE sal_dw_cl_user.etl_dw_date
AS
BEGIN
 INSERT INTO sal_dw_cl_user.temp_date
(SELECT * FROM ts_dw_data_user.dw_date cus WHERE cus.date_id IN (SELECT date_id FROM ts_sal_data_user.fct_sales_dd));



MERGE INTO ts_sal_data_user.dim_date TARGET
     USING (SELECT * FROM  sal_dw_cl_user.temp_date) SOURCE
        ON ( TARGET.date_id = SOURCE.date_id)
      WHEN NOT MATCHED THEN
        INSERT (date_id
                , date_desc
                , date_full_number
                , date_full_string
                , weekday_fl
                , us_civil_holiday_fl
                , last_day_of_week_fl
                , last_day_of_month_fl
                , last_day_of_qtr_fl
                , last_day_of_yr_fl
                , day_id
                , day_desc
                , day_of_week_name
                , day_of_week_abbr
                , day_number_of_week
                , day_number_of_month
                , day_number_of_qtr
                , day_number_of_yr
                , week_id
                , week_desc
                , week_number_of_month
                , week_number_of_qtr
                , week_number_of_yr 
                , week_begin_dt
                , week_end_dt
                , month_id
                , month_desc
                , month_name
                , month_name_abbr
                , month_number_of_yr
                , month_begin_dt
                , month_end_dt
                , quarter_id
                , quarter_desc
                , qtr_number_of_yr
                , qtr_begin_dt
                , qtr_end_dt
                , year_id
                , year_desc
                , yr_begin_dt
                , yr_end_dt
                , insert_dt
                , update_dt)
        VALUES (SOURCE.date_id
                , SOURCE.date_desc
                , SOURCE.date_full_number
                , SOURCE.date_full_string
                , SOURCE.weekday_fl
                , SOURCE.us_civil_holiday_fl
                , SOURCE.last_day_of_week_fl
                , SOURCE.last_day_of_month_fl
                , SOURCE.last_day_of_qtr_fl
                , SOURCE.last_day_of_yr_fl
                , SOURCE.day_id
                , SOURCE.day_desc
                , SOURCE.day_of_week_name
                , SOURCE.day_of_week_abbr
                , SOURCE.day_number_of_week
                , SOURCE.day_number_of_month
                , SOURCE.day_number_of_qtr
                , SOURCE.day_number_of_yr
                , SOURCE.week_id
                , SOURCE.week_desc
                , SOURCE.week_number_of_month
                , SOURCE.week_number_of_qtr
                , SOURCE.week_number_of_yr
                , SOURCE.week_begin_dt
                , SOURCE.week_end_dt
                , SOURCE.month_id
                , SOURCE.month_desc
                , SOURCE.month_name
                , SOURCE.month_name_abbr
                , SOURCE.month_number_of_yr
                , SOURCE.month_begin_dt
                , SOURCE.month_end_dt
                , SOURCE.quarter_id
                , SOURCE.quarter_desc
                , SOURCE.qtr_number_of_yr
                , SOURCE.qtr_begin_dt
                , SOURCE.qtr_end_dt
                , SOURCE.year_id
                , SOURCE.year_desc
                , SOURCE.yr_begin_dt
                , SOURCE.yr_end_dt
                , SOURCE.insert_dt
                , SOURCE.update_dt)
      WHEN MATCHED THEN
        UPDATE SET TARGET.date_desc                     = SOURCE.date_desc
                   , TARGET.date_full_number            = SOURCE.date_full_number
                   , TARGET.date_full_string            = SOURCE.date_full_string
                   , TARGET.weekday_fl                  = SOURCE.weekday_fl
                   , TARGET.us_civil_holiday_fl         = SOURCE.us_civil_holiday_fl
                   , TARGET.last_day_of_week_fl         = SOURCE.last_day_of_week_fl
                   , TARGET.last_day_of_month_fl        = SOURCE.last_day_of_month_fl
                   , TARGET.last_day_of_qtr_fl          = SOURCE.last_day_of_qtr_fl
                   , TARGET.last_day_of_yr_fl           = SOURCE.last_day_of_yr_fl
                   , TARGET.day_id                      = SOURCE.day_id
                   , TARGET.day_desc                    = SOURCE.day_desc
                   , TARGET.day_of_week_name            = SOURCE.day_of_week_name
                   , TARGET.day_of_week_abbr            = SOURCE.day_of_week_abbr
                   , TARGET.day_number_of_week          = SOURCE.day_number_of_week
                   , TARGET.day_number_of_month         = SOURCE.day_number_of_month
                   , TARGET.day_number_of_qtr           = SOURCE.day_number_of_qtr
                   , TARGET.day_number_of_yr            = SOURCE.day_number_of_yr
                   , TARGET.week_id                     = SOURCE.week_id
                   , TARGET.week_desc                   = SOURCE.week_desc
                   , TARGET.week_number_of_month        = SOURCE.week_number_of_month
                   , TARGET.week_number_of_qtr          = SOURCE.week_number_of_qtr
                   , TARGET.week_number_of_yr           = SOURCE.week_number_of_yr
                   , TARGET.week_begin_dt               = SOURCE.week_begin_dt
                   , TARGET.week_end_dt                 = SOURCE.week_end_dt
                   , TARGET.month_id                    = SOURCE.month_id
                   , TARGET.month_desc                  = SOURCE.month_desc
                   , TARGET.month_name                  = SOURCE.month_name
                   , TARGET.month_name_abbr             = SOURCE.month_name_abbr
                   , TARGET.month_number_of_yr          = SOURCE.month_number_of_yr
                   , TARGET.month_begin_dt              = SOURCE.month_begin_dt
                   , TARGET.month_end_dt                = SOURCE.month_end_dt
                   , TARGET.quarter_id                  = SOURCE.quarter_id
                   , TARGET.quarter_desc                = SOURCE.quarter_desc
                   , TARGET.qtr_number_of_yr            = SOURCE.qtr_number_of_yr
                   , TARGET.qtr_begin_dt                = SOURCE.qtr_begin_dt
                   , TARGET.qtr_end_dt                  = SOURCE.qtr_end_dt
                   , TARGET.year_id                     = SOURCE.year_id
                   , TARGET.year_desc                   = SOURCE.year_desc
                   , TARGET.yr_begin_dt                 = SOURCE.yr_begin_dt
                   , TARGET.yr_end_dt                   = SOURCE.yr_end_dt
                   , TARGET.insert_dt                   = SOURCE.insert_dt
                   , TARGET.update_dt                   = SOURCE.update_dt;
COMMIT;
END;

     CREATE TABLESPACE archive_2018
   DATAFILE 'aharkevich_archive_2018_data_01.dat'
       SIZE 50M
 AUTOEXTEND ON NEXT 10M
    SEGMENT SPACE MANAGEMENT AUTO;


   CREATE TABLE sal_dw_cl_user.sales_2019 TABLESPACE archive_2018 
NOLOGGING COMPRESS PARALLEL 4 AS SELECT * FROM ts_dw_data_user.dw_sales
    WHERE date_id >= 20190101
      AND date_id < 20200101;

ALTER TABLE ts_sal_data_user.fct_sales_dd MODIFY CONSTRAINT pk_dw_sales DISABLE;


SELECT COUNT(*) FROM ts_sal_data_user.fct_sales_dd PARTITION (sales_2019);

SELECT COUNT(*) FROM sal_dw_cl_user.sales_2019;

ALTER TABLE ts_sal_data_user.fct_sales_dd EXCHANGE PARTITION sales_2019
 WITH TABLE sal_dw_cl_user.sales_2019 INCLUDING INDEXES;

ALTER TABLE ts_sal_data_user.fct_sales_dd MODIFY CONSTRAINT pk_dw_sales ENABLE NOVALIDATE;
ALTER TABLE ts_sal_data_user.fct_sales_dd MODIFY CONSTRAINT pk_dw_sales RELY;


     CREATE TABLESPACE before_2019
   DATAFILE 'aharkevich_archive_2019_data_01.dat'
       SIZE 50M
 AUTOEXTEND ON NEXT 10M
    SEGMENT SPACE MANAGEMENT AUTO;

   ALTER TABLE ts_sal_data_user.fct_sales_dd MERGE PARTITIONS sales_2017, sales_2018
    INTO PARTITION sales_before_2019 TABLESPACE before_2019 
COMPRESS UPDATE GLOBAL INDEXES PARALLEL 4;


   CREATE TABLE sal_dw_cl_user.sales_before_2019 TABLESPACE before_2019 
NOLOGGING COMPRESS PARALLEL 4 AS SELECT * FROM ts_dw_data_user.dw_sales
    WHERE date_id < 20190101


SELECT COUNT(*) FROM ts_sal_data_user.fct_sales_dd PARTITION (sales_before_2019);

SELECT COUNT(*) FROM sal_dw_cl_user.sales_before_2019;

ALTER TABLE ts_sal_data_user.fct_sales_dd MODIFY CONSTRAINT pk_dw_sales DISABLE;

ALTER TABLE ts_sal_data_user.fct_sales_dd    EXCHANGE PARTITION sales_before_2019
 WITH TABLE sal_dw_cl_user.sales_before_2019 INCLUDING INDEXES;

ALTER TABLE ts_sal_data_user.fct_sales_dd MODIFY CONSTRAINT pk_dw_sales ENABLE NOVALIDATE;
ALTER TABLE ts_sal_data_user.fct_sales_dd MODIFY CONSTRAINT pk_dw_sales RELY;