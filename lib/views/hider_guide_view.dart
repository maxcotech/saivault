import 'package:flutter/material.dart';

class GuideView extends StatelessWidget{
  final String title;
  final Widget bodyContent;
  GuideView({this.title,this.bodyContent});
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:Text(this.title)),
      body:this.bodyContent
    );
  }
}