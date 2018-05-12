#!/bin/bash
# -------------------------------------------------
# demiurge:jianggang
# time: F_ 20180321 \ L_ 20180512
# version:0.1.6
# encoded:UTF-8
# functions:
# P.S:
# -------------------------------------------------


#--红色高亮输出
hightEcho() {
    echo -e "\033[37;31;1m  ${1}  \033[39;49;0m"
}


#--检查是否文件、执行日期两个参数都传正确了
checkValue() {
    local hql_file=$1
    local date=$2
    local err_value=$3
    local array_a=($hql_file)
    local array_b=($date)

    # 判断传入的参数是否为单个值,hql文件是否正常
    local a_l=`echo ${hql_file}|awk '{print $1}'`
    if [ `echo ${#array_a[*]}` -gt 1 ] || [ `echo ${#array_b[*]}` -gt 1 ] || [ ${#hql_file} -ne ${#a_l} ];then
        echo "< ERROR! > Please input right values!"
        exit -1
    fi
    # 判断是否传入了多余参数
    if [ ${#err_value} -ne 0 ];then
        echo "< ERROR! > Can't input greater than two values!"
        exit -1
    fi
    # 判断是否传入了需执行的hql文件
    if [ ${#hql_file} -eq 0 ];then
        echo "< ERROR! > Please input hql file!"
        exit -1
    fi
    #--检查是否存在hql文件
    if [ ! -f ${hql_file} ];then
        echo "< ERROR! > No such file ( ${hql_file} )!"
        exit -1
    fi
    # 判断传入的时间参数是否正常
    if [ ${#date} -ne 0 ];then
        expr ${date} "+" 1 &> /dev/null
        local mess1=$?
        date -d "${date} + 1 days" +"%Y%m%d" &> /dev/null
        if [ $? -ne 0 ] || [ ${mess1} -ne 0 ] || [ ${#date} -ne 8 ];then
            echo "< ERROR! > Please input right date(YYYYMMDD)!"
            exit -1
        fi
    fi
}


executeHql() {
    local begin_time=`date +"%Y-%m-%d %H:%M:%S"`
    echo -e "\n[- ^binggo^ ${begin_time} -]\n"
    echo -e '@START'`date +"%s"`'Dot@'
    #--程序内核:BeeLine
    ${beeline} --color=false --silent=false --verbose=false -f ${R_hql}
    echo $? > ${job_flag}
    echo -e '@OVER'`date +"%s"`'Dot@'"\n"
    local end_time=`date +"%Y-%m-%d %H:%M:%S"`
    echo -e "\n------------------------------------------------------------------\n|  .begin : ${begin_time}  --  .end : ${end_time}  |\n------------------------------------------------------------------\n"
}


cutFile() {
    # 通过日志文件找到报错的语句";"在第几行,通过hql文件找到这一行上最近的一个--CUT
    line_id=`sed -n "1,$(grep "${beeline_head}" -c ${job_log})p" ${R_hql}|grep '\--<CUT>' -no|awk -F':' '{print $1}'|tail -1`
    if [ ${#line_id} -eq 0 ];then
        line_id=1
    fi
    # 从报错的--CUT开始切割文件
    sed -n "${line_id},$(cat ${R_hql}|wc -l)p" ${R_hql} -i
}


judgeErrorMess() {
    # 错误识别学习，规则：相同错误，重复执行5次以上未解决，则视为重跑不可修复错误，存储错误信息供下次程序判断是否需要重跑，重跑能够修复的和不能够修复的错误信息都要存储
    # 需要获取哪些维度信息?
    # 在同一时间段，出现相同报错的任务较多，则能够反映一定的问题，时间段长度怎么设置更加合理，分析此报错信息得到衍生信息？
    # 按场景，按任务分类？
    # 如果是磁盘溢出的错误，是可以知道是重跑可以解决的问题，怎么设置等待时间？
    # 将所有用到此程序的训练库都收集起来，总部进行更加智能的训练？怎么让用到我的程序的人都把信息传过来？

    local errLog=$1
    local executeState=$2
    local loopCnt=$3

    if [ ${executeState} -eq 0 ];then
        echo "0"
    else
        if [ ${loopCnt} -gt 3 ];then
            echo "0"
        else
            echo "1"
        fi
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


writeLog() {
    sleep 5s

    all_log_size=0

    if [ ${#date} -eq 0 ];then
        exectime=`date +'%Y%m%d'`
    else
        exectime=${date}
    fi

    while true
    do
        while true
        do
            tmp_size=`du -b ${all_log}|awk '{print $1}'`
            if [ ${tmp_size} -ne ${all_log_size} ];then
                all_log_size=${tmp_size}
                break;
            else
                if [ -f ${over_flag} ];then
                    break 2;
                fi

                if [ `ps -ef|grep ${pid}|grep ${hql_file}|wc -l` -eq 0 ];then
                    echo "the procedure was be killed."
                    break 2;
                fi
                sleep 2s
            fi
        done

        local log_id=${timestamp}
        local file_name=`echo ${all_log##*/}|xargs|awk -F'.' '{print $1}'`
        local tmp_file=${job_path}/logs/poppy/${file_name}
        # 将日志文件做拍照到临时文件
        cp ${all_log} ${tmp_file}
        # 重跑运行开始标志
        starts=(`grep '@START[0-9]*Dot@' -no ${all_log}`)
        # 重跑运行结束标志
        overs=(`grep '@OVER[0-9]*Dot@' -no ${all_log}`)

        echo > ${log_record_sql}

        for((xx=0;xx<${#starts[*]};xx++))
        do
            # 重跑运行开始标志所在行数
            start_line=`echo ${starts["${xx}"]}|awk -F':' '{print $1}'`
            # 重跑运行开始标志记录的时间
            start_time=`echo ${starts["${xx}"]}|awk -F':' '{print $2}'|sed 's/@START//g'|sed 's/Dot@//g'`

            if [ ${#overs["${xx}"]} -eq 0 ];then
                over_line=`cat ${tmp_file}|wc -l`
                over_time=''
            else
                # 重跑运行结束标志所在行数
                over_line=`echo ${overs["${xx}"]}|awk -F':' '{print $1}'`
                # 重跑运行结束标志记录的时间
                over_time=`echo ${overs["${xx}"]}|awk -F':' '{print $2}'|sed 's/@OVER//g'|sed 's/Dot@//g'`
            fi

            loop_file=${tmp_file}${xx}
            sed -n "${start_line},${over_line}p" ${tmp_file} > ${loop_file}
            # HQL运行时间所在行数
            usetimes=(`grep 'N\?o\?[0-9]* row[s]\? selected ([0-9]\+\.[0-9]\+ seconds)' -no ${loop_file}|sed s/[[:space:]]//g`)

            echo > ${log_record_sql}${xx}

            # 以 1 row selected (144.57 seconds) 为分割线
            for((o=0;o<${#usetimes[*]};o++))
            do
                u=$((o-1))
                usetime_time=`echo "${usetimes["${o}"]}"|awk -F':' '{print $2}'|awk -F'(' '{print $2}'|sed s/'seconds)'//g`
                # 块备注所在行数
                blocks=`grep '\-\-<\?C\?U\?T\?>\?\[.*\]€[0-9]*€' -no ${loop_file}|sed s/[[:space:]]//g`

                # 判断所属块的标志
                for block in ${blocks}
                do
                    block_line=`echo "${block}"|awk -F':' '{print $1}'`
                    block_mess=`echo "${block}"|awk -F':' '{print $2}'|grep '\[.*\]' -o|sed 's/\[//g'|sed 's/\]//g'`
                    block_cnt=`echo "${block}"|awk -F':' '{print $2}'|grep '€[0-9]*€' -o|sed 's/€//g'`

                    if [ `echo "${usetimes["${o}"]}"|awk -F':' '{print $1}'` -gt ${block_line} ];then
                        blockmess=${block_mess}
                        blockcnt=${block_cnt}
                    fi
                done

                if [ ${o} -eq 0 ];then
                    hql=$(sed -n "1,`echo "${usetimes["${o}"]}"|awk -F':' '{print $1}'`p" ${loop_file}|grep "${beeline_head}"|sed s@"${beeline_head}"@@g)
                else
                    hql=$(sed -n "`echo "${usetimes["${u}"]}"|awk -F':' '{print $1}'`,`echo "${usetimes["${o}"]}"|awk -F':' '{print $1}'`p" ${loop_file}|grep "${beeline_head}"|sed s@"${beeline_head}"@@g)
                fi

                echo ${log_id},${exectime},${table_name},${hql_file},${blockcnt},${blockmess},${xx},"${hql}",${start_time},$(echo ${start_time}+${usetime_time}|bc),${usetime_time},0 >> ${log_record_sql}${xx}
                start_time=$(echo ${start_time}+${usetime_time}|bc)
            done

            if [ ${#usetimes[*]} -eq 0 ];then
                hql=$(cat ${loop_file}|grep "${beeline_head}"|sed s@"${beeline_head}"@@g)
            else
                lscn=$((${#usetimes[*]}-1))
                hql=$(sed -n "`echo "${usetimes["${lscn}"]}"|awk -F':' '{print $1}'`,`cat ${loop_file}|wc -l`p" ${loop_file}|grep "${beeline_head}"|sed s@"${beeline_head}"@@g)
            fi

            if [ ${#hql} -ne 0 ];then
                error_mess=`cat ${loop_file}|grep -i error`
                if [ ${#error_mess} -ne 0 ];then
                    echo ${log_id},${exectime},${table_name},"${hql_file}",${blockcnt},${blockmess},${xx},"${hql}",${start_time},${over_time},$(echo ${over_time}-${start_time}|bc),-1,${error_mess} >> ${log_record_sql}${xx}
                fi

                if [ ${#over_time} -eq 0 ];then
                    echo ${log_id},${exectime},${table_name},"${hql_file}",${blockcnt},${blockmess},${xx},"${hql}",${start_time},,,1, >> ${log_record_sql}${xx}
                fi
            fi
            if [ -f ${log_record_sql}${xx} ];then
                cat ${log_record_sql}${xx} >> ${log_record_sql}
            fi
        done
    done
}


descBlock() {
    descBlockFile=${R_hql}.desc
    rm -f ${descBlockFile} &> /dev/null
    local cnt=0
    cat ${R_hql}|while read line
    do
        if [ `echo ${line}|grep '\-\-<\?C\?U\?T\?>\?\[.*\]'|wc -l` -ne 0 ];then
            cnt=$((cnt+1))
            line=${line}€${cnt}€
        fi
        echo "${line}" >> ${descBlockFile}
    done
    rm -f ${R_hql}
    mv ${descBlockFile} ${R_hql}
    rm -f ${descBlockFile}
}


judgeJobStatus() {
    if [ `cat ${job_flag}` -ne 0 ];then
        exit -1
    else
        exit 0
    fi
}


superHive() {
    local i=1
    while true
    do
        executeHql 2>&1 | tee ${job_log} | tee -a ${all_log}
        flag=`cat ${job_flag}`
        if [ `judgeErrorMess "${errorlog}" "${flag}" "${i}"` -eq 0 ];then
            touch ${over_flag}
            break;
        else
            sleep 12s
            echo "looping...${i}"
            cutFile
        fi
        i=$((i+1))
    done
}

pid=$$
timestamp=$(date +"%s%N")
#--beeline
beeline='/home/edc_jk/sparkForThrift/bin/beeline -u "jdbc:hive2://hnedaint03:10001/default;principal=edc_jk/admin@NBDP.COM" --hiveconf hive.exec.dynamic.partition.mode=nonstrict --hiveconf hive.mapred.mode=strict'
#--beeline的前缀
beeline_head='0: jdbc:hive2://hnedaint03:10001/default>'

#--hive.sh脚本所在的绝对路径
shell_path=$(cd "$(dirname "$0")";pwd)
#--此工具的绝对路径
job_path=$(cd ${shell_path}/..;pwd)
#--替换参数的jar包
sedmodel_jar=${job_path}/lib/sedModel.jar

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
# 任务的日志
job_log="${job_path}/logs/${table_name}_${date}_${timestamp}.log"
# 完整日志
all_log="${job_path}/logs/${table_name}_${date}_${timestamp}_all.log"
# 任务执行结果flag文件
job_flag="${job_path}/logs/poppy/${table_name}_${date}_${timestamp}.flag"
# 任务执行结束标志文件
over_flag="${job_path}/logs/poppy/${table_name}_${date}_${timestamp}.over"
# 日志记录sql文件
log_record_sql="${job_path}/logs/poppy/${table_name}_${date}_${timestamp}.sql"

#--创建日志存放路径和执行文件路径
if [ ! -d ${job_path}/logs/poppy/ ];then
    mkdir -p ${job_path}/logs/poppy/
fi

#--删除5天以前的历史日志,5天前的执行hql文件
find ${job_path}/logs/ -mtime +5 -type f |xargs rm -f &> /dev/null

#--检查是否文件名、执行日期两个参数都传正确了
checkValue "${hql_file}" "${date}" "${err_value}"

#--替换hql参数并校验
java -jar "${sedmodel_jar}" "${hql_file}" "${R_hql}" "${date}"
if [ $? -ne 0 ];then
    exit -1;
fi

descBlock

writeLog &

superHive

wait

judgeJobStatus

