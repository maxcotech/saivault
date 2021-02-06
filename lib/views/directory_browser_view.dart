import 'dart:io';
import 'package:flutter/material.dart';
import 'package:saivault/controllers/directory_browser_controller.dart';
import 'package:get/get.dart';
import 'package:saivault/controllers/file_storage_controller.dart';
import 'package:saivault/widgets/empty_widget.dart';

class DirectoryBrowserView extends StatelessWidget{
  final FileStorageController storageControl = Get.find<FileStorageController>();
  final DirectoryBrowserController controller = Get.find<DirectoryBrowserController>();
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title:Text(controller.path.split('/').last),
        actions:<Widget>[
          IconButton(icon:Icon(Icons.home),onPressed:()=>Get.until((route)=>Get.currentRoute == '/'))
        ]
      ),
      body:_body()
    );
  }
  Widget _body(){
    return Column(
      children:<Widget>[
        Expanded(child:GetBuilder(builder:(FileStorageController scontrol)=>_entityList())),
        _actionBtns()
      ]
    );
  }
  Widget _actionBtns(){
    return Container(
      height:50,width:Get.width,
      child:Row(
        children: <Widget>[
          Expanded(
            child:Padding(
              padding:EdgeInsets.only(left:10,right:5),
              child:RaisedButton(
                onPressed:storageControl.onTrackSelected,
                color:Colors.blue,
                child:Text('OK',style:TextStyle(color:Colors.white))
              )
          )),
          Expanded(
            child:Padding(
              padding:EdgeInsets.only(right:10,left:5),
              child:RaisedButton(
                onPressed:()=> Get.until((route) => Get.currentRoute == '/'),
                child:Text('CANCEL')
              )
          ))
        ],
      )
    );
  }
  Widget _entityList(){
    return GetBuilder(
      builder: (DirectoryBrowserController control) => FutureBuilder(
      future: controller.getFileSystemEntities(),
      builder: (BuildContext context,AsyncSnapshot<List<FileSystemEntity>> snapshot){
        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
          if(snapshot.data.length > 0){
            return ListView.builder(

              itemCount:snapshot.data.length,
              itemBuilder:(BuildContext context,int index){
                FileSystemEntity entity = snapshot.data[index];
                return ListTile(
                  onTap:()=>Get.toNamed('/directory_browser',arguments:entity.path,preventDuplicates:false),
                  leading:storageControl.getFileTypeIcon(entity),
                  title:Text(entity.path.split('/').last),
                  subtitle:Text(entity.path),
                  trailing:Checkbox(value:storageControl.pathIsSelected(entity.path),
                  onChanged:(bool newval){
                    storageControl.toggleAppendPathsToTrack(entity.path);
                  })
                );
              }
            );
          }else{
            return EmptyWidget(message:'This folder is empty');
          }
        }else if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child:CircularProgressIndicator());
        }
        else{
          return EmptyWidget(message:'This folder is empty');
        }
      }
     ),
    );
  
  }
}