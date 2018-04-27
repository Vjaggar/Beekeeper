package priv.jianggg.sedModel;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class TT {

    public static void getDayListOfMonth() throws ParseException {


        Date date = new SimpleDateFormat("yyyyMMdd").parse("20080214");

        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        int value = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
        cal.set(Calendar.DAY_OF_MONTH, value);
        System.out.println (new SimpleDateFormat("dd").format(cal.getTime()));

    }


        public static void main(String[] args) throws ParseException {


            getDayListOfMonth();

//        getDay(2018, 4);
        }

        private static void getDay(int year, int month) {
            SimpleDateFormat df=new SimpleDateFormat("yyyyMMdd");
            Calendar c = Calendar.getInstance();

            c.set(Calendar.YEAR, year);
            c.set(Calendar.MONTH, month-1);
            c.set(Calendar.DAY_OF_MONTH, 1);
            c.add(Calendar.DAY_OF_MONTH, -1);
            System.out.println("上月倒数第二天为："+df.format(c.getTime()));


            c.set(Calendar.YEAR, year);
            c.set(Calendar.MONTH, month);
            c.set(Calendar.DAY_OF_MONTH, 1);
            c.add(Calendar.DAY_OF_MONTH, -2);
            System.out.println("本月倒数第二天为："+df.format(c.getTime()));
            //测试结果为
            //上月倒数第二天为：20081230
            //本月倒数第二天为：20090130

        }

}
