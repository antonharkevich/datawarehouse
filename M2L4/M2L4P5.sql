CREATE TABLE u_dw_references.gen_periods(
    sales_cat_id NUMBER NOT NULL, 
	sales_cat_desc VARCHAR2(30 BYTE) NOT NULL, 
	start_amount NUMBER NOT NULL, 
	end_amount NUMBER NOT NULL
);

INSERT INTO u_dw_references.gen_periods(sales_cat_id
                                        , sales_cat_desc
                                        , start_amount
                                        , end_amount)
VALUES (4, 'big success', 900001, 1000000);
commit;

GRANT ALL PRIVILEGES ON u_dw_references.gen_periods TO dw_cl_user;
GRANT ALL PRIVILEGES ON ts_dw_data_user.dw_gen_periods TO dw_cl_user;

CREATE OR REPLACE PACKAGE dw_cl_user.pkg_etl_dim_gen_periods_dw
AS
    TYPE curs IS REF CURSOR; 
    TYPE ids IS TABLE OF NUMBER;
    periods_ids_array ids ;
    updt_periods_ids_array ids ;
    PROCEDURE load_gen_periods(first_curs IN OUT curs, second_curs IN OUT curs);

END;
/