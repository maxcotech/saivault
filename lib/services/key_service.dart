import 'package:get/get.dart';
import 'package:saivault/models/key_model.dart';
import 'package:saivault/services/db_service.dart';
import 'package:sqflite/sqlite_api.dart';

class KeyService extends GetxService{
  Database _db;
  Database get db => this._db;
  @override 
  void onInit(){
    DBService dbService = Get.find<DBService>();
    this._db = dbService.db;
    super.onInit();
  }
  Future<bool> contains(String key) async {
    List<Map<String,dynamic>> results = await db.query('key_store',where:'key_label = ?',whereArgs:[key]);
    if(results.length > 0){
      return true;
    }else{
      return false;
    }
  }
  Future<int> write(String key,dynamic value)async{
    int result;
    DateTime currentTime = new DateTime.now();
    KeyModel model = new KeyModel(keyValue:value,keyLabel:key,createdAt:currentTime.toIso8601String());
    if(await this.contains(key)){
      result = await db.update('key_store',<String,dynamic>{
        'key_label':key,'key_value':value},where:'key_label = ?',whereArgs:[key]);
    }else{
      result = await db.insert('key_store',model.toMap());
    }
    return result;
  }
  Future<String> read(String key) async {
    List<Map<String,dynamic>> result = await db.query('key_store',
    where:'key_label = ?',whereArgs:[key],limit:1);
    if(result.length > 0){
      return result[0]['key_value'];
    }else{
      return null;
    }
  }
  Future delete(String key) async {
    return await db.delete('key_store',where:'key_label = ?',whereArgs:[key]);
  }

}