
#-- 完成参数设计

# 1.距离今天多少天之前
# 昨天
20180502
201805
2018

# 2.距离今天多少月之前
# 上个月的今天
20180403
201804
2018

# 3.距离今天多少年之前
# 一年前的今天
20170503
201705
2017
2018

# 4.距离本月多少月之前的月份的顺数第几天(上个月的第一天，第二天)
# 上个月的最后一天
20180430

# 昨天的6个月前的月份的最后一天
20171130
    --       ${day,-1,-2day,-1th,yyyyMMdd}
# 5.距离本月多少月之前的月份的倒数第几天(上个月的最后一天)






FROM TST.LAB_EVT_PRD_COMPLETE_IN_D A
INNER JOIN TMP.TMP_LAB_EVT_PRD_COMPLETE_IN_D04 B
ON   A.PROD_INST_ID = B.PROD_INST_ID
WHERE A.P_DAY_ID IN ('20180501')
AND  A.PRD_COMPLETE_IN = 0
-- AND  A.LAN_ID = '${LAN_ID}'
-- AND A.MON_ID >= TO_NUMBER(TO_CHAR(ADD_MONTHS(TO_DATE(${day,-1,yyyyMMdd}, 'YYYYMMDD'),-6), 'YYYYMM'))
AND A.MON_ID >= '201710'


TO_NUMBER(TO_CHAR(ADD_MONTHS(TO_DATE(20180502, 'YYYYMMDD'),-6), 'YYYYMM')) 这种参数咋设计


2017110220240502


20180328


year month day hour minutes second













