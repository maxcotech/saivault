import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:native_crypto/native_crypto.dart' as nc;
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

static Future<String> encryptFile(Map<String,dynamic> payload)async{
  File sourceFile = new File(payload['source_path']);
  File desFile = new File(payload['des_path']);
  if(await sourceFile.exists() == false) return null;
  if(await desFile.exists() == false) await desFile.create(recursive:true);
  nc.SecretKey key = nc.SecretKey.fromBytes(base64Url.decode(payload['key']),algorithm:nc.CipherAlgorithm.AES);
  nc.AESCipher aes = nc.AESCipher(key,nc.CipherParameters(
    nc.BlockCipherMode.CBC,nc.PlainTextPadding.PKCS5
  ));
  DateTime beforeenc = DateTime.now();
  var sourceData = await sourceFile.readAsBytes();
  nc.CipherText cipherText = await aes.encrypt(sourceData);
  await desFile.writeAsBytes(cipherText.bytes);
  Duration duration = DateTime.now().difference(beforeenc);
  print('Entity encryption completed in '+ duration.inMilliseconds.toString()+' milliseconds');
  await sourceFile.delete();
  return base64Url.encode(cipherText.iv);

}
static Future<bool> decryptFile(Map<String,dynamic> payload)async{
   File sourceFile = new File(payload['source_path']);
   File desFile = new File(payload['des_path']);
   if(await sourceFile.exists() == false) return false;
   if(await desFile.exists() == false) await desFile.create(recursive:true);
   nc.SecretKey key = nc.SecretKey.fromBytes(base64Url.decode(payload['key']),algorithm:nc.CipherAlgorithm.AES);
   nc.AESCipher aes = nc.AESCipher(key,nc.CipherParameters(
    nc.BlockCipherMode.CBC,nc.PlainTextPadding.PKCS5
  ));
  DateTime beforedec = DateTime.now();
  var sourceData = await sourceFile.readAsBytes();
  nc.CipherText cipherText = nc.AESCipherText(sourceData,base64Url.decode(payload['iv_string']));
  var decrypted = await aes.decrypt(cipherText);   
  await desFile.writeAsBytes(decrypted);  
  Duration duration = DateTime.now().difference(beforedec);
  print('Entity decryption completed in '+duration.inMilliseconds.toString()+' milliseconds');
  await sourceFile.delete();
  return true;
   
}

}