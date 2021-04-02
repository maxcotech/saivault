import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:saivault/controllers/edit_password_controller.dart';
import 'package:saivault/widgets/bad_widget.dart';
import 'package:saivault/widgets/custom_text_field.dart';

class EditPasswordView extends StatelessWidget{
  final EditPasswordController controller = Get.put(new EditPasswordController());
  @override 
  Widget build(BuildContext context){
     return Scaffold(
      appBar:AppBar(
        title:Text('Edit Password')
      ),
      body:GetBuilder(
      builder:(EditPasswordController control)=>_body(context))
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
    return SingleChildScrollView(
        padding:EdgeInsets.symmetric(horizontal:15,vertical:30),
        child:Column(
          children:<Widget>[
            customTextField(
              controller:controller.label,
              labelText:'Enter Password Label',
              prefixIcon: Icon(LineIcons.file_text)
            ),
            SizedBox(height:20),
            customTextField(
              controller:controller.password,
              maxLines: 7000,
              minLines: 1,
              labelText:'Enter Password Value',
              prefixIcon: Icon(LineIcons.lock)
              ,
              
            ),
            SizedBox(height:40),
            _submitBtn()
          ]
        )
      
    );
  }
  Widget _submitBtn(){
    return SizedBox(
      width:Get.width,
      height:48,
      child:RaisedButton(
        color:Get.theme.accentColor,
        child:controller.isLoading?CircularProgressIndicator(backgroundColor:Colors.white):Text('SAVE PASSWORD',style:Get.theme.textTheme.button.copyWith(color:Colors.white)),
        onPressed:controller.onSubmit
      )
    );
  }
}