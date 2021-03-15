

import 'package:flutter/material.dart';

class ThemeConfig{

  static ThemeData lightTheme(){
    return ThemeData(
        primarySwatch:Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ).copyWith(appBarTheme:AppBarTheme(
        elevation: 1,
        iconTheme: IconThemeData(color:Colors.blueGrey),
        color:Colors.white,textTheme:TextTheme(headline6:TextStyle(
          color:Colors.black87,fontSize:19,fontWeight:FontWeight.bold))));
  }

  static ThemeData darkTheme(){
    return ThemeData.dark().copyWith(accentColor: Colors.blueAccent);
  }
}