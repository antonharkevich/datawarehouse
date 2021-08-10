grant all privileges on u_dw_references.dim_date to dw_cl_user;
grant all privileges on ts_dw_data_user.dw_date to dw_cl_user;


CREATE OR REPLACE PACKAGE dw_cl_user.pkg_etl_dim_date_dw
AS
    TYPE date_curs IS REF CURSOR; 
    I number;
    x number;
    PROCEDURE load_date(curs IN OUT date_curs);

END;
/