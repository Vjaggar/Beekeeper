package priv.jianggg.sedModel;

import java.io.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/*
* ${day,-1,yyyyMMdd}
* ${month,-1,yyyyMM}
* ${year,-1,yyyy}
*
* */



public class Main {

    /*
    * 检查传入参数是否正常
    * */
    public static boolean aviDa(String para1,String para2,String para3) {

        File file = new File(para1);
        if (file.exists()) {
            if (file.isDirectory()) {
                System.err.println("输入文件不存在");
                System.exit(2);
            } else {
                System.out.println("file exists");
            }

        } else {
            System.err.println("输入文件不存在");
            System.exit(2);
        }

        System.out.println(para1 + " -- " + para2 + " -- " + para3) ;


        boolean convertSuccess=true;
   // 指定日期格式为四位年/两位月份/两位日期，注意yyyy/MM/dd区分大小写；
        SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
        try {
  // 设置lenient为false. 否则SimpleDateFormat会比较宽松地验证日期，比如2007/02/29会被接受，并转换成2007/03/01
            format.setLenient(false);
            format.parse(para3);
        } catch (ParseException e) {
            // e.printStackTrace();
// 如果throw java.text.ParseException或者NullPointerException，就说明格式不对
            convertSuccess=false;
            System.out.println("日期格式有问题");
            System.exit(2);
        }
        return convertSuccess;
    }

    public static void main(String[] args) {

        String sourceFile = args[0];
        String resultFile = args[1];
        String executeDate = args[2];

    if (args.length == 3){
        sourceFile = args[0];
        resultFile = args[1];
        executeDate = args[2];
    }
    else if (args.length == 2){
        sourceFile = args[0];
        resultFile = args[1];
        executeDate = "20180303";
        }
    else {
        System.err.println("参数不完整");
        System.exit(2);
    }

        aviDa(args[0],args[1],args[2]);

        System.out.println(Arrays.toString(args));


        BufferedReader br = null;
        String temp;
        String dateString = null;
        try {
            // 指定生成的文件为UTF-8格式
            BufferedWriter bw = new BufferedWriter(new BufferedWriter(new OutputStreamWriter(new FileOutputStream(new File(resultFile)), "UTF-8")));
            br = new BufferedReader(new InputStreamReader(new FileInputStream(sourceFile), "utf-8"));
            StringBuffer sb = new StringBuffer();
            temp = br.readLine();
            while (temp != null) {
                String match = null;
                // 匹配时间参数格式
                Pattern p = Pattern.compile("\\$\\{(minute|hour|day|month|year),[-+][0-9]+,\\S+\\}");
                Matcher m = p.matcher(temp);
                while (m.find()) {
//                    System.out.println(m.group());
                    match = m.group();
//                    System.out.println("match: " + match);
                    // 算出变量时间
                    String allVa = match.substring(2, match.length() - 1);
                    String[] arrayAllVa = allVa.split(",");
                    String dateType = arrayAllVa[0];
                    String dateCal = arrayAllVa[1];
                    String dateFormat = arrayAllVa[2];
                    int calDate = Integer.valueOf(dateCal).intValue();
//                    System.out.println(dateType + " " + dateCal + " -- " + dateFormat + " -- " + calDate);
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
                    Date date = null;
                    try {
                        date = sdf.parse(executeDate);
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
                    date = calendar.getTime();
                    SimpleDateFormat formatter = new SimpleDateFormat(dateFormat);
                    dateString = formatter.format(date);
//                    System.out.println(dateString);
                }
//                System.out.println("temp: " + temp);
//                System.out.println("match2: " + match);
                if (match != null) {
                    temp = temp.replace(match, dateString);
                }
//                System.out.println("temp+++ " + temp);
                bw.write(temp + "\r");
                temp = br.readLine();
            }
            String allMess = sb.toString();
//            System.out.println(allMess);
            bw.close();
        } catch (IOException e) {
        } finally {
            try {
                br.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
