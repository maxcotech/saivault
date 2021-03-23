import 'package:flutter/material.dart';
import 'package:saivault/services/app_service.dart';
import 'package:get/get.dart';

class AboutView extends StatelessWidget{
  final AppService appService = Get.find<AppService>();
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:Text('About')),
      body:_body()
    );
  }

  Widget _body(){
    return SingleChildScrollView(
      child:Container(
        padding:EdgeInsets.symmetric(horizontal:15,vertical: 15),
        child:Table(
        border:TableBorder(horizontalInside: BorderSide(color:Colors.blueGrey)),
        children:getRows()
      ))
    );
  }
  List<TableRow> getRows(){
    return <TableRow>[
       TableRow(
         children: <Widget>[
           TableCell(child:Padding(child:Text('APP NAME',style:TextStyle(fontWeight:FontWeight.bold,fontSize:16)),padding:EdgeInsets.symmetric(vertical:10))),
           TableCell(child:Padding(child:Text(appService.packageInfo.appName,style:TextStyle(fontSize:16)),padding:EdgeInsets.symmetric(vertical:10)))
        ]
      ),
     
      TableRow(
         children: <Widget>[
           TableCell(child:Padding(child:Text('APP VERSION',style:TextStyle(fontWeight:FontWeight.bold,fontSize:16)),padding:EdgeInsets.symmetric(vertical:10))),
           TableCell(child:Padding(child:Text("v "+appService.packageInfo.version,style:TextStyle(fontSize:16)),padding:EdgeInsets.symmetric(vertical:10)))
        ]
      ),
      TableRow(
         children: <Widget>[
           TableCell(child:Padding(child:Text('DEVELOPER',style:TextStyle(fontWeight:FontWeight.bold,fontSize:16)),padding:EdgeInsets.symmetric(vertical:10))),
           TableCell(child:Padding(child:
           GestureDetector(
             onTap:() => appService.launchUrl("https://maxcotechpro.com"),
             child:Text("Maxcotech LTD",style:TextStyle(fontSize:16,color:Colors.blue))),padding:EdgeInsets.symmetric(vertical:10)))
        ]
      ),
      TableRow(
         children: <Widget>[
           TableCell(child:Padding(child:Text('DEV CONTACT',style:TextStyle(fontWeight:FontWeight.bold,fontSize:16)),padding:EdgeInsets.symmetric(vertical:10))),
           TableCell(child:Padding(child:Text("info@maxcotechpro.com",style:TextStyle(fontSize:16)),padding:EdgeInsets.symmetric(vertical:10)))
        ]
      ),
       TableRow(
         children: <Widget>[
           TableCell(child:Padding(child:Text('APP PACKAGE',style:TextStyle(fontWeight:FontWeight.bold,fontSize:16)),padding:EdgeInsets.symmetric(vertical:10))),
           TableCell(child:Padding(child:Text(appService.packageInfo.packageName,style:TextStyle(fontSize:16)),padding:EdgeInsets.symmetric(vertical:10)))
        ]
      ),
      TableRow(
         children: <Widget>[
           TableCell(child:Padding(child:Text('BUILD NUMBER',style:TextStyle(fontWeight:FontWeight.bold,fontSize:16)),padding:EdgeInsets.symmetric(vertical:10))),
           TableCell(child:Padding(child:Text("maxco - "+appService.packageInfo.buildNumber,style:TextStyle(fontSize:16)),padding:EdgeInsets.symmetric(vertical:10)))
        ]
      ),
      TableRow(
         children: <Widget>[
           TableCell(child:Padding(child:Text('WEBSITE',style:TextStyle(fontWeight:FontWeight.bold,fontSize:16)),padding:EdgeInsets.symmetric(vertical:10))),
           TableCell(child:Padding(
             child:GestureDetector(
               onTap:() => appService.launchUrl("https://maxcotechpro.com"),
               child:Text('https://maxcotechpro.com',style:TextStyle(fontSize:16,color:Colors.blue))),padding:EdgeInsets.symmetric(vertical:10)))
        ]
      )
    ];
  }
}