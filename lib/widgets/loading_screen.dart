import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingScreen extends StatelessWidget{
  final bool isLoading;
  final String message;
  LoadingScreen({this.isLoading:false,this.message:'Processing...'});
  @override 
  Widget build(BuildContext context){
    if(this.isLoading == true){
      return loadingView();
    }else{
      return Container();
    }
  }
  Widget loadingView(){
    return Container(
      height:Get.height,
      width:Get.width,
      decoration:BoxDecoration(
        color:Colors.black.withOpacity(0.5),
      ),
      child:Center(child:loadingColumn())
    );
  }
  Widget loadingColumn(){
    return Column(
      mainAxisSize:MainAxisSize.min,
      children:<Widget>[
        CircularProgressIndicator(backgroundColor:Colors.white),
        SizedBox(height:15),
        Text(this.message,style:TextStyle(color:Colors.white))
      ]
    );
  }
}