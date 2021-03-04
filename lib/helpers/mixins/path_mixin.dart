import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:path/path.dart';
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
  Future<String> generateCryptPathFromOriginal(String path)async{
    if(path.isEmpty) return null;
    String prefixPath = await this.encryptedFilePath();
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
  Future<String> encryptedFilePath()async{
    List<StorageInfo> info = await PathProviderEx.getStorageInfo();
    String externalRoot = info[0].rootDir;
    String appExternalPath = '.maxwell/recovery_path';
    return join(externalRoot,appExternalPath);
  }
  String generateUuidString(){
    Uuid uuid = new Uuid();
    return uuid.v4();
  }
}