import 'dart:io';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/material.dart';
import 'package:saivault/controllers/directory_browser_controller.dart';
import 'package:get/get.dart';
import 'package:saivault/controllers/file_storage_controller.dart';
import 'package:saivault/widgets/directory_search_delegate.dart';
import 'package:saivault/widgets/empty_widget.dart';

class DirectoryBrowserView extends GetWidget<DirectoryBrowserController>{
  final FileStorageController storageControl = Get.find<FileStorageController>();
  //final DirectoryBrowserController controller = Get.find<DirectoryBrowserController>();
  @override 
  Widget build(BuildContext context){
    return GetBuilder(
      init:DirectoryBrowserController(),
      builder: (DirectoryBrowserController control) => Scaffold(
      appBar: AppBar(
        title:Text(controller.path != null? controller.path.split('/').last:'Loading...'),
        actions:<Widget>[
          IconButton(icon:Icon(Icons.search),onPressed:(){
            showSearch(context:context,delegate:DirectorySearchDelegate(
              controller:controller,
              storageControl:storageControl
              ));
          }),
          IconButton(icon:Icon(Icons.home),onPressed:()=>Get.until((route)=>Get.currentRoute == '/'))
        ]
      ),
      body:_body()
    ));
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
    
        List<FileSystemEntity> entities = controller.getDesiredEntities();
          if(controller.isLoading){
            return Center(child:CircularProgressIndicator());
          }
          if(entities == null || entities.length == 0){
            return EmptyWidget();
          }
          return ListView.builder(
            itemCount:entities.length,
            itemBuilder:(BuildContext context,int index){
              FileSystemEntity entity = entities[index];
              return ListTile(
                onTap:()=>Get.toNamed('/directory_browser',arguments:entity.path,preventDuplicates:false),
                leading:storageControl.getFileTypeIcon(entity),
                title:Text(entity.path.split('/').last),
                subtitle:Text(entity.path),
                trailing:CircularCheckBox(value:storageControl.pathIsSelected(entity.path),
                onChanged:(bool newval){
                  storageControl.toggleAppendPathsToTrack(entity.path);
                })
              );
            }
          );
      
    }
}