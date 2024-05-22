
@CustomDialog
export struct LoadingDialog{
  controller: CustomDialogController
  build(){
    Row(){
      LoadingProgress().width(40).height(40).color(0x317aff)
      Text("Loading...").fontSize(20).fontColor(Color.Gray)
    }.width(100).height(100)
  }
}