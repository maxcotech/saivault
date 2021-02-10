import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:saivault/models/password_model.dart';
import 'package:saivault/models/hidden_file_model.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:io';
import 'package:cryptography/cryptography.dart';

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
    //CipherWithAppendedMac cipher = CipherWithAppendedMac(aesCtr, Hmac(sha256));
    if(await sourceFile.exists() == false) return false;
    if(await desFile.exists() == false) await desFile.create(recursive:true);
    //IOSink sink = desFile.openWrite();
    //Stream<List<int>> stream = sourceFile.openRead();
    var sourceFileData = await sourceFile.readAsBytes();
    DateTime beforeenc = DateTime.now();
    /*await for(List<int> data in stream){
      Uint8List encrypted = await chacha20Poly1305Aead.encrypt(data,nonce:nonce,secretKey:key);
      sink.add(encrypted.toList());
    }*/
    Uint8List encrypted = await chacha20Poly1305Aead.encrypt(sourceFileData,nonce:nonce,secretKey:key);
    await desFile.writeAsBytes(encrypted);
    Duration duration = DateTime.now().difference(beforeenc);
    print('Entity encryption completed in '+ duration.inMilliseconds.toString()+' milliseconds');
    /*await sink.flush();
    await sink.close();*/
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
    //CipherWithAppendedMac cipher = CipherWithAppendedMac(aesCtr,Hmac(sha256));
    if(await sourceFile.exists() == false) return false;
    if(await desFile.exists() == false) await desFile.create(recursive:true);
    /*IOSink sink = desFile.openWrite();
    Stream<List<int>> stream = sourceFile.openRead();*/
    DateTime beforedec = DateTime.now();
    /*await for(List<int> data in stream){
      Uint8List decrypted = await chacha20Poly1305Aead.decrypt(data, secretKey: key, nonce: nonce);
      sink.add(decrypted.toList());
    }*/
    var sourceFileData = await sourceFile.readAsBytes();
    Duration duration = DateTime.now().difference(beforedec);
    Uint8List decrypted = await chacha20Poly1305Aead.decrypt(sourceFileData, secretKey: key, nonce: nonce);
    await desFile.writeAsBytes(decrypted);
    print('Entity decryption completed in '+duration.inMilliseconds.toString()+' milliseconds');
    /*await sink.flush();
    await sink.close();*/
    await sourceFile.delete();
    return true;
  }
  catch(e){
    print(e.toString());
    return false;
  }
  
}