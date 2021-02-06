import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:saivault/helpers/isolate_helpers.dart';
import 'package:saivault/helpers/mixins/file_extension.dart';
import 'package:saivault/helpers/mixins/path_mixin.dart';
import 'package:saivault/models/hidden_file_model.dart';
import 'package:saivault/services/app_service.dart';
import 'package:saivault/services/db_service.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:saivault/widgets/confirm_dialog.dart';
import 'package:saivault/widgets/dialog.dart';

class FileManagerController extends Controller with FileExtension,PathMixin{
  DBService dbService;
  AppService appService;
  List<HiddenFileModel> _hiddenFiles;
  List<HiddenFileModel> get hiddenFiles => this._hiddenFiles;
  Future<void> onInit()async{
    dbService = Get.find<DBService>();
    appService = Get.find<AppService>();
    _hiddenFiles = new List<HiddenFileModel>();
    this.setLoading(true);
    await this.loadTrackFiles();
    this.setLoading(false);
    super.onInit();
  }


  Future<void> onClickAdd()async{
    Get.toNamed('/file_storage');
  }
  Future<void> loadTrackFiles()async{
    List<Map<String,dynamic>> results = await dbService.db.query('hidden_files');
    dynamic payload = {'result':results,'key':appService.encryptionKey};
    this._hiddenFiles = await compute(serializeAndDecryptListToHiddenFileModels,payload);
    this.update();
  }
  Future<void> onDeleteTrackedItem(HiddenFileModel model)async{
    try{
      if(model.hidden == 1){
        throw new Exception('You can not remove entities that has been hidden. if you must remove an entity, you have to restore the entity then proceed to remove it.');
      }else{
        if(await confirmDialog(message:'Are you sure you want to remove this entity?')){
          this.setLoading(true);
          int result = await dbService.db.delete('hidden_files',where:'id = ?',whereArgs:[model.id]);
          if(result == -1){
            throw new Exception('failed to remove entity');
          }else{
            await this.loadTrackFiles();
            this.setLoading(false);
            Get.rawSnackbar(message:'Successfully removed tracked item',duration:Duration(seconds:3));
          }
        }
      }
    }
    catch(e){
      this.setLoading(false);
      getDialog(message:e.toString(),status:Status.error);
    }
  }
  Future<bool> hideEntity(String originalPath,String cryptPath,Key key,String ivString)async{
    FileSystemEntityType entityType = await FileSystemEntity.type(originalPath);
    if(entityType == FileSystemEntityType.directory){
      Directory folder = new Directory(originalPath);
      if(await folder.exists()){
        await for(FileSystemEntity folderItem in folder.list()){
          String itemCPath = await this.generateCryptPathFromOriginal(folderItem.path);
          bool result = await this.hideEntity(folderItem.path,itemCPath,key,ivString);
          if(result == false) return false;
        }
        await folder.delete();
        return true;
      }else{
        return false;
      }
    }
    if(entityType == FileSystemEntityType.file){
      //entity is a file
      return await this.hideFile(originalPath,cryptPath,key,ivString);
    }
    return false;
  }
  
 
  Future onToggleHideEntity(HiddenFileModel model)async{
    try{
      this.setLoading(true);
      Key key = appService.encryptionKey;
      if(model.hidden == 0){
        //proceed to hide entity
        if(await this.hideEntity(model.originalPath,model.hiddenPath,
          key,model.initialVector) == true){
          await this.updateEntityStatusAndNotify(1,model.id);
        }else{
          throw new Exception('Failed to hide entity');
        }
      }
      else if(model.hidden == 1){
        //restore file;
        if(await this.restoreEntity(model.originalPath,model.hiddenPath,key,model.initialVector) == true){
          await this.updateEntityStatusAndNotify(0,model.id);
        }else{
          throw new Exception('Failed to restore hidden entity.');
        }
      }
      await this.loadTrackFiles();
      this.setLoading(false);
    }
    catch(e){
      this.setLoading(false);
      getDialog(message:e.toString(),status:Status.error);
    }
    
  }
  Future<int> updateEntityStatusAndNotify(int status,int id)async{
    int dbResult = await dbService.db.update(
      'hidden_files',<String,dynamic>{'hidden':status},where:'id = ?',whereArgs:[id]);
    if(dbResult != -1){
      String message = "";
      if(status == 1){
        message = 'Entity was successfully hidden';
      }else if(status == 0){
        message = 'Entity was Successfully restored';
      }
      if(message.isNotEmpty) Get.rawSnackbar(message:message,duration:Duration(seconds:3));
    }
    return dbResult;
  }
  Future<bool> hideFile(String sourcePath,String desPath,Key key,String ivString)async{
    bool result = await compute(encryptAndHideFile,<String,dynamic>{
      'des_path':desPath,'source_path':sourcePath,
      'key':key.base64,'iv_string':ivString
    });
    return result;
  }
  Future<bool> restoreEntity(String originalPath,String cryptPath,Key key,String ivString)async{
    FileSystemEntityType entityType = await FileSystemEntity.type(cryptPath);
    if(entityType == FileSystemEntityType.directory){
      return false;
    }
    if(entityType == FileSystemEntityType.file){
      return await this.restoreFile(cryptPath,originalPath,key,ivString);
    }
    return false;
  }
  Future<bool> restoreFile(String sourcePath,String desPath,Key key,String ivString)async{
    return await compute(decryptAndRestoreFile,<String,dynamic>{
      'des_path':desPath,'source_path':sourcePath,
      'key':key.base64,'iv_string':ivString
    });
  }
 
  
}