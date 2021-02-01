import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class StorageService extends GetxService{
  FlutterSecureStorage _store;
  FlutterSecureStorage get store => this._store;
  StorageService init(){
     this._store = new FlutterSecureStorage();
     return this;
  }
  Future<bool> contains(String key) async {
    try{
      String result = await _store.read(key:key);
      if(result == null){
        return false;
      }else{
        return true;
      }
    }
    on PlatformException {
      return false;
    }
  }
  Future<String> read(String key) async {
    try{
      String result =await _store.read(key:key);
      return result;
    }
    on PlatformException {
      return null;
    }
  }
  Future<void> write(String key,String value) async {
    await _store.write(key:key,value:value);
  }
  Future<Map<String,String>> readAll() async {
    return await _store.readAll();
  }
  Future<void> deleteAll() async {
     await _store.deleteAll();
  }

}