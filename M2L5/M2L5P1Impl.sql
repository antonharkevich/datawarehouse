CREATE OR REPLACE PROCEDURE DW_CL_USER.etl_companies(min_stmt NUMBER, max_stmt NUMBER) IS
  TYPE CurType IS REF CURSOR;
  src_cur         CurType;
  src_cur2         CurType;
  curid           NUMBER;
  curid2          NUMBER;
  sql_stmt        VARCHAR2(200);
  sql_stmt2       VARCHAR2(200);
  ret             INTEGER;
  empnos          DBMS_SQL.Number_Table;
  depts           DBMS_SQL.Number_Table;
  TYPE ids IS TABLE OF NUMBER;
  updt_company_ids_array ids ;
  company_ids_array ids ;
BEGIN


  curid := DBMS_SQL.OPEN_CURSOR;
 
  sql_stmt :=    'SELECT company_id FROM sa_companies_user.sa_companies where company_id between :b1 and :b2';
  sql_stmt2 :=    'SELECT company_id FROM sa_companies_user.sa_companies where company_id > :1';

  DBMS_SQL.PARSE(curid, sql_stmt, DBMS_SQL.NATIVE);
  DBMS_SQL.BIND_VARIABLE(curid, 'b1', min_stmt);
  DBMS_SQL.BIND_VARIABLE(curid, 'b2', max_stmt);
  ret := DBMS_SQL.EXECUTE(curid);

  -- Switch from DBMS_SQL to native dynamic SQL
  src_cur := DBMS_SQL.TO_REFCURSOR(curid);

  -- Fetch with native dynamic SQL
  FETCH src_cur BULK COLLECT INTO updt_company_ids_array;

  FORALL j IN updt_company_ids_array.FIRST .. updt_company_ids_array.LAST
                UPDATE ts_dw_data_user.dw_companies   
                SET       company_name = (SELECT company_name from sa_companies_user.sa_companies where company_id = updt_company_ids_array(j))
                        , company_desc = (SELECT company_desc from sa_companies_user.sa_companies where company_id = updt_company_ids_array(j))
                        , update_dt =    (SELECT CURRENT_DATE FROM DUAL)
                WHERE company_id = updt_company_ids_array(j);
    COMMIT;	
   -- Close cursor
  CLOSE src_cur;
  
  curid2 := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(curid2, sql_stmt2, DBMS_SQL.NATIVE);
  DBMS_SQL.BIND_VARIABLE(curid2, '1', max_stmt);
  ret := DBMS_SQL.EXECUTE(curid2);
  src_cur2 := DBMS_SQL.TO_REFCURSOR(curid2);
  
  FETCH src_cur2 BULK COLLECT INTO company_ids_array;

        FORALL i IN company_ids_array.FIRST .. company_ids_array.LAST
                INSERT INTO ts_dw_data_user.dw_companies(company_id, company_name, company_desc, insert_dt, update_dt)
                VALUES (company_ids_array(i)
                        , (SELECT company_name from sa_companies_user.sa_companies where company_id = company_ids_array(i))
                        , (SELECT company_desc from sa_companies_user.sa_companies where company_id = company_ids_array(i))
                        , (SELECT CURRENT_DATE FROM DUAL)
                        , (SELECT CURRENT_DATE FROM DUAL));
        COMMIT;	
        
        CLOSE src_cur2;
  
END;