CREATE OR REPLACE PACKAGE BODY DW_CL_USER.pkg_etl_dim_date_dw AS

   PROCEDURE load_date(curs IN OUT date_curs)
   IS
            
        BEGIN
        
        OPEN curs FOR select u_dw_references.dim_date.date_key from u_dw_references.dim_date;
        LOOP
            BEGIN
            FETCH curs INTO  I; 
            EXIT WHEN curs%NOTFOUND;  
            select date_id into x from  ts_dw_data_user.dw_date where date_id = I;
                UPDATE ts_dw_data_user.dw_date
                SET ts_dw_data_user.dw_date.date_desc = (select date_full_string from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.date_full_string = (select date_full_string from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.date_full_number = (select date_full_number from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.weekday_fl = (select date_weekday_fl from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.US_CIVIL_HOLIDAY_FL = (select DATE_US_CIVIL_HOLIDAY_FL from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.last_day_of_week_fl = (select DATE_LAST_DAY_OF_WEEK_FL from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.last_day_of_month_FL = (select date_last_day_of_month_FL from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.last_day_of_yr_fl = (select date_last_day_of_yr_fl from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.last_day_of_qtr_fl = (select date_last_day_of_qtr_fl from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.day_of_week_name = (select date_day_of_week_name from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.day_desc = (select date_day_of_week_name from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.day_of_week_abbr = (select date_day_of_week_abbr from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.day_id = (select date_day_number_of_yr from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.day_number_of_week = (select date_day_number_of_week from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.day_number_of_month = (select date_day_number_of_month from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.day_number_of_qtr = (select date_day_number_of_qtr from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.day_number_of_yr = (select date_day_number_of_yr from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.week_id = (select date_week_number_of_yr from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.week_desc = (select to_char(date_week_number_of_yr) from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.week_number_of_month = (select date_week_number_of_month from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.week_number_of_qtr = (select date_week_number_of_qtr from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.week_number_of_yr = (select date_week_number_of_yr from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.week_begin_dt = (select date_week_begin_dt from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.week_end_dt = (select date_week_end_dt from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.month_id = (select date_month_number_of_yr from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.month_desc = (select to_char(date_month_number_of_yr) from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.month_name= (select date_month_name from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.month_name_abbr = (select date_month_name_abbr from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.month_number_of_yr = (select date_month_number_of_yr from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.month_begin_dt = (select date_month_begin_dt from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.month_end_dt = (select date_month_end_dt from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.quarter_id = (select date_qtr_number_of_yr from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.quarter_desc = (select to_char(date_qtr_number_of_yr) from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.qtr_number_of_yr = (select date_qtr_number_of_yr from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.qtr_begin_dt = (select date_qtr_begin_dt from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.qtr_end_dt = (select date_qtr_end_dt from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.year_id = (select date_year_number from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.year_desc = (select to_char(date_year_number) from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.yr_begin_dt = (select date_yr_begin_dt from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.yr_end_dt = (select date_yr_end_dt from u_dw_references.dim_date where date_key = I),
                    ts_dw_data_user.dw_date.update_dt = (select CURRENT_DATE FROM DUAL)
                WHERE ts_dw_data_user.dw_date.date_id  = I;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                Insert into ts_dw_data_user.dw_date(date_id, date_desc, date_full_string, date_full_number, weekday_fl, US_CIVIL_HOLIDAY_FL, last_day_of_week_fl,
                                                    last_day_of_month_FL, last_day_of_yr_fl, last_day_of_qtr_fl, day_of_week_name, day_desc, day_of_week_abbr,
                                                    day_id, day_number_of_week, day_number_of_month, day_number_of_qtr, day_number_of_yr, week_id, week_desc,
                                                    week_number_of_month, week_number_of_qtr, week_number_of_yr, week_begin_dt, week_end_dt, month_id, month_desc, 
                                                    month_name, month_name_abbr, month_number_of_yr, month_begin_dt, month_end_dt, quarter_id,
                                                    quarter_desc, qtr_number_of_yr, qtr_begin_dt, qtr_end_dt, year_id, year_desc, yr_begin_dt, yr_end_dt, update_dt, insert_dt)
                VALUES (I, (select date_full_string from u_dw_references.dim_date where date_key = I), (select date_full_string from u_dw_references.dim_date where date_key = I),
                        (select date_full_number from u_dw_references.dim_date where date_key = I), (select date_weekday_fl from u_dw_references.dim_date where date_key = I),
                        (select DATE_US_CIVIL_HOLIDAY_FL from u_dw_references.dim_date where date_key = I), (select DATE_LAST_DAY_OF_WEEK_FL from u_dw_references.dim_date where date_key = I),
                        (select date_last_day_of_month_FL from u_dw_references.dim_date where date_key = I), (select date_last_day_of_yr_fl from u_dw_references.dim_date where date_key = I),
                        (select date_last_day_of_qtr_fl from u_dw_references.dim_date where date_key = I), (select date_day_of_week_name from u_dw_references.dim_date where date_key = I),
                        (select date_day_of_week_name from u_dw_references.dim_date where date_key = I), (select date_day_of_week_abbr from u_dw_references.dim_date where date_key = I),
                        (select date_day_number_of_yr from u_dw_references.dim_date where date_key = I), (select date_day_number_of_week from u_dw_references.dim_date where date_key = I),
                        (select date_day_number_of_month from u_dw_references.dim_date where date_key = I), (select date_day_number_of_qtr from u_dw_references.dim_date where date_key = I),
                        (select date_day_number_of_yr from u_dw_references.dim_date where date_key = I), (select date_week_number_of_yr from u_dw_references.dim_date where date_key = I),
                        (select to_char(date_week_number_of_yr) from u_dw_references.dim_date where date_key = I), (select date_week_number_of_month from u_dw_references.dim_date where date_key = I),
                        (select date_week_number_of_qtr from u_dw_references.dim_date where date_key = I), (select date_week_number_of_yr from u_dw_references.dim_date where date_key = I),
                        (select date_week_begin_dt from u_dw_references.dim_date where date_key = I), (select date_week_end_dt from u_dw_references.dim_date where date_key = I),
                        (select date_month_number_of_yr from u_dw_references.dim_date where date_key = I), (select to_char(date_month_number_of_yr) from u_dw_references.dim_date where date_key = I),
                        (select date_month_name from u_dw_references.dim_date where date_key = I), (select date_month_name_abbr from u_dw_references.dim_date where date_key = I),
                         (select date_month_number_of_yr from u_dw_references.dim_date where date_key = I), (select date_month_begin_dt from u_dw_references.dim_date where date_key = I),
                         (select date_month_end_dt from u_dw_references.dim_date where date_key = I),
                        (select date_qtr_number_of_yr from u_dw_references.dim_date where date_key = I), (select to_char(date_qtr_number_of_yr) from u_dw_references.dim_date where date_key = I),
                        (select date_qtr_number_of_yr from u_dw_references.dim_date where date_key = I), (select date_qtr_begin_dt from u_dw_references.dim_date where date_key = I),
                        (select date_qtr_end_dt from u_dw_references.dim_date where date_key = I), (select date_year_number from u_dw_references.dim_date where date_key = I),
                        (select to_char(date_year_number) from u_dw_references.dim_date where date_key = I), (select date_yr_begin_dt from u_dw_references.dim_date where date_key = I),
                        (select date_yr_end_dt from u_dw_references.dim_date where date_key = I), (select CURRENT_DATE FROM DUAL), (select CURRENT_DATE FROM DUAL));
            
        END;
        END LOOP;
        COMMIT;	
        
        CLOSE curs;
        

   END load_date;
END;
/