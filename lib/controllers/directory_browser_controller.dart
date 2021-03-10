import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:get/get.dart';
import 'package:saivault/controllers/file_storage_controller.dart';

class DirectoryBrowserController extends Controller{
  String path;
  int _filterOption = 0;
  List<FileSystemEntity> entities;
  FileStorageController storageController;

  int get filterOption => this._filterOption;
  @override 
  Future<void> onInit()async{
    path = Get.arguments as String;
    entities = await this.getFileSystemEntities();
    storageController = Get.find<FileStorageController>();
    this.update();
    super.onInit();
  }
  void onToggleAllToTrack(){
    storageController.toggleAppendDirectoryContentToTrack(entities);
    this.update();
  }
  Future<List<FileSystemEntity>> getFileSystemEntities()async{
    List<FileSystemEntity> entities = new List<FileSystemEntity>();
    if(await Permission.storage.request().isGranted){
      print('permission granted');
        if(path == null){
          return entities;
        }
        Directory rootDir = new Directory(path);
        if(await rootDir.exists()){
          print('directory exists');
          List<FileSystemEntity> contents = await rootDir.list().toList();
          entities.addAll(this.filterHiddenEntities(contents));
        }else{
          print('directory does not exists');
        }
    }else{
      Get.back();
      print('permission not granted');
      return null;
    }
   
    return entities;
  }
  List<FileSystemEntity> getDesiredEntities(){
    if(this._filterOption == 0) return this.entities;
    return <FileSystemEntity>[];
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
  void setFilterOption(int val){
    this._filterOption = val;
    print('new option is $val');
    this.update();
  }
  List<FileSystemEntity> searchEntities(String query){
    if(this.entities != null && this.entities.length > 0){
      List<FileSystemEntity> newList = this.entities.where((FileSystemEntity item){
        String lowerPath = item.path.split('/').last.toLowerCase();
        String lowerQuery = query.toLowerCase();
        return lowerPath.contains(lowerQuery);
      }).toList();
      return newList;
    }else{
      return <FileSystemEntity>[];
    }
  }
}