CREATE TABLESPACE SB_MBackUp
DATAFILE 'SB_MBackUp.dat'
SIZE 200M
 AUTOEXTEND ON NEXT 100M
 SEGMENT SPACE MANAGEMENT AUTO;



CREATE USER SB_MBackUp_USER
  IDENTIFIED BY "%PWD%"
    DEFAULT TABLESPACE SB_MBackUp;

GRANT CONNECT,RESOURCE TO SB_MBackUp_USER;

drop table SB_MBackUp_USER.SB_MBackUp;
create table SB_MBackUp_USER.SB_MBackUp
(
   country_id           number                         not null,
   country_desc         varchar(100)                    not null,
   region_id            number                         not null,
   region_desc          varchar(100)                    not null,
   part_id              number                         not null,
   part_desc            varchar(100)                    not null,
   geo_systems_id       number                         not null,
   geo_systems_code     varchar(100)                    not null,
   geo_systems_desc     varchar(100)                    not null
)
tablespace SB_MBackUp;

GRANT UNLIMITED TABLESPACE TO SB_MBackUp_USER;
commit;


insert into SB_MBackUp_USER.SB_MBackUp(geo_systems_id, geo_systems_code, geo_systems_desc, part_id, part_desc, region_id, region_desc, country_id, country_desc)
with geo_system as (
    select geo_id, geo_system_id, geo_system_code, geo_system_desc from u_dw_references.cu_geo_systems
), 
geo_parts as (
    select geo_id, part_id, part_desc from u_dw_references.cu_geo_parts
),
geo_regions as (
    select geo_id, region_id, region_desc from u_dw_references.cu_geo_regions
),

geo_countries as (
    select geo_id, country_id, country_desc from u_dw_references.cu_countries
),
links as (
    select parent_geo_id, child_geo_id from u_dw_references.w_geo_object_links 
    CONNECT BY PRIOR child_geo_id = parent_geo_id
),
links2 as (
    select parent_geo_id, child_geo_id from u_dw_references.w_geo_object_links 
    CONNECT BY PRIOR child_geo_id = parent_geo_id
),
links3 as (
    select parent_geo_id, child_geo_id from u_dw_references.w_geo_object_links 
    CONNECT BY PRIOR child_geo_id = parent_geo_id
),
joined as (
    select geo_system_id, geo_system_code, geo_system_desc, part_id, part_desc, region_id, region_desc, country_id, country_desc
    from geo_system, geo_parts, geo_regions, geo_countries, links, links2, links3
    
    where (geo_system.geo_id = links.parent_geo_id and geo_parts.geo_id = links.child_geo_id) and (geo_parts.geo_id = links2.parent_geo_id and geo_regions.geo_id = links2.child_geo_id) and
          (geo_regions.geo_id = links3.parent_geo_id and geo_countries.geo_id = links3.child_geo_id)
)
select * from joined;

select * from SB_MBackUp_USER.SB_MBackUp order by country_id;


create table SB_MBackUp_USER.SB_MBackUp_fx
(
   geo_id               number                         not null,
   geo_desc             varchar(100)                   not null

)
tablespace SB_MBackUp;




insert into SB_MBackUp_USER.SB_MBackUp_fx(geo_id, geo_desc)
select geo_id, geo_system_desc from u_dw_references.cu_geo_systems;


insert into SB_MBackUp_USER.SB_MBackUp_fx(geo_id, geo_desc)
select geo_id, part_desc from u_dw_references.cu_geo_parts;

insert into SB_MBackUp_USER.SB_MBackUp_fx(geo_id, geo_desc)
select geo_id, region_desc from u_dw_references.cu_geo_regions;

insert into SB_MBackUp_USER.SB_MBackUp_fx(geo_id, geo_desc)
select geo_id, country_desc from u_dw_references.cu_countries;

select * from SB_MBackUp_USER.SB_MBackUp_fx order by geo_id;


ALTER TABLE SB_MBackUp_USER.SB_MBackUp_fx ADD geo_parent_id number NULL;

truncate table SB_MBackUp_USER.SB_MBackUp_fx;


insert into SB_MBackUp_USER.SB_MBackUp_fx(geo_id, geo_desc, geo_parent_id)
with links as (
    select parent_geo_id, child_geo_id from u_dw_references.w_geo_object_links 
            where parent_geo_id < 276 and child_geo_id < 276
            connect by prior child_geo_id = parent_geo_id
),
geo_objects as (
    select geo_id, geo_desc from SB_MBackUp_USER.SB_MBackUp_fx
),
joined as (
    select geo_id, geo_desc, parent_geo_id
    from geo_objects, links
    where geo_objects.geo_id = links.child_geo_id
)
select DISTINCT * from joined order by geo_id;


select * from SB_MBackUp_USER.SB_MBackUp_fx order by geo_id;

delete from SB_MBackUp_USER.SB_MBackUp_fx where geo_parent_id is null and geo_id != 6;
commit;

create table SB_MBackUp_USER.SB_MBackUp_final(

select a.geo_parent_id, count(a.geo_id) from SB_MBackUp_USER.SB_MBackUp_fx a, SB_MBackUp_USER.SB_MBackUp_final b where a.geo_id = b.geo_id group by a.geo_parent_id;

insert into SB_MBackUp_USER.SB_MBackUp_final(geo_desc, geo_id, geo_parent_id, geo_is_leaf, geo_level, geo_path)
select e.geo_desc, geo_id, geo_parent_id, connect_by_isleaf, level, sys_connect_by_path(geo_desc,':') path
from SB_MBackUp_USER.SB_MBackUp_fx e
start with e.geo_parent_id is null
connect by prior e.geo_id = e.geo_parent_id
order siblings by e.geo_desc;




create table SB_MBackUp_USER.SB_MBackUp_final
(
   geo_desc           varchar(100)                         null,
   geo_id         number                     null,
   geo_parent_id            number                         null,
   geo_is_leaf          number                    null,
   geo_level              number                         null,
   geo_path           varchar(1000)                    null,
   geo_type      varchar(100)                         null,
   geo_count_of_childs    number                    null
)
tablespace SB_MBackUp;

GRANT UNLIMITED TABLESPACE TO SB_MBackUp_USER;
commit;

select geo_parent_id, count(geo_id) from SB_MBackUp_USER.SB_MBackUp_fx a  group by a.geo_parent_id order by geo_parent_id;
select * from SB_MBackUp_USER.SB_MBackUp_final;

update SB_MBackUp_USER.SB_MBackUp_final set geo_type='leaf' where geo_is_leaf = 1 ;
update SB_MBackUp_USER.SB_MBackUp_final set geo_type='branch' where geo_is_leaf = 0 ;
update SB_MBackUp_USER.SB_MBackUp_final set geo_type='root' where geo_parent_id is null ;


MERGE INTO SB_MBackUp_USER.SB_MBackUp_final target  USING (select geo_parent_id, count(geo_id) kol  from SB_MBackUp_USER.SB_MBackUp_fx a  group by a.geo_parent_id order by geo_parent_id) source   -- источник данных, который мы рассмотрели выше
ON (target.geo_id = source.geo_parent_id)  -- условие связи между источником и изменяемой таблицей
WHEN MATCHED
    THEN UPDATE SET target.geo_count_of_childs = source.kol -- обновление

commit;