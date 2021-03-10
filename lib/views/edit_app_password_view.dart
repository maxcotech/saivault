import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:saivault/controllers/edit_app_password_controller.dart';
import 'package:saivault/widgets/custom_text_field.dart';

class EditAppPasswordView extends StatelessWidget{
  final EditAppPasswordController controller = Get.put(EditAppPasswordController());
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:Text('Change Password')),
      body:GetBuilder(builder:(control) => _body(),init:EditAppPasswordController())
    );
  }
  Widget _body(){
    return SingleChildScrollView(
      padding:EdgeInsets.only(left:15,right:15,top:30),
      child:Column(
        children:<Widget>[
          customTextField(
            prefixIcon:Icon(LineIcons.lock),
            labelText: "Enter Old Password",
            controller:controller.oldPassword
          ),
          SizedBox(height:20),
          customTextField(
            prefixIcon:Icon(LineIcons.lock),
            labelText: "Enter New Password",
            controller:controller.password,
            obscureText: true
          ),
          SizedBox(height:20),
          customTextField(
            prefixIcon:Icon(LineIcons.lock),
            labelText: "Confirm New Password",
            controller:controller.confirmPassword,
            obscureText: true
        
          ),
          SizedBox(height:40),
          SizedBox(
            height:49,
            width:Get.width,
            child:RaisedButton(
              color:Colors.blue,
              child:controller.isLoading? CircularProgressIndicator(backgroundColor: Colors.white):Text('SUBMIT',style:TextStyle(color:Colors.white)),
              onPressed:controller.onSubmit
            )
          )
        ]
      )
    );
  }
}