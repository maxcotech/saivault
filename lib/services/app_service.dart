import 'package:get/get.dart';
import 'package:encrypt/encrypt.dart';

class AppService extends GetxService{
  Key _encryptionKey;
  Key get encryptionKey => this._encryptionKey;
  void setAppEncryptionKey(String key){
    _encryptionKey = Key.fromBase64(key);
    
  }
}