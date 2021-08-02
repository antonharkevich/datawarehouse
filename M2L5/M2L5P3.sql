set serveroutput on;
DECLARE
 min_num           NUMBER;
 max_num           NUMBER;
 sql_stmt3          VARCHAR2(2000);
BEGIN
 sql_stmt3 := 'SELECT min(sales_cat_id) FROM ts_dw_data_user.dw_gen_periods';
 EXECUTE IMMEDIATE sql_stmt3 INTO min_num;
 EXECUTE IMMEDIATE 'SELECT max(sales_cat_id) FROM ts_dw_data_user.dw_gen_periods' INTO max_num;
 DW_CL_USER.etl_gen_periods('sales_cat_id', min_num, max_num);

END;
