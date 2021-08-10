GRANT ALL PRIVILEGES ON sa_companies_user.sa_companies TO dw_cl_user;
GRANT ALL PRIVILEGES ON ts_dw_data_user.dw_companies   TO dw_cl_user;

CREATE OR REPLACE PACKAGE dw_cl_user.pkg_etl_dim_companies_dw
AS
    CURSOR comp      IS SELECT company_id      FROM sa_companies_user.sa_companies WHERE company_id NOT IN (SELECT company_id FROM ts_dw_data_user.dw_companies);
    CURSOR comp_updt IS SELECT company_id      FROM sa_companies_user.sa_companies WHERE company_id     IN (SELECT company_id FROM ts_dw_data_user.dw_companies);
    TYPE ids IS TABLE OF NUMBER;
    company_ids_array ids ;
    updt_company_ids_array ids ;
    PROCEDURE load_companies;
END;
/