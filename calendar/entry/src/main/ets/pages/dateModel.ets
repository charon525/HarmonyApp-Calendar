import { Lunar } from './Lunar'
import http from '@ohos.net.http'

export class date {
  isSelected: boolean = false;
  isToday: boolean = false;
  date: Date | null ;
  weekDay: number = 0; //星期几？
  // yearTips: string = ""; // 干支描述
  // chineseZodiac: string = ""; //生肖
  // lunaryear: string = "";
  lunarmonth:string = "";
  lunarday:string ="";
  result: any ;
  // solarTerms: ""; //节气描述
  // avoid: ""; // 不宜事项
  // lunarCalendar: string = ""; //农历日期
  // suit: ""; //宜事项
  // dayOfYear: number = 0; //一年的第几天
  // weekOfYear: number = 0; //一年的第几周
  // constellation: string = ""; //星座
  // indexWorkDayOfMonth: number = 0; //当月的第几个工作日
  lunar = new Lunar()
  constructor(isToday: boolean, date: Date | null) {
    this.isToday = isToday;
    this.date = date;
    if(this.date !== null){
      this.weekDay = this.date.getDay()
      this.result = this.lunar.solarToLunar(date)
      // this.chineseZodiac = result.shengxiao;
      // this.yearTips = result.Ganzhi;
      // this.lunaryear = result.lunaryear;
      this.lunarmonth = this.lunar.lunarFormat(this.result, "M");
      this.lunarday = this.lunar.lunarFormat(this.result, "D");
    }
  }
}


// async function getdata(year: number, month: number) {
//   let httpRequest = http.createHttp();
//   let tmp = year.toString() + (month < 10 ? "0" : "") + month.toString();
//   let url = 'https://www.mxnzp.com/api/holiday/list/month/' + tmp +
//   '?ignoreHoliday=false&app_id=xljlk9pdslpnjqi9&app_secret=JDSTVBDRBwBNO9LXa5622S3dSxL11z2Z';
//   return new Promise((resolve, reject) => {
//     httpRequest.request(url, (err, res) => {
//       if (!err) {
//         // @ts-ignore
//         resolve(JSON.parse(res.result).data);
//       } else {
//         reject(err);
//       }
//     });
//   });
// }