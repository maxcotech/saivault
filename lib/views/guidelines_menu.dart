import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saivault/views/password_guide_view.dart';
import 'package:get/get.dart';


class GuidelinesMenu extends StatelessWidget{
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:Text('Help and Guidelines')),
      body:SingleChildScrollView(
        child:Column(
          children:<Widget>[
            ListTile(
              title:Text('Password Manager Guide'),
              trailing:Icon(CupertinoIcons.forward),
              onTap:() => Get.to(PasswordGuideView())
            ),
             ListTile(
              title:Text('File Hider Guide'),
              trailing:Icon(CupertinoIcons.forward),
            )
          ]
        )
      )
    );
  }
}