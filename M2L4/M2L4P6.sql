CREATE OR REPLACE PACKAGE DW_CL_USER.pkg_etl_dim_games_dw
AS
    CURSOR curs IS SELECT game_id FROM sa_games_user.sa_games;
    I number;
    x number;
    y number;
    z number;
    xxx number;
    PROCEDURE load_games;
END;