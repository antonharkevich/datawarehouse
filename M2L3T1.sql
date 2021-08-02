  CREATE TABLESPACE SB_MBackUp
DATAFILE 'SB_MBackUp.dat'
    SIZE 200M
AUTOEXTEND ON NEXT 100M
 SEGMENT SPACE MANAGEMENT AUTO;



    CREATE USER SB_MBackUp_USER
IDENTIFIED BY "%PWD%"
   DEFAULT TABLESPACE SB_MBackUp;

GRANT CONNECT,RESOURCE TO SB_MBackUp_USER;

DROP TABLE sb_mbackup_user.sb_mbackup;
CREATE TABLE sb_mbackup_user.sb_mbackup
(
   country_id           NUMBER                          NOT NULL,
   country_desc         VARCHAR(100)                    NOT NULL,
   region_id            NUMBER                          NOT NULL,
   region_desc          VARCHAR(100)                    NOT NULL,
   part_id              NUMBER                          NOT NULL,
   part_desc            VARCHAR(100)                    NOT NULL,
   geo_systems_id       NUMBER                          NOT NULL,
   geo_systems_code     VARCHAR(100)                    NOT NULL,
   geo_systems_desc     VARCHAR(100)                    NOT NULL
)
TABLESPACE sb_mbackup;

GRANT UNLIMITED TABLESPACE TO sb_mbackup_user;
COMMIT;


INSERT INTO sb_mbackup_user.sb_mbackup(geo_systems_id
                                       , geo_systems_code
                                       , geo_systems_desc
                                       , part_id
                                       , part_desc
                                       , region_id
                                       , region_desc
                                       , country_id
                                       , country_desc)
  WITH geo_system AS (
        SELECT geo_id
               , geo_system_id
               , geo_system_code
               , geo_system_desc 
          FROM u_dw_references.cu_geo_systems)
       , geo_parts AS (
        SELECT geo_id, part_id, part_desc 
          FROM u_dw_references.cu_geo_parts)
       , geo_regions AS (
        SELECT geo_id
               , region_id
               , region_desc 
          FROM u_dw_references.cu_geo_regions)    
       , geo_countries AS (
        SELECT geo_id
               , country_id
               , country_desc 
        FROM u_dw_references.cu_countries)
       , links AS (
        SELECT parent_geo_id
               , child_geo_id 
          FROM u_dw_references.w_geo_object_links 
       CONNECT BY PRIOR child_geo_id = parent_geo_id)
       , links2 AS (
         SELECT parent_geo_id
                , child_geo_id 
           FROM u_dw_references.w_geo_object_links 
        CONNECT BY PRIOR child_geo_id = parent_geo_id)
        , links3 AS (
          SELECT parent_geo_id
                 , child_geo_id 
            FROM u_dw_references.w_geo_object_links 
         CONNECT BY PRIOR child_geo_id = parent_geo_id)
         , joined AS (
           SELECT geo_system_id
                  , geo_system_code
                  , geo_system_desc
                  , part_id
                  , part_desc
                  , region_id
                  , region_desc
                  , country_id
                  , country_desc
             FROM geo_system
                  , geo_parts
                  , geo_regions
                  , geo_countries
                  , links
                  , links2
                  , links3
            WHERE (geo_system.geo_id = links.parent_geo_id AND geo_parts.geo_id = links.child_geo_id) 
                   AND (geo_parts.geo_id = links2.parent_geo_id AND geo_regions.geo_id = links2.child_geo_id) 
                   AND (geo_regions.geo_id = links3.parent_geo_id AND geo_countries.geo_id = links3.child_geo_id))
SELECT DISTINCT * FROM joined;

SELECT * FROM sb_mbackup_user.sb_mbackup ORDER BY country_id;
COMMIT;


CREATE TABLE sb_mbackup_user.sb_mbackup_fx
(
   geo_id               NUMBER                         NOT NULL,
   geo_desc             VARCHAR(100)                   NOT NULL

)
TABLESPACE sb_mbackup;




INSERT INTO sb_mbackup_user.sb_mbackup_fx(geo_id, geo_desc)
SELECT geo_id, geo_system_desc FROM u_dw_references.cu_geo_systems;


INSERT INTO sb_mbackup_user.sb_mbackup_fx(geo_id, geo_desc)
SELECT geo_id, part_desc FROM u_dw_references.cu_geo_parts;

INSERT INTO sb_mbackup_user.sb_mbackup_fx(geo_id, geo_desc)
SELECT geo_id, region_desc FROM u_dw_references.cu_geo_regions;

