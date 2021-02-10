import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:saivault/helpers/isolate_helpers.dart';
import 'package:saivault/helpers/mixins/encryption_mixin.dart';
import 'package:saivault/helpers/mixins/file_extension.dart';
import 'package:saivault/helpers/mixins/path_mixin.dart';
import 'package:saivault/models/hidden_file_model.dart';
import 'package:saivault/services/app_service.dart';
import 'package:saivault/services/db_service.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:saivault/services/file_encryption.dart';
import 'package:saivault/widgets/confirm_dialog.dart';
import 'package:saivault/widgets/dialog.dart';

class FileManagerController extends Controller with FileExtension,PathMixin,EncryptionMixin{
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
          if(await this.createNestedEntityPath(folderItem.path, itemCPath)){
            bool result = await this.hideEntity(folderItem.path,itemCPath,key,ivString);
            if(result == false) return false;
          }else{
            return false;
          }
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
      int updateStatus;
      if(model.hidden == 0){
        //proceed to hide entity
        if(await this.hideEntity(model.originalPath,model.hiddenPath,
          key,model.initialVector) == true){
          updateStatus = await this.updateEntityStatus(1,model.id);
          if(updateStatus != -1) Get.rawSnackbar(message:'Entity was successfully hidden.',duration:Duration(seconds:3));
        }else{
          throw new Exception('Failed to hide entity');
        }
      }
      else if(model.hidden == 1){
        //restore file;
        if(await this.restoreEntity(model.originalPath,model.hiddenPath,key,model.initialVector) == true){
          updateStatus = await this.updateEntityStatus(0,model.id);
          if(updateStatus != -1) Get.rawSnackbar(message:'Entity successfully restored.',duration:Duration(seconds:3));

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
  Future<int> updateEntityStatus(int status,int id)async{
    int dbResult = await dbService.db.update(
      'hidden_files',<String,dynamic>{'hidden':status},where:'id = ?',whereArgs:[id]);
    return dbResult;
  }
  
  Future<bool> restoreEntity(String originalPath,String cryptPath,Key key,String ivString)async{
    FileSystemEntityType entityType = await FileSystemEntity.type(cryptPath);
    if(entityType == FileSystemEntityType.directory){
      Directory folder = new Directory(cryptPath);
      await for(FileSystemEntity entity in folder.list()){
        String newOriginalPath = await this.getOriginalPathByHidden(entity.path);
        if(newOriginalPath != null){
          bool result = await this.restoreEntity(newOriginalPath,entity.path,key,ivString);
          if(result == false){print('file restoration failed');return false;}
        }else{return false;}
      }
      if(await this.deleteNestedEntityByHidden(cryptPath) != -1){
        await folder.delete();
      }
      return true;
    }
    if(entityType == FileSystemEntityType.file){
      return await this.restoreFile(cryptPath,originalPath,key,ivString);
    }
    return false;
  }
  Future<bool> restoreFile(String sourcePath,String desPath,Key key,String ivString)async{
    bool result = await compute(decryptAndRestoreFile,<String,dynamic>{
      'des_path':desPath,'source_path':sourcePath,
      'key':key.base64,'iv_string':ivString
    });
    return result;
  }
  Future<bool> hideFile(String sourcePath,String desPath,Key key,String ivString)async{
    bool result = await compute(encryptAndHideFile,<String,dynamic>{
      'des_path':desPath,'source_path':sourcePath,
      'key':key.base64,'iv_string':ivString
    });
    return result;
  }

  Future<bool> nestedHiddenPathExists(String path)async{
    List<Map<String,dynamic>> result = await this.dbService.db.query('nested_entities',
    where:'hidden_path = ?',whereArgs:[path]);
    if(result.length > 0){
      return true;
    }
    return false;
  }
  Future<bool> createNestedEntityPath(String original,String hidden)async{
    Map<String,dynamic> encObj = await this.encryptString(original,this.appService.encryptionKey);
    int result;
    if(await this.nestedHiddenPathExists(hidden)){
      result = await this.dbService.db.update('nested_entities',<String,dynamic>{
        'original_path':encObj['encrypted_string'],
        'initial_vector':encObj['iv_string']
      },where:'hidden_path = ?',whereArgs:[hidden]);
    }else{
      result = await this.dbService.db.insert('nested_entities',<String,dynamic>{
        'original_path':encObj['encrypted_string'],
        'initial_vector':encObj['iv_string'],
        'hidden_path':hidden
      });
    }
    return result != -1? true:false;
  }
  Future<String> getOriginalPathByHidden(String hidden)async{
    List<Map<String,dynamic>> result = await dbService.db.query('nested_entities',
      where:'hidden_path = ?',whereArgs:[hidden]);
    if(result.length > 0){
      String encString = result[0]['original_path'];
      String ivString = result[0]['initial_vector'];
      String decString = await this.decryptString(encString,this.appService.encryptionKey,ivString);
      return decString;
    }else{
      return null;
    }
  }
  Future<int> deleteNestedEntityByHidden(String hidden)async{
    return await dbService.db.delete('nested_entities',where:'hidden_path = ?',whereArgs:[hidden]);
  }

  Future onHideAllTrackedEntities()async{
    List<HiddenFileModel> openEntities = this._hiddenFiles.where((element) => element.hidden == 0).toList();
    Key key = appService.encryptionKey;
    try{
      if(openEntities.length > 0){
        this.setLoading(true);
        for(HiddenFileModel item in openEntities){
          if(await this.hideEntity(item.originalPath,item.hiddenPath,key,item.initialVector) == true){
            await this.updateEntityStatus(1,item.id);
          }else{
            throw new Exception('Failed to hide entity on path '+item.originalPath);
          }
        }
        await this.loadTrackFiles();
        this.setLoading(false);
      }
      Get.rawSnackbar(message:'All entities has been hidden.',duration:Duration(seconds:3));
    }
    catch(e){
      this.setLoading(false);
      getDialog(message:e.toString(),status:Status.error);
    }
  }
  Future onRestoreAllTrackedEntities()async{
    List<HiddenFileModel> hiddenEntities = this._hiddenFiles.where((element)=>element.hidden == 1).toList();
    Key key = appService.encryptionKey;
    try{
      if(hiddenEntities.length > 1){
        this.setLoading(true);
        for(HiddenFileModel item in hiddenEntities){
          if(await this.restoreEntity(item.originalPath,item.hiddenPath,key,item.initialVector) == true){
            await this.updateEntityStatus(0,item.id);
          }else{
            throw new Exception('Failed to restore entity on path '+item.originalPath);
          }
        }
        await this.loadTrackFiles();
        this.setLoading(false);
      }
      Get.rawSnackbar(message:'All entities has been hidden.',duration:Duration(seconds:3));
    }
    catch(e){
      this.setLoading(false);
      getDialog(message:e.toString(),status:Status.error);
    }
  }
  
}