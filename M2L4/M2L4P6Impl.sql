CREATE OR REPLACE PACKAGE BODY DW_CL_USER.pkg_etl_dim_games_dw AS

   PROCEDURE load_games
   IS
        BEGIN
        IF curs %ISOPEN THEN
        CLOSE curs ;
        END IF;
        OPEN curs;
        LOOP
            BEGIN
             FETCH curs INTO  I; 
              EXIT WHEN curs%NOTFOUND;  
            SELECT game_id   INTO X FROM  ts_dw_data_user.dw_games_scd WHERE game_surr_id = I;
            SELECT game_cost INTO y FROM sa_games_user.sa_games        WHERE game_id = I;
            SELECT game_cost INTO z FROM ts_dw_data_user.dw_games_scd  WHERE game_surr_id = I;
                IF y = z THEN
                UPDATE ts_dw_data_user.dw_games_scd
                   SET ts_dw_data_user.dw_games_scd.game_desc  = (SELECT game_desc      FROM sa_games_user.sa_games  WHERE game_id = I),
                    ts_dw_data_user.dw_games_scd.game_cost     = (SELECT game_cost      FROM sa_games_user.sa_games  WHERE game_id = I),
                    ts_dw_data_user.dw_games_scd.category_id   = (SELECT category_id    FROM sa_games_user.sa_games  WHERE game_id = I),
                    ts_dw_data_user.dw_games_scd.category_desc = (SELECT category_desc  FROM sa_games_user.sa_games  WHERE game_id = I),
                    ts_dw_data_user.dw_games_scd.platform_id   = (SELECT platform_id    FROM sa_games_user.sa_games  WHERE game_id = I),
                    ts_dw_data_user.dw_games_scd.platform_desc = (SELECT platform_desc  FROM sa_games_user.sa_games  WHERE game_id = I),
                    ts_dw_data_user.dw_games_scd.update_dt     = (SELECT CURRENT_DATE   FROM DUAL)
                WHERE ts_dw_data_user.dw_games_scd.game_id     = I;
                ELSE
                        
                        
                SELECT MIN(game_surr_id) INTO xxx  FROM ts_dw_data_user.dw_games_scd;   
                
                UPDATE ts_dw_data_user.dw_games_scd
                SET 
                    ts_dw_data_user.dw_games_scd.game_surr_id     = (xxx - 1),
                    ts_dw_data_user.dw_games_scd.game_desc        = (SELECT game_desc     FROM sa_games_user.sa_games  WHERE game_id = I),
                    ts_dw_data_user.dw_games_scd.category_id      = (SELECT category_id   FROM sa_games_user.sa_games  WHERE game_id = I),
                    ts_dw_data_user.dw_games_scd.category_desc    = (SELECT category_desc FROM sa_games_user.sa_games  WHERE game_id = I),
                    ts_dw_data_user.dw_games_scd.platform_id      = (SELECT platform_id   FROM sa_games_user.sa_games  WHERE game_id = I),
                    ts_dw_data_user.dw_games_scd.platform_desc    = (SELECT platform_desc FROM sa_games_user.sa_games  WHERE game_id = I),
                    ts_dw_data_user.dw_games_scd.update_dt        = (SELECT CURRENT_DATE  FROM DUAL),
                    ts_dw_data_user.dw_games_scd.valid_to         = (SELECT CURRENT_DATE  FROM DUAL),
                    ts_dw_data_user.dw_games_scd.is_active        = 0                 
                WHERE ts_dw_data_user.dw_games_scd.game_id = I AND ts_dw_data_user.dw_games_scd.game_cost = z;
                
                
                INSERT INTO ts_dw_data_user.dw_games_scd(game_id, game_surr_id, game_desc, game_cost, valid_from, valid_to, is_active, category_id, category_desc, platform_id, platform_desc, insert_dt, update_dt)
                VALUES (I
                        , I  
                        , (SELECT game_desc     FROM sa_games_user.sa_games  WHERE game_id = I)
                        , (SELECT game_cost     FROM sa_games_user.sa_games  WHERE game_id = I)
                        , (SELECT CURRENT_DATE  FROM DUAL)
                        , (SELECT CURRENT_DATE  FROM DUAL)
                        , 1
                        , (SELECT category_id   FROM sa_games_user.sa_games  WHERE game_id = I)
                        , (SELECT category_desc FROM sa_games_user.sa_games  WHERE game_id = I)
                        , (SELECT platform_id   FROM sa_games_user.sa_games  WHERE game_id = I)
                        , (SELECT platform_desc FROM sa_games_user.sa_games  WHERE game_id = I)
                        , (SELECT CURRENT_DATE  FROM DUAL)
                        , (SELECT CURRENT_DATE  FROM DUAL));
                END IF;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                INSERT INTO ts_dw_data_user.dw_games_scd(game_id
                                                         , game_surr_id
                                                         , game_desc
                                                         , game_cost
                                                         , valid_from
                                                         , valid_to
                                                         , is_active
                                                         , category_id
                                                         , category_desc
                                                         , platform_id
                                                         , platform_desc
                                                         , insert_dt
                                                         , update_dt) 
                VALUES (I
                        , I 
                        , (SELECT game_desc     FROM sa_games_user.sa_games  WHERE game_id = I)
                        , (SELECT game_cost     FROM sa_games_user.sa_games  WHERE game_id = I)
                        , (SELECT CURRENT_DATE  FROM DUAL)
                        , (SELECT CURRENT_DATE  FROM DUAL)
                        , 1
                        , (SELECT category_id   FROM sa_games_user.sa_games  WHERE game_id = I)
                        , (SELECT category_desc FROM sa_games_user.sa_games  WHERE game_id = I)
                        , (SELECT platform_id   FROM sa_games_user.sa_games  WHERE game_id = I)
                        , (SELECT platform_desc FROM sa_games_user.sa_games  WHERE game_id = I)
                        , (SELECT CURRENT_DATE  FROM DUAL)
                        , (SELECT CURRENT_DATE  FROM DUAL));
            END;
        END LOOP;
        COMMIT;	
        
        CLOSE curs;
        

   END load_games;
END;
/