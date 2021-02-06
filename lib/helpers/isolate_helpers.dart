import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:saivault/models/password_model.dart';
import 'package:saivault/models/hidden_file_model.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:io';
import 'package:cryptography_flutter/cryptography.dart';

List<PasswordModel> serializeListToPasswordModels(dynamic results){
  List<PasswordModel> passwordModels = new List<PasswordModel>();
  results.forEach((item){
    passwordModels.add(PasswordModel.fromMap(item));
  });
  return passwordModels;
}
List<HiddenFileModel> serializeAndDecryptListToHiddenFileModels(dynamic payload){
  List<HiddenFileModel> hiddenFileModels = new List<HiddenFileModel>();
  List<Map<String,dynamic>> results = payload['result'] as List<Map<String,dynamic>>;
  Key key = payload['key'] as Key;
  if(results.length > 0){
    Encrypter encrypter = new Encrypter(AES(key));
    results.forEach((Map<String,dynamic> obj){
      Map<String,dynamic> item = Map<String,dynamic>.from(obj);
      IV iv = IV.fromBase64(item['initial_vector']);
      item['original_path'] = encrypter.decrypt64(item['original_path'],iv:iv);
      hiddenFileModels.add(HiddenFileModel.fromMap(item));
    });
  }
  return hiddenFileModels;
  
}

Future<bool> encryptAndHideFile(dynamic payload)async{
  try{
    File sourceFile = new File(payload['source_path']);
    File desFile = new File(payload['des_path']);
    Nonce nonce = new Nonce(base64Url.decode(payload['iv_string']).toList());
    SecretKey key = new SecretKey(base64Url.decode(payload['key']).toList());
    CipherWithAppendedMac cipher = CipherWithAppendedMac(aesCbc, Hmac(sha256));
    if(await sourceFile.exists() == false) return false;
    if(await desFile.exists() == false) await desFile.create(recursive:true);
    IOSink sink = desFile.openWrite();
    Stream<List<int>> stream = sourceFile.openRead();
    await for(List<int> data in stream){
      Uint8List encrypted = await cipher.encrypt(data,nonce:nonce,secretKey:key);
      sink.add(encrypted.toList());
    }
    print('entity encryption completed');
    await sink.flush();
    await sink.close();
    await sourceFile.delete();
    return true;
  }
  catch(e){
    print(e.toString());
    return false;
  }
  
}

Future<bool> decryptAndRestoreFile(dynamic payload)async{
  try{
    File sourceFile = new File(payload['source_path']);
    File desFile = new File(payload['des_path']);
    Nonce nonce = new Nonce(base64Url.decode(payload['iv_string']).toList());
    SecretKey key = new SecretKey(base64Url.decode(payload['key']).toList());
    CipherWithAppendedMac cipher = CipherWithAppendedMac(aesCbc,Hmac(sha256));
    if(await sourceFile.exists() == false) return false;
    if(await desFile.exists() == false) desFile.create(recursive:true);
    IOSink sink = desFile.openWrite();
    Stream<List<int>> stream = sourceFile.openRead();
    await for(List<int> data in stream){
      Uint8List decrypted = await cipher.decrypt(data, secretKey: key, nonce: nonce);
      sink.add(decrypted.toList());
    }
    await sink.flush();
    await sink.close();
    await sourceFile.delete();
    return true;
  }
  catch(e){
    print(e.toString());
    return false;
  }
  
}