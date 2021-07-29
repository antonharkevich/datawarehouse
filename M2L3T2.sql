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


create table SB_MBackUp_USER.game_objects
(
   object_id               number                         null,
   object_desc             varchar(100)                   null,
   object_parent_id          number                        null
)
tablespace SB_MBackUp;

drop table SB_MBackUp_USER.games;
create table SB_MBackUp_USER.games
(
   game_id               number                         null,
   game_desc             varchar(100)                   null,
   category_id          number                         null
)
tablespace SB_MBackUp;

drop table SB_MBackUp_USER.categories;
create table SB_MBackUp_USER.categories
(
   category_id               number                         null,
   category_desc             varchar(100)                   null,
   platform_id               number                         null
)
tablespace SB_MBackUp;

drop table SB_MBackUp_USER.platforms;
create table SB_MBackUp_USER.platforms
(
   platform_id               number                         null,
   platform_desc             varchar(100)                   null
)
tablespace SB_MBackUp;






INSERT INTO SB_MBackUp_USER.game_objects(object_id
                                   , object_desc
                                   , object_parent_id)
SELECT * from SB_MBackUp_USER.games;

INSERT INTO SB_MBackUp_USER.game_objects(object_id
                                   , object_desc
                                   , object_parent_id)
SELECT * from SB_MBackUp_USER.categories;

INSERT INTO SB_MBackUp_USER.game_objects(object_id
                                   , object_desc)
SELECT * from SB_MBackUp_USER.platforms;

select * from SB_MBackUp_USER.game_objects;

drop table SB_MBackUp_USER.platform_analyze;
create table SB_MBackUp_USER.platform_analyze
(
   object_desc           varchar(100)                         null,
   object_id         number                     null,
   object_parent_id            number                         null,
   object_is_leaf          number                    null,
    object_root            varchar(1000)                    null,
   object_level              number                         null,
   object_path           varchar(1000)                    null

)
tablespace SB_MBackUp;

drop table SB_MBackUp_USER.categories_analyze;
create table SB_MBackUp_USER.categories_analyze
(
   object_desc           varchar(100)                         null,
   object_id         number                     null,
   object_parent_id            number                         null,
   object_root            varchar(1000)                    null,
   object_is_leaf          number                    null,
   object_level              number                         null,
   object_path           varchar(1000)                    null

)
tablespace SB_MBackUp;

truncate table SB_MBackUp_USER.categories_analyze;
insert into SB_MBackUp_USER.categories_analyze(object_desc, object_id, object_parent_id,  object_root, object_is_leaf, object_level, object_path)
select lpad(' ', level*2-1,' ') || e.object_desc, object_id, object_parent_id,  CONNECT_BY_ROOT object_desc as root,  connect_by_isleaf, level, sys_connect_by_path(object_desc,':') path
from SB_MBackUp_USER.game_objects e
start with e.object_id > 10 and e.object_id < 51
connect by prior e.object_id = e.object_parent_id
order siblings by e.object_desc;

insert into SB_MBackUp_USER.platform_analyze(object_desc, object_id, object_parent_id,  object_root, object_is_leaf, object_level, object_path)
select lpad(' ', level*2-1,' ') || e.object_desc, object_id, object_parent_id,  CONNECT_BY_ROOT object_desc as root,  connect_by_isleaf, level, sys_connect_by_path(object_desc,':') path
from SB_MBackUp_USER.game_objects e
start with e.object_parent_id is null
connect by prior e.object_id = e.object_parent_id
order siblings by e.object_desc;