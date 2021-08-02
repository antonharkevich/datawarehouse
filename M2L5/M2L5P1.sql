DECLARE
 min_num           NUMBER;
 max_num           NUMBER;
 sql_stmt3          VARCHAR2(2000);
BEGIN   
 sql_stmt3 := 'SELECT min(company_id) FROM ts_dw_data_user.dw_companies';
 EXECUTE IMMEDIATE sql_stmt3 INTO min_num;
 EXECUTE IMMEDIATE 'SELECT max(company_id) FROM ts_dw_data_user.dw_companies' INTO max_num;
 DW_CL_USER.etl_companies(min_num, max_num); 
     
END;