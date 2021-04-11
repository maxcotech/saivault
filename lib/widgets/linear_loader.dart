import 'package:flutter/material.dart';

class LinearLoader extends StatelessWidget{
  final bool isLoading;
  LinearLoader({this.isLoading:true});
  @override
  Widget build(BuildContext context){
    if(this.isLoading == false){
      return Container();
    } else {
      return LinearProgressIndicator();
    }
  }
}