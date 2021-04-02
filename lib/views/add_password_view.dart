import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:saivault/controllers/add_password_controller.dart';
import 'package:get/get.dart';
import 'package:saivault/widgets/bad_widget.dart';
import 'package:saivault/widgets/custom_text_field.dart';

class AddPasswordView extends StatelessWidget{
  final AddPasswordController controller = Get.put(new AddPasswordController());
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(
        title:Text('Add Password')
      ),
      body: GetBuilder(
      builder:(AddPasswordController control)=> _body())
    );
  }

  Widget _body(){
    return Column(
      children:<Widget>[
        Expanded(child:_bodyView()),
        BadWidget(completer:controller.completer, bads: controller.bads)

      ]
    );
  }

  Widget _bodyView(){
    return SingleChildScrollView(
        padding:EdgeInsets.symmetric(horizontal:15,vertical:30),
        child:Column(
          children:<Widget>[
            customTextField(
              controller:controller.passwordLabel,
              labelText:'Enter Password Label',
              prefixIcon: Icon(LineIcons.file_text)
            ),
            SizedBox(height:20),
            customTextField(
              controller:controller.passwordValue,
              maxLines: 7000,
              minLines: 1,
              labelText:'Enter Password Value',
              prefixIcon: Icon(LineIcons.lock)
      
                /*suffixIcon: IconButton(
                  tooltip: 'Auto generate password',
                  icon:Icon(LineIcons.key),
                ),*/
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
        onPressed: controller.onSavePassword
      )
    );
  }

}