
#-- 完成参数设计

# 1.距离今天多少天之前
${day,-1,yyyyMMdd}
${day,-1,yyyyMM}
${day,-1,yyyy}

# 2.距离今天多少月之前
${month,-1,yyyyMMdd}
${month,-1,yyyyMM}
${month,-1,yyyy}

# 3.距离今天多少年之前
${year,-1,yyyyMMdd}
${year,-1,yyyyMM}
${year,-1,yyyy}
${year,+0,yyyy}

# 4.距离本月多少月之前的月份的顺数第几天(上个月的第一天，第二天)
${month,-1,-1th,yyyyMMdd}



# 5.距离本月多少月之前的月份的倒数第几天(上个月的最后一天)













