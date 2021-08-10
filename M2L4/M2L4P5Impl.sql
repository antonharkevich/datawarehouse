CREATE OR REPLACE PACKAGE BODY dw_cl_user.pkg_etl_dim_gen_periods_dw AS

   PROCEDURE load_gen_periods(first_curs IN OUT curs, second_curs IN OUT curs)
   IS
     BEGIN
        OPEN first_curs FOR SELECT sales_cat_id FROM u_dw_references.gen_periods WHERE sales_cat_id NOT IN (SELECT sales_cat_id FROM ts_dw_data_user.dw_gen_periods);
        FETCH first_curs BULK COLLECT INTO periods_ids_array;

        FORALL I IN periods_ids_array.FIRST .. periods_ids_array.LAST
                INSERT INTO ts_dw_data_user.dw_gen_periods(sales_cat_id
                                                           , sales_cat_desc
                                                           , start_amount
                                                           , end_amount
                                                           , insert_dt
                                                           , update_dt)
                VALUES (periods_ids_array(I)
                        , (SELECT sales_cat_desc FROM u_dw_references.gen_periods WHERE sales_cat_id = periods_ids_array(I))
                        , (SELECT start_amount   FROM u_dw_references.gen_periods WHERE sales_cat_id = periods_ids_array(I))
                        , (SELECT end_amount     FROM u_dw_references.gen_periods WHERE sales_cat_id = periods_ids_array(I))
                        , (SELECT current_date   FROM dual)
                        , (SELECT current_date   FROM dual));
        COMMIT;	
        
        CLOSE first_curs;
        

        OPEN second_curs FOR SELECT sales_cat_id FROM u_dw_references.gen_periods WHERE sales_cat_id IN (SELECT sales_cat_id FROM ts_dw_data_user.dw_gen_periods);
        FETCH second_curs BULK COLLECT INTO updt_periods_ids_array;
        FORALL j IN updt_periods_ids_array.FIRST .. updt_periods_ids_array.LAST
                UPDATE ts_dw_data_user.dw_gen_periods   
                SET       sales_cat_desc = (SELECT sales_cat_desc FROM u_dw_references.gen_periods WHERE sales_cat_id = updt_periods_ids_array(j))
                        , start_amount   = (SELECT start_amount   FROM u_dw_references.gen_periods WHERE sales_cat_id = updt_periods_ids_array(j))
                        , end_amount     = (SELECT end_amount     FROM u_dw_references.gen_periods WHERE sales_cat_id = updt_periods_ids_array(j))
                        , update_dt      = (SELECT current_date   FROM dual)
                WHERE sales_cat_id = updt_periods_ids_array(j);
        COMMIT;	
        CLOSE second_curs;
        
            
   END load_gen_periods;
END;
/