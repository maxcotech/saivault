import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';


Future<bool> confirmDialog({String message:'Are you sure?',String okLabel:'OK',String cancelLabel:'CANCEL'})async{
  return await Get.dialog<bool>(AlertDialog(
    title:Icon(LineIcons.info_circle,color:Colors.blue,size:45),
    content: Text(message),
    actions: <Widget>[
      FlatButton(child:Text(cancelLabel),onPressed:() => Get.back(result:false)),
      FlatButton(child:Text(okLabel),onPressed:() => Get.back(result:true))
    ]
  ));
}