
mysql -uroot -proot
mysql> CREATE DATABASE beekeeper character set utf8;
mysql> USE beekeeper;
mysql> CREATE USER 'beekeeper'@'node1' IDENTIFIED BY 'beekeeper';
mysql> GRANT ALL ON beekeeper.* TO 'beekeeper'@'node1' IDENTIFIED BY 'beekeeper';
mysql> GRANT ALL ON beekeeper.* TO 'beekeeper'@'%' IDENTIFIED BY 'beekeeper';
mysql> FLUSH PRIVILEGES;
mysql> quit;



drop table beekeeper_log;
create table beekeeper_log(
task_id bigint COMMENT '任务ID',
exectime    int COMMENT '需执行的日期',
table_name  VARCHAR(200) COMMENT '表名',
hql_file VARCHAR(600) COMMENT 'HQL文件路径',
blockcnt int COMMENT '块编号',
blockmess VARCHAR(2000) COMMENT '块备注',
loop_cnt  int COMMENT '重跑次数编号',
hql    blob  COMMENT '执行的HQL语句',
start_time  double  COMMENT '开始时间',
over_time  double  COMMENT '结束时间',
use_time  double  COMMENT '花费时间(s)',
task_status  int  COMMENT '任务状态',
error_mess VARCHAR(12000) COMMENT '错误信息'
) 
default charset = utf8
;



insert into beekeeper_log(task_id,exectime,table_name,hql_file,blockcnt,blockmess,loop_cnt,hql,start_time,over_time,use_time,task_status,error_mess) values();


SELECT * FROM beekeeper_log ORDER BY start_time     








 