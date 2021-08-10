CREATE OR REPLACE PACKAGE DW_CL_USER.pkg_etl_dim_locations_dw_v2
AS
    CURSOR curs IS SELECT country_id FROM sb_mbackup_user.sb_mbackup;
    I NUMBER;
    x NUMBER;
    sql_stmt VARCHAR2(2000);
    PROCEDURE load_locations;
END;
