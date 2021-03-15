import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyWidget extends StatelessWidget{
  final String asset;
  final String message;
  final String btnLabel;
  final void Function() onClickBtn;
  EmptyWidget({
    this.btnLabel:'GET STARTED',this.onClickBtn,
    this.asset:'assets/svg/not_found.svg',this.message:'Could not find anything'});

  @override 
  Widget build(BuildContext context){
    return Center(child:
    Column(
      mainAxisSize: MainAxisSize.min,
      children:<Widget>[
      SvgPicture.asset(
      this.asset,
      width:150,height:150
    ),
    SizedBox(height:30),
    Text(this.message,),//style:TextStyle(color:Colors.black))
    SizedBox(height:20),
    this.onClickBtn == null? Container():actionButton()
    ]));
  }

  Widget actionButton(){
    return SizedBox(
      height:40,width:Get.width / 2,
      child:RaisedButton(
        color:Get.theme.accentColor,
        child:Text(this.btnLabel,style:TextStyle(color:Colors.white)),onPressed:this.onClickBtn)
      );
  }
}