import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:saivault/controllers/password_manager_controller.dart';
import 'package:saivault/helpers/mixins/color_mixin.dart';
import 'package:saivault/models/password_model.dart';

class PasswordWidget extends StatefulWidget{
  final PasswordModel model;
  final int index;
  final PasswordManagerController controller;
  PasswordWidget({this.model,this.index,this.controller});
  PasswordWidgetState createState() => PasswordWidgetState();
}

class PasswordWidgetState extends State<PasswordWidget> with ColorMixin{

  bool showPassword = false;
  @override 
  Widget build(BuildContext context){
    return ListTile(
      leading:_avatar(),
      title:Text(widget.model.passwordLabel),
      subtitle:Text(this.showPassword? widget.controller.decryptPassword(widget.model):"*******************",
      maxLines:this.showPassword? 7000:1,
      ),
      trailing:_trailing()
    );
  }
  Widget _avatar(){
    String firstLetter = widget.model.passwordLabel[0].toUpperCase();
    return CircleAvatar(
      child:Text(firstLetter,style:TextStyle(fontWeight:FontWeight.bold)),
      backgroundColor: this.getColorFromText(firstLetter),

    );
  }
  Widget _trailing(){
    return PopupMenuButton(
      onSelected:this.onActionSelect,
      itemBuilder: (BuildContext context) => <PopupMenuItem>[
          PopupMenuItem(child: _menuItemLabel(
            this.showPassword?'Hide Password':'View Password',
            this.showPassword?Icons.visibility_off:Icons.visibility),value:'view'),
          PopupMenuItem(child: _menuItemLabel('Edit Password',LineIcons.edit),value:'edit'),
          PopupMenuItem(child: _menuItemLabel('Delete Password',Icons.delete),value:'delete'),
          PopupMenuItem(child: _menuItemLabel('Copy Password',LineIcons.copy),value:'copy')
        ]
      );
  }
  Widget _menuItemLabel(String label,IconData icon){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:<Widget>[
        Icon(icon),
        SizedBox(width:8),
        Text(label)
      ]
    );
  }
  Future<void> onActionSelect(dynamic action)async{
     switch(action){
       case 'view':this.toggleViewPassword();break;
       case 'delete':widget.controller.deletePasswordById(widget.model.id);break;
       case 'copy':await this.copyPasswordToClipboard();break;
       case 'edit':Get.toNamed('/edit_password',arguments: widget.model);break;
       default:print('no matching action');
     }
  }
  void toggleViewPassword(){
    this.showPassword = !this.showPassword;
    this.setState((){});
  }
  Future<void> copyPasswordToClipboard()async{
    ClipboardData data = new ClipboardData(text:widget.controller.decryptPassword(widget.model));
    await Clipboard.setData(data);
    Get.rawSnackbar(message:'Password copied to clipboard');
  }
  
}