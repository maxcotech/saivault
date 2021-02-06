import 'dart:io';
import 'package:path/path.dart';
import 'package:encrypt/encrypt.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:saivault/controllers/file_manager_controller.dart';
import 'package:saivault/helpers/mixins/file_extension.dart';
import 'package:saivault/helpers/mixins/path_mixin.dart';
import 'package:saivault/models/hidden_file_model.dart';
import 'package:saivault/services/app_service.dart';
import 'package:saivault/services/db_service.dart';
import 'package:get/get.dart';
import 'package:saivault/widgets/dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

class FileStorageController extends Controller with FileExtension,PathMixin{
  List<String> _pathsToTrack;
  DBService dbService;
  AppService appService;
  FileManagerController mController;
  List<String> get pathsToTrack => this._pathsToTrack;
  @override 
  Future<void> onInit()async{
    dbService = Get.find<DBService>();
    appService = Get.find<AppService>();
    this._pathsToTrack = new List<String>();
    mController = Get.find<FileManagerController>();
    super.onInit();
  }
  Future<List<StorageInfo>> getStoragePaths()async{
    return await PathProviderEx.getStorageInfo();
  }
  void toggleAppendPathsToTrack(String path){
    if(_pathsToTrack.contains(path)){
      _pathsToTrack.remove(path);
    }
    else{
      _pathsToTrack.add(path);
    }
    this.update();
  }

  bool pathIsSelected(String path){
    if(_pathsToTrack.contains(path)){
      return true;
    }
    return false;
  }

  Future<String> generateUniqueCryptPath(String path)async{
    String newPath;
    while(true){
      newPath = await this.generateCryptPathFromOriginal(path);
      if(await this.cryptPathExists(newPath) == false){
        break;
      }
    }
    print('new path '+newPath);
    return newPath;
  }

  Future<bool> cryptPathExists(String path)async{
    List<Map<String,dynamic>> results = await dbService.db.query('hidden_files',
      where:'hidden_path = ?',whereArgs:[path]);
    if(results.length > 0){
      return true;
    }
    return false;
  }
  Future<bool> originalPathExists(String path)async{
    List<Map<String,dynamic>> results = await dbService.db.query('hidden_files',
      where:'original_path = ?',whereArgs:[path]);
    if(results.length > 0){
      return true;
    }
    return false;
  }
  
  Future<void> onTrackSelected()async{
    try{
      this.setLoading(true);
      if(this._pathsToTrack.length > 0){
        Key key = appService.encryptionKey;
        Encrypter encrypter = new Encrypter(AES(key));
        IV iv = IV.fromLength(16);
        await Future.forEach(this._pathsToTrack,(String path)async{
          Encrypted encrypted = encrypter.encrypt(path,iv:iv);
          String encryptedText = encrypted.base64;
          if(await this.originalPathExists(encryptedText) == false){
            String cryptPath = await this.generateUniqueCryptPath(path);
            HiddenFileModel model = new HiddenFileModel(
              hiddenPath:cryptPath,originalPath:encryptedText,initialVector:iv.base64,
              createdAt:DateTime.now().toIso8601String(),hidden:0);
            int result = await dbService.db.insert('hidden_files',model.toMap());
            if(result == -1) throw new Exception('Failed to add new track files.');
          }
        });
      }
      await this.mController.loadTrackFiles();
      Get.until((route) => Get.currentRoute == '/');
      this.setLoading(false);
      this._pathsToTrack.clear();
    }
    catch(e){
      this.setLoading(false);
      getDialog(message:e.toString(),status:Status.error);
    }
  }

}