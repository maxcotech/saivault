import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:saivault/controllers/edit_password_controller.dart';

class EditPasswordView extends StatelessWidget{
  final EditPasswordController controller = Get.put(new EditPasswordController());
  @override 
  Widget build(BuildContext context){
     return Scaffold(
      appBar:AppBar(
        title:Text('Add Password')
      ),
      body:_body(context)
    );
  }

  Widget _body(BuildContext context){
    return GetBuilder(
      builder:(EditPasswordController control)=>SingleChildScrollView(
        padding:EdgeInsets.symmetric(horizontal:15,vertical:40),
        child:Column(
          children:<Widget>[
            TextField(
              controller:controller.label,
              decoration:InputDecoration(
                labelText:'Enter Password Label',
                prefixIcon: Icon(LineIcons.file_text)
              )
            ),
            SizedBox(height:20),
            TextField(
              controller:controller.password,
              maxLines: 7000,
              minLines: 1,
              decoration:InputDecoration(
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
        onPressed:controller.onSubmit
      )
    );
  }
}