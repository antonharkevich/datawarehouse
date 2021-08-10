grant all privileges on sb_mbackup_user.sb_mbackup to Dw_Cl_User;
grant all privileges on ts_dw_data_user.dw_geo_locations to dw_cl_user;

CREATE OR REPLACE PACKAGE dw_cl_user.pkg_etl_dim_locations_dw
AS
    CURSOR curs IS SELECT country_id FROM sb_mbackup_user.sb_mbackup;
    I number;
    x number;
    PROCEDURE load_locations;
END;
