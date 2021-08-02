CREATE OR REPLACE PACKAGE BODY DW_CL_USER.pkg_etl_dim_locations_dw_v2 AS

   PROCEDURE load_locations
   IS
            
        BEGIN
        OPEN curs;
        LOOP
            BEGIN
            FETCH curs INTO  I; 
            EXIT WHEN curs%NOTFOUND;  
            sql_stmt := 'select country_id from  ts_dw_data_user.dw_geo_locations where country_id = :1';
            EXECUTE IMMEDIATE sql_stmt into x using I;
                UPDATE ts_dw_data_user.dw_geo_locations
                SET ts_dw_data_user.dw_geo_locations.country_desc = (select country_desc from sb_mbackup_user.sb_mbackup where country_id = I),
                    ts_dw_data_user.dw_geo_locations.region_id = (select region_id from sb_mbackup_user.sb_mbackup where country_id = I),
                    ts_dw_data_user.dw_geo_locations.region_desc = (select region_desc from sb_mbackup_user.sb_mbackup where country_id = I),
                    ts_dw_data_user.dw_geo_locations.part_id = (select part_id from sb_mbackup_user.sb_mbackup where country_id = I),
                    ts_dw_data_user.dw_geo_locations.part_desc = (select part_desc from sb_mbackup_user.sb_mbackup where country_id = I),
                    ts_dw_data_user.dw_geo_locations.geo_systems_id = (select geo_systems_id from sb_mbackup_user.sb_mbackup where country_id = I),
                    ts_dw_data_user.dw_geo_locations.geo_systems_desc = (select geo_systems_desc from sb_mbackup_user.sb_mbackup where country_id = I),
                    ts_dw_data_user.dw_geo_locations.geo_systems_code = (select geo_systems_code from sb_mbackup_user.sb_mbackup where country_id = I),
                    ts_dw_data_user.dw_geo_locations.update_dt = (select CURRENT_DATE FROM DUAL)
                WHERE ts_dw_data_user.dw_geo_locations.country_id  = I;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                Insert into ts_dw_data_user.dw_geo_locations( country_id, country_desc, region_id, region_desc, part_id, part_desc, geo_systems_id, geo_systems_desc, geo_systems_code, update_dt, insert_dt) 
                VALUES (I, (select country_desc from sb_mbackup_user.sb_mbackup where country_id = I), (select region_id from sb_mbackup_user.sb_mbackup where country_id = I),
                        (select region_desc from sb_mbackup_user.sb_mbackup where country_id = I), (select part_id from sb_mbackup_user.sb_mbackup where country_id = I),
                        (select part_desc from sb_mbackup_user.sb_mbackup where country_id = I), (select geo_systems_id from sb_mbackup_user.sb_mbackup where country_id = I),
                        (select geo_systems_desc from sb_mbackup_user.sb_mbackup where country_id = I), (select geo_systems_code from sb_mbackup_user.sb_mbackup where country_id = I),
                        (select CURRENT_DATE FROM DUAL), (select CURRENT_DATE FROM DUAL));
            END;
        END LOOP;
        COMMIT;	
        
        CLOSE curs;
        

   END load_locations;
END;
/