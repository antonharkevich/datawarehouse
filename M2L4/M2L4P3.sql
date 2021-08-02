CREATE OR REPLACE PACKAGE DW_CL_USER.pkg_etl_dim_date_dw
AS
    TYPE date_curs IS REF CURSOR; 
    I number;
    x number;
    PROCEDURE load_date(curs IN OUT date_curs);

END;
/