INSERT INTO SB_MBackUp_USER.games(game_id
                                  , game_desc
                                  , category_id)
SELECT ROWNUM + 50
       , 'Game ' || to_char(ROWNUM)
       , round((DBMS_RANDOM.VALUE(11, 50)),0)
  FROM dual
CONNECT BY LEVEL <= 100000;
COMMIT;


INSERT INTO SB_MBackUp_USER.categories(category_id
                                       , category_desc
                                       , platform_id)
 SELECT ROWNUM + 10
        , 'Category ' || to_char(ROWNUM)
        , round((DBMS_RANDOM.VALUE(1, 10)),0)
   FROM dual
CONNECT BY LEVEL <= 40;
 COMMIT;

 INSERT INTO SB_MBackUp_USER.platforms(platform_id
                                       , platform_desc)
 SELECT ROWNUM
        , 'Platform ' || to_char(ROWNUM)
   FROM dual
CONNECT BY LEVEL <= 10;
 COMMIT;


CREATE TABLE sb_mbackup_user.game_objects
(
   object_id               NUMBER                        NULL,
   object_desc             VARCHAR(100)                  NULL,
   object_parent_id        NUMBER                        NULL
)
TABLESPACE sb_mbackup;

DROP TABLE sb_mbackup_user.games;
CREATE TABLE sb_mbackup_user.games
(
   game_id              NUMBER                         NULL,
   game_desc            VARCHAR(100)                   NULL,
   category_id          NUMBER                         NULL
)
TABLESPACE sb_mbackup;

  DROP TABLE sb_mbackup_user.categories;
CREATE TABLE sb_mbackup_user.categories
(
   category_id               NUMBER                         NULL,
   category_desc             VARCHAR(100)                   NULL,
   platform_id               NUMBER                         NULL
)
TABLESPACE sb_mbackup;

  DROP TABLE sb_mbackup_user.platforms;
CREATE TABLE sb_mbackup_user.platforms
(
   platform_id               NUMBER                         NULL,
   platform_desc             VARCHAR(100)                   NULL
)
TABLESPACE sb_mbackup;






INSERT INTO sb_mbackup_user.game_objects(object_id
                                        , object_desc
                                        , object_parent_id)
SELECT * FROM sb_mbackup_user.games;

INSERT INTO sb_mbackup_user.game_objects(object_id
                                        , object_desc
                                        , object_parent_id)
SELECT * FROM sb_mbackup_user.categories;

INSERT INTO sb_mbackup_user.game_objects(object_id
                                         , object_desc)
SELECT * FROM sb_mbackup_user.platforms;

SELECT * FROM sb_mbackup_user.game_objects;

  DROP TABLE sb_mbackup_user.platform_analyze;
CREATE TABLE sb_mbackup_user.platform_analyze
(
   object_desc           VARCHAR(100)                   NULL,
   object_id             NUMBER                         NULL,
   object_parent_id      NUMBER                         NULL,
   object_is_leaf        NUMBER                         NULL,
   object_root           VARCHAR(1000)                  NULL,
   object_level          NUMBER                         NULL,
   object_path           VARCHAR(1000)                  NULL

)
TABLESPACE sb_mbackup;

  DROP TABLE sb_mbackup_user.categories_analyze;
CREATE TABLE sb_mbackup_user.categories_analyze
(
   object_desc           VARCHAR(100)                   NULL,
   object_id             NUMBER                         NULL,
   object_parent_id      NUMBER                         NULL,
   object_root           VARCHAR(1000)                  NULL,
   object_is_leaf        NUMBER                         NULL,
   object_level          NUMBER                         NULL,
   object_path           VARCHAR(1000)                  NULL

)
TABLESPACE sb_mbackup;

TRUNCATE TABLE sb_mbackup_user.categories_analyze;


 INSERT INTO sb_mbackup_user.categories_analyze(object_desc
                                                , object_id
                                                , object_parent_id
                                                , object_root
                                                , object_is_leaf
                                                , object_level
                                                , object_path)
 SELECT lpad(' ', LEVEL*2-1,' ') || E.object_desc
        , object_id
        , object_parent_id
        , CONNECT_BY_ROOT object_desc AS ROOT
        , CONNECT_BY_ISLEAF, LEVEL
        , sys_connect_by_path(object_desc,':') PATH
   FROM sb_mbackup_user.game_objects E
  START WITH E.object_id > 10 AND E.object_id < 51
CONNECT BY PRIOR E.object_id = E.object_parent_id
  ORDER SIBLINGS BY E.object_desc;

 INSERT INTO sb_mbackup_user.platform_analyze(object_desc
                                              , object_id
                                              , object_parent_id
                                              , object_root
                                              , object_is_leaf
                                              , object_level
                                              , object_path)
 SELECT lpad(' ', LEVEL*2-1,' ') || E.object_desc
        , object_id, object_parent_id
        ,  CONNECT_BY_ROOT object_desc AS ROOT
        ,  CONNECT_BY_ISLEAF, LEVEL
        , sys_connect_by_path(object_desc,':') PATH
   FROM sb_mbackup_user.game_objects E
  START WITH E.object_parent_id IS NULL
CONNECT BY PRIOR E.object_id = E.object_parent_id
  ORDER SIBLINGS BY E.object_desc;