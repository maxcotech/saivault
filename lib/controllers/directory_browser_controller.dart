import 'dart:io';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:get/get.dart';

class DirectoryBrowserController extends Controller{
  String path;
  @override 
  void onInit(){
    path = Get.arguments as String;
    
    super.onInit();
  }
  Future<List<FileSystemEntity>> getFileSystemEntities()async{
    List<FileSystemEntity> entities = new List<FileSystemEntity>();
    if(await Permission.storage.request().isGranted){
      print('permission granted');
        
        Directory rootDir = new Directory(path);
        if(await rootDir.exists()){
          print('directory exists');
          List<FileSystemEntity> contents = await rootDir.list().toList();
          entities.addAll(this.filterHiddenEntities(contents));
        }else{
          print('directory does not exists');
        }
    }else{
      print('permission not granted');
    }
   
    return entities;
  }
  List<FileSystemEntity> filterHiddenEntities(List<FileSystemEntity> entities){
    List<FileSystemEntity> newEntities = new List<FileSystemEntity>();
    if(entities.length > 0){
      entities.forEach((FileSystemEntity item){
        if(item.path.split('/').last.startsWith('.') == false){
          newEntities.add(item);
        }
      });
    }
    return newEntities;
  }
}