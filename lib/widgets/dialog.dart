import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

enum Status{error,info,warning,success}

void getDialog({String message,Status status = Status.success}){

  Color getIconColor(){
    switch(status){
      case Status.error: return Colors.red;
      case Status.info: return Colors.blue;
      case Status.warning: return Colors.yellow;
      case Status.success: return Colors.green;
      default: return Colors.green;
    }
  }
  IconData getIconData(){
    switch(status){
      case Status.error: return Icons.error;
      case Status.info: return LineIcons.info;
      case Status.warning: return LineIcons.warning;
      case Status.success: return LineIcons.check_circle;
      default: return LineIcons.check_circle;
    }
  }

  Get.dialog(Dialog(
    child:Container(
      padding:EdgeInsets.symmetric(horizontal:15,vertical:15),
      child:Column(
        mainAxisSize: MainAxisSize.min,
        children:<Widget>[
        Icon(getIconData(),color:getIconColor(),size:45),
        SizedBox(height:10),
        Text(message,style:TextStyle(fontSize:16)),
        SizedBox(height:20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children:<Widget>[
          FlatButton(child:Text('OK',style:TextStyle(fontSize:16,fontWeight:FontWeight.bold)),onPressed:()=>Get.back())
        ])
      ])
    )
  ));
}