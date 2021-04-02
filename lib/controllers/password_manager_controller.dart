import 'package:encrypt/encrypt.dart' as e;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:saivault/config/app_constants.dart';
import 'package:saivault/controllers/controller.dart';
import 'package:saivault/helpers/ad_manager.dart';
import 'package:saivault/models/password_model.dart';
import 'package:saivault/services/app_service.dart';
import 'package:saivault/services/db_service.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:get/get.dart';
import 'dart:async';
import 'package:saivault/services/password_generator_service.dart';
import 'package:saivault/widgets/confirm_dialog.dart';
import 'package:saivault/widgets/dialog.dart';
import 'package:saivault/helpers/isolate_helpers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PasswordManagerController extends Controller{
  List<PasswordModel> _savedPasswords = new List<PasswordModel>();
  TextEditingController pLengthControl;
  TextEditingController generatedPassControl;
  PasswordGeneratorService pService;
  DBService dbService;
  AppService appService;
  
  List<PasswordModel> get savedPasswords => this._savedPasswords;
  BannerAd bads;
  Completer<BannerAd> completer = new Completer<BannerAd>();

  @override 
  Future<void> onInit()async {
    dbService = Get.find<DBService>();
    appService = Get.find<AppService>();
    this.pService = new PasswordGeneratorService();
    this.pLengthControl = new TextEditingController(text:pService.getPassLength().toString());
    this.generatedPassControl = new TextEditingController();
    this.pLengthControl.addListener(this.setPassLength);
    await this.loadSavedPasswords();
    this.bads = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      listener: AdListener(onAdLoaded: (Ad ad){completer.complete(ad as BannerAd);}),
      request: AdRequest(),
      size:AdSize.getSmartBanner(Orientation.landscape)
    );
    this.bads.load();
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
     e.Key decryptKey = appService.encryptionKey;
     print(model.createdAt);
     if(model.initialVector == null || model.passwordValue == null){
       return "";
     }
     e.IV iv = e.IV.fromBase64(model.initialVector);
     e.Encrypter encrypter = new e.Encrypter(e.AES(decryptKey));
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

   Future setShouldHaveNumerals(bool val) async {
    await this.pService.setShouldHaveNumerals(val);
    this.update();
  }
  Future setShouldHaveNonAlphaNumerals(bool val) async {
    await this.pService.setShouldHaveNonAlphaNumerals(val);
    this.update();
  }
  Future setShouldHaveUpperAlpha(bool val) async {
    await this.pService.setShouldHaveUpperAlpha(val);
    this.update();
  }
  Future setShouldHaveLowerAlpha(bool val) async {
    await this.pService.setShouldHaveLowerAlpha(val);
    this.update();
  }
  Future setPassLength() async {
    await this.pService.setPassLength(int.tryParse(this.pLengthControl.text));
    this.update();
  }
  void copyGeneratedPassword(){
    Clipboard.setData(new ClipboardData(text:this.generatedPassControl.text));
    Get.rawSnackbar(message:'Password copied to clipboard.',duration:Duration(seconds:3));
  }

  void onSavePassword(){
    if(this.generatedPassControl.text.isNotEmpty){
      Get.offNamed("/add_password",arguments:this.generatedPassControl.text);
    } else {
      Get.rawSnackbar(message:'No password to change.',duration:Duration(seconds:3));
    }
  }
  
  void generatePassword(){
    try{
      PasswordGeneratorService pService = new PasswordGeneratorService();
      if(pService.getPassLength() > MAX_PASSWORD_LENGTH){
        getDialog(
          status:Status.error,
          message:'Chief, Your password length cannot be greater than $MAX_PASSWORD_LENGTH, for obvious reasons.');
        return;
      }
      this.generatedPassControl.text = pService.generatePassword();
    }
    catch(e,stack){
      print(stack.toString());
      getDialog(message:"Sorry, unable to generate password, please try again.",status:Status.error);
      print(e.toString());
    }
  }
  
  @override 
  void onClose(){
    this.pLengthControl.removeListener(this.setPassLength);
    this.pLengthControl.dispose();
    this.generatedPassControl.dispose();
    bads?.dispose();
    super.onClose();
  }
}