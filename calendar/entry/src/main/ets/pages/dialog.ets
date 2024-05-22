import ScheduleData from "./ScheduleData"
import prompt from '@ohos.promptAction';

@CustomDialog
export struct dialog{
  controller? : CustomDialogController;
  @Link isInsert: boolean;
  @Link newSchedule: ScheduleData;
  @Link selectedDate: Date;
  @State text:string = "";
  @State title: string = "";
  private textinputContreller =  new TextInputController()
  private TextAreaController = new TextAreaController()
  confirm?: (IsInsert: boolean, newSchedule: ScheduleData) => void;

  DateTostr(currentDate: Date){
    const dateString: string = `${currentDate.getFullYear()}-${(currentDate.getMonth() + 1).toString().padStart(2, '0')}-${currentDate.getDate().toString().padStart(2, '0')}`;
    return dateString;
  }
  getyear(date: Date){
    return date.getFullYear();
  }
  getmonth(date: Date){
    return date.getMonth() + 1;
  }
  build(){
    Column(){
      Column(){
          Text(this.isInsert? "新增日程":"查看日程").fontSize(20).fontWeight(FontWeight.Bold)
          Divider().vertical(false).height(5).backgroundColor('#f2f6fb').width(80).margin({top:5})
      }.width('100%').height(20).margin({top:10}).justifyContent(FlexAlign.Center)

      Column(){
          Column(){
            TextInput({text:this.newSchedule.title=== ''? '': this.newSchedule.title, placeholder: '点击输入标题', controller: this.textinputContreller}).enterKeyType(EnterKeyType.Next)
              .placeholderColor(Color.Gray).placeholderFont({size:16, weight:FontWeight.Bold}).backgroundColor('#f2f6fb')
              .onChange((value)=>{
                this.title = value;
              })
            Divider().vertical(false).backgroundColor(Color.White).width('97%').height(3)
            Text("日期：" + this.DateTostr(this.selectedDate)).width('100%').height('50%').margin({left:28}).fontWeight(FontWeight.Bold)
          }.width('100%').height('100%').borderRadius(20).backgroundColor('#f2f6fb').alignItems(HorizontalAlign.Center).margin({top:15})
      }.width('100%').height('25%').padding({top:10, left:5, right:5}).margin({top:10})

     Column(){
            Text("    备注：").width('100%').backgroundColor('#f2f6fb').borderRadius({topLeft:20, topRight:20}).margin({top:30}).fontWeight(FontWeight.Bold)
            Divider().vertical(false).backgroundColor(Color.White).width('100%').height(2).alignSelf(ItemAlign.Center)
            TextArea({
              placeholder:"点击添加备注",
              text:this.newSchedule.note === ''? "":this.newSchedule.note,
              controller:this.TextAreaController
            }).width('100%').height('70%').borderRadius({bottomLeft:20, bottomRight:20})
              .placeholderColor(Color.Gray).placeholderFont({size:16, weight:FontWeight.Bold}).backgroundColor('#f2f6fb')
              .onChange((value)=>{
                this.text = value;
              })
      }.width('100%').height('50%').padding({top:10, left:5, right:5}).margin({top:20}).borderRadius(20)
      .alignItems(HorizontalAlign.Start)
      Column() {
        Button() {
          Text('确定')
            .fontSize(16)
            .fontColor(Color.White)
        }
        .width('100%')
        .height(40)
        .onClick(() => {
          if (this.title === '' && this.newSchedule.title === '' ) {
            prompt.showToast({ message: '标题不能为空', bottom: 70 });
          } else {
              this.newSchedule.title = this.title;
              this.newSchedule.note = this.text;
              this.newSchedule.year = this.getyear(this.selectedDate);
              this.newSchedule.month = this.getmonth(this.selectedDate);
              this.newSchedule.date = this.DateTostr(this.selectedDate);
              this.confirm && this.confirm(this.isInsert, this.newSchedule);
              this.controller?.close();
          }
        })
      }.margin({top:10})
      .layoutWeight(1)
      .padding({
        bottom: 10,
        left: 24,
        right: 24
      })
      .justifyContent(FlexAlign.End)
    }.width('100%').height('50%')
    .borderRadius({ topLeft: 24, topRight: 24 })
    .backgroundColor(Color.White)
    .align(Alignment.BottomEnd)
  }

}