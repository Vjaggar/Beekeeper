USE beekeeper;
DELETE FROM beekeeper_log WHERE task_id = 1526753708078925083;

insert into beekeeper_log(task_id,exectime,table_name,hql_file,blockcnt,blockmess,loop_cnt,hql,start_time,over_time,use_time,task_status) values(1526753708078925083,20180101,'a','/root/a.hql',1,'A',0,' 
 
 
 --<CUT>[A]€1€
 use test;',1526753708,1526753708.241,0.241,0);
insert into beekeeper_log(task_id,exectime,table_name,hql_file,blockcnt,blockmess,loop_cnt,hql,start_time,over_time,use_time,task_status) values(1526753708078925083,20180101,'a','/root/a.hql',1,'A',0,' show tables;',1526753708.241,1526753708.309,0.068,0);
insert into beekeeper_log(task_id,exectime,table_name,hql_file,blockcnt,blockmess,loop_cnt,hql,start_time,over_time,use_time,task_status) values(1526753708078925083,20180101,'a','/root/a.hql',2,'B',0,' --<CUT>[B]€2€
 drop table if exists test.student1;',1526753708.309,1526753708.366,0.057,0);
insert into beekeeper_log(task_id,exectime,table_name,hql_file,blockcnt,blockmess,loop_cnt,hql,start_time,over_time,use_time,task_status,error_mess) values(1526753708078925083,20180101,'a','/root/a.hql',3,'C',0,' --<CUT>[C]€3€
 create table test.student1 as 
 select count(*) 1from test.student;',1526753708.366,1526753710,1.634,-1,'Error: org.apache.spark.sql.catalyst.parser.ParseException: ');

insert into beekeeper_log(task_id,exectime,table_name,hql_file,blockcnt,blockmess,loop_cnt,hql,start_time,over_time,use_time,task_status,error_mess) values(1526753708078925083,20180101,'a','/root/a.hql',3,'C',1,' --<CUT>[C]€3€
 create table test.student1 as 
 select count(*) 1from test.student;',1526753712,1526753713,1,-1,'Error: org.apache.spark.sql.catalyst.parser.ParseException: ');

insert into beekeeper_log(task_id,exectime,table_name,hql_file,blockcnt,blockmess,loop_cnt,hql,start_time,over_time,use_time,task_status,error_mess) values(1526753708078925083,20180101,'a','/root/a.hql',3,'C',2,' --<CUT>[C]€3€
 create table test.student1 as 
 select count(*) 1from test.student;',1526753715,1526753718,3,-1,'Error: org.apache.spark.sql.catalyst.parser.ParseException: ');

insert into beekeeper_log(task_id,exectime,table_name,hql_file,blockcnt,blockmess,loop_cnt,hql,start_time,over_time,use_time,task_status,error_mess) values(1526753708078925083,20180101,'a','/root/a.hql',3,'C',3,' --<CUT>[C]€3€
 create table test.student1 as 
 select count(*) 1from test.student;',1526753720,1526753722,2,-1,'Error: org.apache.spark.sql.catalyst.parser.ParseException: ');

insert into beekeeper_log(task_id,exectime,table_name,hql_file,blockcnt,blockmess,loop_cnt,hql,start_time,over_time,use_time,task_status,error_mess) values(1526753708078925083,20180101,'a','/root/a.hql',3,'C',4,' --<CUT>[C]€3€
 create table test.student1 as 
 select count(*) 1from test.student;',1526753724,1526753726,2,-1,'Error: org.apache.spark.sql.catalyst.parser.ParseException: ');

insert into beekeeper_log(task_id,exectime,table_name,hql_file,blockcnt,blockmess,loop_cnt,hql,start_time,over_time,use_time,task_status,error_mess) values(1526753708078925083,20180101,'a','/root/a.hql',3,'C',5,' --<CUT>[C]€3€
 create table test.student1 as 
 select count(*) 1from test.student;',1526753728,1526753730,2,-1,'Error: org.apache.spark.sql.catalyst.parser.ParseException: ');
