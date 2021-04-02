import 'dart:math';
import 'package:password_hash/password_hash.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:saivault/helpers/mixins/connection_mixin.dart';
import 'package:saivault/services/db_service.dart';
import 'package:saivault/services/key_service.dart';
import 'package:saivault/widgets/confirm_dialog.dart';
import 'package:saivault/widgets/dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:saivault/helpers/ad_manager.dart';
import 'package:saivault/config/app_constants.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:encrypt/encrypt.dart' as e;
import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';


class SetupController extends Controller with ConnectionMixin{
   KeyService keyService;
   bool _showPassword = false;
   TextEditingController _password;
   TextEditingController _confirmPassword;
   DBService dbService;
   TextEditingController get password => this._password;
   TextEditingController get confirmPassword => this._confirmPassword;
   final String setupInfo =
   "If this is not your first time using $APPNAME,\n"
   "You may have data backup from previous installations.\n\n"
   "To recover your data from previous installations, please select the RECOVER option.\n"
   "Otherwise, select the CONTINUE option to proceed with a new setup.";

   BannerAd bads;
   Completer<BannerAd> completer = new Completer<BannerAd>();

   @override 
   Future<void> onInit()async{
     this.keyService = Get.find<KeyService>();
     dbService = Get.find<DBService>();
     this._password = new TextEditingController();
     this._confirmPassword = new TextEditingController();
     if(await keyService.contains('encryption_key') == true) Get.offNamed('/login');
     this.bads = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      listener: AdListener(onAdLoaded: (Ad ad){completer.complete(ad as BannerAd);}),
      request: AdRequest(),
      size:AdSize.getSmartBanner(Orientation.landscape)
    );
    bads.load();
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
     await keyService.write('user_password',secondHash);
     print('password set');
     Get.offNamed('/login');
   }
    Future<String> generateFirstPassHash() async {
       PBKDF2 hasher = new PBKDF2();
       String salt = Salt.generateAsBase64String(6);
       String hash = hasher.generateBase64Key(this._password.text, salt,1000,16);
       await keyService.write('password_salt',salt);
       return hash;
    }
    
    Future<void> encryptAndSaveKey(String data,passHash) async {
     e.Key key = e.Key.fromBase64(passHash);
     e.IV iv = e.IV.fromLength(16);
     final encrypter = e.Encrypter(e.AES(key));
     e.Encrypted encrypted = encrypter.encrypt(data,iv:iv);
     await keyService.write('encryption_key',encrypted.base64);
     await keyService.write('encryption_key_iv',iv.base64);
     return;
   }
   String generateSecondPassHash(String passHash){
     List<int> bytes = utf8.encode(passHash);
     Digest digest = sha256.convert(bytes);
     return digest.toString();
   }

   void onSetup() async {
     bool result = await confirmDialog(message:this.setupInfo,okLabel:'CONTINUE',cancelLabel:'RECOVER');
     if(result != null){
       if(result == true){
         await this.savePassword();
       } else {
         await this.onDataRecovery();
       }
     }
   }

   String generateEncryptionKey(){
     Random rand = Random.secure();
     List<int> values = List<int>.generate(32,(i)=>rand.nextInt(256));
     String crypto = base64Url.encode(values);
     return crypto;
   }

   Future<void> onDataRecovery({bool connectionWarning = true}) async {
     try{
       this.setLoading(true);
       if(await this.isConnectedToInternet() == false){
         if(connectionWarning == true){
            getDialog(message:'Sorry, you do not have an intenet connection.',status:Status.error);
         }
         this.setLoading(false);
         return;
       }
       await dbService.restoreDatabaseFromDrive();
       if(await keyService.contains('encryption_key') == true) Get.offNamed('/login');
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
     bads?.dispose();
     super.onClose();
   }

}