CREATE OR REPLACE PACKAGE BODY DW_CL_USER.pkg_etl_dim_companies_dw AS

   PROCEDURE load_companies 
   IS
            

        BEGIN
--        EXECUTE IMMEDIATE 'TRUNCATE TABLE ts_dw_data_user.dw_companies';
        IF comp %ISOPEN THEN
        CLOSE comp ;
        END IF;
        OPEN comp;
        FETCH comp BULK COLLECT INTO company_ids_array;

        FORALL i IN company_ids_array.FIRST .. company_ids_array.LAST
                INSERT INTO ts_dw_data_user.dw_companies(company_id, company_name, company_desc, insert_dt, update_dt)
                VALUES (company_ids_array(i)
                        , (SELECT company_name from sa_companies_user.sa_companies where company_id = company_ids_array(i))
                        , (SELECT company_desc from sa_companies_user.sa_companies where company_id = company_ids_array(i))
                        , (SELECT CURRENT_DATE FROM DUAL)
                        , (SELECT CURRENT_DATE FROM DUAL));
        COMMIT;	
        
        CLOSE comp;
        
        IF comp_updt %ISOPEN THEN
        CLOSE comp_updt ;
        END IF;
        OPEN comp_updt;
        FETCH comp_updt BULK COLLECT INTO updt_company_ids_array;
        FORALL j IN updt_company_ids_array.FIRST .. updt_company_ids_array.LAST
                UPDATE ts_dw_data_user.dw_companies   
                SET       company_name = (SELECT company_name from sa_companies_user.sa_companies where company_id = updt_company_ids_array(j))
                        , company_desc = (SELECT company_desc from sa_companies_user.sa_companies where company_id = updt_company_ids_array(j))
                        , update_dt =    (SELECT CURRENT_DATE FROM DUAL)
                WHERE company_id = updt_company_ids_array(j);
        COMMIT;	
        CLOSE comp_updt;
   END load_companies;
END;
/