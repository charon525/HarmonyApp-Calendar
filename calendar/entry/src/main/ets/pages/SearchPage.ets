import router from '@ohos.router'
import ScheduleData from './ScheduleData'
import { dialog } from './dialog'
import scheduleTable from '../common/database/tables/ScheduleTable'


@Entry
@Component
struct SearchPage {
  colorArray: string[] = router.getParams()['colorArray'];
  searchValue:string = router.getParams()['searchValue'];
  schedules =  router.getParams()['schedules'];




  build() {
    Row() {
      Column(){
        Row(){
            Image($rawfile('back.png')).width(25).height(25)
            Text("返回").fontWeight(FontWeight.Bold)
        }.width('100%').height(50).padding({left:10})
        .onClick(()=>{
          router.back()
        })
        Row(){
          if(this.schedules.length === 0){
            Row(){
              Text("无关键字\"").fontColor(Color.Gray)
              Text(this.searchValue).fontWeight(FontWeight.Bold)
              Text("\"的相关日程").fontColor(Color.Gray)
            }
          }else{
            Row(){
              Text("以下是关键字").fontColor(Color.Gray)
              Text(this.searchValue).fontWeight(FontWeight.Bold)
              Text("的相关日程：").fontColor(Color.Gray)
            }
          }
        }.margin({top:20})
        List({space:5}){
          ForEach(this.schedules, (item: ScheduleData)=>{
            ListItem(){
              Row(){
                Column().width(10).height(35).backgroundColor(this.colorArray[Math.floor(Math.random()*6)]).borderRadius(20)
                Column(){
                  Text("      " + item.title).fontWeight(FontWeight.Bold).fontSize(20).textOverflow({ overflow: TextOverflow.Ellipsis }).maxLines(1)
                  Text(item.date).fontSize(15).margin({left:32})
                }

                if(item.note !== ''){
                  Divider().vertical(true).height("80%").margin({left: 10})
                  Column(){
                    Text(){
                      Span('备注： ')
                      Span(item.note).fontWeight(FontWeight.Bold)
                    }.margin({left:10})
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(3)
                  }.width('35%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Start)
                }
              }.width('100%').height('100%').padding({left:10}).borderRadius(10)
            }.width('100%').height(60)
          })
        }.backgroundColor(Color.White).margin({top:20})
      }.width('100%').height('100%').padding({left:5, right:5, top:10}).borderRadius(20)
    }
    .height('100%')
  }

}