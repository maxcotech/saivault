import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:path/path.dart';
import 'package:saivault/services/app_service.dart';
import 'package:uuid/uuid.dart';

mixin PathMixin{
  /**
   * /data/user/0/com.example.saivault/app_flutter/.storage.hider/.emulated.hider/.0.hider/.DCIM.hider/.Camera.hider/7c2b2965-e471-4715-95fd-8e7522c15654.aes
   * /storage/emulated/0/.maxwell/recovery_path/.storage.hider/.emulated.hider/.0.hider/.DCIM.hider
   */
  
  Future<String> extractCryptPath(String path)async{
    List<String> segments = path.split('/');
    int indexOfRecovery = this.getIndexOfRecoveryPath(segments);
    if(indexOfRecovery != null){
      List<String> newSegments = new List<String>();
      int counter = indexOfRecovery;
      while(counter < segments.length){
        newSegments.add(segments[counter]);
        counter++;
      }
      String newPath = newSegments.join('/');
      return newPath;
    }else{
      return null;
    }
    
  }
  Future<String> getRemovableStoragePath() async {
    List<StorageInfo> storageInfos = await PathProviderEx.getStorageInfo();
    if(storageInfos != null && storageInfos.length > 0){
      int len = storageInfos.length;
      return storageInfos[len - 1].rootDir;
    } else {
      return "/storage/emulated/0";
    }
  }

  Future<String> removeRootFromPath(String path) async {
    String newPath = path;
    String rootDir = await getPathStorageDir(newPath);
    if(rootDir != null){
      String entityPath = newPath.replaceFirst(rootDir,"");
      if(entityPath.startsWith('/')) entityPath = entityPath.replaceFirst('/','');
      return entityPath;
    }
    return null;
  }

  Future<String> getStoragePathByEntity(String entityPath) async {
    List<StorageInfo> storageInfos = await PathProviderEx.getStorageInfo();
    for(var info in storageInfos){
      if(entityPath.startsWith(info.rootDir)){
        return info.rootDir;
      }
    }
    return storageInfos[storageInfos.length - 1].rootDir;
  }

  int getIndexOfRecoveryPath(List<String> segments){
    int counter = 0;
    while(counter < segments.length){
      if(segments[counter] == 'recovery_path'){
        return counter;
      }
      counter++;
    }
    return null;
  }
  Future<String> generateCryptPathFromOriginal(String path, AppService appService)async{
    if(path.isEmpty) return null;
    String prefixPath = await this.encryptedFilePath(appService.getStorageLocationIndex());
    List<String> segments = path.split('/');
    List<String> newSegments = new List<String>();
    segments.forEach((String item){
      if(item == segments.last){
        List<String> itemSegs = item.split(".");
        if(itemSegs.length == 1){
          if(item.isNotEmpty) newSegments.add("."+item+".hider");
        }else{
          newSegments.add(this.generateUuidString()+".aes");
        }
      }else{
        if(item.isNotEmpty && item != " "){
          newSegments.add("."+item+".hider");
        }
      }
    });
    String newPath = newSegments.join('/');
    return join(prefixPath,newPath);
  }
  Future<String> encryptedFilePath(int storageIndex)async{
    List<StorageInfo> info = await PathProviderEx.getStorageInfo();
    String externalRoot = info[storageIndex].rootDir;
    String appExternalPath = '.maxwell/recovery_path';
    return join(externalRoot,appExternalPath);
  }
  String generateUuidString(){
    Uuid uuid = new Uuid();
    return uuid.v4();
  }

  Future<String> getPathStorageDir(String path) async {
    if(path == null || path.isEmpty) return null;
    List<StorageInfo> stores = await PathProviderEx.getStorageInfo();
    for(StorageInfo info in stores){
      if(path.contains(info.rootDir) && path.startsWith(info.rootDir)){
        return info.rootDir;
      }
    }
    return null;
  }

  bool fileNameContainsSpace(String path){
    ///checks if the file name contains space
    if(path == null || path.isEmpty) return false;
    if(path.contains('/')){
      String fileName = path.split('/').last;
      return fileName.contains(" ");
    } else {
      return path.contains(" ");
    }
  }

  String generateSpaceFreeFileName(String path,{String replaceWith:"_"}){
    ///generates file name where all space are replaced with the value of 
    ///replace with parameter.     
    String newFileName;
    if(path == null || path.isEmpty) return null;
    if(path.contains('/')){
      String fileName = path.split('/').last;
      newFileName = fileName.replaceAll(" ",replaceWith);
    } else {
      newFileName = path.replaceAll(" ",replaceWith);
    }
    if(newFileName == null) return null;
    if(newFileName.contains(new RegExp(r"[^a-zA-Z0-9\.\(\)_]"))) newFileName = newFileName.replaceAll(new RegExp(r"[^a-zA-Z0-9\.\(\)_]"),"");
    return newFileName;
  }
  
  String removeFileExtension(String path){
    if(path.contains(".")){
      List<String> segments = path.split(".");
      segments.removeAt(segments.length - 1);
      if(segments.length > 1){
        return segments.join(".");
      } else {
        return segments[segments.length - 1];
      }
    } else {
      return path;
    }
  }

  String replaceEntityOnPath(String path,String newEntityName){
    List<String> pathSegs = path.split('/');
    pathSegs.last = newEntityName;
    String newPath = pathSegs.join('/');
    return newPath;
  }

  


}