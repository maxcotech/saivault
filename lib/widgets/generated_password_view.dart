import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:saivault/controllers/password_manager_controller.dart';

Widget _textField(PasswordManagerController pmControl,{String label,TextEditingController controller,
      TextInputType itype = TextInputType.text,List<TextInputFormatter> iformatters,
      Widget suffix }){
      return Padding(
        padding:EdgeInsets.symmetric(horizontal: 10,vertical:5),
        child:TextField(
        controller:controller,
        inputFormatters: iformatters,
        keyboardType: itype,
        minLines: 1,
        maxLines:50,
        decoration: InputDecoration(
          labelStyle:TextStyle(fontSize:20),
          suffixIcon: suffix,
          labelText:label,
          filled:true
        )
      ));
}

Widget _btns(PasswordManagerController pmControl){
  return Padding(
    padding:EdgeInsets.only(left:10,right:10,top:25),
    child:Row(
    children:<Widget>[
      Expanded(
        child:RaisedButton(
          color:Colors.blue,
          child:Text('GENERATE',style:TextStyle(color:Colors.white)),
          onPressed:pmControl.generatePassword)),
      SizedBox(width:10),
      Expanded(child:RaisedButton(
        elevation: 0,
        color:Colors.transparent,
        shape:Border.all(color:Colors.blue),
        child:Text('SAVE'),
        onPressed:pmControl.onSavePassword))
    ]
  ));
}

Future onShowPasswordView() async {
  PasswordManagerController pmControl = Get.find<PasswordManagerController>();
  pmControl.generatePassword();
  await Get.bottomSheet(
    Container(
      padding:EdgeInsets.only(top:20,left:15,right:15,bottom:15),
      decoration: BoxDecoration(
      color:Get.theme.scaffoldBackgroundColor,
      borderRadius:BorderRadius.only(topRight:Radius.circular(10),topLeft:Radius.circular(10))),
      child: GetBuilder(
      init:PasswordManagerController(),
      builder: (control) => SingleChildScrollView(child:Column(
        mainAxisSize: MainAxisSize.min,
        children:<Widget>[
          Text('Password Generator',style:TextStyle(fontSize:15)),
          SizedBox(height:20),
          ListTile(
            //leading:Icon(LineIcons.arrow_circle_o_right),
            title:Text('Include Lowercase Letters'),
            trailing:Switch(
             onChanged: pmControl.setShouldHaveLowerAlpha,
             value: pmControl.pService.shouldHaveLowerAlpha())
          ),
          ListTile(
            //leading:Icon(LineIcons.arrow_circle_o_right),
            title:Text('Include Uppercase Letters'),
            trailing:Switch(
              onChanged: pmControl.setShouldHaveUpperAlpha,
              value: pmControl.pService.shouldHaveUpperAlpha())
          ),
          ListTile(
           // leading:Icon(LineIcons.arrow_circle_o_right),
            title:Text('Include Numerals'),
            trailing:Switch(
              onChanged: pmControl.setShouldHaveNumerals, 
              value: pmControl.pService.shouldHaveNumerals())
          ),
          ListTile(
            //leading:Icon(LineIcons.arrow_circle_o_right),
            title:Text('Include Non-Alphanumerals'),
            trailing:Switch(
              onChanged: pmControl.setShouldHaveNonAlphaNumerals , 
              value:pmControl.pService.shouldHaveNonAlphaNumerals())
          ),
          _textField(
            pmControl,
            controller:pmControl.pLengthControl,
            itype:TextInputType.number,
            label:'Length of password',iformatters:<TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]),
          _textField(
            pmControl,
            suffix:IconButton(
              icon:Icon(Icons.copy,size:20),onPressed:pmControl.copyGeneratedPassword),
            controller:pmControl.generatedPassControl,
            label:'Generated Password'),
          _btns(pmControl)

        ]
      ))
    ),
    ),isScrollControlled: true);
    
}