package priv.jianggg.sedmodel;

import java.io.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class Main {

    /*
     * 检查传入参数是否正常
     * */
    public static void checkArguments(String para1, String para2) {

        // 检查传入的文件是否存在
        File file = new File(para1);
        if (file.exists()) {
            if (file.isDirectory()) {
                System.out.println("输入文件不存在");
                System.exit(2);
            }
        } else {
            System.out.println("输入文件不存在");
            System.exit(2);
        }

        // 检查传入的日期格式是否正常
        SimpleDateFormat format;
        if (para2.length() == 8) {
            format = new SimpleDateFormat("yyyyMMdd");
        } else {
            format = new SimpleDateFormat("yyyyMMddHH");
        }
        try {
            // 设置lenient为false. 否则SimpleDateFormat会比较宽松地验证日期，比如2007/02/29会被接受，并转换成2007/03/01
            format.setLenient(false);
            format.parse(para2);
        } catch (ParseException e) {
            // 如果throw java.text.ParseException或者NullPointerException，就说明格式不对
            System.out.println("传入的日期格式有问题: " + para2);
            System.exit(2);
        }

    }

    /*
     * 替换时间变量
     * */
    public static void replaceDate(String sourceFile, String resultFile, String executeDate) {
        BufferedReader br = null;
        String temp;
        String dateString = null;
        String splitTemp;
        String match;
        int errParameterFlag = 0;
        int i = 1;
        try {
            // 指定生成的文件为UTF-8格式
            BufferedWriter bw = new BufferedWriter(new BufferedWriter(new OutputStreamWriter(new FileOutputStream(new File(resultFile)), "UTF-8")));
            br = new BufferedReader(new InputStreamReader(new FileInputStream(sourceFile), "utf-8"));
            temp = br.readLine();
            while (temp != null) {
                String[] strArray = temp.split("--");
                if (strArray.length == 0) {
                    splitTemp = "";
                } else {
                    splitTemp = strArray[0];
                }

                // 匹配时间参数格式
                Pattern p = Pattern.compile("\\$\\{(hour|day|month|year),[-+][0-9]+,[^\\$\\{]+\\}");
                Matcher m = p.matcher(splitTemp);
                while (m.find()) {
                    match = m.group();
                    // 统计有多少个逗号
                    int num = 0;
                    for (int x = 0; x < match.length(); x++) {
                        if (match.charAt(x) == ',') {
                            num++;
                        }
                    }
                    if (num > 4) {
                        // 当逗号个数大于4时告警
                        System.out.println("< WARN! > " + "Line " + i + " has an unrecognized parameter: " + match);
                        errParameterFlag = 1;
                    } else if (num == 2) {
                        String allVa = match.substring(2, match.length() - 1);
                        String[] arrayAllVa = allVa.split(",");
                        String dateType = arrayAllVa[0];
                        String dateCal = arrayAllVa[1];
                        String dateFormat = arrayAllVa[2];
                        int calDate = Integer.valueOf(dateCal).intValue();
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHH");
                        Date date = null;
                        try {
                            date = sdf.parse(executeDate);
                        } catch (ParseException e) {
                            e.printStackTrace();
                        }
                        Calendar calendar = new GregorianCalendar();
                        calendar.setTime(date);
                        if (dateType.equals("hour")) {
                            calendar.add(calendar.HOUR, calDate);
                        } else if (dateType.equals("day")) {
                            calendar.add(calendar.DATE, calDate);
                        } else if (dateType.equals("month")) {
                            calendar.add(calendar.MONTH, calDate);
                        } else if (dateType.equals("year")) {
                            calendar.add(calendar.YEAR, calDate);
                        } else {

                        }
                        date = calendar.getTime();
                        try {
                            SimpleDateFormat formatter = new SimpleDateFormat(dateFormat);
                            dateString = formatter.format(date);
                        } catch (Exception e) {
                            System.out.println("< WARN! > " + "Line " + i + " has an unrecognized parameter: " + match);
                            errParameterFlag = 1;
                        }
                    } else if (num == 3) {
                        dateString = match;

                        Pattern p3 = Pattern.compile("\\$\\{month,[-+][0-9]+,[-+]([1-9]|[1-2]\\d|30|31)th,\\S+\\}");
                        Matcher m3 = p3.matcher(match);
                        while (m3.find()) {
                            int th = 0;
                            String allVa = match.substring(2, match.length() - 1);
                            String[] arrayAllVa = allVa.split(",");
                            String dateCal = arrayAllVa[1];
                            String theDay = arrayAllVa[2].replace("th", "");
                            String dateFormat = arrayAllVa[3];
                            int calDate = Integer.valueOf(dateCal).intValue();
                            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
                            Date date = null;
                            try {
                                date = sdf.parse(executeDate.substring(0, 8));
                            } catch (ParseException e) {
                                e.printStackTrace();
                            }
                            Calendar calendar = new GregorianCalendar();
                            calendar.setTime(date);
                            calendar.add(calendar.MONTH, calDate);
                            date = calendar.getTime();
                            String theMonth = sdf.format(date);
                            Date date2 = new SimpleDateFormat("yyyyMMdd").parse(theMonth);
                            Calendar cal = Calendar.getInstance();
                            cal.setTime(date2);
                            int value = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
                            cal.set(Calendar.DAY_OF_MONTH, value);
                            List list = new ArrayList();
                            Calendar aCalendar = Calendar.getInstance(Locale.CHINA);
                            aCalendar.set(Calendar.YEAR, Integer.parseInt(theMonth.substring(0, 4)));
                            int year = aCalendar.get(Calendar.YEAR);//年份
                            aCalendar.set(Calendar.MONTH, Integer.parseInt(theMonth.substring(4, 6)));
                            int month = aCalendar.get(Calendar.MONTH);//月份
                            int day = Integer.parseInt(new SimpleDateFormat("dd").format(cal.getTime()));
                            String str = "00";
                            for (int j = 1; j <= day; j++) {
                                String aDate = String.valueOf(year) + str.substring(0, 2 - String.valueOf(month).length()) + String.valueOf(month) + str.substring(0, 2 - String.valueOf(j).length()) + String.valueOf(j);
                                list.add(aDate);
                            }
                            if (Integer.parseInt(theDay) > 0) {
                                th = Integer.parseInt(theDay) - 1;
                            } else {
                                th = day + Integer.parseInt(theDay);
                            }
                            String list1 = (String) list.get(th);
                            try {
                                dateString = new SimpleDateFormat(dateFormat).format(new SimpleDateFormat("yyyyMMdd").parse(list1));
//                                dateString = new SimpleDateFormat(dateFormat).format(new SimpleDateFormat(dateFormat).format(new SimpleDateFormat("yyyyMMdd").parse(list1)));
                            } catch (Exception e) {
                                System.out.println("( " + sourceFile + " ) " + "Line " + i + " has an unrecognized parameter: " + match);
                                errParameterFlag = 1;
                            }
                        }

                        Pattern p4 = Pattern.compile("\\$\\{(day|month|year),[-+][0-9]+,[-+][0-9]+(year|month|day),\\S+\\}");
                        Matcher m4 = p4.matcher(match);
                        while (m4.find()) {
                            String allVa = match.substring(2, match.length() - 1);
                            String[] arrayAllVa = allVa.split(",");
                            String dateType = arrayAllVa[0];
                            String dateCal = arrayAllVa[1];
                            String nextCal = arrayAllVa[2];
                            String dateFormat = arrayAllVa[3];
                            int numCal = 0;
                            int calDate = Integer.valueOf(dateCal).intValue();
                            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
                            Date date = null;
                            try {
                                date = sdf.parse(executeDate.substring(0, 8));
                            } catch (ParseException e) {
                                e.printStackTrace();
                            }
                            Calendar calendar = new GregorianCalendar();
                            calendar.setTime(date);
                            if (dateType.equals("day")) {
                                calendar.add(calendar.DATE, calDate);
                            } else if (dateType.equals("month")) {
                                calendar.add(calendar.MONTH, calDate);
                            } else if (dateType.equals("year")) {
                                calendar.add(calendar.YEAR, calDate);
                            } else {

                            }
                            if (nextCal.substring(nextCal.length() - 3, nextCal.length()).equals("day")) {
                                numCal = Integer.parseInt(nextCal.replace("day", ""));
                                calendar.add(calendar.DATE, numCal);
                            } else if (nextCal.substring(nextCal.length() - 5, nextCal.length()).equals("month")) {
                                numCal = Integer.parseInt(nextCal.replace("month", ""));
                                calendar.add(calendar.MONTH, numCal);
                            } else if (nextCal.substring(nextCal.length() - 4, nextCal.length()).equals("year")) {
                                numCal = Integer.parseInt(nextCal.replace("year", ""));
                                calendar.add(calendar.YEAR, numCal);
                            } else {

                            }
                            date = calendar.getTime();
                            try {
                                SimpleDateFormat formatter = new SimpleDateFormat(dateFormat);
                                dateString = formatter.format(date);
                            } catch (Exception e) {
                                System.out.println("< WARN! > " + "Line " + i + " has an unrecognized parameter: " + match);
                                errParameterFlag = 1;
                            }
                        }
                    } else if (num == 4) {
                        dateString = match;
                        Pattern p4 = Pattern.compile("\\$\\{(day|month|year),[-+][0-9]+,[-+][0-9]+month,[-+]([1-9]|[1-2]\\d|30|31)th,\\S+\\}");
                        Matcher m4 = p4.matcher(match);
                        while (m4.find()) {
                            int th = 0;
                            String allVa = match.substring(2, match.length() - 1);
                            String[] arrayAllVa = allVa.split(",");
                            String dateType = arrayAllVa[0];
                            String dateCal = arrayAllVa[1];
                            String nextCal = arrayAllVa[2];
                            String theDay = arrayAllVa[3].replace("th", "");
                            String dateFormat = arrayAllVa[4];
                            int numCal = 0;
                            int calDate = Integer.valueOf(dateCal).intValue();
                            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
                            Date date = null;
                            try {
                                date = sdf.parse(executeDate.substring(0, 8));
                            } catch (ParseException e) {
                                e.printStackTrace();
                            }
                            Calendar calendar = new GregorianCalendar();
                            calendar.setTime(date);
                            if (dateType.equals("day")) {
                                calendar.add(calendar.DATE, calDate);
                            } else if (dateType.equals("month")) {
                                calendar.add(calendar.MONTH, calDate);
                            } else if (dateType.equals("year")) {
                                calendar.add(calendar.YEAR, calDate);
                            } else {

                            }
                            numCal = Integer.parseInt(nextCal.replace("month", ""));
                            calendar.add(calendar.MONTH, numCal);
                            date = calendar.getTime();
                            String theMonth = sdf.format(date);
                            Date date2 = new SimpleDateFormat("yyyyMMdd").parse(theMonth);
                            Calendar cal = Calendar.getInstance();
                            cal.setTime(date2);
                            int value = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
                            cal.set(Calendar.DAY_OF_MONTH, value);
                            List list = new ArrayList();
                            Calendar aCalendar = Calendar.getInstance(Locale.CHINA);
                            aCalendar.set(Calendar.YEAR, Integer.parseInt(theMonth.substring(0, 4)));
                            int year = aCalendar.get(Calendar.YEAR);//年份
                            aCalendar.set(Calendar.MONTH, Integer.parseInt(theMonth.substring(4, 6)));
                            int month = aCalendar.get(Calendar.MONTH);//月份
                            int day = Integer.parseInt(new SimpleDateFormat("dd").format(cal.getTime()));
                            String str = "00";
                            for (int j = 1; j <= day; j++) {
                                String aDate = String.valueOf(year) + str.substring(0, 2 - String.valueOf(month).length()) + String.valueOf(month) + str.substring(0, 2 - String.valueOf(j).length()) + String.valueOf(j);
                                list.add(aDate);
                            }
                            if (Integer.parseInt(theDay) > 0) {
                                th = Integer.parseInt(theDay) - 1;
                            } else {
                                th = day + Integer.parseInt(theDay);
                            }
                            String list1 = (String) list.get(th);
                            try {
                                dateString = new SimpleDateFormat(dateFormat).format(new SimpleDateFormat("yyyyMMdd").parse(list1));
                            } catch (Exception e) {
                                System.out.println("< WARN! > " + "Line " + i + " has an unrecognized parameter: " + match);
                                errParameterFlag = 1;
                            }
                        }
                    }
                    temp = temp.replace(match, dateString);
                    splitTemp = splitTemp.replace(match, dateString);
//                    System.out.println("match: " + match + " dateString: " + dateString);
                }
                Pattern p2 = Pattern.compile("\\$\\{(\\S|\\s|)+\\}");
                Matcher m2 = p2.matcher(splitTemp);
                if (m2.find()) {
                    System.out.println("< WARN! > " + "Line " + i + " has an unrecognized parameter: " + m2.group());
                    errParameterFlag = 1;
                }
                bw.write(temp + "\n");
                temp = br.readLine();
                i++;
            }
//            bw.write("\n");
            bw.close();
        } catch (IOException e) {
//            e.printStackTrace();
        } catch (ParseException e) {
            e.printStackTrace();
        } finally {
            try {
                br.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        if (errParameterFlag == 1) {
            System.exit(2);
        }

    }

    public static void main(String[] args) {

        String sourceFile = "";
        String resultFile = "";
        String executeDate = "";
        Date day = new Date();
        SimpleDateFormat df = new SimpleDateFormat("yyyyMMddHH");

        if (args.length == 3) {
            if (args[2].trim().length() == 0) {
                sourceFile = args[0];
                resultFile = args[1];
                executeDate = df.format(day);
            } else {
                sourceFile = args[0];
                resultFile = args[1];
                if (executeDate.length()==8) {
                    executeDate = args[2] + df.format(day).substring(8);
                } else {
                    executeDate = args[2];
                }
            }
        } else if (args.length == 2) {
            sourceFile = args[0];
            resultFile = args[1];
            executeDate = df.format(day);
        } else {
            System.out.println("参数不完整");
            System.exit(2);
        }
//        System.out.println(executeDate.substring(0,8));
        checkArguments(sourceFile, executeDate);
        replaceDate(sourceFile, resultFile, executeDate);
    }
}
