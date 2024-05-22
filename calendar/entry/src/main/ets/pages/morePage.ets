import router from '@ohos.router'
import http from '@ohos.net.http'
import { LoadingDialog } from './LoadingDialog'
import Prompt from '@system.prompt'
import prompt from '@ohos.prompt'

@Entry
@Component
struct MorePage {
  //date: string = router.getParams()['date']
  LoadingdialogController = new CustomDialogController({
    builder: LoadingDialog({}),
  })
  @State days: any = {};
  @State weekDay: number = 0;
  @State suit: string[] = [];
  @State avoid: string[] = [];
  @State typeDes: string = ""
  @State yearTips: string = ""; // 干支描述
  @State chineseZodiac: string = ""; //生肖
  @State solarTerms: string = ""; //节气描述
  @State lunarCalendar: string = ""; //农历日期
  @State dayOfYear: number = 0; //一年的第几天
  @State weekOfYear: number = 0; //一年的第几周
  @State constellation: string = ""; //星座
  @State indexWorkDayOfMonth: number = -1; //当月的第几个工作日
  // @ts-ignore
  @State words: string[] = []
  async onPageShow() {
    this.LoadingdialogController.open()
  }
  aboutToAppear() {
    let httpRequest = http.createHttp();
    let result = router.getParams()['date'].replace(/-/g, '');
    let url = 'https://www.mxnzp.com/api/holiday/single/' + result +
    '?ignoreHoliday=false&app_id=xljlk9pdslpnjqi9&app_secret=JDSTVBDRBwBNO9LXa5622S3dSxL11z2Z';
    httpRequest.request(url, {
      readTimeout: 3000,
    },(err, res) => {
      if (!err) {
        // @ts-ignore
        let tmp = JSON.parse(res.result).data;
        this.days = tmp;
        // @ts-ignore
        console.log("请求的数据为：" + JSON.stringify(JSON.parse(res.result).data))
        //console.log("请求的数据为：" + JSON.stringify(this.days))
        // @ts-ignore
        this.suit = tmp.suit.split('.')
        console.log("请求数据区成功， suit数组长度" + this.suit.length.toString())
        // @ts-ignore
        this.avoid = tmp.avoid.split('.')
        // @ts-ignore
        let tmp_str = "农历" + tmp.lunarCalendar
        this.words = []
        for (let i = 0;i < tmp_str.length; i++) {
          this.words.push(tmp_str[i])
        }
        this.weekDay = tmp.weekDay;
        this.typeDes = tmp.typeDes;
        this.yearTips = tmp.yearTips;
        this.chineseZodiac = tmp.chineseZodiac;
        this.solarTerms = tmp.solarTerms;
        this.dayOfYear = tmp.dayOfYear;
        this.weekOfYear = tmp.weekOfYear;
        this.constellation = tmp.constellation;
        this.LoadingdialogController.close()
        // @ts-ignore
        console.log("请求数据成功， 详细日期：" + tmp.date)
      } else {
        console.log("请求数据失败！")
        this.LoadingdialogController.close()
        prompt.showToast({ message: '加载失败，请检查网络后重试！', bottom: 70 });
        setTimeout(function (){
            router.back()
        }, 500);
      }
    });
  }

