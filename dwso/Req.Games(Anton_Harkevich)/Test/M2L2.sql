DROP TABLE sa_tnx_sales_user.sa_tnx_sales;
CREATE TABLE sa_tnx_sales_user.sa_tnx_sales
(
   sales_id             NUMBER                         NOT NULL,
   game_id              NUMBER                         NOT NULL,
   company_id           NUMBER                         NOT NULL,
   customer_id          NUMBER                         NOT NULL,
   date_key             NUMBER                         NOT NULL,
   sales_cat_id         NUMBER                         NOT NULL,
   country_id           NUMBER                         NOT NULL,
   sales_amount         NUMBER                         NULL,
   sales_dollars        DECIMAL                        NULL,
   profit_margin        INT                            NULL,
   CONSTRAINT pk_sa_sales PRIMARY KEY (sales_id)
)
TABLESPACE ts_sa_sales_data_01;


--TRUNcATE TABLE sa_tnx_sales_user.sa_tnx_sales;
INSERT INTO sa_tnx_sales_user.sa_tnx_sales(sales_id
                                           , game_id
                                           , company_id
                                           , customer_id
                                           , date_key
                                           , sales_cat_id
                                           , country_id
                                           , sales_amount
                                           , sales_dollars
                                           , profit_margin)
SELECT ROWNUM
       , ROUNd((DBMS_RANdOM.VALUE(1, 50000)),0)
       , ROUNd((DBMS_RANdOM.VALUE(1, 500000)),0)
       , ROUNd((DBMS_RANdOM.VALUE(1, 5000000)),0)
       , to_number(to_char((DATE '2017-01-01' + ROUNd((DBMS_RANdOM.VALUE(1, 1000)),0) - 1), 'yyyymmdd'))
       , ROUNd((DBMS_RANdOM.VALUE(1, 4)),0)
       , ROUNd((DBMS_RANdOM.VALUE(4, 900)),0)
       , ROUNd((DBMS_RANdOM.VALUE(1, 1000000)),0)
       , ROUNd((DBMS_RANdOM.VALUE(1, 100000000)),0)
       , ROUNd((DBMS_RANdOM.VALUE(1, 100)),0)
  FROM dUAL
CONNECT BY LEVEL <= 100000;
COMMIT;



UPDATE sa_tnx_sales_user.sa_tnx_sales
SET country_id = (SELECT country_id FROM sb_mbackup_user.sb_mbackup order by dbms_random.value fetch first 1 row only);
COMMIT;

UPDATE sa_tnx_sales_user.sa_tnx_sales
SET sales_cat_id = 1
WHERE SALES_AMOUNT between 1 and 300000;


UPDATE sa_tnx_sales_user.sa_tnx_sales
SET sales_cat_id = 4
WHERE SALES_AMOUNT between 900001 and 1000000;
COMMIT;


VARIABLE n_all_data NUMBER;
VARIABLE n_customer NUMBER;
VARIABLE n_company NUMBER;
VARIABLE n_summary NUMBER;
BEGIN
 -- set values to 0 to disable
 :n_all_data := 0; -- 1 to enable
 :n_customer := 2; -- 2 to enable
 :n_company  := 0; -- 3 to enable
 :n_summary  := 4; -- 4 to enable
END;
/

SET AUTOTRACE ON;

SELECT /*+ gather_plan_statistics */ g.game_desc game
       , decode(GROUPING(c.company_desc),1,'ALL cOMPANIES',c.company_desc) company
       , decode(GROUPING(cus.customer_desc),1,'ALL CUSTOMERS',cus.customer_desc) customer
       , d.date_day_number_of_yr day
       , SUM(S.sales_amount) sales_amount
  FROM sa_tnx_sales_user.sa_tnx_sales s
       , u_dw_references.dim_date d
       , sa_companies_user.sa_companies c
       , sa_customers_user.sa_customers cus
       , sa_games_user.sa_games g
 WHERE s.date_key = d.date_key 
   AND s.company_id = c.company_id 
   AND s.game_id = g.game_id 
   AND s.customer_id = cus.customer_id 
   AND d.date_year_number IN (2018) 
   AND d.date_day_number_of_yr BETWEEN 1 AND 366
 GROUP BY d.date_day_number_of_yr
          , g.game_desc
          , CUBE(c.company_desc, cus.customer_desc)
