import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatelessWidget{
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      body:Image.asset('assets/saivault_bg_dark.png',height:Get.height,width:double.infinity,
      fit:BoxFit.cover
     )
    );
  }
}