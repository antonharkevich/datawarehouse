 GRANT ALL PRIVILEGES ON sa_customers_user.sa_customers TO dw_cl_user;
 GRANT ALL PRIVILEGES ON ts_dw_data_user.dw_customers TO dw_cl_user;
 GRANT UNLIMITED TABLESPACE TO ts_dw_data_user;
CREATE OR REPLACE PACKAGE dw_cl_user.pkg_etl_dim_customers_dw
    AS
    PROCEDURE load_customers;
END;
/