CREATE OR REPLACE PACKAGE DW_CL_USER.pkg_etl_dim_gen_periods_dw
AS
    TYPE curs IS REF CURSOR; 
    TYPE ids IS TABLE OF NUMBER;
    periods_ids_array ids ;
    updt_periods_ids_array ids ;
    PROCEDURE load_gen_periods(first_curs IN OUT curs, second_curs IN OUT curs);

END;
/