import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:saivault/widgets/custom_text_field.dart';

class ChangePasswordView extends StatelessWidget{
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:Text('Change Password')),
      body:_body()
    );
  }
  Widget _body(){
    return SingleChildScrollView(
      padding:EdgeInsets.only(left:15,right:15,top:30),
      child:Column(
        children:<Widget>[
          customTextField(
            prefixIcon:Icon(LineIcons.lock),
            labelText: "Enter Old Password"
            
          ),
          SizedBox(height:20),
          customTextField(
            prefixIcon:Icon(LineIcons.lock),
            labelText: "Enter New Password"
            
          ),
          SizedBox(height:20),
          customTextField(
            prefixIcon:Icon(LineIcons.lock),
            labelText: "Confirm New Password"
        
          ),
          SizedBox(height:40),
          SizedBox(
            height:49,
            width:Get.width,
            child:RaisedButton(
              color:Colors.blue,
              child:Text('SUBMIT',style:TextStyle(color:Colors.white)),
              onPressed:(){}
            )
          )
        ]
      )
    );
  }
}