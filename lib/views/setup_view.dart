import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:saivault/controllers/setup_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saivault/widgets/custom_text_field.dart';
import 'package:flutter/services.dart';


class SetupView extends GetView<SetupController>{
 
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: _appBar(),
      body: GetBuilder(
        init:SetupController(),
        builder:(SetupController control)=>_body())
    );
  }
  Widget _appBar(){
    return AppBar(
      title: Text('Setup Password'),
    );
  }
  Widget _body(){
    return SingleChildScrollView(
      padding:EdgeInsets.only(top:35,left:15,right:15),
      child:Column(
        crossAxisAlignment:CrossAxisAlignment.center,
        children:<Widget>[
          _getHeadIcon(),
          SizedBox(height:10),
          customTextField(
            autofocus: true,
            controller:controller.password,
            obscureText: controller.showPassword? false:true,
            prefixIcon:Icon(LineIcons.lock),
            itype:TextInputType.number,
            inputFormatters:<TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
            labelText:'Enter Password',
          ),
          SizedBox(height:20),
          customTextField(
            controller:controller.confirmPassword,
            obscureText:controller.showPassword? false:true,
            prefixIcon:Icon(LineIcons.lock),
            itype:TextInputType.number,
            inputFormatters:<TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
            labelText:'Confirm Password',
          ),
          SizedBox(height:10),
          _toggleVisibilityWidget(),
          SizedBox(height:10),
          _submitButton(),
          SizedBox(height:10),
          _recoveryBtn()
      ])
    );
  }

  Widget _toggleVisibilityWidget(){
    return SwitchListTile(
      title:Text('Password Visibility'),
      value: controller.showPassword, 
      onChanged: controller.togglePasswordVisibility
      );
  }

  Widget _recoveryBtn(){
     return SizedBox(
      height:48,
      width:Get.size.width,
      child:RaisedButton(
        elevation: 0,
        color:Colors.transparent,
        shape:Border.all(color:Colors.blue),
        child:Text(controller.isLoading?'RECOVERING...':'DATA RECOVERY'),
        onPressed:() async {if(controller.isLoading == false) {await controller.onDataRecovery();}}
      )
      );
  }

  Widget _getHeadIcon(){
    return Center(
      child:SvgPicture.asset(
      'assets/svg/lock.svg',
      height: 150,
      width: 150
    ));
  }
  Widget _submitButton(){
    return SizedBox(
      height:48,
      width:Get.size.width,
      child:RaisedButton(
        color:Colors.blueAccent,
        child:Text('SAVE PASSWORD',style:Get.theme.textTheme.button.copyWith(color:Colors.white)),
        onPressed:controller.savePassword
      )
      );
  }


  
}