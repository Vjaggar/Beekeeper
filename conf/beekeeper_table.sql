
mysql -uroot -proot



CREATE DATABASE beekeeper character set utf8;
USE beekeeper;
CREATE USER 'beekeeper'@'node1' IDENTIFIED BY 'beekeeper';
GRANT ALL ON beekeeper.* TO 'beekeeper'@'node1' IDENTIFIED BY 'beekeeper';
GRANT ALL ON beekeeper.* TO 'beekeeper'@'%' IDENTIFIED BY 'beekeeper';
FLUSH PRIVILEGES;
quit;



drop table beekeeper_log;
create table beekeeper_log(
task_id     bigint        COMMENT '任务ID'                             ,
exectime    int           COMMENT '需执行的日期'                       ,
table_name  VARCHAR(200)  COMMENT '表名'                               ,
hql_file    VARCHAR(2000) COMMENT 'HQL文件路径'                        ,
blockcnt    int           COMMENT '块编号'                             ,
blockmess   VARCHAR(2000) COMMENT '块备注'                             ,
loop_cnt    int           COMMENT '重跑次数编号'                       ,
hql         blob          COMMENT '执行的HQL语句'                      ,
start_time  double        COMMENT '开始时间(Linux时间戳)'              ,
over_time   double        COMMENT '结束时间(Linux时间戳)'              ,
use_time    double        COMMENT '花费时间(s)'                        ,
task_status int           COMMENT '任务状态(0:成功 -1:失败 1:正在进行)',
error_mess  blob          COMMENT 'HQL报错信息'
)
default charset = utf8
;



SELECT * FROM beekeeper_log ORDER BY start_time ;








