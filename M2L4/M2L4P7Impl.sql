CREATE OR REPLACE PACKAGE BODY DW_CL_USER.pkg_etl_dim_sales_dw

AS
   PROCEDURE load_sales
   AS
   BEGIN
      MERGE INTO ts_dw_data_user.dw_sales target
           USING (SELECT * FROM sa_tnx_sales_user.sa_tnx_sales ) source
              ON ( target.sales_id = source.sales_id)
      WHEN NOT MATCHED THEN
         INSERT (sales_id
                , customer_id
                , game_surr_id
                , company_id
                , country_id
                , date_id
                , sales_cat_id
                , fct_sales_amount
                , fct_sales_dollars
                , fct_profit_margin
                , insert_dt
                , event_dt)
         VALUES (source.sales_id
                , source.customer_id
                , source.game_id
                , source.company_id
                , source.country_id
                , source.date_key
                , source.sales_cat_id
                , source.sales_amount
                , source.sales_dollars
                , source.profit_margin 
                , (select CURRENT_DATE from DUAL)
                , (select CURRENT_DATE from DUAL))
      WHEN MATCHED THEN
         UPDATE 
            SET target.customer_id=source.customer_id
                , target.game_surr_id=source.game_id
                , target.company_id=source.company_id
                , target.country_id=source.country_id
                , target.date_id=source.date_key, target.sales_cat_id=source.sales_cat_id
                , target.fct_sales_amount=source.sales_amount
                , target.fct_profit_margin=source.profit_margin
                , target.fct_sales_dollars=source.sales_dollars
                , target.insert_dt= (select CURRENT_DATE from dual)
                , target.event_dt= (select CURRENT_DATE from dual);

      --Commit Resulst
      COMMIT;
   END load_sales;
END;
/