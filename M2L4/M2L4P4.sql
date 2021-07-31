CREATE OR REPLACE PACKAGE DW_CL_USER.pkg_etl_dim_locations_dw
AS
    CURSOR curs IS SELECT country_id FROM sb_mbackup_user.sb_mbackup;
    I number;
    x number;
    PROCEDURE load_locations;
END;
