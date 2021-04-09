import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saivault/controllers/login_controller.dart';
import 'package:saivault/widgets/bad_widget.dart';
import 'package:saivault/widgets/custom_text_field.dart';

class LoginView extends StatelessWidget{
  final LoginController controller = Get.put(new LoginController());
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(
        title:Text('User Login')),
      body:GetBuilder(builder:(LoginController control)=>_body(),init:LoginController())
    );
  }

 Widget _body(){
   return Column(children:<Widget>[
     Expanded(child:_bodyContent()),
     BadWidget(completer:controller.completer, bads: controller.bads)
   ]);
 }
 Widget _bodyContent(){
    return SingleChildScrollView(
      padding:EdgeInsets.only(top:70,left:15,right:15),
      child:Column(
        crossAxisAlignment:CrossAxisAlignment.center,
        children:<Widget>[
          _getHeadIcon(),
          SizedBox(height:20),
          customTextField(
            autocorrect: false,
            autofocus: true,
            controller:controller.password,
            obscureText: controller.showPassword ? false:true,
            prefixIcon:Icon(LineIcons.lock),
            labelText:'Enter Password',
            itype:TextInputType.number,
            inputFormatters:<TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
            suffixIcon: IconButton(
                icon:Icon(controller.showPassword? Icons.visibility:Icons.visibility_off),
                onPressed:controller.togglePasswordVisibility
              )
          ),
          SizedBox(height:30),
          _submitButton(),
      ])
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
        child:Text('PROCEED',style:Get.theme.textTheme.button.copyWith(color:Colors.white)),
        onPressed:controller.onLogin
      )
      );
  }

}