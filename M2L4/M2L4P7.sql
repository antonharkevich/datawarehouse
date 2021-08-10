GRANT ALL PRIVILEGES ON sa_tnx_sales_user.sa_tnx_sales TO dw_cl_user;
GRANT ALL PRIVILEGES ON ts_dw_data_user.dw_sales TO dw_cl_user;

CREATE OR REPLACE PACKAGE dw_cl_user.pkg_etl_dim_sales_dw
AS
    PROCEDURE load_sales;
END;