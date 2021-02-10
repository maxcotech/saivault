import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'dart:io';
import 'dart:convert';

class FileEncryption{
  static Future<bool> decryptAndRestoreFile(dynamic payload)async{
  try{
    File sourceFile = new File(payload['source_path']);
    File desFile = new File(payload['des_path']);
    Nonce nonce = new Nonce(base64Url.decode(payload['iv_string']).toList());
    SecretKey key = new SecretKey(base64Url.decode(payload['key']).toList());
    CipherWithAppendedMac cipher = CipherWithAppendedMac(aesCtr,Hmac(sha256));
    if(await sourceFile.exists() == false) return false;
    if(await desFile.exists() == false) await desFile.create(recursive:true);
    IOSink sink = desFile.openWrite();
    Stream<List<int>> stream = sourceFile.openRead();
    DateTime beforedec = DateTime.now();
    await for(List<int> data in stream){
      Uint8List decrypted = await chacha20Poly1305Aead.decrypt(data, secretKey: key, nonce: nonce);
      sink.add(decrypted.toList());
    }
    Duration duration = DateTime.now().difference(beforedec);
    print('Entity decryption completed in '+duration.inMilliseconds.toString()+' milliseconds');
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
static Future<bool> encryptAndHideFile(dynamic payload)async{
  try{
    File sourceFile = new File(payload['source_path']);
    File desFile = new File(payload['des_path']);
    Nonce nonce = new Nonce(base64Url.decode(payload['iv_string']).toList());
    SecretKey key = new SecretKey(base64Url.decode(payload['key']).toList());
    CipherWithAppendedMac cipher = CipherWithAppendedMac(aesCtr, Hmac(sha256));
    if(await sourceFile.exists() == false) return false;
    if(await desFile.exists() == false) await desFile.create(recursive:true);
    IOSink sink = desFile.openWrite();
    Stream<List<int>> stream = sourceFile.openRead();
    DateTime beforeenc = DateTime.now();
    await for(List<int> data in stream){
      Uint8List encrypted = await chacha20Poly1305Aead.encrypt(data,nonce:nonce,secretKey:key);
      sink.add(encrypted.toList());
    }
    Duration duration = DateTime.now().difference(beforeenc);
    print('Entity encryption completed in '+ duration.inMilliseconds.toString()+' milliseconds');
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

}