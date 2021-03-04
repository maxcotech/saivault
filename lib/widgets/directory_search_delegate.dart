import 'dart:io';

import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:saivault/controllers/directory_browser_controller.dart';
import 'package:saivault/controllers/file_storage_controller.dart';
import 'package:saivault/helpers/mixins/file_extension.dart';
import 'package:saivault/widgets/empty_widget.dart';

class DirectorySearchDelegate extends SearchDelegate with FileExtension{
  final DirectoryBrowserController controller;
  final FileStorageController storageControl;
  DirectorySearchDelegate({this.controller,this.storageControl});
  List<Widget> buildActions(BuildContext context){
    return <Widget>[
      IconButton(
        icon:Icon(LineIcons.close),
        onPressed:(){
          query = "";
        }
      )
    ];
  }
  @override 
  Widget buildLeading(BuildContext context){
    return IconButton(
      icon:Icon(LineIcons.arrow_left),
      onPressed:(){
        Navigator.pop(context);
      }
      );
  }
  @override
  Widget buildResults(BuildContext context){
    return Container();
  }
  Widget widgetList(List<FileSystemEntity> entities){
    return GetBuilder<FileStorageController>(builder:(control)=>ListView.builder(
        padding:EdgeInsets.only(bottom:55),
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
        }));
  }
  
  @override 
  Widget buildSuggestions(BuildContext context){
    List<FileSystemEntity> entities;
    if(query.isEmpty){
      entities = controller.getDesiredEntities();
      if(entities == null || entities.length == 0) return EmptyWidget();
      return this.widgetList(entities);
    }else{
      entities = controller.searchEntities(query);
      if(entities == null || entities.length == 0){
        return EmptyWidget();
      }else{
        return this.widgetList(entities);
      }
    }

  }
}