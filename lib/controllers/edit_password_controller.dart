import 'package:encrypt/encrypt.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:get/get.dart';
import 'package:saivault/controllers/password_manager_controller.dart';
import 'package:saivault/controllers/settings_controller.dart';
import 'package:saivault/helpers/mixins/connection_mixin.dart';
import 'package:saivault/models/password_model.dart';
import 'package:flutter/material.dart' show TextEditingController;
import 'package:saivault/services/app_service.dart';
import 'package:saivault/services/db_service.dart';
import 'package:saivault/widgets/dialog.dart';

class EditPasswordController extends Controller with ConnectionMixin{
  PasswordModel model;
  SettingsController settings;
  TextEditingController _label;
  TextEditingController _password;
  TextEditingController get label => this._label;
  TextEditingController get password => this._password;
  AppService appService;
  DBService dbService;
  PasswordManagerController pmanager;
  @override 
  void onInit(){
    this.model = Get.arguments as PasswordModel;
    if(model == null || model.id == null) Get.back();
    pmanager = Get.find<PasswordManagerController>();
    _label = new TextEditingController(text:this.model.passwordLabel);
    _password = new TextEditingController(text:pmanager.decryptPassword(this.model));
    appService = Get.find<AppService>();
    dbService = Get.find<DBService>();
    super.onInit();
  }
  Future<void> onSubmit()async{
    try{
      this.setLoading(true);
      if(await this.validateInputs() == false){
        this.setLoading(false);return;
      } 
      IV iv = IV.fromSecureRandom(10);
      Key key = appService.encryptionKey;
      Encrypter encrypter = new Encrypter(AES(key));
      Encrypted encrypted = encrypter.encrypt(_password.text,iv:iv);
      String cryptString = encrypted.base64;
      String ivString = iv.base64;
      int result = await dbService.db.update('password_store',
      this.getPasswordPayload(ivString,cryptString),where:'id = ?',whereArgs:[this.model.id]);
      if(result != -1){
        getDialog(message:'Password Successfully edited',status:Status.success);
        await pmanager.loadSavedPasswords();
        if(await this.isConnectedToInternet()){
          this.settings = Get.find<SettingsController>();
          await this.settings.backupDatabase();
          Get.rawSnackbar(message:'Backup data successfully updated.',duration:Duration(seconds:3));
        } 
      }
      this.setLoading(false);
    }
    catch(e){
      this.setLoading(false);
      getDialog(message:e.toString(),status:Status.error);
    }
  }
  Map<String,dynamic> getPasswordPayload(String iv, String pass){
    PasswordModel pmodel = new PasswordModel(
      initialVector: iv,passwordValue:pass,
      passwordLabel: _label.text
    );
    return pmodel.toMap();
  }
  Future<bool> labelExists()async{
    List<Map<String,dynamic>> results = await dbService.db.query(
      'password_store',where:'id != ? and password_label = ?',
      whereArgs:[this.model.id,_label.text]);
    if(results.length > 0){
      return true;
    }
    return false;
  }
  Future<bool> validateInputs()async{
    if(_password.text.isEmpty){
      getDialog(message:'Password is required',status:Status.error);
      return false;
    }
    if(_label.text.isEmpty){
      getDialog(message:'Password label is required',status:Status.error);
      return false;
    }
    if(await this.labelExists()){
      getDialog(message:'Password label already exists, please use unique labels as they will help you to easily retrieve your passwords subsequently.',status:Status.info);
      return false;
    }
    return true;
  }
  @override 
  void onClose(){
    _label.dispose();
    _password.dispose();
  }

}