CREATE OR REPLACE PROCEDURE DW_CL_USER.etl_gen_periods (
     column_list_in VARCHAR2
     , c_id_in  IN u_dw_references.gen_periods.sales_cat_id%TYPE
     , c_id_in2 IN u_dw_references.gen_periods.sales_cat_id%TYPE
)
IS
   sql_stmt   CLOB;
   sql_stmt2  CLOB;
   src_cur    SYS_REFCURSOR;
   src_cur2   SYS_REFCURSOR;
   curid      NUMBER;
   curid2     NUMBER;
   desctab    DBMS_SQL.desc_tab;
   colcnt     NUMBER;
   desctab2   DBMS_SQL.desc_tab;
   colcnt2    NUMBER;
   numvar     NUMBER;
   numvar2    NUMBER;
BEGIN

   sql_stmt :=
      'SELECT '
      || column_list_in
      || ' FROM u_dw_references.gen_periods WHERE sales_cat_id between :1 and :2';
      
   OPEN src_cur FOR sql_stmt USING c_id_in, c_id_in2;
   curid := DBMS_SQL.to_cursor_number (src_cur);
   DBMS_SQL.describe_columns          (curid, colcnt, desctab);
   DBMS_SQL.define_column             (curid, 1, numvar);
   
   WHILE DBMS_SQL.fetch_rows (curid) > 0
   LOOP
        DBMS_SQL.COLUMN_VALUE (curid, 1, numvar);
        UPDATE ts_dw_data_user.dw_gen_periods   
           SET       sales_cat_desc    = (SELECT sales_cat_desc FROM u_dw_references.gen_periods WHERE sales_cat_id = numvar)
                        , start_amount = (SELECT start_amount   FROM u_dw_references.gen_periods WHERE sales_cat_id = numvar)
                        , end_amount   = (SELECT end_amount     FROM u_dw_references.gen_periods WHERE sales_cat_id = numvar)
                        , update_dt    = (SELECT CURRENT_DATE   FROM DUAL)
         WHERE sales_cat_id = numvar;
        COMMIT;	
   END LOOP;
   DBMS_SQL.close_cursor (curid);
   
   sql_stmt2 :=
      'SELECT '
      || column_list_in
      || ' FROM u_dw_references.gen_periods WHERE sales_cat_id > :1';
      
   OPEN src_cur2 FOR sql_stmt2 USING c_id_in2;
   curid2 := DBMS_SQL.to_cursor_number (src_cur2);
   DBMS_SQL.describe_columns           (curid2, colcnt2, desctab2);
   DBMS_SQL.define_column              (curid2, 1, numvar2);
   
   WHILE DBMS_SQL.fetch_rows (curid2) > 0
   LOOP
       DBMS_SQL.COLUMN_VALUE (curid2, 1, numvar2);
       INSERT INTO ts_dw_data_user.dw_gen_periods(sales_cat_id
                                                  , sales_cat_desc
                                                  , start_amount
                                                  , end_amount
                                                  , insert_dt
                                                  , update_dt)
       VALUES           (numvar2
                        , (SELECT sales_cat_desc FROM u_dw_references.gen_periods WHERE sales_cat_id = numvar2)
                        , (SELECT start_amount   FROM u_dw_references.gen_periods WHERE sales_cat_id = numvar2)
                        , (SELECT end_amount     FROM u_dw_references.gen_periods WHERE sales_cat_id = numvar2)
                        , (SELECT CURRENT_DATE   FROM DUAL)
                        , (SELECT CURRENT_DATE   FROM DUAL));
	
        COMMIT;	
   END LOOP;
   DBMS_SQL.close_cursor (curid2);
END;
