import 'package:flutter/material.dart';

Widget customTextField({
  TextEditingController controller,String labelText,double inputFontSize:18.0,
  Widget prefixIcon,Widget suffixIcon,bool obscureText:false,
  bool autofocus:false,bool autocorrect = false,int minLines:1,int maxLines:1}){
  return TextField(
    style:TextStyle(fontSize:inputFontSize),
    minLines:minLines,
    maxLines: maxLines,
    autocorrect: autocorrect,
    controller:controller,
    obscureText: obscureText,
    autofocus:autofocus,
    decoration: InputDecoration(
      filled:true,
      labelText:labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,

    ),
  );
}