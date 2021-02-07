import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:get/get.dart';

class SettingsView extends StatelessWidget{
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:Text('Settings')),
      body:_body()
    );
  }
  Widget _body(){
    return ListView(
      children:<Widget>[
        ListTile(
          leading:Icon(LineIcons.lock),
          title:Text('Change Password'),
          onTap: () => Get.toNamed('/change_password'),
          trailing:Icon(CupertinoIcons.forward)
          ),
        ListTile(
          leading:Icon(Icons.help),
          title:Text('Help and Guidelines'),
          trailing:Icon(CupertinoIcons.forward)
        ),
        ListTile(
          leading:Icon(Icons.apps_sharp),
          title:Text('About'),
          trailing:Icon(CupertinoIcons.forward)
        )
      ]
    );
  }
}