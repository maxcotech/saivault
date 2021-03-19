import 'package:flutter/widgets.dart' show TextEditingController;
import 'package:saivault/controllers/controller.dart';
import 'package:saivault/controllers/password_manager_controller.dart';
import 'package:saivault/controllers/settings_controller.dart';
import 'package:saivault/helpers/mixins/connection_mixin.dart';
import 'package:saivault/models/password_model.dart';
import 'package:saivault/services/app_service.dart';
import 'package:saivault/services/db_service.dart';
import 'package:saivault/services/key_service.dart';
import 'package:saivault/widgets/dialog.dart';
import 'package:get/get.dart';
import 'package:encrypt/encrypt.dart';

class AddPasswordController extends Controller with ConnectionMixin{
  TextEditingController _passwordLabel;
  TextEditingController _passwordValue;
  PasswordManagerController pmController;
  SettingsController settings;
  bool _showPassword = false;
  DBService dbService;
  KeyService store;
  AppService appService;
  TextEditingController get passwordLabel => this._passwordLabel;
  TextEditingController get passwordValue => this._passwordValue;
  bool get showPassword => this._showPassword;
  @override 
  void onInit(){
    
    _passwordLabel = new TextEditingController();
    _passwordValue = new TextEditingController();
    pmController = Get.find<PasswordManagerController>();
    dbService = Get.find<DBService>();
    store = Get.find<KeyService>();
    appService = Get.find<AppService>();
    super.onInit();
  }
  void togglePasswordVisibility(){
    _showPassword = !_showPassword;
    this.update();
  }
  @override 
  void onClose(){
    _passwordLabel.dispose();
    _passwordValue.dispose();
  }
  Future<bool> validateInputs() async {
    if(this._passwordLabel.text.isEmpty || this._passwordLabel.text == ""){
      getDialog(message:'Password Label is required',status:Status.error);
      return false;
    }
    if(this._passwordValue.text.isEmpty || this._passwordValue.text == ""){
      getDialog(message:'Password is required',status:Status.error);
      return false;
    }
    if(await this.labelExists()){
      getDialog(message:'Password Label already exists, please use unique labels as it will help you to easily retrieve your passwords subsequently.',status:Status.error);
      return false;
    }
    return true;
  }
  Future<bool> labelExists() async {
    String passLabel = this._passwordLabel.text;
    List<Map<String,dynamic>> results = await dbService.db.query('password_store',
    where:'password_label = ?',whereArgs:[passLabel]);
    if(results.length > 0){
      return true;
    }
    return false;
  }
  Future<int> encryptAndSavePassword() async {
    if(appService.encryptionKey == null) Get.toNamed('/login');
    IV iv = IV.fromLength(16);
    Key key = appService.encryptionKey;
    Encrypter encrypter = new Encrypter(AES(key));
    Encrypted encryptedPass = encrypter.encrypt(_passwordValue.text,iv:iv);
    DateTime currentTime = DateTime.now();
    PasswordModel model = new PasswordModel(
      passwordLabel:_passwordLabel.text,passwordValue:encryptedPass.base64,
      initialVector:iv.base64,createdAt:currentTime.toIso8601String()
    );
    int result = await dbService.db.insert('password_store',model.toMap());
    print(result.toString());
    return result;
  }
  Future onSavePassword() async{
    try{
      this.setLoading(true);
      if(await this.validateInputs() != true){
        this.setLoading(false); return;
      }
      int result = await this.encryptAndSavePassword();
      if(result != -1){
       await pmController.loadSavedPasswords();
       getDialog(message:'Your new password was saved successfully.',status:Status.success);
      _passwordValue.clear();
      _passwordLabel.clear();
       if(await this.isConnectedToInternet()){
          this.settings = Get.find<SettingsController>();
          await this.settings.backupDatabase();
          Get.rawSnackbar(message:'Backup data successfully updated.',duration:Duration(seconds:3));
        } 
      }
      else{getDialog(message:'An error occurred, could not save your password.',status:Status.error);}
      this.setLoading(false);
    }
    catch(e){
      this.setLoading(false);
      getDialog(message:e.toString(),status:Status.error);
    }
  }
  
}