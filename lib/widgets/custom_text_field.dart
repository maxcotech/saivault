import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget customTextField({
  TextEditingController controller,String labelText,double inputFontSize:18.0,
  Widget prefixIcon,Widget suffixIcon,bool obscureText:false,
  List<TextInputFormatter> inputFormatters,
  TextInputType itype,
  bool autofocus:false,bool autocorrect = false,int minLines:1,int maxLines:1}){
  return TextField(
    style:TextStyle(fontSize:inputFontSize),
    minLines:minLines,
    keyboardType: itype,
    inputFormatters:inputFormatters,
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