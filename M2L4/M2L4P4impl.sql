CREATE OR REPLACE PACKAGE BODY DW_CL_USER.pkg_etl_dim_locations_dw AS

   PROCEDURE load_locations
   IS
    BEGIN
        OPEN curs;
        LOOP
            BEGIN
            FETCH curs INTO  I; 
            EXIT WHEN curs%NOTFOUND;  
            SELECT country_id INTO X FROM  ts_dw_data_user.dw_geo_locations WHERE country_id = I;
                UPDATE ts_dw_data_user.dw_geo_locations
                   SET ts_dw_data_user.dw_geo_locations.country_desc       = (SELECT country_desc FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                       , ts_dw_data_user.dw_geo_locations.region_id        = (SELECT region_id FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                       , ts_dw_data_user.dw_geo_locations.region_desc      = (SELECT region_desc FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                       , ts_dw_data_user.dw_geo_locations.part_id          = (SELECT part_id FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                       , ts_dw_data_user.dw_geo_locations.part_desc        = (SELECT part_desc FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                       , ts_dw_data_user.dw_geo_locations.geo_systems_id   = (SELECT geo_systems_id FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                       , ts_dw_data_user.dw_geo_locations.geo_systems_desc = (SELECT geo_systems_desc FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                       , ts_dw_data_user.dw_geo_locations.geo_systems_code = (SELECT geo_systems_code FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                       , ts_dw_data_user.dw_geo_locations.update_dt        = (SELECT CURRENT_DATE FROM DUAL)
                WHERE ts_dw_data_user.dw_geo_locations.country_id          = I;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                INSERT INTO ts_dw_data_user.dw_geo_locations( country_id
                                                              , country_desc
                                                              , region_id
                                                              , region_desc
                                                              , part_id
                                                              , part_desc
                                                              , geo_systems_id
                                                              , geo_systems_desc
                                                              , geo_systems_code
                                                              , update_dt
                                                              , insert_dt) 
                VALUES (I
                        , (SELECT country_desc     FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                        , (SELECT region_id        FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                        , (SELECT region_desc      FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                        , (SELECT part_id          FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                        , (SELECT part_desc        FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                        , (SELECT geo_systems_id   FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                        , (SELECT geo_systems_desc FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                        , (SELECT geo_systems_code FROM sb_mbackup_user.sb_mbackup WHERE country_id = I)
                        , (SELECT CURRENT_DATE     FROM DUAL)
                        , (SELECT CURRENT_DATE     FROM DUAL));
            END;
        END LOOP;
        COMMIT;	
        
        CLOSE curs;
        

   END load_locations;
END;
/