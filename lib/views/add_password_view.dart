import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:saivault/controllers/add_password_controller.dart';
import 'package:get/get.dart';

class AddPasswordView extends StatelessWidget{
  final AddPasswordController controller = Get.put(new AddPasswordController());
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(
        title:Text('Add Password')
      ),
      body:_body()
    );
  }
  Widget _body(){
    return GetBuilder(
      builder:(AddPasswordController control)=>SingleChildScrollView(
        padding:EdgeInsets.symmetric(horizontal:15,vertical:40),
        child:Column(
          children:<Widget>[
            TextField(
              controller:controller.passwordLabel,
              decoration:InputDecoration(
                labelText:'Enter Password Label',
                prefixIcon: Icon(LineIcons.file_text)
              )
            ),
            SizedBox(height:20),
            TextField(
              controller:controller.passwordValue,
              maxLines: 7000,
              minLines: 1,
              decoration:InputDecoration(
                /*suffixIcon: IconButton(
                  tooltip: 'Auto generate password',
                  icon:Icon(LineIcons.key),
                ),*/
                labelText:'Enter Password Value',
                prefixIcon: Icon(LineIcons.lock)
              ),
              
            ),
            SizedBox(height:40),
            _submitBtn()
          ]
        )
      )
    );
  }
  Widget _submitBtn(){
    return SizedBox(
      width:Get.width,
      height:48,
      child:RaisedButton(
        color:Get.theme.accentColor,
        child:controller.isLoading?CircularProgressIndicator(backgroundColor:Colors.white):Text('Save Password',style:Get.theme.textTheme.button.copyWith(color:Colors.white)),
        onPressed: controller.onSavePassword
      )
    );
  }

}