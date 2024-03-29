import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:get/get.dart';
import 'package:saivault/controllers/settings_controller.dart';
import 'package:saivault/widgets/bad_widget.dart';
import 'package:saivault/widgets/linear_loader.dart';


class SettingsView extends StatelessWidget{
  final SettingsController controller = Get.find<SettingsController>();
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:Text('Settings')),
      body:GetBuilder(builder:(control)=>_body(context),init:SettingsController())
    );
  }

  Widget _body(BuildContext context){
    return Column(children:<Widget>[
      LinearLoader(isLoading:controller.isLoading),
      Expanded(child:_bodyView(context:context)),
      BadWidget(completer:controller.completer, bads: controller.bads)
    ]);
  }
  Widget _bodyView({BuildContext context}){
    List<Widget> items = this.getBodyList();
    return ListView.separated(
      padding:EdgeInsets.only(top:10),
      itemCount:items.length,
      itemBuilder: (context,index) => items[index],
      separatorBuilder: (context,index) => Divider(),
    );
  }

  List<Widget> getBodyList(){
    return <Widget>[
        ListTile(
          leading:CircleAvatar(child:Icon(LineIcons.lock)),
          title:Text('Change Password'),
          subtitle:Text('This will enable you to change the password used to authenticate user access to the app.'),
          onTap: () => Get.toNamed('/change_password'),
          trailing:Icon(CupertinoIcons.forward)
          ),
        ListTile(
          leading:CircleAvatar(child:Icon(Icons.disc_full_outlined)),
          title:Text('Storage Location'),
          subtitle: Text(controller.getCurrentStoragePathString()),
          onTap:controller.onChooseNewStorageLocation,
          trailing:Icon(CupertinoIcons.forward)
        ),
        ListTile(
          leading:CircleAvatar(child:Icon(controller.appService.shouldShowPathOnBrowser()? 
          Icons.visibility_rounded: Icons.visibility_off_outlined)),
          title:Text('Show Paths on Browser'),
          subtitle:Text('Show file entity paths on File system browser view.'),
          trailing:SizedBox(
            width:55,
            child:Switch(
            onChanged: (bool val) => controller.setShowPathOnBrowser(val),
            value: controller.appService.shouldShowPathOnBrowser(),))
        ),
        ListTile(
          leading:CircleAvatar(child:Icon(controller.appService.shouldShowPathOnManager()? 
          Icons.visibility_rounded: Icons.visibility_off_outlined)),
          title:Text('Show Paths on Manager'),
          subtitle:Text('Show file entity paths on tracked file manager view.'),
          trailing:SizedBox(
            width:55,
            child:Switch(
            onChanged: (bool val) => controller.setShowPathOnManager(val),
            value: controller.appService.shouldShowPathOnManager(),))
        ),
        ListTile(
          leading:CircleAvatar(child:Icon(LineIcons.street_view)),
          title:Text('Dark Mode'),
          subtitle:Text('Toggle theme modes.'),
          trailing:SizedBox(
            width:55,
            child:Switch(
            onChanged: (bool val) => controller.mainControl.setThemeMode(val),
            value: controller.appService.isDarkThemeMode(),))
        ),
         ListTile(
          onTap:controller.onBackupDatabase,
          leading:CircleAvatar(child:Icon(LineIcons.info)),
          title:Text('Backup your data'),
          subtitle:Text('This will enable you to backup your records, which includes your saved passwords, currently tracked file system entities and encrypted security credencials.'),
          trailing:this.backupStateWidget()
        ),
        ListTile(
          leading:CircleAvatar(child:Icon(LineIcons.database)),
          title:Text('Auto Backup'),
          subtitle:Text('Automatically update backup as soon as you make changes to your data.'),
          trailing:SizedBox(
            width:55,
            child:Switch(
            onChanged: (bool val) => controller.setShouldAutoBackup(val),
            value: controller.appService.shouldAutoBackup(),))
        ),
         
      ];
  }

  Widget backupStateWidget(){
    if(controller.isBackingUp == true){
      return SizedBox(child:CircularProgressIndicator(strokeWidth: 2),height:20,width:20);
    } else {
      return Icon(CupertinoIcons.forward);
    }
  }
  
}