CREATE OR REPLACE PACKAGE BODY DW_CL_USER.pkg_etl_dim_customers_dw

AS
   PROCEDURE load_customers
   AS
   BEGIN
      MERGE INTO ts_dw_data_user.dw_customers target
           USING (SELECT * FROM sa_customers_user.sa_customers ) source
              ON ( target.customer_id = source.customer_id)
      WHEN NOT MATCHED THEN
         INSERT (customer_id, customer_desc, customer_age, customer_gender, insert_dt, update_dt)
             VALUES (source.customer_id, source.customer_desc, source.customer_age, source.customer_gender
             , (select CURRENT_DATE from DUAL)
             , (select CURRENT_DATE from DUAL))
      WHEN MATCHED THEN
         UPDATE SET target.customer_desc=source.customer_desc, target.customer_age=source.customer_age, target.customer_gender=source.customer_gender
         , target.update_dt= (select CURRENT_DATE from dual);

      --Commit Resulst
      COMMIT;
   END load_customers;
END;
/