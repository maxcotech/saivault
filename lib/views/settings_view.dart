import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:get/get.dart';
import 'package:saivault/controllers/settings_controller.dart';

class SettingsView extends StatelessWidget{
  final SettingsController controller = Get.find<SettingsController>();
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:Text('Settings')),
      body:GetBuilder(builder:(control)=>_body(),init:SettingsController())
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
          leading:Icon(Icons.storage),
          title:Text('Storage Location'),
          subtitle: Text(controller.getCurrentStoragePathString()),
          onTap:controller.onChooseNewStorageLocation,
          trailing:Icon(CupertinoIcons.forward)
        ),
        ListTile(
          leading:Icon(controller.appService.shouldShowPathOnBrowser()? 
          Icons.visibility_rounded: Icons.visibility_off_outlined),
          title:Text('Show Paths on Browser'),
          trailing:SizedBox(
            width:55,
            child:Switch(
            onChanged: (bool val) => controller.setShowPathOnBrowser(val),
            value: controller.appService.shouldShowPathOnBrowser(),))
        ),
        ListTile(
          leading:Icon(controller.appService.shouldShowPathOnManager()? 
          Icons.visibility_rounded: Icons.visibility_off_outlined),
          title:Text('Show Paths on Manager'),
          trailing:SizedBox(
            width:55,
            child:Switch(
            onChanged: (bool val) => controller.setShowPathOnManager(val),
            value: controller.appService.shouldShowPathOnManager(),))
        ),
        ListTile(
          leading:Icon(Icons.mode_rounded),
          title:Text('Dark Mode'),
          trailing:SizedBox(
            width:55,
            child:Switch(
            onChanged: (bool val) => controller.mainControl.setThemeMode(val),
            value: controller.appService.isDarkThemeMode(),))
        ),
         ListTile(
          onTap:controller.onBackupDatabase,
          leading:Icon(Icons.info),
          title:Text('Backup your data'),
          trailing:Icon(CupertinoIcons.forward)
        ),
        ListTile(
          leading:Icon(Icons.help),
          title:Text('Help and Guidelines'),
          onTap:controller.onDownloadFile,
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