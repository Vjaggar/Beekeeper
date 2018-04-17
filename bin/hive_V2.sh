


#--红色高亮输出
hightEcho() {
    echo -e "\033[37;31;1m  ${1}  \033[39;49;0m"
}

#--检查是否文件、执行日期两个参数都传正确了
checkValue() {
    local a=$1
    local b=$2
    local c=$3
    local array_a=($a)
    local array_b=($b)

    # 判断传入的参数是否为单个值,hql文件是否正常
    local a_l=`echo ${a}|awk '{print $1}'`
    if [ `echo ${#array_a[*]}` -gt 1 ] || [ `echo ${#array_b[*]}` -gt 1 ] || [ ${#a} -ne ${#a_l} ];then
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
    # 判断传入的时间参数是否正常
    expr ${b} "+" 1 &> /dev/null
    local mess1=$?
    date -d "${b} + 1 days" +"%Y%m%d" &> /dev/null
    if [ $? -ne 0 ] || [ ${mess1} -ne 0 ] || [ ${#b} -ne 8 ];then
        hightEcho "< ERROR! > Please input right date(YYYYMMDD)!"
        exit -1
    fi
}

#--替换hql参数并校验
sedModel() {
    java -jar ${sedmodel_jar} "${hql_file}" "${R_hql}" "${date}"
    echo -e " \n" >> ${R_hql}
    if [ $(grep '\${' ${R_hql}|wc -l) -ne 0 ];then
        local err_message=$(grep -n -e '\${' -e '}' ${R_hql} --color=always)
        echo -e "\033[37;31;1mError: Can't write the unknown HIVE's variates! ERROR LINE:\033[39;49;0m( ${err_message} )\033[37;31;1m. The file: ${R_hql}\033[39;49;0m"
        exit -1
    fi
}

executeHql() {
    local begin_time=`date +"%Y-%m-%d %H:%M:%S"`
    hightEcho "[- ^binggo(${err_i})^ ${begin_time} -]\n" | tee -a ${job_log}
    #--程序内核:BeeLine
    # ${beeline} --color=true --silent=false --verbose=true --hiveconf mapred.job.name="${table_name}" -f ${R_hql} >> ${job_log} 2>&1
    echo "${beeline} --color=true --silent=false --verbose=true --hiveconf mapred.job.name="${table_name}" -f ${R_hql}" | tee -a ${job_log}
    local sh_state=$?
    local end_time=`date +"%Y-%m-%d %H:%M:%S"`
    echo -e "\n------------------------------------------------------------------\n|  .begin : ${begin_time}  --  .end : ${end_time}  |\n------------------------------------------------------------------\n" | tee -a ${job_log}
    if [ ${sh_state} -ne 0 ];then
        StephenChow &> /dev/null
    fi
}

setVariate() {
    timestamp=$(date +"%s%N")
    #--beeline
    beeline='/hadoop/hive-0.13.1-cdh5.3.3/bin/beeline -u "jdbc:hive2://hive01:10001" -n hadoop -p 1qaz#EDC --hiveconf mapred.job.queue.name=hadoop'
    #--hive.sh脚本所在的绝对路径
    shell_path=$(cd "$(dirname "$0")";pwd)
    #--此工具的绝对路径
    job_path=$(cd ${shell_path}/..;pwd)
    #--替换参数的jar包
    sedmodel_jar=${job_path}/lib

    #--文件名
    hql_file=$1
    #--表名
    table_name=`echo ${hql_file##*/}|xargs|awk -F'.' '{print $1}'`
    #--执行日期
    date=$2
    #--多余参数判断
    err_value=$3


    # 需执行的hql文件
    R_hql="${job_path}/logs/poppy/${table_name}_${date}_${timestamp}.q"
    # 任务的日志文件
    job_log="${job_path}/logs/${table_name}_${date}_${timestamp}.log"
    # 错误日志文件
    err_log="${job_path}/logs/${table_name}_${date}_${timestamp}_err.log"


    #--创建日志存放路径和执行文件路径
    if [ ! -d ${job_path}/logs/poppy/ ];then
        mkdir -p ${job_path}/logs/poppy/
    fi

    #--删除5天以前的历史日志,5天前的执行hql文件
    find ${job_path}/logs/ -mtime +5 -type f |xargs rm -f &> /dev/null

}


cutFile() {
    # 通过日志文件找到报错的语句";"在第几行,通过hql文件找到这一行上最近的一个--CUT
    line_id=`sed -n "1,$(grep 'jdbc:hive2://' -c ${job_log})p" ${hql_file}|grep '\-- CUT' -no|awk -F':' '{print $1}'|tail -1`
    if [ ${#line_id} -eq 0 ];then
        line_id=1
    fi
    # 从报错的--CUT开始切割文件
    sed -n "${line_id},$(cat ${hql_file}|wc -l)p" ${hql_file} > /tmp/xx${i}.txt
}


judgeErrorMess() {
    # 错误识别学习，规则：相同错误，重复执行5次以上未解决，则视为重跑不可修复错误，存储错误信息供下次程序判断是否需要重跑，重跑能够修复的和不能够修复的错误信息都要存储
    # 需要获取哪些维度信息?
    # 在同一时间段，出现相同报错的任务较多，则能够反映一定的问题，时间段长度怎么设置更加合理，分析此报错信息得到衍生信息？
    # 按场景，按任务分类？
    # 如果是磁盘溢出的错误，是可以知道是重跑可以解决的问题，怎么设置等待时间？
    # 将所有用到此程序的训练库都收集起来，总部进行更加智能的训练？怎么让用到我的程序的人都把信息传过来？

    local executeCommand=$1
    `${executeCommand}`
    # 如果第一次执行不成功，则获取其错误信息
    if [ $? -ne 0 ];then
        error_mess=`cat ${error_log}|grep -i "ERROR"|head -1`
    fi
    # 将获取到的错误信息在库中进行对比
    # 若是可重跑修复的报错，则返回重跑次数，再次执行
    # 1、若再次执行后还是抱相同错误，则再次执行
    # 2、若再次执行后报的为新错误，则再次对比，返回新的重跑次数，以此循环，知道执行成功或确定为不可重跑修复的报错中止程序


    # 你告诉我: 错误信息 最终结果状态 执行的次数，我给你返回建议的重跑次数
    # 如果你告诉我的错误信息我没收录，那么我会收录进来。
    # 默认未收录的错误，返回的建议重跑次数为5，若你给我的执行次数为6，则我返回0
    #

    # 1.人为定义建议库  [编号(主键)、错误信息、最终结果状态、执行次数、收录时间、系统生成的建议信息(如:根据系统收录显示,此错误为可重跑修复,建议重跑次数为3、根据系统收录显示,此错误为可重跑不可修复,建议重跑次数为0)] (优先级最高)
    # 2.系统生成的建议库[编号(主键)、错误信息、最终结果状态、执行次数、生成时间、更新时间]
    # 3.收录的信息库    [编号(主键)、错误信息、最终结果状态、执行次数、收录时间]



}

exita(){

echo "exit 2"
# haha &> /dev/null

}


#-- 完成参数设计
# 1.距离今天多少天之前
# 2.距离本月多少月之前
# 3.距离今年多少年之前

# 4.距离本月多少月之前的月份的顺数第几天(上个月的第一天，第二天)
# 5.距离本月多少月之前的月份的倒数第几天(上个月的最后一天)


setVariate

#--检查是否文件名、执行日期两个参数都传正确了
checkValue "${hql_file}" "${date}" "${err_value}"













