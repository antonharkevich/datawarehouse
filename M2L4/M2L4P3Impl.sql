CREATE OR REPLACE PACKAGE BODY DW_CL_USER.pkg_etl_dim_date_dw AS

   PROCEDURE load_date(curs IN OUT date_curs)
   IS
     BEGIN
        
        OPEN curs FOR SELECT u_dw_references.dim_date.date_key FROM u_dw_references.dim_date;
        LOOP
            BEGIN
            FETCH curs INTO  I; 
             EXIT WHEN curs%NOTFOUND;  
           SELECT date_id INTO x FROM  ts_dw_data_user.dw_date WHERE date_id = I;
                UPDATE ts_dw_data_user.dw_date
                SET ts_dw_data_user.dw_date.date_desc             = (SELECT date_full_string                     FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.date_full_string      = (SELECT date_full_string                     FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.date_full_number      = (SELECT date_full_number                     FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.weekday_fl            = (SELECT date_weekday_fl                      FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.us_civil_holiday_fl   = (SELECT date_us_civil_holiday_fl             FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.last_day_of_week_fl   = (SELECT date_last_day_of_week_fl             FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.last_day_of_month_fl  = (SELECT date_last_day_of_month_fl            FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.last_day_of_yr_fl     = (SELECT date_last_day_of_yr_fl               FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.last_day_of_qtr_fl    = (SELECT date_last_day_of_qtr_fl              FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.day_of_week_name      = (SELECT date_day_of_week_name                FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.day_desc              = (SELECT date_day_of_week_name                FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.day_of_week_abbr      = (SELECT date_day_of_week_abbr                FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.day_id                = (SELECT date_day_number_of_yr                FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.day_number_of_week    = (SELECT date_day_number_of_week              FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.day_number_of_month   = (SELECT date_day_number_of_month             FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.day_number_of_qtr     = (SELECT date_day_number_of_qtr               FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.day_number_of_yr      = (SELECT date_day_number_of_yr                FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.week_id               = (SELECT date_week_number_of_yr               FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.week_desc             = (SELECT to_char(date_week_number_of_yr)      FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.week_number_of_month  = (SELECT date_week_number_of_month            FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.week_number_of_qtr    = (SELECT date_week_number_of_qtr              FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.week_number_of_yr     = (SELECT date_week_number_of_yr               FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.week_begin_dt         = (SELECT date_week_begin_dt                   FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.week_end_dt           = (SELECT date_week_end_dt                     FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.month_id              = (SELECT date_month_number_of_yr              FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.month_desc            = (SELECT to_char(date_month_number_of_yr)     FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.month_name            = (SELECT date_month_name                      FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.month_name_abbr       = (SELECT date_month_name_abbr                 FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.month_number_of_yr    = (SELECT date_month_number_of_yr              FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.month_begin_dt        = (SELECT date_month_begin_dt                  FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.month_end_dt          = (SELECT date_month_end_dt                    FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.quarter_id            = (SELECT date_qtr_number_of_yr                FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.quarter_desc          = (SELECT to_char(date_qtr_number_of_yr)       FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.qtr_number_of_yr      = (SELECT date_qtr_number_of_yr                FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.qtr_begin_dt          = (SELECT date_qtr_begin_dt                    FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.qtr_end_dt            = (SELECT date_qtr_end_dt                      FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.year_id               = (SELECT date_year_number                     FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.year_desc             = (SELECT to_char(date_year_number)            FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.yr_begin_dt           = (SELECT date_yr_begin_dt                     FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.yr_end_dt             = (SELECT date_yr_end_dt                       FROM u_dw_references.dim_date WHERE date_key = I),
                    ts_dw_data_user.dw_date.update_dt             = (SELECT current_date                         FROM dual)
                WHERE ts_dw_data_user.dw_date.date_id             = I;
            EXCEPTION WHEN no_data_found THEN
                INSERT INTO ts_dw_data_user.dw_date(date_id
                                                    , date_desc
                                                    , date_full_string
                                                    , date_full_number
                                                    , weekday_fl
                                                    , us_civil_holiday_fl
                                                    , last_day_of_week_fl
                                                    ,last_day_of_month_fl
                                                    , last_day_of_yr_fl
                                                    , last_day_of_qtr_fl
                                                    , day_of_week_name
                                                    , day_desc
                                                    , day_of_week_abbr
                                                    , day_id
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
                                                    ,  month_number_of_yr
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
                                                    , update_dt
                                                    , insert_dt)
                VALUES (I
                        , (SELECT date_full_string                   FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_full_string                   FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_full_number                   FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_weekday_fl                    FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_us_civil_holiday_fl           FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_last_day_of_week_fl           FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_last_day_of_month_fl          FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_last_day_of_yr_fl             FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_last_day_of_qtr_fl            FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_day_of_week_name              FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_day_of_week_name              FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_day_of_week_abbr              FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_day_number_of_yr              FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_day_number_of_week            FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_day_number_of_month           FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_day_number_of_qtr             FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_day_number_of_yr              FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_week_number_of_yr             FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT to_char(date_week_number_of_yr)    FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_week_number_of_month          FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_week_number_of_qtr            FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_week_number_of_yr             FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_week_begin_dt                 FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_week_end_dt                   FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_month_number_of_yr            FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT to_char(date_month_number_of_yr)   FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_month_name                    FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_month_name_abbr               FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_month_number_of_yr            FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_month_begin_dt                FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_month_end_dt                  FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_qtr_number_of_yr              FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT to_char(date_qtr_number_of_yr)     FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_qtr_number_of_yr              FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_qtr_begin_dt                  FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_qtr_end_dt                    FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_year_number                   FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT to_char(date_year_number)          FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_yr_begin_dt                   FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT date_yr_end_dt                     FROM u_dw_references.dim_date WHERE date_key = I)
                        , (SELECT current_date                       FROM dual)
                        , (SELECT current_date                       FROM dual));
            
            END;
        END LOOP;
        COMMIT;	
        
        CLOSE curs;
        

     END load_date;
END;
/