HAVING GROUPING_ID(c.company_desc,cus.customer_desc)+1 IN(:n_all_data,:n_customer,:n_company,:n_summary)
 ORDER BY 4, 1, 2, 3;
 
 
 
 SET AUTOTRAcE ON;
 
 SELECT /*+ gather_plan_statistics */ g.game_desc game
        , decode(GROUPING(C.company_desc),1,'ALL cOMPANIES',C.company_desc) company
        , decode(GROUPING(cus.customer_desc),1,'ALL CUSTOMERS',cus.customer_desc) customer
        , d.date_month_number_of_yr month
        , SUM(S.sales_amount) sales_amount
   FROM sa_tnx_sales_user.sa_tnx_sales s
        , u_dw_references.dim_date d
        , sa_companies_user.sa_companies c
        , sa_customers_user.sa_customers cus
        , sa_games_user.sa_games g
  WHERE s.date_key = d.date_key 
    AND s.company_id = c.company_id 
    AND s.game_id = g.game_id 
    AND s.customer_id = cus.customer_id 
    AND d.date_year_number IN (2018) 
    AND d.date_month_number_of_yr BETWEEN 1 AND 13
  GROUP BY d.date_month_number_of_yr
           , g.game_desc
           , ROLLUP(c.company_desc, cus.customer_desc)
 HAVING GROUPING_ID(c.company_desc,cus.customer_desc)+1 IN(:n_all_data,:n_customer,:n_company,:n_summary)
  ORDER BY 4, 1, 2, 3;
 
 
SET AUTOTRAcE ON;
SELECT 
 (CASE
  WHEN ((GROUPING(d.date_year_number)=0 )
   AND (GROUPING(d.date_qtr_number_of_yr)=1 ))
  THEN (to_char(d.date_year_number) || '_0')
  WHEN ((GROUPING(d.date_qtr_number_of_yr)=0 )
   AND (GROUPINg(d.date_month_number_of_yr)=1 ))
  THEN (to_char(d.date_qtr_number_of_yr) || '_1')
  WHEN ((GROUPING(d.date_month_number_of_yr)=0)
   AND (GROUPING(d.date_day_number_of_yr)=1 ))
  THEN (to_char(d.date_month_number_of_yr) || '_2')
  ELSE (to_char(d.date_day_number_of_yr) || '_3')
   END) hierarchical_time
        , d.date_year_number year
        , d.date_qtr_number_of_yr quarter
        , d.date_month_number_of_yr month
        , d.date_day_number_of_yr day
        , GROUPING_Id(d.date_year_number
                      , d.date_qtr_number_of_yr
                      , d.date_month_number_of_yr
                      , d.date_day_number_of_yr) gid_t
                      , g.category_desc game_category
                      , decode(GROUPING(c.company_desc),1,'ALL cOMPANIES',c.company_desc) company
                      , decode(GROUPING(cus.customer_desc),1,'ALL cUSTOMERS',cus.customer_desc) customer
                      , SUM(S.sales_amount) sales_amount
  FROM sa_tnx_sales_user.sa_tnx_sales s
       , u_dw_references.dim_date d
       , sa_companies_user.sa_companies c
       , sa_customers_user.sa_customers cus
       , sa_games_user.sa_games g
 WHERE S.date_key = d.date_key 
   AND s.company_id = c.company_id 
   AND s.game_id = g.game_id 
   AND s.customer_id = cus.customer_id
 GROUP BY g.category_desc
          , ROLLUP(c.company_desc, cus.customer_desc)
          , ROLLUP(d.date_year_number
                   , d.date_qtr_number_of_yr
                   , d.date_month_number_of_yr
                   , d.date_day_number_of_yr);
