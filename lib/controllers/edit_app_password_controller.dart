import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:saivault/controllers/login_controller.dart';
import 'package:saivault/widgets/dialog.dart';
import 'package:get/get.dart';
import 'package:encrypt/encrypt.dart' as e;

class EditAppPasswordController extends LoginController{
  TextEditingController _password,_confirmPassword,_oldPassword;
  TextEditingController get password => this._password;
  TextEditingController get confirmPassword => this._confirmPassword;
  TextEditingController get oldPassword => this._oldPassword;

  @override
  Future<void> onInit() async {
    this._password = new TextEditingController();
    this._confirmPassword = new TextEditingController();
    this._oldPassword = new TextEditingController();
    await super.onInit();
  }
  bool validateInputs(){
    if(_oldPassword.text.isEmpty || _oldPassword.text == ""){
      getDialog(message:'Old password is required.',status:Status.error);
      return false;
    }
    if(_password.text.isEmpty || _password.text == ""){
      getDialog(message:'New password is required.',status:Status.error);
      return false;
    }
    if(_password.text.length < 8){
      getDialog(message:'Length of password must be greater than or equal to 8 characters.',status:Status.error);
      return false;
    }
    if(_confirmPassword.text.isEmpty || _confirmPassword.text == ""){
      getDialog(message:'New password confirmation is required.',status:Status.error);
      return false;
    }
    if(_confirmPassword.text != _password.text){
      getDialog(message:"New password and it's confirmation does not match.",status:Status.error);
      return false;
    }
    return true;
  }

  Future<void> encryptAndSaveKey(String data,passHash) async {
     e.Key key = e.Key.fromBase64(passHash);
     e.IV iv = e.IV.fromLength(16);
     final encrypter = e.Encrypter(e.AES(key));
     e.Encrypted encrypted = encrypter.encrypt(data,iv:iv);
     await this.store.write('encryption_key',encrypted.base64);
     await this.store.write('encryption_key_iv',iv.base64);
     return;
   }
   String generateSecondPassHash(String passHash){
     List<int> bytes = utf8.encode(passHash);
     Digest digest = sha256.convert(bytes);
     return digest.toString();
   }

   void clearInputs(){
     password.clear();
     confirmPassword.clear();
     oldPassword.clear();
   }

  Future<void> onSubmit() async {
    try{
      if(this.validateInputs()){
        this.setLoading(true);
        print('validation passed.');
        String userPassHash = await this.store.read('user_password');
        String passSalt = await this.store.read('password_salt');
        if(userPassHash == null || passSalt == null){ Get.offNamed('/setup');return;}
        String inputHash = this.generateFirstPassHash(passSalt,this._oldPassword.text);
        if(this.isPasswordCorrect(inputHash, userPassHash)){
            var appKey = appService.encryptionKey;
            String newPassHash = this.generateFirstPassHash(passSalt, this._password.text);
            await this.encryptAndSaveKey(appKey.base64,newPassHash);
            String secondHash = this.generateSecondPassHash(newPassHash);
            int res = await this.store.write('user_password',secondHash);
            if(res != -1) Get.rawSnackbar(message:'Your password was changed successfully.',duration:Duration(seconds:4));
            this.clearInputs();
            this.setLoading(false);
        } else {
          setLoading(false);
          getDialog(message:"The Old password you entered is invalid.",status:Status.error);
          return;
        }
        
      }
    }
    catch(e){
      print(e.toString());
      this.setLoading(false);
      getDialog(message:e.toString(),status:Status.error);
    }
  }




  @override
  void onClose() {
    this._password.dispose();
    this._oldPassword.dispose();
    this._confirmPassword.dispose();
    super.onClose();
  }

}