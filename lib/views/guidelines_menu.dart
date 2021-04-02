import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saivault/controllers/guide_menu_controller.dart';
import 'package:saivault/widgets/bad_widget.dart';


class GuidelinesMenu extends StatelessWidget{
  final controller = Get.put(GuideMenuController());
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:Text('Help and Guidelines')),
      body:GetBuilder(init:GuideMenuController(),builder:(control){
        controller.showIntAds();
        return _body();})
    );
  }

  Widget _body(){
    return Column(children:<Widget>[
      Expanded(child:_bodyView()),
      BadWidget(completer:controller.completer, bads: controller.bads)
    ]);
  }

  Widget _bodyView(){
    return SingleChildScrollView(
        child:Column(
          children:<Widget>[
            ListTile(
              title:Text('Password Manager Guide'),
              trailing:Icon(CupertinoIcons.forward),
              onTap:() => Get.toNamed('/password_guide_view')
            ),
             ListTile(
              title:Text('File Hider Guide'),
              onTap:() => Get.toNamed('/hider_guide_view'),
              trailing:Icon(CupertinoIcons.forward),
            )
          ]
        )
      );
  }
}