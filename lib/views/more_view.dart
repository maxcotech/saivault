import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:get/get.dart';
import 'package:saivault/controllers/settings_controller.dart';
import 'package:saivault/config/app_constants.dart';


class MoreView extends StatelessWidget{
  final SettingsController controller = Get.find<SettingsController>();
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:Text('More Options')),
      body:GetBuilder(builder:(control)=>_body(context:context),init:SettingsController())
    /* body:Image.asset('assets/saivault_bg_dark.png',height:Get.height,width:double.infinity,
      fit:BoxFit.cover
     )*/
    );
  }
  Widget _body({BuildContext context}){
    return ListView(
      padding:EdgeInsets.only(top:10),
      children:<Widget>[
     
        ListTile(
          leading:CircleAvatar(child:Icon(LineIcons.question_circle)),
          title:Text('Help and Guidelines'),
          subtitle:Text('Contains guides necessary to get you started with using the features offered by $APPNAME.'),
          onTap:() => Get.toNamed('/guidelines_menu'),
          trailing:Icon(CupertinoIcons.forward)
        ),
        ListTile(
          leading:CircleAvatar(child:Icon(Icons.library_books)),
          onTap: ()=> showLicensePage(
            context: context,
            applicationIcon:Image.asset('assets/saivault.png',width:100),
            applicationVersion: "v ${controller.appService.packageInfo.version}",
            applicationLegalese:"Developed By Maxcotech"),
          title:Text('App Licenses'),
          subtitle:Text('Browse license of App dependencies and dev tools.'),
          trailing:Icon(CupertinoIcons.forward)
        ),
        ListTile(
          leading:CircleAvatar(child:Icon(Icons.update_rounded)),
          title:Text('App Update'),
          subtitle:Text('Check if a newer version of $APPNAME is available on Play Store.'),
          trailing:Icon(CupertinoIcons.forward),
          onTap:() => controller.appService.checkNewAppUpdate()
        ),
        ListTile(
          leading:CircleAvatar(child:Icon(Icons.policy_outlined)),
          title:Text('Terms And Conditions'),
          subtitle:Text('Policies, terms and conditions governing usage of this product.'),
          trailing:Icon(CupertinoIcons.forward),
          onTap:() => controller.appService.launchUrl(APP_TERMS_URL)
        ),
         ListTile(
          leading:CircleAvatar(child:Icon(Icons.apps_sharp)),
          title:Text('About'),
          subtitle:Text('v ${controller.appService.packageInfo.version}'),
          trailing:Icon(CupertinoIcons.forward),
          onTap:() => Get.toNamed('/about_page')
        ),
         
      ]
    );
  }
  
}