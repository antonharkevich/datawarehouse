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
            select game_id into x from  ts_dw_data_user.dw_games_scd where game_surr_id = I;
                select game_cost into y from sa_games_user.sa_games where game_id = I;
                select game_cost into z from ts_dw_data_user.dw_games_scd where game_surr_id = I;
                IF y = z THEN
                UPDATE ts_dw_data_user.dw_games_scd
                SET ts_dw_data_user.dw_games_scd.game_desc = (select game_desc from sa_games_user.sa_games  where game_id = I),
                    ts_dw_data_user.dw_games_scd.game_cost = (select game_cost from sa_games_user.sa_games  where game_id = I),
                    ts_dw_data_user.dw_games_scd.category_id = (select category_id from sa_games_user.sa_games  where game_id = I),
                    ts_dw_data_user.dw_games_scd.category_desc = (select category_desc from sa_games_user.sa_games  where game_id = I),
                    ts_dw_data_user.dw_games_scd.platform_id = (select platform_id from sa_games_user.sa_games  where game_id = I),
                    ts_dw_data_user.dw_games_scd.platform_desc = (select platform_desc from sa_games_user.sa_games  where game_id = I),
                    ts_dw_data_user.dw_games_scd.update_dt = (select CURRENT_DATE from DUAL)
                WHERE ts_dw_data_user.dw_games_scd.game_id = I;
                ELSE
                        
                        
                        
                        



                select min(game_surr_id) into xxx  from ts_dw_data_user.dw_games_scd;   
                UPDATE ts_dw_data_user.dw_games_scd
                
                
                
                SET 
                    ts_dw_data_user.dw_games_scd.game_surr_id = (xxx - 1),
                    ts_dw_data_user.dw_games_scd.game_desc = (select game_desc from sa_games_user.sa_games  where game_id = I),
                    
                    ts_dw_data_user.dw_games_scd.category_id = (select category_id from sa_games_user.sa_games  where game_id = I),
                    
                    
                    ts_dw_data_user.dw_games_scd.category_desc = (select category_desc from sa_games_user.sa_games  where game_id = I),
                    ts_dw_data_user.dw_games_scd.platform_id = (select platform_id from sa_games_user.sa_games  where game_id = I),
                    
                    
                    ts_dw_data_user.dw_games_scd.platform_desc = (select platform_desc from sa_games_user.sa_games  where game_id = I),
                    ts_dw_data_user.dw_games_scd.update_dt = (select CURRENT_DATE from DUAL),
                    ts_dw_data_user.dw_games_scd.valid_to = (select CURRENT_DATE from DUAL),
                    ts_dw_data_user.dw_games_scd.is_active = 0
                    
                WHERE ts_dw_data_user.dw_games_scd.game_id = I and ts_dw_data_user.dw_games_scd.game_cost = z;
                
                
                INSERT INTO ts_dw_data_user.dw_games_scd(game_id, game_surr_id, game_desc, game_cost, valid_from, valid_to, is_active, category_id, category_desc, platform_id, platform_desc, insert_dt, update_dt)
                VALUES (I, I , 
                        (select game_desc from sa_games_user.sa_games  where game_id = I)
                        , (select game_cost from sa_games_user.sa_games  where game_id = I)
                        , (select CURRENT_DATE from DUAL)
                        , (select CURRENT_DATE from DUAL)
                        , 1
                        , (select category_id from sa_games_user.sa_games  where game_id = I)
                        , (select category_desc from sa_games_user.sa_games  where game_id = I)
                        , (select platform_id from sa_games_user.sa_games  where game_id = I)
                        , (select platform_desc from sa_games_user.sa_games  where game_id = I)
                        , (select CURRENT_DATE from DUAL)
                        , (select CURRENT_DATE from DUAL));
                END IF;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                Insert into ts_dw_data_user.dw_games_scd(game_id, game_surr_id, game_desc, game_cost, valid_from, valid_to, is_active, category_id, category_desc, platform_id, platform_desc, insert_dt, update_dt) 
                VALUES (I, I, 
                        (select game_desc from sa_games_user.sa_games  where game_id = I)
                        , (select game_cost from sa_games_user.sa_games  where game_id = I)
                        , (select CURRENT_DATE from DUAL)
                        , (select CURRENT_DATE from DUAL)
                        , 1
                        , (select category_id from sa_games_user.sa_games  where game_id = I)
                        , (select category_desc from sa_games_user.sa_games  where game_id = I)
                        , (select platform_id from sa_games_user.sa_games  where game_id = I)
                        , (select platform_desc from sa_games_user.sa_games  where game_id = I)
                        , (select CURRENT_DATE from DUAL)
                        , (select CURRENT_DATE from DUAL));
            END;
        END LOOP;
        COMMIT;	
        
        CLOSE curs;
        

   END load_games;
END;
/