INSERT INTO sb_mbackup_user.sb_mbackup_fx(geo_id, geo_desc)
SELECT geo_id, country_desc FROM u_dw_references.cu_countries;

SELECT * FROM sb_mbackup_user.sb_mbackup_fx ORDER BY geo_id;


ALTER TABLE sb_mbackup_user.sb_mbackup_fx ADD geo_parent_id NUMBER NULL;

TRUNCATE TABLE sb_mbackup_user.sb_mbackup_fx;


INSERT INTO sb_mbackup_user.sb_mbackup_fx(geo_id
                                          , geo_desc
                                          , geo_parent_id)
  WITH links AS (
        SELECT parent_geo_id
               , child_geo_id 
          FROM u_dw_references.w_geo_object_links 
         WHERE parent_geo_id < 276 AND child_geo_id < 276
       CONNECT BY PRIOR child_geo_id = parent_geo_id)
       , geo_objects AS (
        SELECT geo_id
               , geo_desc 
          FROM sb_mbackup_user.sb_mbackup_fx)
        , joined AS (
        SELECT geo_id
               , geo_desc
               , parent_geo_id
          FROM geo_objects
               , links
         WHERE geo_objects.geo_id = links.child_geo_id
)
SELECT DISTINCT * FROM joined ORDER BY geo_id;


SELECT * FROM sb_mbackup_user.sb_mbackup_fx ORDER BY geo_id;

DELETE FROM sb_mbackup_user.sb_mbackup_fx 
 WHERE geo_parent_id IS NULL AND geo_id != 6;
COMMIT;



CREATE TABLE sb_mbackup_user.sb_mbackup_final(

SELECT A.geo_parent_id
       , COUNT(A.geo_id) 
  FROM sb_mbackup_user.sb_mbackup_fx A
       , sb_mbackup_user.sb_mbackup_final b 
 WHERE A.geo_id = b.geo_id 
 GROUP BY A.geo_parent_id;

INSERT INTO sb_mbackup_user.sb_mbackup_final(geo_desc
                                             , geo_id
                                             , geo_parent_id
                                             , geo_is_leaf
                                             , geo_level
                                             , geo_path)
 SELECT E.geo_desc
        , geo_id
        , geo_parent_id
        , CONNECT_BY_ISLEAF
        , LEVEL
        , sys_connect_by_path(geo_desc,':') PATH
   FROM sb_mbackup_user.sb_mbackup_fx E
  START WITH E.geo_parent_id IS NULL
CONNECT BY PRIOR E.geo_id = E.geo_parent_id
  ORDER SIBLINGS BY E.geo_desc;




CREATE TABLE sb_mbackup_user.sb_mbackup_final
(
   geo_desc               VARCHAR(100)               NULL,
   geo_id                 NUMBER                     NULL,
   geo_parent_id          NUMBER                     NULL,
   geo_is_leaf            NUMBER                     NULL,
   geo_level              NUMBER                     NULL,
   geo_path               VARCHAR(1000)              NULL,
   geo_type               VARCHAR(100)               NULL,
   geo_count_of_childs    NUMBER                     NULL
)
TABLESPACE sb_mbackup;

GRANT UNLIMITED TABLESPACE TO sb_mbackup_user;
COMMIT;

SELECT geo_parent_id
       , COUNT(geo_id) 
  FROM sb_mbackup_user.sb_mbackup_fx A  
 GROUP BY A.geo_parent_id 
 ORDER BY geo_parent_id;
 
 
SELECT * FROM sb_mbackup_user.sb_mbackup_final;

UPDATE sb_mbackup_user.sb_mbackup_final SET geo_type='leaf' WHERE geo_is_leaf = 1 ;
UPDATE sb_mbackup_user.sb_mbackup_final SET geo_type='branch' WHERE geo_is_leaf = 0 ;
UPDATE sb_mbackup_user.sb_mbackup_final SET geo_type='root' WHERE geo_parent_id IS NULL ;


MERGE INTO sb_mbackup_user.sb_mbackup_final TARGET  
USING (SELECT geo_parent_id
              , COUNT(geo_id) kol  
         FROM sb_mbackup_user.sb_mbackup_fx A  
        GROUP BY A.geo_parent_id 
        ORDER BY geo_parent_id) SOURCE   -- источник данных, который мы рассмотрели выше
   ON (TARGET.geo_id = SOURCE.geo_parent_id)  -- условие связи между источником и изменяемой таблицей
 WHEN MATCHED
         THEN UPDATE SET TARGET.geo_count_of_childs = SOURCE.kol -- обновление

COMMIT;