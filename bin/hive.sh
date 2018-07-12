#!/bin/bash
# -------------------------------------------------
# demiurge:jianggang
# time: F_ 20180321 \ L_ 20180712
# version:0.1.18
# encoded:UTF-8
# functions:
# P.S:
# -------------------------------------------------

. /etc/profile


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
    local a_l=$(echo ${hql_file}|awk '{print $1}')
    if [ ${#array_a[*]} -gt 1 ] || [ ${#array_b[*]} -gt 1 ] || [ ${#hql_file} -ne ${#a_l} ];then
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
        if [ ${#date} -eq 8 ];then
            date -d "${date} + 1 days" +"%Y%m%d" &> /dev/null
            if [ $? -ne 0 ] || [ ${mess1} -ne 0 ];then
                echo "< ERROR! > Please input right date(YYYYMMDD or YYYYMMDDHH)!"
                exit -1
            fi
        elif [ ${#date} -eq 10 ];then
            date -d "${date:8:2}" +"%H" &> /dev/null
            if [ $? -ne 0 ] || [ ${mess1} -ne 0 ];then
                echo "< ERROR! > Please input right date(YYYYMMDD or YYYYMMDDHH)!"
                exit -1
            fi
        else
            echo "< ERROR! > Please input right date(YYYYMMDD or YYYYMMDDHH)!"
            exit -1
        fi
    fi
}


#-- 执行HQL内核
executeHql() {
    local begin_time=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "\n[- ^binggo^ ${begin_time} -]\n"
    echo -e '@BeekeeperSTART'$(date +"%s")'Dot@'
    #--程序内核:BeeLine
    ${beeline} --color=false --silent=false --verbose=false -f ${R_hql}
    echo $? > ${job_flag}
    echo -e '@BeekeeperOVER'$(date +"%s")'Dot@'
    local end_time=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "\n------------------------------------------------------------------\n|  .begin : ${begin_time}  --  .end : ${end_time}  |\n------------------------------------------------------------------\n"
}


#-- 根据--<CUT>切割HQL文件以支撑重跑
cutFile() {
    # 通过日志文件找到报错的语句";"在第几行,通过hql文件找到这一行上最近的一个--CUT
    line_id_dot=$(cat ${job_log}|grep '^\.'|grep '\. \. \. \. \. \. \. \. \. \.'|grep '>'|awk -F'>' '{print $1}'|awk 'NR==1{print}')
    if [ ${#line_id_dot} -eq 0 ];then
        line_id_dot_ms="${beeline_head}"
    else
        line_id_dot_ms="${line_id_dot}"">"
    fi
    line_id=$(sed -n "1,$(cat ${job_log}|grep -e "${beeline_head}" -e "${line_id_dot_ms}" -c)p" ${R_hql}|grep '\--<CUT>' -no|awk -F':' '{print $1}'|tail -1)
    if [ ${#line_id} -eq 0 ];then
        line_id=1
    fi
    # 从报错的--<CUT>开始切割文件
    sed -n "${line_id},$(cat ${R_hql}|wc -l)p" ${R_hql} -i
}


#-- 判断异常报错是否需按预期直接中止程序
judgeErrorMess() {
    local errLog=($1)
    local executeState=$2
    local loopCnt=$3

    # 限定错误信息长度为16个字符串,减少循环匹配时长
    if [ ${#errLog[*]} -gt 16 ];then
        errLogIndexCnt=16
    else
        errLogIndexCnt=${#errLog[*]}
    fi

    if [ -f ${over_flag} ];then
        rm -f ${over_flag}
    fi

    if [ ${executeState} -eq 0 ];then
        touch ${over_flag}
    else
        if [ ${loopCnt} -gt ${needLoopCnt} ];then
            touch ${over_flag}
        else
            if [ -f ${errorMess} ];then
                errorMessAll=$(cat ${errorMess}|xargs|sed s/[[:space:]]//g)
                if [ ${#errorMessAll} -ne 0 ];then
                    for((ii=0;ii<${errLogIndexCnt};ii++))
                    do
                        for((jj=$((ii+1));jj<$((${errLogIndexCnt}+1));jj++))
                        do
                            mess=""
                            for((xo=${ii};xo<${jj};xo++))
                            do
                                mess=${mess}" "${errLog["${xo}"]}
                                while read -r errorMessLine
                                do
                                    MS1=$(echo ${errorMessLine}|sed 's/^[ \t]*//g'|sed 's/[ \t]*$//g')
                                    MS2=$(echo ${mess}|sed 's/^[ \t]*//g'|sed 's/[ \t]*$//g')
                                    if [ "${MS1}" = "${MS2}" ];then
                                        touch ${over_flag}
                                        break 4;
                                    fi
                                done < ${errorMess}
                            done
                        done
                    done
                fi
            fi
        fi
    fi

    if [ -f ${over_flag} ];then
        echo "0"
    else
        echo "1"
    fi
}


#-- 分析日志,生成能够写入数据库的SQL语句
writeLog() {
    # 开局等待5秒钟
    sleep 5s

    all_log_size=0

    if [ ${#date} -eq 0 ];then
        exectime=$(date +'%Y%m%d')
    else
        exectime=${date}
    fi

    while true
    do
        while true
        do
            # 若日志文件大小发生变化,则更新日志SQL
            tmp_size=$(du -b ${all_log}|awk '{print $1}')
            if [ ${tmp_size} -ne ${all_log_size} ];then
                all_log_size=${tmp_size}
                break;
            else
                # 若结束标志文件存在,则判定为程序结束
                if [ -f ${over_flag} ];then
                    break 2;
                fi
                # 若在未生成结束标志文件的情况下,程序主进程不存在,则判定为程序被杀死
                if [ $(ps -ef|grep ${pid}|grep ${hql_file}|wc -l) -eq 0 ];then
                    echo "The procedure was be killed."
                    exit -1;
                fi
                sleep 2s
            fi
        done

        local task_id=${timestamp}
        local file_name=$(echo ${all_log##*/}|xargs|awk -F'.' '{print $1}')
        local tmp_file=${job_path}/logs/poppy/${file_name}
        # 将日志文件做拍照到临时文件
        cp ${all_log} ${tmp_file}

        beeline_dot_head=$(cat ${tmp_file}|grep '^\.'|grep '\. \. \. \. \. \. \. \. \. \.'|grep '>'|awk -F'>' '{print $1}'|awk 'NR==1{print}')
        if [ ${#beeline_dot_head} -eq 0 ];then
            beeline_dot_head_ms="${beeline_head}"
        else
            beeline_dot_head_ms="${beeline_dot_head}"">"
        fi

        # 重跑运行开始标志
        starts=($(grep '@BeekeeperSTART[0-9]*Dot@' -no ${all_log}))
        # 重跑运行结束标志
        overs=($(grep '@BeekeeperOVER[0-9]*Dot@' -no ${all_log}))

        echo -e "USE beekeeper;\nDELETE FROM beekeeper_log WHERE task_id = ${task_id};" > ${log_record_sql}

        for((xx=0;xx<${#starts[*]};xx++))
        do
            # 重跑运行开始标志所在行数
            start_line=$(echo ${starts["${xx}"]}|awk -F':' '{print $1}')
            # 重跑运行开始标志记录的时间
            start_time=$(echo ${starts["${xx}"]}|awk -F':' '{print $2}'|sed 's/@BeekeeperSTART//g'|sed 's/Dot@//g')

            if [ ${#overs["${xx}"]} -eq 0 ];then
                over_line=$(cat ${tmp_file}|wc -l)
                over_time=''
            else
                # 重跑运行结束标志所在行数
                over_line=$(echo ${overs["${xx}"]}|awk -F':' '{print $1}')
                # 重跑运行结束标志记录的时间
                over_time=$(echo ${overs["${xx}"]}|awk -F':' '{print $2}'|sed 's/@BeekeeperOVER//g'|sed 's/Dot@//g')
            fi

            loop_file=${tmp_file}${xx}
            sed -n "${start_line},${over_line}p" ${tmp_file} > ${loop_file}
            # HQL运行时间所在行数
            usetimes=($(grep -e 'N\?o\?[0-9]* row[s]\? selected ([0-9]\+\.[0-9]\+ seconds)' -e 'N\?o\?[0-9]* row[s]\? affected ([0-9]\+\.[0-9]\+ seconds)' -no ${loop_file}|sed s/[[:space:]]//g))

             > ${log_record_sql}${xx}

            # 块备注所在行数
            blocks=$(grep '\-\-<\?C\?U\?T\?>\?\[.*\]€[0-9]*€' -no ${loop_file}|sed s/[[:space:]]//g)

            # 以 1 row selected (144.57 seconds) 此类标志为分割线
            for((o=0;o<${#usetimes[*]};o++))
            do
                u=$((o-1))
                usetime_time=$(echo "${usetimes["${o}"]}"|awk -F':' '{print $2}'|awk -F'(' '{print $2}'|sed s/'seconds)'//g)

                # 判断所属块的标志
                for block in ${blocks}
                do
                    block_line=$(echo "${block}"|awk -F':' '{print $1}')
                    block_mess=$(echo "${block}"|awk -F':' '{print $2}'|grep '\[.*\]' -o|sed 's/\[//g'|sed 's/\]//g')
                    block_cnt=$(echo "${block}"|awk -F':' '{print $2}'|grep '€[0-9]*€' -o|sed 's/€//g')

                    if [ $(echo "${usetimes["${o}"]}"|awk -F':' '{print $1}') -gt ${block_line} ];then
                        blockmess=${block_mess}
                        blockcnt=${block_cnt}
                    fi
                done

                if [ ${o} -eq 0 ];then
                    hql=$(sed -n "1,$(echo "${usetimes["${o}"]}"|awk -F':' '{print $1}')p" ${loop_file}|grep -e "${beeline_head}" -e "${beeline_dot_head_ms}"|sed s@"${beeline_head}"@@g|sed s@"${beeline_dot_head_ms}"@@g)
                else
                    hql=$(sed -n "$(echo "${usetimes["${u}"]}"|awk -F':' '{print $1}'),$(echo "${usetimes["${o}"]}"|awk -F':' '{print $1}')p" ${loop_file}|grep -e "${beeline_head}" -e "${beeline_dot_head_ms}"|sed s@"${beeline_head}"@@g|sed s@"${beeline_dot_head_ms}"@@g)
                fi
                echo "insert into beekeeper_log(task_id,exectime,table_name,hql_file,blockcnt,blockmess,loop_cnt,hql,start_time,over_time,use_time,task_status) values(${task_id},${exectime},'${table_name}','${hql_file}',${blockcnt},'${blockmess}',${xx},'${hql}',${start_time},$(echo ${start_time}+${usetime_time}|bc),${usetime_time},0);" >> ${log_record_sql}${xx}
                start_time=$(echo ${start_time}+${usetime_time}|bc)
            done

            if [ ${#usetimes[*]} -eq 0 ];then
                hql=$(cat ${loop_file}|grep -e "${beeline_head}" -e "${beeline_dot_head_ms}"|sed s@"${beeline_head}"@@g|sed s@"${beeline_dot_head_ms}"@@g)
            else
                lscn=$((${#usetimes[*]}-1))
                hql=$(sed -n "$(echo "${usetimes["${lscn}"]}"|awk -F':' '{print $1}'),$(cat ${loop_file}|wc -l)p" ${loop_file}|grep -e "${beeline_head}" -e "${beeline_dot_head_ms}"|sed s@"${beeline_head}"@@g|sed s@"${beeline_dot_head_ms}"@@g)
            fi

            if [ ${#hql} -ne 0 ];then
                # 判断所属块的标志
                for block in ${blocks}
                do
                    block_line=$(echo "${block}"|awk -F':' '{print $1}')
                    block_mess=$(echo "${block}"|awk -F':' '{print $2}'|grep '\[.*\]' -o|sed 's/\[//g'|sed 's/\]//g')
                    block_cnt=$(echo "${block}"|awk -F':' '{print $2}'|grep '€[0-9]*€' -o|sed 's/€//g')

                    if [ $(cat ${loop_file}|wc -l) -gt ${block_line} ];then
                        blockmess=${block_mess}
                        blockcnt=${block_cnt}
                    fi
                done

                error_mess=$(cat ${loop_file}|grep -i error|sed s/\;//g|sed s/\'//g|sed 's/\,/ /g')
                if [ ${#error_mess} -ne 0 ];then
                    echo "insert into beekeeper_log(task_id,exectime,table_name,hql_file,blockcnt,blockmess,loop_cnt,hql,start_time,over_time,use_time,task_status,error_mess) values(${task_id},${exectime},'${table_name}','${hql_file}',${blockcnt},'${blockmess}',${xx},'${hql}',${start_time},${over_time},$(echo ${over_time}-${start_time}|bc),-1,'${error_mess}');" >> ${log_record_sql}${xx}
                fi

                if [ ${#over_time} -eq 0 ];then
                    echo "insert into beekeeper_log(task_id,exectime,table_name,hql_file,blockcnt,blockmess,loop_cnt,hql,start_time,task_status) values(${task_id},${exectime},'${table_name}','${hql_file}',${blockcnt},'${blockmess}',${xx},'${hql}',${start_time},1);" >> ${log_record_sql}${xx}
                fi
            fi
            if [ -f ${log_record_sql}${xx} ];then
                cat ${log_record_sql}${xx} >> ${log_record_sql}
                rm -f ${log_record_sql}${xx}
            fi
            rm -f ${loop_file}
        done
        rm -f ${tmp_file}

        writeLogToDatabase

    done
}


# 执行已生成的日志SQL文件,将日志信息插入数据库中
writeLogToDatabase() {
    # :
    mysql -h 10.0.0.11 -ubeekeeper -pbeekeeper -Ne "source ${log_record_sql};"
}


#-- 给--[]块备注序号
descBlock() {
    descBlockFile=${R_hql}.desc
     > ${descBlockFile}
    local cnt=0
    while IFS= read -r line
    do
        if [ $(echo "${line}"|grep '\-\-<\?C\?U\?T\?>\?\[.*\]'|wc -l) -ne 0 ];then
            cnt=$((cnt+1))
            line=$(echo "${line}"|sed 's/[ \t]*$//g')€${cnt}€
        fi
        echo "${line}" >> ${descBlockFile}
    done < ${R_hql}
    rm -f ${R_hql}
    mv ${descBlockFile} ${R_hql}
}


#-- 判断HQL执行最终状态
judgeJobStatus() {
    if [ $(cat ${job_flag}) -ne 0 ];then
        exit -1
    else
        exit 0
    fi
}


#-- 启动吧!超级HIVE,火力全开!
superHive() {
    local i=1
    while true
    do
        executeHql 2>&1 | tee ${job_log} | tee -a ${all_log}
        flag=$(cat ${job_flag})
        errorlog=$(cat ${job_log}|grep -i error)
        if [ $(judgeErrorMess "${errorlog}" "${flag}" "${i}") -eq 0 ];then
            rm -f ${job_log}
            break;
        else
            sleep ${loop_sleep_time}s
            echo "Looping... ${i}"
            cutFile
        fi
        i=$((i+1))
    done
}


pid=$$
timestamp=$(date +"%s%N")

#--hive.sh脚本所在的绝对路径
shell_path=$(cd "$(dirname "$0")";pwd)
#--此工具的绝对路径
job_path=$(cd ${shell_path}/..;pwd)

# 加载参数配置文件
beekeeper_cfg="${job_path}/conf/beekeeper.cfg"
if [ ! -f "${beekeeper_cfg}" ];then
    echo "< ERROR! > No such file ${beekeeper_cfg}"
    exit -1;
fi
. ${beekeeper_cfg}

beekeeper_cfg_tmp_flag=0
# beeline的链接
if [ ! "${beeline_link}" ];then
    echo "< ERROR! > No such variable 'beeline_link' in ${beekeeper_cfg}"
    beekeeper_cfg_tmp_flag=1
fi

# beeline的头
if [ ! "${beeline_head}" ];then
    echo "< ERROR! > No such variable 'beeline_head' in ${beekeeper_cfg}"
    beekeeper_cfg_tmp_flag=1
fi

# Java的路径
if [ ! "${JAVA_HOME}" ];then
    echo "< ERROR! > No such variable 'JAVA_HOME' in ${beekeeper_cfg}"
    beekeeper_cfg_tmp_flag=1
fi

if [ ${beekeeper_cfg_tmp_flag} -ne 0 ];then
    exit -1
fi

# HQL执行异常时重跑次数
expr ${need_loop_cnt} + 1 &>/dev/null
need_loop_cnt_flag=$?
arry_need_loop_cnt=(${need_loop_cnt})
if [ ! "${need_loop_cnt}" ];then
    needLoopCnt=3
elif [[ ${#arry_need_loop_cnt[*]} -ne 1 || ${need_loop_cnt_flag} -ne 0 ]];then
    echo "< WARN!> ${beekeeper_cfg} The need_loop_cnt is error: ${need_loop_cnt}"
    needLoopCnt=3
else
    needLoopCnt=${need_loop_cnt}
fi

# HQL执行异常时重跑间隔时间(单位:s)
expr ${loop_sleep_time} + 1 &>/dev/null
loop_sleep_time_flag=$?
arry_loop_sleep_time=(${loop_sleep_time})
if [ ! "${loop_sleep_time}" ];then
    loop_sleep_time=300
elif [[ ${#arry_loop_sleep_time[*]} -ne 1 || ${loop_sleep_time_flag} -ne 0 ]];then
    echo "< WARN!> ${beekeeper_cfg} The loop_sleep_time is error: ${loop_sleep_time}"
    loop_sleep_time=300
else
    loop_sleep_time=${loop_sleep_time}
fi

#--替换参数的jar包
sedmodel_jar="${job_path}/lib/sedModel.jar"
if [ ! -f "${sedmodel_jar}" ];then
    echo "< ERROR! > No such file ${sedmodel_jar}"
    exit -1;
fi

#--beeline
beeline="${beeline_link}"

#--文件名
hql_file=$1
#--表名
table_name=$(echo ${hql_file##*/}|xargs|awk -F'.' '{print $1}')
#--执行日期
date=$2
#--多余参数判断
err_value=$3

# 需执行的hql文件
R_hql="${job_path}/logs/poppy/${table_name}_${date}_${timestamp}.q"
# 任务临时日志
job_log="${job_path}/logs/${table_name}_${date}_${timestamp}TMP.log"
# 完整日志
all_log="${job_path}/logs/${table_name}_${date}_${timestamp}.log"
# 任务执行结果flag文件
job_flag="${job_path}/logs/poppy/${table_name}_${date}_${timestamp}.flag"
# 任务执行结束标志文件
over_flag="${job_path}/logs/poppy/${table_name}_${date}_${timestamp}.over"
# 日志记录sql文件
log_record_sql="${job_path}/logs/poppy/${table_name}_${date}_${timestamp}.sql"
# 报错直接重跑的关键字符串
errorMess="${job_path}/conf/errorMess"

#--创建日志存放路径和执行文件路径
if [ ! -d ${job_path}/logs/poppy/ ];then
    mkdir -p ${job_path}/logs/poppy/
fi

#--删除5天以前的日志文件
find ${job_path}/logs/ -mtime +5 -type f |xargs rm -f &> /dev/null

#--检查是否文件名、执行日期两个参数都传正确了
checkValue "${hql_file}" "${date}" "${err_value}"

#--替换hql参数并校验
${JAVA_HOME}/bin/java -jar "${sedmodel_jar}" "${hql_file}" "${R_hql}" "${date}"
if [ $? -ne 0 ];then
    exit -1;
fi
echo -e "\n" >> "${R_hql}"

descBlock

writeLog &

superHive

wait

judgeJobStatus

