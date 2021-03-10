import 'package:get/get.dart';
import 'package:encrypt/encrypt.dart';
import 'package:saivault/config/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppService extends GetxService{
  Key _encryptionKey;
  SharedPreferences _pref;
  Key get encryptionKey => this._encryptionKey;
  SharedPreferences get pref => this._pref;
  
  Future<AppService> init() async {
    this._pref= await SharedPreferences.getInstance();
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
  
}