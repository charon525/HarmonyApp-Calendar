import {  date } from './dateModel'
import { Lunar } from './Lunar'
import router from '@ohos.router'
import prompt from '@ohos.promptAction';
import ScheduleData from './ScheduleData'
import { dialog } from './dialog'
import Logger from '../common/utils/Logger'
import scheduleTable from '../common/database/tables/ScheduleTable'
import Prompt from '@system.prompt'
import reminderAgentManager from'@ohos.reminderAgentManager';
import wantAgent from '@ohos.wantAgent';


@Entry
@Component
struct Index {
  @State tmpMonth: number = 0;
  @State tmpYear:number = 0;
  private textinputContreller1 =  new TextInputController()
  private textinputContreller2 =  new TextInputController()
  @State year: number = (new Date()).getFullYear();
  @State month: number = (new Date()).getMonth() + 1;
  @State select_showMenu: boolean = false;
  private tabController: TabsController = new TabsController()
  private months: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  private weeks: string[] = ["日", "一", "二", "三", "四", "五", "六"]
  @State offsetx: number = 0;
  @State days: date[] = []
  private lunar:Lunar =  new Lunar();
  @State selectedindex: number = Math.min(30, Math.floor(Math.random()*5+7));
  @State selectedDate: Date = new Date();
  @State isInsert:boolean = false;
  @State deleteList: ScheduleData[] = [];
  @State schedules: ScheduleData[] = [];
  @State schedulesOfday: ScheduleData[] = [];
  @State index: number = 0;

