import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:saivault/controllers/password_manager_controller.dart';
import 'package:saivault/widgets/bad_widget.dart';
import 'package:saivault/widgets/empty_widget.dart';
import 'package:saivault/widgets/password_search_delegate.dart';
import 'package:saivault/widgets/password_widget.dart';
import 'package:saivault/widgets/generated_password_view.dart';

class PasswordManagerView extends GetView<PasswordManagerController>{
  @override 
  Widget build(BuildContext context){
    return GetBuilder(
      builder:(PasswordManagerController control)=>Scaffold(
        appBar: _appBar(context),
        body:_body(context),
        floatingActionButton: _fabBtn(),
    ));
  }
  FloatingActionButton _fabBtn(){
    return FloatingActionButton(
      child:Icon(Icons.add),
      onPressed:() => Get.toNamed('add_password')
    );
  }
  AppBar _appBar(BuildContext context){
    return AppBar(
      title:Text('Manage Passwords'),
      actions: <Widget>[
        IconButton(
          icon:Icon(LineIcons.search),
          onPressed:()async{
            await showSearch(context:context,delegate:PasswordSearchDelegate());
          }
        ),
        IconButton(
          tooltip:'Generate password using the password generator',
          icon:Icon(LineIcons.key),
          onPressed:() => onShowPasswordView()
        ),
        IconButton(
          tooltip: 'Open user guides.',
          icon:Icon(LineIcons.question_circle),
          onPressed:() => Get.toNamed('/password_guide_view')
        )

      ]
    );
  }
  Widget _body(BuildContext context){
    return Column(
      children:<Widget>[
        Expanded(child:_bodyView(context)),
        BadWidget(completer:controller.completer, bads: controller.bads)

      ]
    );
  }
  Widget _bodyView(BuildContext context){
    if(controller.savedPasswords.length > 0){
      return ListView.builder(
        padding:EdgeInsets.only(bottom:55),
        itemCount:controller.savedPasswords.length,
        itemBuilder: (BuildContext context,int index){
          return PasswordWidget(
            controller:controller,
            model:controller.savedPasswords.elementAt(index),index:index);
        });
    }else{
      return EmptyWidget(
        message:'You have not saved any password yet.',
        btnLabel:'GET STARTED',
        onClickBtn:() => Get.toNamed('add_password')
        );
    }
  }
}