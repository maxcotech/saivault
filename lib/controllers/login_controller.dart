import 'package:flutter/widgets.dart';
import 'package:password_hash/pbkdf2.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:saivault/services/app_service.dart';
import 'package:saivault/services/key_service.dart';
import 'package:saivault/widgets/dialog.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as e;

class LoginController extends Controller{
  TextEditingController _password = new TextEditingController();
  bool _showPassword = false;
  AppService _appService;
  KeyService _store;
  bool get showPassword => this._showPassword;
  AppService get appService => this._appService;
  KeyService get store => this._store;
  TextEditingController get password => this._password;
  @override 
  Future<void> onInit()async{
    _appService = Get.find<AppService>();
    _store = Get.find<KeyService>();
    if(await _store.contains('encryption_key') == false) Get.offNamed('/setup');
    super.onInit();
    return;
  }
  void togglePasswordVisibility(){
    this._showPassword = !this._showPassword;
    this.update();
  }
  bool validateInput(){
    if(this._password.text.isEmpty || this._password.text == ""){
      getDialog(message:'Password is required',status:Status.error);
      return false;
    }
    return true;
  }
  String generateFirstPassHash(String salt,String pass){
    PBKDF2 hasher = new PBKDF2();
    String hash = hasher.generateBase64Key(pass, salt,1000,16);
    return hash;
  }

  bool isPasswordCorrect(String inputHash,String passwordHash){
    List<int> bytes = utf8.encode(inputHash);
    Digest digest = sha256.convert(bytes);
    if(digest.toString() != passwordHash){
      return false;
    }
    return true;
  }
  Future<void> decryptAndPersistEncKey(String inputHash) async {
    String ivString = await _store.read('encryption_key_iv');
    String encEncryptionKey = await _store.read('encryption_key');
    if(ivString == null || encEncryptionKey == null){
      Get.offNamed('/setup');
      return;
    }
    e.Key decryptionKey = e.Key.fromBase64(inputHash);
    e.IV iv = e.IV.fromBase64(ivString);
    e.Encrypter encrypter = new e.Encrypter(e.AES(decryptionKey));
    e.Encrypted encKeyObj = e.Encrypted.fromBase64(encEncryptionKey);
    String decryptedKey = encrypter.decrypt(encKeyObj,iv:iv);
    if(decryptedKey != null){
      _appService.setAppEncryptionKey(decryptedKey);
    }else{
      throw new Exception('Failed to decrypt app encryption key');
    }

  }

  Future<void> onLogin()async{
     try{
      if(!this.validateInput()) return;
      String passwordHash = await _store.read('user_password');
      String passwordSalt = await _store.read('password_salt');
      if(passwordHash == null || passwordSalt == null){
        Get.offNamed('/setup');
        return;
      }
      String inputHash = this.generateFirstPassHash(passwordSalt,this._password.text);
      if(!this.isPasswordCorrect(inputHash,passwordHash)){
        getDialog(message:"The password you entered is incorrect.",status:Status.error);
        return;
      }
      await this.decryptAndPersistEncKey(inputHash);
      Get.offNamed('/');
    }
    catch(e){
      getDialog(message:e.toString(),status:Status.error);
    }
  }
  @override 
  void onClose(){
    _password.dispose();
    super.onClose();
  }

}