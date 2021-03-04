import 'package:encrypt/encrypt.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:saivault/models/password_model.dart';
import 'package:saivault/services/app_service.dart';
import 'package:saivault/services/db_service.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:get/get.dart';
import 'package:saivault/widgets/confirm_dialog.dart';
import 'package:saivault/widgets/dialog.dart';
import 'package:saivault/helpers/isolate_helpers.dart';

class PasswordManagerController extends Controller{
  List<PasswordModel> _savedPasswords = new List<PasswordModel>();
  DBService dbService;
  AppService appService;
  List<PasswordModel> get savedPasswords => this._savedPasswords;
  
  @override 
  Future<void> onInit()async {
    dbService = Get.find<DBService>();
    appService = Get.find<AppService>();
    await this.loadSavedPasswords();
    super.onInit();
  }
  Future<void> loadSavedPasswords() async {
    try{
      List<Map<String,dynamic>> results = await dbService.db.query('password_store');
      print(results);
      List<PasswordModel> passModels = await compute(serializeListToPasswordModels,results);
      this.setSavedPasswords(passModels);
    }
    catch(e){
      getDialog(message:e.toString(),status:Status.error);
    }
  }
  void setSavedPasswords(List<PasswordModel> passModels){
    this._savedPasswords = passModels;
    this.update();
  }
  String decryptPassword(PasswordModel model){
     Key decryptKey = appService.encryptionKey;
     print(model.createdAt);
     if(model.initialVector == null || model.passwordValue == null){
       return "";
     }
     IV iv = IV.fromBase64(model.initialVector);
     Encrypter encrypter = new Encrypter(AES(decryptKey));
     String result = encrypter.decrypt64(model.passwordValue,iv:iv);
     return result;
  }
  Future<int> deletePasswordById(int id)async{
    if(await confirmDialog(message:'Are you sure you wish to proceed with deleting this key record ?')  ){
      int result = await dbService.db.delete('password_store',where:'id = ?',whereArgs:[id]);
      await this.loadSavedPasswords();
      if(result != -1){
        Get.rawSnackbar(message:'Password Successfully deleted',duration:Duration(seconds:3));
      }
      return result;
    }
    return null;
  }
  Future<List<PasswordModel>> searchPasswords(String query)async{
    
    List<Map<String,dynamic>> results = await dbService.db.rawQuery(
      "SELECT * FROM password_store WHERE password_label LIKE '%$query%'"
    );
    List<PasswordModel> resultModels = await compute(serializeListToPasswordModels,results);
    return resultModels;
  }
  
  @override 
  void onClose(){
    super.onClose();
  }
}