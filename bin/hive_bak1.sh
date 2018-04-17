#!/bin/bash

. /etc/profile

# -------------------------------------------------
# demiurge:jianggang
# time: F_ 20180116 \ L_ 20180308
# version:0.0.2
# encoded:UTF-8
# functions:
#       1.需按格式要求传入 文件名(必填) 执行日期(选填[YYYYMMDD]，不填则默认为当天日期)
#       3.相关变量参数说明参考ReadeMe文件
# P.S: 后续创建继续重跑信息库和立即终止信息库
# -------------------------------------------------

#--红色高亮输出
hightEcho()
{
echo -e "\033[37;31;1m  ${1}  \033[39;49;0m"
}

#--检查是否文件、执行日期两个参数都传正确了
checkValue()
{
local a=$1
local b=$2
local c=$3

local array_a=($a)
local array_b=($b)

# 判断传入的参数是否为单个值
if [ `echo ${#array_a[*]}` -gt 1 ] || [ `echo ${#array_b[*]}` -gt 1 ];then
    hightEcho "< ERROR! > Please input right values!"
    exit -1
fi
# 判断是否传入了多余参数
if [ ${#c} -ne 0 ];then
    hightEcho "< ERROR! > Can't input greater than two values!"
    exit -1
fi

# 判断是否传入了需执行的hql文件
if [ ${#a} -eq 0 ];then
    hightEcho "< ERROR! > Please input hql file!"
    exit -1
fi
#--检查是否存在hql文件
if [ ! -f ${hql_file} ];then
    hightEcho "< ERROR! > No such file ( ${hql_file} )!"
    exit -1
fi

# 判断需执行的hql文件是否正常
local a_l=`echo ${a}|awk '{print $1}'`
if [ ${#a} -ne ${#a_l} ];then
    hightEcho "< ERROR! > Please input right hql file!"
    exit -1
fi

# 判断传入的时间参数是否正常
expr ${b} "+" 1 &> /dev/null
if [ $? -ne 0 ] || [ ${#b} -ne 8 ];then
    hightEcho "< ERROR! > Please input right date(YYYYMMDD)!"
    exit -1
fi
date -d "${b} + 1 days" +"%Y%m%d" &> /dev/null
if [ $? -ne 0 ];then
    hightEcho "< ERROR! > Please input right date(YYYYMMDD)!"
    exit -1
fi

}

#--替换hql模版文件生成hql执行文件
sedModel()
{

timestamp=$(date +"%s%N")

# 需执行的hql文件
R_hql="${shell_path}/poppy/${table_name}_${date}_${timestamp}.q"

java -jar ${shell_path}/sedModel.jar "${hql_file}" "${R_hql}" "${date}"

}

#--超级执行
superExecute()
{

#--任务最大循环执行次数
local max_loop_cnt=3

for((i=0;i<=${max_loop_cnt};i++))
do
	local err_i=$((${i}+1))
	local xy=$((${max_loop_cnt}-1))
    if [ ${i} -eq ${max_loop_cnt} ];then
        exit -1
	else

        #--替换hql模版文件生成hql执行文件
        sedModel

        local begin_time=`date +"%Y-%m-%d %H:%M:%S"`
        echo -e "\n[- ^binggo(${err_i})^ ${begin_time} -]\n~.hql : ${hql_file}\n~.date: ${date}\n.R_hql: ${R_hql}\n"
        #--程序内核:BeeLine
        # ${beeline} --color=true --silent=false --verbose=true --hiveconf mapred.job.name="${table_name}${date}" -f ${R_hql}
        echo "${beeline} --color=true --silent=false --verbose=true --hiveconf mapred.job.name="${table_name}${date}" -f ${R_hql}"
        local sh_state=$?
        local end_time=`date +"%Y-%m-%d %H:%M:%S"`

        echo -e "\n------------------------------------------------------------------\n|  .begin : ${begin_time}  --  .end : ${end_time}  |\n------------------------------------------------------------------\n"
        if [ ${sh_state} -ne 0 ];then
            if [ ${i} -ne ${xy} ];then
                #--重跑等待间隔时间
                sleep 10s
            fi
        else
            break
        fi
    fi
done
}


#--beeline
beeline='/hadoop/hive-0.13.1-cdh5.3.3/bin/beeline -u "jdbc:hive2://hive01:10001" -n hadoop -p 1qaz#EDC --hiveconf mapred.job.queue.name=hadoop'

#--文件名
hql_file=$1
#--表名
table_name=`echo ${hql_file##*/}|xargs|awk -F'.' '{print $1}'`
#--执行日期
date=$2
#--多余参数判断
err_value=$3
#--hive.sh脚本所在的绝对路径
shell_path=$(cd "$(dirname "$0")";pwd)

#--检查是否文件名、执行日期两个参数都传正确了
checkValue "${hql_file}" "${date}" "${err_value}"

#--创建执行文件存放路径
if [ ! -d ${job_path}/poppy/ ];then
	mkdir -p ${job_path}/poppy/
fi

#--删除5天前的执行hql文件
find ${job_path}/poppy/ -mtime +5 -type f |xargs rm -f &> /dev/null

#--超级执行
superExecute


