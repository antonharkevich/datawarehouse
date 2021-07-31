CREATE OR REPLACE PACKAGE BODY DW_CL_USER.pkg_etl_dim_gen_periods_dw AS

   PROCEDURE load_gen_periods(first_curs IN OUT curs, second_curs IN OUT curs)
   IS
     BEGIN
        OPEN first_curs for SELECT sales_cat_id FROM u_dw_references.gen_periods where sales_cat_id not in (SELECT sales_cat_id FROM ts_dw_data_user.dw_gen_periods);
        FETCH first_curs BULK COLLECT INTO periods_ids_array;

        FORALL i IN periods_ids_array.FIRST .. periods_ids_array.LAST
                INSERT INTO ts_dw_data_user.dw_gen_periods(sales_cat_id, sales_cat_desc, start_amount, end_amount, insert_dt, update_dt)
                VALUES (periods_ids_array(i)
                        , (SELECT sales_cat_desc from u_dw_references.gen_periods where sales_cat_id = periods_ids_array(i))
                        ,  (SELECT start_amount from u_dw_references.gen_periods where sales_cat_id = periods_ids_array(i))
                        ,  (SELECT end_amount from u_dw_references.gen_periods where sales_cat_id = periods_ids_array(i))
                        , (SELECT CURRENT_DATE FROM DUAL)
                        , (SELECT CURRENT_DATE FROM DUAL));
        COMMIT;	
        
        CLOSE first_curs;
        

        OPEN second_curs for SELECT sales_cat_id FROM u_dw_references.gen_periods where sales_cat_id in (SELECT sales_cat_id FROM ts_dw_data_user.dw_gen_periods);
        FETCH second_curs BULK COLLECT INTO updt_periods_ids_array;
        FORALL j IN updt_periods_ids_array.FIRST .. updt_periods_ids_array.LAST
                UPDATE ts_dw_data_user.dw_gen_periods   
                SET       sales_cat_desc = (SELECT sales_cat_desc from u_dw_references.gen_periods where sales_cat_id = updt_periods_ids_array(j))
                        , start_amount = (SELECT start_amount from u_dw_references.gen_periods where sales_cat_id = updt_periods_ids_array(j))
                        , end_amount = (SELECT end_amount from u_dw_references.gen_periods where sales_cat_id = updt_periods_ids_array(j))
                        , update_dt =    (SELECT CURRENT_DATE FROM DUAL)
                WHERE sales_cat_id = updt_periods_ids_array(j);
        COMMIT;	
        CLOSE second_curs;
        
            
   END load_gen_periods;
END;
/