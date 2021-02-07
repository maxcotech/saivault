import 'package:flutter/material.dart';

Widget customTextField({
  TextEditingController controller,String labelText,
  Widget prefixIcon,Widget suffixIcon,bool obscureText:false,
  bool autofocus:false,bool autocorrect = false,int minLines:1,int maxLines:1}){
  return TextField(
    minLines:minLines,
    maxLines: maxLines,
    autocorrect: autocorrect,
    controller:controller,
    obscureText: obscureText,
    autofocus:autofocus,
    decoration: InputDecoration(
      filled:true,
      border:OutlineInputBorder(borderSide: BorderSide.none,borderRadius:BorderRadius.circular(8)),
      labelText:labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,

    ),
  );
}