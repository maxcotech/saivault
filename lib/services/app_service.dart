import 'package:get/get.dart';
import 'package:encrypt/encrypt.dart';
import 'package:new_version/new_version.dart';
import 'package:saivault/config/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AppService extends GetxService{
  Key _encryptionKey;
  SharedPreferences _pref;
  Key get encryptionKey => this._encryptionKey;
  PackageInfo packageInfo;
  SharedPreferences get pref => this._pref;
  
  Future<AppService> init() async {
    this._pref= await SharedPreferences.getInstance();
    this.packageInfo = await PackageInfo.fromPlatform();
    return this;
  }
  void setAppEncryptionKey(String key){
    _encryptionKey = Key.fromBase64(key);
  }
  
  int getStorageLocationIndex() {
    if(pref.containsKey(STORAGE_KEY)){
      return pref.get(STORAGE_KEY);
    } else {
      return INITIAL_STORAGE_LOCATION_INDEX;
    }
  }
  Future<bool> setStorageLocationIndex(int value) async {
    return await pref.setInt(STORAGE_KEY, value);
  }
  bool shouldShowPathOnBrowser(){
    if(pref.containsKey(SHOW_ENTITY_PATH_ON_BROWSER)){
      return pref.get(SHOW_ENTITY_PATH_ON_BROWSER);
    } else {
      return true;
    }
  }
  bool shouldShowPathOnManager(){
    if(pref.containsKey(SHOW_ENTITY_PATH_ON_MANAGER)){
      return pref.get(SHOW_ENTITY_PATH_ON_MANAGER);
    } else {
      return false;
    }
  }
  bool shouldAutoBackup(){
    if(pref.containsKey(SHOULD_AUTO_BACKUP)){
      return pref.get(SHOULD_AUTO_BACKUP);
    } else {
      return true;
    }
  }

  void launchUrl(String url) async {
    if(await canLaunch(url)){
      await launch(url,enableJavaScript: true);
    }
  }
  void checkNewAppUpdate() async {
    final newVersion = new NewVersion(context: Get.context);
    newVersion.showAlertIfNecessary();
  }

  bool isDarkThemeMode(){
    if(pref.containsKey(THEME_MODE)){
      return pref.get(THEME_MODE);
    } else {
      return true;
    }
  }
  
  
  Future<bool> setThemeMode(bool val) async {
    return await pref.setBool(THEME_MODE,val);
  }

  Future<bool> setShouldShowPathOnBrowser(bool value) async {
    return await pref.setBool(SHOW_ENTITY_PATH_ON_BROWSER,value);
  }
  Future<bool> setShouldShowPathOnManager(bool value) async {
    return await pref.setBool(SHOW_ENTITY_PATH_ON_MANAGER,value);
  }
  Future<bool> setShouldAutoBackup(bool value) async {
    return await pref.setBool(SHOULD_AUTO_BACKUP,value);
  }
  

  
  
  
}