  public  colorArray = ['#06FA4E', '#FA060A', '#FE7600', '#009EFE', '#fffb00', '#b0bdf8']
  public  scheduletable = new scheduleTable(()=>{
  });
  @State newSchedule: ScheduleData = {
    id:0,
    title: "",
    date: "",
    year: 0,
    month: 0,
    note:"",
  }
  searchController: SearchController = new SearchController();
  dialogController: CustomDialogController = new CustomDialogController({
    builder: dialog({
      isInsert: $isInsert,
      newSchedule: $newSchedule,
      selectedDate: $selectedDate,
      confirm: (isInsert: boolean, newSchedule: ScheduleData) => this.accept(isInsert, newSchedule)
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  });
  async routePage(searchValue: string, schedules: ScheduleData[]) {
    let options = {
      url: 'pages/SearchPage',
      params: {
        searchValue: searchValue,
        colorArray : this.colorArray,
        schedules: schedules,
      }
    }
    try {
      await router.pushUrl(options)
    } catch (err) {
      console.info(` fail callback, code: ${err.code}, msg: ${err.msg}`)
    }
  }
  accept(isInsert: boolean, newSchedule: ScheduleData):void{
    if(isInsert){
      Logger.info('[Debug.Index]', `The account inserted is:  ${JSON.stringify(newSchedule)}`);
      this.scheduletable.insertData(newSchedule, (id:number)=>{
        newSchedule.id = id;
        this.schedules.push(newSchedule);
        let datetime: reminderAgentManager.LocalDateTime = {
          year: newSchedule.year,
          month: newSchedule.month,
          day: (new Date(newSchedule.date)).getDate(),
          hour: 9,
          minute: 0,
        }
       let remindercalendar: reminderAgentManager.ReminderRequestCalendar = {
            dateTime : datetime,
            reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
            actionButton:[
           {
             title: '延迟通知',
             type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_SNOOZE
           }],
         wantAgent: {
           pkgName: "com.example.calendar",
           abilityName:"EntryAbility"
         },
         timeInterval: 3600,
         title: '日程提醒',
         content: newSchedule.title + '(点击查看详情)' ,
        }
        try{
          reminderAgentManager.publishReminder(remindercalendar, (err, reminderId) =>{
          })
          //console.log("添加提醒成功，日程：", newSchedule.title  + (newSchedule.note === ''? '' :(',详情：' + newSchedule.note)))
        }catch (error){
          //console.log("提醒添加失败, 错误信息为：", error.code + error.message)
        }
        this.isInsert = false;
      })
    }else {
      this.scheduletable.updateData(newSchedule, ()=>{
        let list = this.schedules;
        this.schedules = [];
        list[this.index] = newSchedule;
        this.schedules = list;
        this.index = -1;
      })
    }
  }

  ComputeDays(date1:Date, date2:Date): number{
    let diff = date1.getTime() - date2.getTime();
    return Math.floor(diff / (1000 * 60 * 60 * 24)) +1;
  }

  selectListItem(item: ScheduleData) {
    this.isInsert = false; // 编辑模式
    this.index = this.schedules.indexOf(item);
    this.newSchedule = {
      id: item.id,
      title: item.title,
      date: item.date,
      year: item.year,
      month: item.month,
      note: item.note
    };
  }

  //删除功能
  deleteListItem() {
    for (let i = 0; i < this.deleteList.length; i++) { //// 删除每一项选中的账目并更新页面上的账目清单
      let tmp = this.deleteList[i];
      let index = this.schedules.indexOf(this.deleteList[i]);
      this.schedules.splice(index, 1);
      this.scheduletable.deleteData(this.deleteList[i], () => {
      });
    }
    this.deleteList = [];
  }
  DateTostr(currentDate: Date){
    let tmp = currentDate
    console.log("转换的日期为：", currentDate.toDateString())
    const dateString: string = `${currentDate.getFullYear()}-${(currentDate.getMonth() + 1).toString().padStart(2, '0')}
    -${currentDate.getDate().toString().padStart(2, '0')}`;
    return dateString;
  }
  getyear(date: Date){
    return date.getFullYear();
  }
  getmonth(date: Date){
    return date.getMonth() + 1;
  }
  aboutToAppear() {
    //console.log("index:", this.selectedindex)
    this.getDaysOfMonth(this.year, this.month);
    this.scheduletable.getRdbStore(() =>{
      this.scheduletable.query('year', this.year, (result)=>{
        this.schedules = result;
        //console.log("数据数目：" + this.schedules.length)
      })
    })
  }
  getSchedules(){
    let schedulesOfday = []
    let dateSring = this.DateTostr(this.days[this.selectedindex].date);
    for(let i=0 ;i<this.schedules.length;i++){
      if(this.schedules[i].date === dateSring){
        schedulesOfday.push(this.schedules[i])
      }
    }
    return schedulesOfday
  }

  getDaysOfMonth(year: number, month: number){
    this.days = []
    let d0 = new Date(year, month-1, 1);
    let dt = new Date(year, month, 0).getDate()
    let index = d0.getDay()
    for(let i=0;i<index;i++){
      this.days.push(new date(false, null))
    }
    for(let i=1;i<=dt;i++){
      let currentd = new Date(year, month-1, i)
      let flag = false;
      if(currentd.toDateString() === (new Date()).toDateString()) {
        flag = true;
      }
      console.log("today: " + (new Date()).toDateString() )
      let tmp = new date(flag, currentd)
      if(this.selectedindex - index === i - 1){
        this.selectedDate = currentd;
        tmp.isSelected = true;
      }
      this.days.push(tmp)
    }
  }


  build() {
    Row() {
      Column() {
        Row() {
          Text(`${this.year}年${this.month}月`)
            .fontSize(26)
            .fontWeight(FontWeight.Bolder)
            .margin({ left: '1%' })
            .height('100%')
          Image(this.select_showMenu ?
          $rawfile('up_arrow.png') : $rawfile('down_arrow.png')).width('4%').height('26%')
            .onClick(() => {
              this.select_showMenu = true;
              DatePickerDialog.show({
                start: new Date('1901-1-1'),
                end: new Date('2099-12-31'),
                selected: new Date(),
                onAccept:(value: DatePickerResult) =>{
                  this.year = value.year;
                  this.month = value.month+1;
                  this.aboutToAppear()
                  this.select_showMenu = false;
                },
                onCancel:() =>{
                  console.info("用户取消")
                  this.select_showMenu = false;
                },
                onChange:(value: DatePickerResult) =>{
                  console.info("change:" + JSON.stringify(value))
                }
              })
            })
          Blank()
          Image($r('app.media.search')).width('8%').height('46%').margin({right:10})
            .bindMenu(this.searchMenu())
          Image($rawfile('add.png')).width('6%').height('45%').margin({right:10})
            .bindMenu([
              {
                value:'新建日程',
                action:()=>{
                  this.newSchedule = {
                    id:0,
                    title: "",
                    date: "",
                    year: this.year,
                    month: this.month,
                    note:"",
                  }
                  this.isInsert = true
                  this.dialogController.open()
                }
              }
            ])
        }//导航栏
        .width('100%')
        .height('7%')
        .alignSelf(ItemAlign.Start)
        .padding({ left: '2%', right: '2%' })
        .alignItems(VerticalAlign.Center)

        Row() {
          ForEach(this.weeks, (item: string) => {
            Column() {
              Text(item).fontWeight((item === "日" || item === "六")?
              FontWeight.Normal:FontWeight.Bold).fontColor((item === "日" || item === "六")?
              Color.Gray: Color.Black)
            }.layoutWeight(1)
          })
        }.width('100%').height('4%').justifyContent(FlexAlign.Center).margin({ top: 5 })
        .padding({top:5,left:5,right:5})
        .backgroundColor(Color.White).borderRadius({topLeft:5, topRight:5})

        Row() {
          Tabs({ barPosition: BarPosition.Start, index: this.month - 1, controller: this.tabController }) {
            ForEach(this.months, (item: number) => {
              TabContent() {
                Row() {
                  GridRow({ columns: 7, gutter: { y: 20 } }) {
                    ForEach(this.days, (item: date) => {
                      GridCol() {
                        Column() {
                          Text(item.date === null ? "":item.date.getDate().toString()).fontWeight((item.weekDay===0 || item.weekDay===6)? FontWeight.Normal:FontWeight.Bold).fontSize(20)
                            .fontColor(item.isToday? (item.isSelected? Color.White:'#DC143C'):(item.isSelected? Color.White:((item.weekDay===0 || item.weekDay===6)?Color.Blue: Color.Black)))
                          Text(item.lunarday).fontSize(13).fontColor(item.isToday? (item.isSelected? Color.White:'#DC143C'):(item.isSelected? Color.White:((item.weekDay===0 || item.weekDay===6)?Color.Blue: Color.Black)))
                          if(item.isToday){
                            Row().width("35%").height(2).backgroundColor(item.isSelected? Color.White:'#DC143C').margin({ top: 1 })
                          }
                        }.justifyContent(FlexAlign.Start).backgroundColor(item.isToday? (item.isSelected? '#DC143C':""):(item.isSelected? '#0351bf': '')).borderRadius(50).width(45).height(44)
                        .onClick(() =>{
                          for(let i=0;i<this.days.length;i++){
                            if(this.days[i].date !== null && this.days[i].date.getTime() === item.date.getTime()){
                              this.selectedindex = i;
                              this.selectedDate = item.date;
                              break;
                            }
                          }
                          //console.log("选择的index：", this.selectedindex)
                          this.getDaysOfMonth(this.year, this.month)
                        })
                      }
                    })
                  }.width('100%').height('100%')
                }.width('100%').height('100%')
              }.width('100%').height('100%')
              .gesture(
                PanGesture()
                  .onActionStart(() => {
                    console.log("拖动手势开始！！")
                  })
                  .onActionUpdate((event: GestureEvent) => {
                    this.offsetx = event.offsetX;
                    console.log("offset: " + event.offsetX)
                  })
                  .onActionEnd(() => {
                    if (this.offsetx > 150) {
                      //月份减小
                      if (this.month === 1) {
                        this.year = this.year - 1;
                      }
                      this.month = this.months[(this.month + 10)%12];
                      this.tabController.changeIndex(this.month - 1);
                      this.selectedindex = Math.floor(Math.random()*20) +7;
                      //this.getDaysOfMonth(this.year, this.month)
                      this.aboutToAppear()
                      this.offsetx = 0;
                    } else if (this.offsetx < -150) {
                      //月份增大
                      if (this.month === 12) {
                        this.year = this.year + 1;
                      }
                      this.month = this.months[(this.month)%12];
                      this.tabController.changeIndex(this.month - 1);
                      this.selectedindex = Math.floor(Math.random()*20) +7;
                      this.aboutToAppear()
                      this.offsetx = 0;
                    }
                  })
              )
            })
          }
          .barMode(BarMode.Fixed)
          .animationDuration(200)
          .height('100%')
          .barHeight(1)
          .width('100%')
          .onChange((index: number) => {
            this.month = index + 1;
          })
        }.width('100%').height('48%').padding({ left: '2%', right: '2%', top: '1%' }).backgroundColor(Color.White).borderRadius({bottomLeft:5, bottomRight:5})
        Column(){
          Row().width('50%').height(3).backgroundColor('#f2f6fb').margin({left:'0%'})
          Row(){
            Text(this.ComputeDays(this.selectedDate, new Date()) === 0? "今天" :
              (this.ComputeDays(this.selectedDate, new Date()) < 0?
                (this.ComputeDays(this.selectedDate, new Date()) === -1? "昨天":
                (-1*this.ComputeDays(this.selectedDate, new Date())).toString() + "天前") :
                (this.ComputeDays(this.selectedDate, new Date()) === 1? "明天":
                (this.ComputeDays(this.selectedDate, new Date())).toString() + "天后")) )
              .fontWeight(FontWeight.Bold)
            Text("   农历" + this.days[this.selectedindex].lunarmonth +
            (this.days[this.selectedindex].lunarday[this.days[this.selectedindex].lunarday.length-1]
             === '月'?'(初一)':this.days[this.selectedindex].lunarday) ).fontColor(Color.Gray)
            Blank()
            Image($rawfile('more.png')).width(25).height(25).margin({right:15})
              .onClick(()=>{
                router.pushUrl({
                  url: 'pages/morePage',
                  params:{
                    date: this.DateTostr(this.days[this.selectedindex].date),
                    lunar: this.days[this.selectedindex].lunarmonth + this.days[this.selectedindex].lunarday
                  }
                })
              })
          }.width('100%').height(40).margin({top:8})
          Row(){
              if(this.getSchedules().length === 0){
                Column(){
                  Image($rawfile('calendar.png')).width(90).height(90).interpolation(ImageInterpolation.High).margin({top:40})
                  Text("暂 无 日 程").fontColor(Color.Gray).margin({top:15})
                }.width('100%').height('100%')

              }else{
                Column(){
                    List({space:5}){
                      ForEach(this.getSchedules(), (item: ScheduleData)=>{
                        ListItem(){
                          Row(){
                              Column().width(10).height(35).backgroundColor(this.colorArray[Math.floor(Math.random()*6)]).borderRadius(20)
                              Text("      " + item.title).fontWeight(FontWeight.Bold).fontSize(20).
                              textOverflow({ overflow: TextOverflow.Ellipsis }).maxLines(1)
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
                        }.width('100%').height(40)
                        .swipeAction({end:this.deleteItem(item)})
                        .gesture(
                          LongPressGesture({duration:500})
                            .onAction(()=>{})
                            .onActionEnd(()=>{
                              this.selectListItem(item);
                              this.dialogController.open();
                            })
                        )
                      })
                    }.backgroundColor(Color.White)
                }.width('100%').height('100%').padding({left:5, right:5, top:10}).borderRadius(20)
              }
          }.width('100%').height('60%')
      }.width('100%').height('50%').padding({ left: '2%', right: '2%', top: '1%' }).backgroundColor(Color.White).justifyContent(FlexAlign.Start)

      }.width('100%').height('100%')
    }.height('100%').width('100%').backgroundColor('#f2f6fb')

  }
  @Builder deleteItem(item: ScheduleData){
    Row(){
      Button("编辑").size({width:'15%', height:'100%'}).backgroundColor('#ff9300').type(ButtonType.Normal)
        .onClick(()=>{
          this.isInsert = false;
          this.selectListItem(item);
          this.dialogController.open();
        })
      Button("删除").size({width:'15%', height:'100%'}).backgroundColor('#ff2700').type(ButtonType.Normal)
        .onClick(()=>{
          this.deleteList.push(item);
          this.deleteListItem();
        })
    }
  }
  @Builder GotoItem(){

    Menu(){
      MenuItem(){
       Column(){

        }
      }
    }
  }
  @Builder searchMenu(){
    Menu(){
      MenuItem(){
        Search({
          value: '',
          placeholder: '请输入关键字搜索',
          controller: this.searchController
        })
          .width('100%')
          .searchButton('搜索')
          .borderRadius(20).borderWidth(1.5)
          .borderColor("#33182431")
          .placeholderFont({ size: 16 })
          .textFont({ size: 16 })
          .backgroundColor(Color.White)
          .onChange((searchValue: string) => {
          })
          .onSubmit((searchValue: string) => {
            if (searchValue === '' ) {
              prompt.showToast({ message: '输入不能为空', bottom: 70 });
            } else {
                let tmp = []
                this.scheduletable.queryForsearch(searchValue, (result)=>{
                  tmp = result;
                  this.routePage(searchValue, tmp);
                })
            }
          })
      }
    }
  }
}