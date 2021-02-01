import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget{
  final String asset;
  final String message;
  EmptyWidget({this.asset:'assets/svg/not_found.svg',this.message:'Could not find anything'});

  @override 
  Widget build(BuildContext context){
    return Center(child:
    Column(
      mainAxisSize: MainAxisSize.min,
      children:<Widget>[
      SvgPicture.asset(
      this.asset,
      width:150,height:150
    ),
    SizedBox(height:30),
    Text(this.message,)//style:TextStyle(color:Colors.black))
    ]));
  }
}