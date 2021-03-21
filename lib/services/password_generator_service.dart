import 'dart:math';

import 'package:get/get.dart';
import 'package:saivault/services/app_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PasswordGeneratorService{
  AppService appService;
  SharedPreferences prefs;
  String generatedPassword = "";
  final int initialPasswordLength = 16;
  Map<String,List<String>> characters;
  
  PasswordGeneratorService(){
    this.appService = Get.find<AppService>();
    this.prefs = appService.pref;
    this.characters = <String,List<String>>{
      'numerals':["0","1","2","3","4","5","6","7","8","9"],   //0,4,
      'lower_alpha':["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"], //1,5,
      'upper_alpha':["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"], //2,6
      'non_alphanum':["!","#","%","^","&","*","_","-","+","=","?","<",">",".","@",":",";","~"] //3,7
    };
  }

  String generatePassCharacter(int gnum){
    if(gnum == 0 || gnum == 4){
      if(this.shouldHaveNumerals()){
        return this.getRandomItemFromList(this.characters['numerals']);
      }
    }
    if(gnum == 1 || gnum == 5){
      if(this.shouldHaveLowerAlpha()){
        return this.getRandomItemFromList(this.characters['lower_alpha']);
      }
    }
    if(gnum == 2 || gnum == 6){
      if(this.shouldHaveUpperAlpha()){
        return this.getRandomItemFromList(this.characters['upper_alpha']);
      }
    }
    if(gnum == 3 || gnum == 7){
      if(this.shouldHaveNonAlphaNumerals()){
        return this.getRandomItemFromList(this.characters['non_alphanum']);
      }
    }
    return null;
  }

  String getRandomItemFromList(List<String> items){
    Random rand = new Random();
    int len = items.length;
    int generatedIndex = rand.nextInt(len);
    return items.elementAt(generatedIndex);
  }

  bool shouldHaveUpperAlpha(){
    if(this.prefs.containsKey('pass_should_have_upper_alpha')){
      return this.prefs.getBool('pass_should_have_upper_alpha');
    } else {
      return true;
    }
  }
  bool shouldHaveLowerAlpha(){
    if(this.prefs.containsKey('pass_should_have_lower_alpha')){
      return this.prefs.getBool('pass_should_have_lower_alpha');
    } else {
      return true;
    }
  }

  bool shouldHaveNumerals(){
    if(this.prefs.containsKey('pass_should_have_numerals')){
      return this.prefs.getBool('pass_should_have_numerals');
    } else {
      return true;
    }
  }
  
  bool shouldHaveNonAlphaNumerals(){
    if(this.prefs.containsKey('pass_should_have_non_alpha_numerals')){
      return this.prefs.getBool('pass_should_have_non_alpha_numerals');
    } else {
      return true;
    }
  }

  int getPassLength(){
    if(this.prefs.containsKey('gen_password_length')){
      return this.prefs.getInt('gen_password_length');
    } else {
      return this.initialPasswordLength;
    }
  }

  bool isSettingValid(){
    if(this.shouldHaveLowerAlpha() == false && this.shouldHaveNonAlphaNumerals() == false &&
       this.shouldHaveUpperAlpha() == false && this.shouldHaveNumerals() == false){
      return false;
    }
    if(this.getPassLength() <= 0){
      return false;
    }
    return true;
  }

  bool isPasswordValid({String password}){
    String mpass = password != null? password:this.generatedPassword;
    if(mpass == null) return false;
    bool passedUpperAlpha = false;
    bool passedLowerAlpha = false;
    bool passedNonAlphaNum = false;
    bool passedNumeral = false;
    if(mpass.length < this.getPassLength()) return false;
    if(this.shouldHaveLowerAlpha()){
      for(var item in this.characters['lower_alpha']){
        if(mpass.contains(item)) passedLowerAlpha = true;
      }
    } else {
      passedLowerAlpha = true;
    }
    if(this.shouldHaveUpperAlpha()){
      for(var item in this.characters['upper_alpha']){
        if(mpass.contains(item)) passedUpperAlpha = true;
      }
    } else {
      passedUpperAlpha = true;
    }
    if(this.shouldHaveNonAlphaNumerals()){
      for(var item in this.characters['non_alphanum']){
        if(mpass.contains(item)) passedNonAlphaNum = true;
      }
    } else {
      passedNonAlphaNum = true;
    }
    if(this.shouldHaveNumerals()){
      for(var item in this.characters['numerals']){
        if(mpass.contains(item)) passedNumeral = true;
      }
    } else {
      passedNumeral = true;
    }
    if(passedUpperAlpha && passedLowerAlpha && passedNumeral && passedNonAlphaNum){
      return true;
    }
    return false;
    
  }
  bool isAllParametersExcluded(){
    if(this.shouldHaveNumerals() == false && this.shouldHaveNonAlphaNumerals() == false && 
       this.shouldHaveLowerAlpha() == false && this.shouldHaveUpperAlpha() == false){
       return true;
    } else {
      return false;
    }
  }

  Future<bool> setShouldHaveNumerals(bool val) async {
    return await this.prefs.setBool('pass_should_have_numerals',val);
  }
  Future<bool> setShouldHaveNonAlphaNumerals(bool val) async {
    return await this.prefs.setBool('pass_should_have_non_alpha_numerals',val);
  }
  Future<bool> setShouldHaveUpperAlpha(bool val) async {
    return await this.prefs.setBool('pass_should_have_upper_alpha',val);
  }
  Future<bool> setShouldHaveLowerAlpha(bool val) async {
    return await this.prefs.setBool('pass_should_have_lower_alpha',val);
  }
  Future<bool> setPassLength(int val) async {
    return await this.prefs.setInt('gen_password_length',val);
  }


  String generatePassword(){
    this.generatedPassword = "";
    int passLength = this.getPassLength();
    if(this.isAllParametersExcluded() || passLength == null || passLength <= 0){
      return "";
    }
    Random rand = new Random();
    print(passLength.toString());
    while(this.generatedPassword.length < passLength){
      int generatedIndex = rand.nextInt(8);
      String generatedChar = this.generatePassCharacter(generatedIndex);
      if(generatedChar != null){
        this.generatedPassword += generatedChar;
      }
    }
    return this.generatedPassword;
  }
}