  build() {
    Row() {
      Column() {
        Row() {
          Image($rawfile('back.png')).width(25).height(25)
          Text("返回").fontWeight(FontWeight.Bold)
          Text("日期详情").fontWeight(FontWeight.Bold).margin(105).width(80)
        }
        .width('100%')
        .height(50)
        .padding({ left: 5 })
        .alignSelf(ItemAlign.Start)
        .onClick(() => {
          router.back()
        })

        Column() {
          Row() {
            Column() {
              GridRow({ columns: 1 }) {
                ForEach(this.words, (item: string) => {
                  GridCol() {
                    Row() {
                      Text(item).fontSize(25).fontWeight(FontWeight.Bold).height(`${100 / this.words.length}%`)
                    }
                  }
                })
              }.width('100%').height('100%')
            }
            .width("20%")
            .height('100%')
            .borderWidth(0.1)
            .borderColor(Color.Gray)
            .alignItems(HorizontalAlign.Start)

            Column() {
              Row() {
                Text("干支:     ").fontWeight(FontWeight.Bold)
                Text(this.yearTips + this.chineseZodiac + "年").fontColor(Color.Gray)
              }
              .layoutWeight(1)
              .borderWidth(0.1)
              .borderColor(Color.Gray)
              .justifyContent(FlexAlign.Start)
              .padding({ left: 10 })
              .width('100%')

              Row() {
                Text("类型:     ").fontWeight(FontWeight.Bold)
                Text(this.typeDes).fontColor(Color.Gray)
              }
              .layoutWeight(1)
              .borderWidth(0.1)
              .borderColor(Color.Gray)
              .justifyContent(FlexAlign.Start)
              .padding({ left: 10 })
              .width('100%')

              Row() {
                Text("节气:     ").fontWeight(FontWeight.Bold)
                Text(this.solarTerms).fontColor(Color.Gray)
              }
              .layoutWeight(1)
              .borderWidth(0.1)
              .borderColor(Color.Gray)
              .justifyContent(FlexAlign.Start)
              .padding({ left: 10 })
              .width('100%')

              Row() {
                Text("星座:     ").fontWeight(FontWeight.Bold)
                Text(this.constellation).fontColor(Color.Gray)
              }
              .layoutWeight(1)
              .borderWidth(0.1)
              .borderColor(Color.Gray)
              .justifyContent(FlexAlign.Start)
              .padding({ left: 10 })
              .width('100%')

              Row() {
                Text("描述:     ").fontWeight(FontWeight.Bold)
                Text(`今年第${this.dayOfYear}天， 第${this.weekOfYear}周`).fontColor(Color.Gray)
              }
              .layoutWeight(1)
              .borderWidth(0.1)
              .borderColor(Color.Gray)
              .justifyContent(FlexAlign.Start)
              .padding({ left: 10 })
              .width('100%')
            }.width("80%").height('100%').borderWidth(0.1).borderColor(Color.Gray)
          }.width('100%').height("60%").borderWidth(0.1).borderColor(Color.Gray)

          Column() {
            Row() {
              Row() {
                Row() {
                  Text(" 宜").fontSize(16).fontColor(Color.White).fontWeight(FontWeight.Bold)
                }.borderRadius(100).backgroundColor('#00ff00').width('50%').height('40%')
              }.width("20%").height('100%').justifyContent(FlexAlign.Center).padding(15)

              Row() {
                GridRow({ columns: 5 }) {
                  ForEach(this.suit, (item: string) => {
                    GridCol() {
                      Row() {
                        Text(item).fontSize(15).fontColor(Color.Gray)
                      }
                    }
                  })
                }.width('100%').height('100%')
              }.width("80%").height('100%')
            }.width('100%').height("50%")

            Row() {
              Row() {
                Row() {
                  Text(" 忌").fontSize(16).fontColor(Color.White).fontWeight(FontWeight.Bold)
                }.borderRadius(100).backgroundColor('#ff0000').width('50%').height('40%')
              }.width("20%").height('100%').justifyContent(FlexAlign.Center).padding(15)

              Row() {
                GridRow({ columns: 5 }) {
                  ForEach(this.avoid, (item: string) => {
                    GridCol() {
                      Row() {
                        Text(item).fontSize(15).fontColor(Color.Gray)
                      }
                    }
                  })
                }.width('100%').height('100%')
              }.width("80%").height('100%')
            }.width('100%').height("50%")
          }.width('100%').height("40%")
        }.width('100%').height('60%').borderWidth(0.5).margin({ top: 10 })
      }.width('100%').justifyContent(FlexAlign.Start).height('100%').padding({ left: 5, right: 5 })
    }.height('100%')
  }
}