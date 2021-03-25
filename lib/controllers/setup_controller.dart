import 'dart:math';
import 'package:password_hash/password_hash.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:saivault/helpers/mixins/connection_mixin.dart';
import 'package:saivault/services/key_service.dart';
import 'package:saivault/widgets/dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as e;
import 'dart:convert';
import 'package:saivault/config/app_constants.dart';
import 'package:saivault/services/drive_services.dart';
import 'package:get/get.dart';

class SetupController extends Controller with ConnectionMixin{
   KeyService keyService;
   bool _showPassword = false;
   TextEditingController _password;
   TextEditingController _confirmPassword;
   KeyService _store;
   TextEditingController get password => this._password;
   TextEditingController get confirmPassword => this._confirmPassword;

   @override 
   Future<void> onInit()async{
     keyService = Get.find<KeyService>();
     this._password = new TextEditingController();
     this._confirmPassword = new TextEditingController();
     if(await keyService.contains('encryption_key') == true) Get.offNamed('/login');
     this._store = Get.find<KeyService>();
     super.onInit();
   }
   bool get showPassword => this._showPassword;
   void togglePasswordVisibility(bool val){
     this._showPassword = val;
     this.update();
   }
   Future<void> savePassword() async {
     if(!this.validateInputs()) return;
     String randKey = this.generateEncryptionKey();
     String passHash =await this.generateFirstPassHash();
     await this.encryptAndSaveKey(randKey,passHash);
     String secondHash = this.generateSecondPassHash(passHash);
     await _store.write('user_password',secondHash);
     print('password set');
     Get.offNamed('/login');
   }
    Future<String> generateFirstPassHash() async {
       PBKDF2 hasher = new PBKDF2();
       String salt = Salt.generateAsBase64String(6);
       String hash = hasher.generateBase64Key(this._password.text, salt,1000,16);
       await _store.write('password_salt',salt);
       return hash;
    }
    
    Future<void> encryptAndSaveKey(String data,passHash) async {
     e.Key key = e.Key.fromBase64(passHash);
     e.IV iv = e.IV.fromLength(16);
     final encrypter = e.Encrypter(e.AES(key));
     e.Encrypted encrypted = encrypter.encrypt(data,iv:iv);
     await _store.write('encryption_key',encrypted.base64);
     await _store.write('encryption_key_iv',iv.base64);
     return;
   }
   String generateSecondPassHash(String passHash){
     List<int> bytes = utf8.encode(passHash);
     Digest digest = sha256.convert(bytes);
     return digest.toString();
   }

   String generateEncryptionKey(){
     Random rand = Random.secure();
     List<int> values = List<int>.generate(32,(i)=>rand.nextInt(256));
     String crypto = base64Url.encode(values);
     return crypto;
   }

   Future<void> onDataRecovery() async {
     try{
       this.setLoading(true);
       if(await this.isConnectedToInternet() == false){
         getDialog(message:'Sorry, you do not have an intenet connection.',status:Status.error);
         this.setLoading(false);
         return;
       }
       var dService = await DriveServices().init();
       var fileId = await dService.getIdOfNamedFile(DATABASE_NAME);
       if(fileId != null){
         var result = await dService.downloadDatabaseFile(fileId);
         if(result != null && await result.exists()){
           Get.rawSnackbar(message:'Data recovery successful.',duration: Duration(seconds:2));
           Get.toNamed('/login');
         } else {
          getDialog(message:'Could not restore app data, please try again.',status:Status.error);
         }
       } else {
         getDialog(message:'Sorry, could not find any previously backedup data file.',status:Status.error);
       }
       this.setLoading(false);
     }
     catch(e,stack){
       this.setLoading(false);
       getDialog(message:e.toString(),status:Status.error);
       print(stack.toString());
       print(e.toString());
     }
   }

   bool validateInputs(){
     if(this._password.text.isEmpty || this._password.text == ""){
       getDialog(message:"Password is required",status:Status.error);
       return false;
     }
     if(this._password.text.length < 8){
       getDialog(message:"Password must be longer than 8 characters",status:Status.error);
       return false;
     }
     if(this._confirmPassword.text.isEmpty || this._confirmPassword.text == ""){
       getDialog(message:"Password confirmation is required",status:Status.error);
       return false;
     }
     if(this._confirmPassword.text != this._password.text){
       getDialog(message:"Password does not match",status:Status.error);
       return false;
     }
     return true;
   }
   @override 
   void onClose(){
     _password.dispose();
     _confirmPassword.dispose();
     super.onClose();
   }

}