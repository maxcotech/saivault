
import 'package:saivault/controllers/file_manager_controller.dart';

mixin NestedEntityMixin{
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
      if(result != -1){
        return true;
      }
      return false;
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
  

}