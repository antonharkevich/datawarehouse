GRANT ALL PRIVILEGES ON sa_games_user.sa_games TO dw_cl_user;
GRANT ALL PRIVILEGES ON ts_dw_data_user.dw_games_scd TO dw_cl_user;

CREATE OR REPLACE PACKAGE dw_cl_user.pkg_etl_dim_games_dw
AS
    CURSOR curs IS SELECT game_id FROM sa_games_user.sa_games;
    I   NUMBER;
    X   NUMBER;
    y   NUMBER;
    z   NUMBER;
    xxx NUMBER;
    PROCEDURE load_games;
END;