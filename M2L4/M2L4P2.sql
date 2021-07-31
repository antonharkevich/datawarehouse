CREATE OR REPLACE PACKAGE DW_CL_USER.pkg_etl_dim_companies_dw
AS
    CURSOR comp IS SELECT company_id FROM sa_companies_user.sa_companies where company_id not in (SELECT company_id FROM ts_dw_data_user.dw_companies);
    CURSOR comp_updt IS SELECT company_id FROM sa_companies_user.sa_companies where company_id in (SELECT company_id FROM ts_dw_data_user.dw_companies);
    TYPE ids IS TABLE OF NUMBER;
    company_ids_array ids ;
    updt_company_ids_array ids ;
    PROCEDURE load_companies;

END;
/